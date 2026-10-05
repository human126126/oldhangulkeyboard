import Foundation

enum JamoMapper {

    private static let initialMap: [String: UInt32] = [
        "ㄱ": 0x1100,
        "ㄲ": 0x1101,
        "ㄴ": 0x1102,
        "ㄷ": 0x1103,
        "ㄸ": 0x1104,
        "ㄹ": 0x1105,
        "ㅁ": 0x1106,
        "ㅂ": 0x1107,
        "ㅃ": 0x1108,
        "ㅅ": 0x1109,
        "ㅆ": 0x110A,
        "ㅇ": 0x110B,
        "ㅈ": 0x110C,
        "ㅉ": 0x110D,
        "ㅊ": 0x110E,
        "ㅋ": 0x110F,
        "ㅌ": 0x1110,
        "ㅍ": 0x1111,
        "ㅎ": 0x1112,
        "ㆁ": 0x114C,
        "ㆆ": 0x1159,
        "ㅿ": 0x1140
    ]

    private static let medialMap: [String: UInt32] = [
        "ㅏ": 0x1161,
        "ㅐ": 0x1162,
        "ㅑ": 0x1163,
        "ㅒ": 0x1164,
        "ㅓ": 0x1165,
        "ㅔ": 0x1166,
        "ㅕ": 0x1167,
        "ㅖ": 0x1168,
        "ㅗ": 0x1169,
        "ㅘ": 0x116A,
        "ㅙ": 0x116B,
        "ㅚ": 0x116C,
        "ㅛ": 0x116D,
        "ㅜ": 0x116E,
        "ㅝ": 0x116F,
        "ㅞ": 0x1170,
        "ㅟ": 0x1171,
        "ㅠ": 0x1172,
        "ㅡ": 0x1173,
        "ㅢ": 0x1174,
        "ㅣ": 0x1175,
        "ㆍ": 0x119E
    ]

    static func initial(_ character: String) -> UInt32? {
        initialMap[character]
    }

    static func medial(_ character: String) -> UInt32? {
        medialMap[character]
    }

    static func input(_ character: String) -> UInt32? {
        medial(character) ?? initial(character)
    }
}
