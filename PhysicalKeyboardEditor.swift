import SwiftUI
import UIKit

struct PhysicalKeyboardEditor: UIViewRepresentable {

    func makeUIView(context: Context) -> OldHangulTextView {
        let textView = OldHangulTextView()

        textView.font = UIFont.systemFont(ofSize: 22)
        textView.backgroundColor = .systemBackground
        textView.textColor = .label

        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.smartQuotesType = .no
        textView.smartDashesType = .no

        return textView
    }

    func updateUIView(
        _ uiView: OldHangulTextView,
        context: Context
    ) {
    }
}


final class OldHangulTextView: UITextView {

    private let composer = HangulComposer()

    private var displayedComposition = ""

    override func pressesBegan(
        _ presses: Set<UIPress>,
        with event: UIPressesEvent?
    ) {

        guard let press = presses.first,
              let key = press.key else {

            super.pressesBegan(
                presses,
                with: event
            )

            return
        }

        print(
            "PHYSICAL_KEY",
            "code:", key.keyCode.rawValue,
            "chars:", key.characters,
            "ignoring:", key.charactersIgnoringModifiers
        )

        let modifiers = key.modifierFlags

        if modifiers.contains(.command)
            || modifiers.contains(.control)
            || modifiers.contains(.alternate) {

            finishComposition()

            super.pressesBegan(
                presses,
                with: event
            )

            return
        }

        if key.keyCode == .keyboardDeleteOrBackspace {
            handleBackspace()
            return
        }

        if key.keyCode == .keyboardSpacebar {
            finishComposition()
            insertText(" ")
            return
        }

        if key.keyCode == .keyboardReturnOrEnter {
            finishComposition()
            insertText("\n")
            return
        }

        guard let physicalKey = physicalKeyName(
            for: key.keyCode
        ) else {

            finishComposition()

            super.pressesBegan(
                presses,
                with: event
            )

            return
        }

        let shiftPressed =
            modifiers.contains(.shift)

        if shiftPressed,
           let shifted =
            KeyLayout.shiftedKeys[physicalKey] {

            inputHangul(shifted)
            return
        }

        if let modern =
            KeyLayout.modernKeys[physicalKey] {

            inputHangul(modern)
            return
        }

        if let old =
            KeyLayout.oldHangulKeys[physicalKey] {

            inputHangul(old)
            return
        }

        super.pressesBegan(
            presses,
            with: event
        )
    }


    private func inputHangul(
        _ jamo: String
    ) {

        removeDisplayedComposition()

        let result =
            composer.input(jamo)

        if let committed =
            result.committed {

            insertText(committed)
        }

        if let composing =
            result.composing {

            insertText(composing)

            displayedComposition =
                composing
        }
    }


    private func finishComposition() {

        removeDisplayedComposition()

        if let finished =
            composer.finish() {

            insertText(finished)
        }

        displayedComposition = ""
    }


    private func handleBackspace() {

        if !displayedComposition.isEmpty {

            removeDisplayedComposition()

            if composer.backspace() {

                if let updated =
                    composer.currentText() {

                    insertText(updated)

                    displayedComposition =
                        updated
                }

                return
            }
        }

        deleteBackward()
    }


    private func removeDisplayedComposition() {

        guard !displayedComposition.isEmpty else {
            return
        }

        for _ in displayedComposition {
            deleteBackward()
        }

        displayedComposition = ""
    }


    private func physicalKeyName(
        for keyCode: UIKeyboardHIDUsage
    ) -> String? {

        switch keyCode {

        case .keyboardQ:
            return "Q"

        case .keyboardW:
            return "W"

        case .keyboardE:
            return "E"

        case .keyboardR:
            return "R"

        case .keyboardT:
            return "T"

        case .keyboardY:
            return "Y"

        case .keyboardU:
            return "U"

        case .keyboardI:
            return "I"

        case .keyboardO:
            return "O"

        case .keyboardP:
            return "P"

        case .keyboardA:
            return "A"

        case .keyboardS:
            return "S"

        case .keyboardD:
            return "D"

        case .keyboardF:
            return "F"

        case .keyboardG:
            return "G"

        case .keyboardH:
            return "H"

        case .keyboardJ:
            return "J"

        case .keyboardK:
            return "K"

        case .keyboardL:
            return "L"

        case .keyboardZ:
            return "Z"

        case .keyboardX:
            return "X"

        case .keyboardC:
            return "C"

        case .keyboardV:
            return "V"

        case .keyboardB:
            return "B"

        case .keyboardN:
            return "N"

        case .keyboardM:
            return "M"

        case .keyboardOpenBracket:
            return "["

        case .keyboardCloseBracket:
            return "]"

        case .keyboardSemicolon:
            return ";"

        case .keyboardQuote:
            return "'"

        default:
            return nil
        }
    }
}//
//  PhysicalKeyboardEditor.swift
//  _28hangul
//
//  Created by 김한울 on 9/16/26.
//

