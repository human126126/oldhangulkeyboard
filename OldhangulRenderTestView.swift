import SwiftUI
import UIKit

struct OldHangulRenderTestView: View {

    @State private var text = ""

    private var fontLoaded: Bool {
        UIFont(name: "HCRBatang", size: 20) != nil
    }

    var body: some View {

        VStack(spacing: 20) {

            // MARK: - Header

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text("훈민정음 28자")
                        .font(
                            .custom(
                                "HCRBatang",
                                size: 34
                            )
                        )

                    Text("옛한글 입력기")
                        .font(
                            .custom(
                                "HCRBatang",
                                size: 17
                            )
                        )
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }


            // MARK: - Editor

            HCRBatangTextView(
                text: $text
            )
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background(
                Color(
                    uiColor:
                        .secondarySystemBackground
                )
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 16
                )
            )


            // MARK: - Actions

            Button {
                text = ""
            } label: {
                Label(
                    "전체 지우기",
                    systemImage: "trash"
                )
                .frame(
                    maxWidth: .infinity
                )
            }
            .buttonStyle(.bordered)
            .font(
                .custom(
                    "HCRBatang",
                    size: 17
                )
            )
            // MARK: - Footer

            HStack(spacing: 24) {

                Label(
                    "사용법",
                    systemImage: "questionmark.circle"
                )

                Label(
                    "키 배열",
                    systemImage: "keyboard"
                )

                Label(
                    "설정",
                    systemImage: "gearshape"
                )
            }
            .font(
                .custom(
                    "HCRBatang",
                    size: 15
                )
            )
            .foregroundStyle(.secondary)
        }
        .padding(24)
        .background(
            Color(
                uiColor:
                    .systemBackground
            )
        )
    }
}


struct HCRBatangTextView: UIViewRepresentable {

    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(
        context: Context
    ) -> OldHangulTextView {

        let textView = OldHangulTextView()

        textView.delegate =
            context.coordinator

        textView.font =
            UIFont(
                name: "HCRBatang",
                size: 40
            )
            ?? UIFont.systemFont(
                ofSize: 40
            )

        textView.backgroundColor = .clear
        textView.textColor = .label

        textView.textContainerInset =
            UIEdgeInsets(
                top: 18,
                left: 18,
                bottom: 18,
                right: 18
            )

        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.smartQuotesType = .no
        textView.smartDashesType = .no

        textView.alwaysBounceVertical =
            false

        textView.keyboardDismissMode =
            .interactive

        return textView
    }

    func updateUIView(
        _ uiView: OldHangulTextView,
        context: Context
    ) {

        if uiView.text != text {
            uiView.text = text
        }
    }

    final class Coordinator:
        NSObject,
        UITextViewDelegate {

        var parent:
            HCRBatangTextView

        init(
            _ parent:
                HCRBatangTextView
        ) {
            self.parent = parent
        }

        func textViewDidChange(
            _ textView: UITextView
        ) {

            parent.text =
                textView.text
        }
    }
}
