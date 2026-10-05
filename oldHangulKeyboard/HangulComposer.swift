import Foundation

final class HangulComposer {

    private let engine = OldHangulEngine()

    // MARK: - Input

    func input(
        _ jamo: String
    ) -> (
        committed: String?,
        composing: String?
    ) {

        guard let scalar = JamoMapper.input(jamo) else {

            let finished = finish()

            return (
                committed: finished,
                composing: jamo
            )
        }

        let result = engine.process(scalar)

        return (
            committed: renderCommitted(result.committed),
            composing: renderComposing(result.composing)
        )
    }

    // MARK: - Backspace

    func backspace() -> Bool {
        engine.backspace()
    }

    // MARK: - Finish

    func finish() -> String? {

        let raw = engine.finish()

        guard !raw.isEmpty else {
            return nil
        }

        return renderFinal(raw)
    }

    // MARK: - Current Text

    func currentText() -> String? {

        let raw = engine.currentComposition()

        guard !raw.isEmpty else {
            return nil
        }

        return renderComposing(raw)
    }

    // MARK: - Rendering

    /// 아직 조합 중인 문자열을 화면에 표시한다.
    ///
    /// 중성이 없으면 자음 단독/자음군 상태이므로
    /// 가능한 경우 호환 자모로 표시한다.
    ///
    /// 중성이 들어오면 실제 조합용 자모열을 사용한다.
    private func renderComposing(
        _ text: String
    ) -> String? {

        guard !text.isEmpty else {
            return nil
        }

        let hasChoseong =
            containsChoseong(text)

        let hasJungseong =
            containsJungseong(text)

        // 실제 음절 조합 상태
        if hasChoseong && hasJungseong {
            return HangulOutput.normalize(text)
        }

        // 자음만 있거나 모음만 있는 상태
        return displayStandaloneJamo(text)
    }
    private func renderCommitted(
        _ text: String
    ) -> String? {

        guard !text.isEmpty else {
            return nil
        }

        return renderFinal(text)
    }

    /// 공백·엔터 등으로 현재 조합을 끝낼 때 사용한다.
    private func renderFinal(
        _ text: String
    ) -> String {

        let hasChoseong =
            containsChoseong(text)

        let hasJungseong =
            containsJungseong(text)

        if hasChoseong && hasJungseong {
            return HangulOutput.normalize(text)
        }

        return displayStandaloneJamo(text)
    }

    // MARK: - Composition State
    private func containsChoseong(
        _ text: String
    ) -> Bool {

        return text.unicodeScalars.contains {
            HangulJamoUnicode.isChoseong(
                $0.value
            )
        }
    }
    private func containsJungseong(
        _ text: String
    ) -> Bool {

        text.unicodeScalars.contains {
            HangulJamoUnicode.isJungseong(
                $0.value
            )
        }
    }

    // MARK: - Consonant-only Display

    /// 초성만 존재하는 상태를 가운데 정렬된 문자로 보여준다.
    ///
    /// 1순위:
    /// 조합용 초성에 대응하는 Unicode 호환 자모 사용.
    ///
    /// 2순위:
    /// 호환 자모가 존재하지 않는 옛한글 복합 초성은
    /// 조합용 자모 + 중성 채움 문자(U+1160)를 사용한다.


    private func displayStandaloneJamo(
        _ text: String
    ) -> String {

        let scalars =
            Array(text.unicodeScalars)

        guard !scalars.isEmpty else {
            return ""
        }

        return scalars
            .map {
                displayStandaloneScalar(
                    $0.value
                )
            }
            .joined()
    }

    private func displayStandaloneScalar(
        _ scalar: UInt32
    ) -> String {

        if let compatibility =
            compatibilityJamo(
                for: scalar
            ) {

            return compatibility
        }

        // 호환 자모가 없는 옛 초성
        if HangulJamoUnicode.isChoseong(
            scalar
        ) {
            return scalarString(scalar)
                + scalarString(0x1160)
        }

        // 호환 자모가 없는 옛 중성
        // U+115F 초성 채움자를 앞에 붙여
        // 앞 음절과 붙는 것을 방지한다.
        if HangulJamoUnicode.isJungseong(
            scalar
        ) {
            return scalarString(0x115F)
                + scalarString(scalar)
        }

        return scalarString(scalar)
    }

    private func displayConsonant(
        _ scalar: UInt32
    ) -> String {

        if let compatibility =
            compatibilityJamo(
                for: scalar
            ) {

            return compatibility
        }

        if HangulJamoUnicode.isChoseong(
            scalar
        ) {

            return scalarString(scalar)
                + scalarString(
                    HangulJamoUnicode
                        .jungseongFiller
                )
        }

        return scalarString(scalar)
    }

    // MARK: - Compatibility Jamo

    private func compatibilityJamo(
        for jamo: UInt32
    ) -> String? {

        return compatibilityMap[jamo]
    }

    /// 호환 자모 블록(U+3130...U+318F)을 스캔하여
    /// 조합용 초성 또는 중성에 대응하는 호환 자모를 역매핑한다.
    ///
    /// 예:
    /// U+1100 → ㄱ
    /// U+1112 → ㅎ
    /// U+1161 → ㅏ
    /// U+1173 → ㅡ
    /// U+119E → ㆍ
    private lazy var compatibilityMap:
        [UInt32: String] = {

        var result:
            [UInt32: String] = [:]

        for value in
            UInt32(0x3130)...UInt32(0x318F) {

            guard let scalar =
                UnicodeScalar(value)
            else {
                continue
            }

            let compatibility =
                String(Character(scalar))

            let decomposed =
                compatibility
                    .decomposedStringWithCompatibilityMapping

            let decomposedScalars =
                Array(
                    decomposed.unicodeScalars
                )

            guard
                decomposedScalars.count == 1,
                let first =
                    decomposedScalars.first
            else {
                continue
            }

            let mapped =
                first.value

            guard
                HangulJamoUnicode.isChoseong(mapped)
                || HangulJamoUnicode.isJungseong(mapped)
            else {
                continue
            }

            result[mapped] =
                compatibility
        }

        return result
    }()

    // MARK: - Unicode Helper

    private func scalarString(
        _ scalar: UInt32
    ) -> String {

        guard let unicodeScalar =
            UnicodeScalar(scalar)
        else {
            return ""
        }

        return String(
            Character(unicodeScalar)
        )
    }
}
