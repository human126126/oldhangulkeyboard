import Foundation

enum HangulOutput {

    /// 현대 한글 자모열은 NFC 완성형 음절로 합친다.
    /// 옛한글처럼 대응하는 완성형 코드가 없는 자모열은
    /// 조합형 Unicode Jamo 상태로 유지된다.
    static func normalize(_ text: String) -> String {
        text.precomposedStringWithCanonicalMapping
    }
}
