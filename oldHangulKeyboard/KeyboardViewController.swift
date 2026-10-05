import UIKit

final class KeyboardViewController: UIInputViewController {

    private var composer = HangulComposer()

    private var displayedComposition = ""
    private var isShifted = false

    private var characterButtons: [String: UIButton] = [:]

    private let keyRows: [[String]] = [
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'"],
        ["Z", "X", "C", "V", "B", "N", "M"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboard()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let screen = view.window?.windowScene?.screen else {
            return
        }

        let targetHeight = screen.bounds.height * 0.33

        let heightConstraint = view.heightAnchor.constraint(
            equalToConstant: targetHeight
        )

        heightConstraint.priority = UILayoutPriority(999)
        heightConstraint.isActive = true
    }

    // MARK: - UI

    private func setupKeyboard() {

        let keyboardStack = UIStackView()

        keyboardStack.axis = .vertical
        keyboardStack.spacing = 6
        keyboardStack.distribution = .fillEqually
        keyboardStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(keyboardStack)

        NSLayoutConstraint.activate([
            keyboardStack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 6
            ),
            keyboardStack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -6
            ),
            keyboardStack.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: 6
            ),
            keyboardStack.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -6
            )
        ])

        for (index, row) in keyRows.enumerated() {

            let rowStack = UIStackView()

            rowStack.axis = .horizontal
            rowStack.spacing = 4
            rowStack.distribution = .fillEqually

            if index == 2 {
                rowStack.addArrangedSubview(
                    makeShiftButton()
                )
            }

            for physicalKey in row {

                let button = makeKeyButton(
                    for: physicalKey
                )

                characterButtons[physicalKey] = button

                rowStack.addArrangedSubview(
                    button
                )
            }

            switch index {

            case 0:
                rowStack.addArrangedSubview(
                    makeDeleteButton()
                )

            case 1:
                rowStack.addArrangedSubview(
                    makeReturnButton()
                )

            case 2:
                rowStack.addArrangedSubview(
                    makePunctuationButton(
                        normal: ",",
                        shifted: "!"
                    )
                )

                rowStack.addArrangedSubview(
                    makePunctuationButton(
                        normal: ".",
                        shifted: "?"
                    )
                )

                rowStack.addArrangedSubview(
                    makeShiftButton()
                )

            default:
                break
            }

            keyboardStack.addArrangedSubview(
                rowStack
            )
        }

        keyboardStack.addArrangedSubview(
            makeBottomRow()
        )
    }


    private func makeKeyButton(
        for physicalKey: String
    ) -> UIButton {

        let button = UIButton(type: .system)

        button.setTitle(
            characterForKey(physicalKey),
            for: .normal
        )

        button.titleLabel?.font = UIFont.systemFont(
            ofSize: 20,
            weight: .regular
        )

        button.backgroundColor =
            UIColor.secondarySystemBackground

        button.layer.cornerRadius = 6
        button.accessibilityIdentifier = physicalKey

        button.addTarget(
            self,
            action: #selector(characterKeyPressed(_:)),
            for: .touchUpInside
        )

        return button
    }


    private func makeShiftButton() -> UIButton {

        let button = UIButton(type: .system)

        button.setTitle("⇧", for: .normal)

        button.titleLabel?.font = UIFont.systemFont(
            ofSize: 20,
            weight: .medium
        )

        button.backgroundColor =
            UIColor.tertiarySystemBackground

        button.layer.cornerRadius = 6

        button.addTarget(
            self,
            action: #selector(shiftPressed),
            for: .touchUpInside
        )

        return button
    }


    private func makeDeleteButton() -> UIButton {

        let button = UIButton(type: .system)

        button.setTitle("⌫", for: .normal)

        button.titleLabel?.font = UIFont.systemFont(
            ofSize: 20,
            weight: .medium
        )

        button.backgroundColor =
            UIColor.tertiarySystemBackground

        button.layer.cornerRadius = 6

        button.addTarget(
            self,
            action: #selector(deletePressed),
            for: .touchUpInside
        )

        return button
    }


    private func makeReturnButton() -> UIButton {

        let button = UIButton(type: .system)

        button.setTitle("↵", for: .normal)

        button.titleLabel?.font = UIFont.systemFont(
            ofSize: 22,
            weight: .medium
        )

        button.backgroundColor =
            UIColor.tertiarySystemBackground

        button.layer.cornerRadius = 6

        button.addTarget(
            self,
            action: #selector(returnPressed),
            for: .touchUpInside
        )

        return button
    }


    private func makePunctuationButton(
        normal: String,
        shifted: String
    ) -> UIButton {

        let button = UIButton(type: .system)

        button.setTitle(
            normal,
            for: .normal
        )

        button.titleLabel?.font = UIFont.systemFont(
            ofSize: 20,
            weight: .regular
        )

        button.backgroundColor =
            UIColor.secondarySystemBackground

        button.layer.cornerRadius = 6

        button.accessibilityIdentifier =
            normal + "|" + shifted

        button.addTarget(
            self,
            action: #selector(punctuationPressed(_:)),
            for: .touchUpInside
        )

        return button
    }


    private func characterForKey(
        _ physicalKey: String
    ) -> String {

        if isShifted,
           let shifted =
            KeyLayout.shiftedKeys[physicalKey] {

            return shifted
        }

        return
            KeyLayout.modernKeys[physicalKey]
            ?? KeyLayout.oldHangulKeys[physicalKey]
            ?? physicalKey
    }


    private func makeBottomRow() -> UIStackView {

        let row = UIStackView()

        row.axis = .horizontal
        row.spacing = 6
        row.distribution = .fill

        let globe = UIButton(type: .system)

        globe.setTitle("🌐", for: .normal)
        globe.backgroundColor =
            UIColor.tertiarySystemBackground
        globe.layer.cornerRadius = 6

        globe.addTarget(
            self,
            action: #selector(nextKeyboardPressed),
            for: .touchUpInside
        )

        let leftSpacer = UIView()

        let space = UIButton(type: .system)

        space.setTitle("공백", for: .normal)
        space.backgroundColor =
            UIColor.secondarySystemBackground
        space.layer.cornerRadius = 6

        space.addTarget(
            self,
            action: #selector(spacePressed),
            for: .touchUpInside
        )

        let rightSpacer = UIView()

        let dismiss = UIButton(type: .system)

        dismiss.setTitle("⌨︎↓", for: .normal)
        dismiss.backgroundColor =
            UIColor.tertiarySystemBackground
        dismiss.layer.cornerRadius = 6

        dismiss.addTarget(
            self,
            action: #selector(dismissKeyboardPressed),
            for: .touchUpInside
        )

        row.addArrangedSubview(globe)
        row.addArrangedSubview(leftSpacer)
        row.addArrangedSubview(space)
        row.addArrangedSubview(rightSpacer)
        row.addArrangedSubview(dismiss)

        globe.widthAnchor
            .constraint(equalToConstant: 65)
            .isActive = true

        dismiss.widthAnchor
            .constraint(equalToConstant: 65)
            .isActive = true

        space.widthAnchor
            .constraint(
                equalTo: row.widthAnchor,
                multiplier: 0.50
            )
            .isActive = true

        leftSpacer.widthAnchor
            .constraint(
                equalTo: rightSpacer.widthAnchor
            )
            .isActive = true

        return row
    }

    // MARK: - Character Input

    @objc
    private func characterKeyPressed(_ sender: UIButton) {

        guard let physicalKey = sender.accessibilityIdentifier else {
            return
        }

        // Shift 된소리
        if isShifted,
           let shifted = KeyLayout.shiftedKeys[physicalKey] {

            inputModernHangul(shifted)
            setShift(false)
            return
        }

        // 현대 한글
        if let jamo = KeyLayout.modernKeys[physicalKey] {
            inputModernHangul(jamo)
            setShift(false)
            return
        }

        // 옛한글 4자
        if let oldJamo = KeyLayout.oldHangulKeys[physicalKey] {

            inputModernHangul(oldJamo)
            setShift(false)
            return
        }
    }

    @objc
    private func punctuationPressed(_ sender: UIButton) {

        guard let identifier =
            sender.accessibilityIdentifier
        else {
            return
        }

        let parts =
            identifier.split(
                separator: "|",
                maxSplits: 1,
                omittingEmptySubsequences: false
            )

        guard parts.count == 2 else {
            return
        }

        let text =
            isShifted
            ? String(parts[1])
            : String(parts[0])

        displayedComposition = ""
        composer = HangulComposer()

        textDocumentProxy.insertText(text)
        setShift(false)
    }


    private func inputModernHangul(_ jamo: String) {

        removeDisplayedComposition()

        let result = composer.input(jamo)

        if let committed = result.committed {
            textDocumentProxy.insertText(committed)
        }

        if let composing = result.composing {

            textDocumentProxy.insertText(composing)
            displayedComposition = composing

        } else {

            displayedComposition = ""
        }
    }

    // MARK: - Shift

    @objc
    private func shiftPressed() {
        setShift(!isShifted)
    }

    private func setShift(_ value: Bool) {

        isShifted = value

        for (physicalKey, button) in characterButtons {

            button.setTitle(
                characterForKey(physicalKey),
                for: .normal
            )
        }
    }

    // MARK: - Composition

    private func removeDisplayedComposition() {

        guard !displayedComposition.isEmpty else {
            return
        }

        guard let before =
            textDocumentProxy.documentContextBeforeInput
        else {
            textDocumentProxy.deleteBackward()
            displayedComposition = ""
            return
        }

        guard before.hasSuffix(displayedComposition) else {
            textDocumentProxy.deleteBackward()
            displayedComposition = ""
            return
        }

        let baseText =
            String(
                before.dropLast(
                    displayedComposition.count
                )
            )

        var attempts = 0

        while attempts < 12 {

            guard let current =
                textDocumentProxy.documentContextBeforeInput
            else {
                break
            }

            if current == baseText {
                break
            }

            textDocumentProxy.deleteBackward()

            attempts += 1
        }

        displayedComposition = ""
    }

    private func commitComposition() {

        removeDisplayedComposition()

        if let finished = composer.finish() {
            textDocumentProxy.insertText(finished)
        }

        displayedComposition = ""
    }

    // MARK: - Space

    @objc
    private func spacePressed() {

        commitComposition()
        textDocumentProxy.insertText(" ")
        setShift(false)
    }
    
    @objc
    private func returnPressed() {

        commitComposition()
        textDocumentProxy.insertText("\n")
        setShift(false)
    }

    @objc
    private func dismissKeyboardPressed() {

        commitComposition()
        dismissKeyboard()
    }

    // MARK: - Delete

    @objc
    private func deletePressed() {

        if !displayedComposition.isEmpty {

            removeDisplayedComposition()

            if composer.backspace() {

                if let updated = composer.currentText() {

                    textDocumentProxy.insertText(updated)
                    displayedComposition = updated
                }

                return
            }
        }

        textDocumentProxy.deleteBackward()
    }

    // MARK: - Globe

    @objc
    private func nextKeyboardPressed() {

        commitComposition()
        advanceToNextInputMode()
    }
}
