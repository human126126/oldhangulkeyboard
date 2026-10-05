import Foundation

enum HangulJamoUnicode {

    static let choseongFiller: UInt32 = 0x115F
    static let jungseongFiller: UInt32 = 0x1160

    static func isChoseong(_ scalar: UInt32) -> Bool {
        (0x1100...0x115F).contains(scalar)
        || (0xA960...0xA97C).contains(scalar)
    }

    static func isJungseong(_ scalar: UInt32) -> Bool {
        (0x1160...0x11A7).contains(scalar)
        || (0xD7B0...0xD7C6).contains(scalar)
    }

    static func isJongseong(_ scalar: UInt32) -> Bool {
        (0x11A8...0x11FF).contains(scalar)
        || (0xD7CB...0xD7FB).contains(scalar)
    }

    static func isJamo(_ scalar: UInt32) -> Bool {
        isChoseong(scalar)
        || isJungseong(scalar)
        || isJongseong(scalar)
    }
}

extension HangulJamoUnicode {

    enum OldJamo {
        static let yesIeungInitial: UInt32 = 0x114C
        static let yesIeungFinal: UInt32 = 0x11F0

        static let araeaMedial: UInt32 = 0x119E

        static let yeorinHieutInitial: UInt32 = 0x1159
        static let yeorinHieutFinal: UInt32 = 0x11F9

        static let bansieotInitial: UInt32 = 0x1140
        static let bansieotFinal: UInt32 = 0x11EB
    }
}
