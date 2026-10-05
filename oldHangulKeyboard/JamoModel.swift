import Foundation

// MARK: - 자모의 음절 내 위치

enum JamoPosition {
    case initial
    case medial
    case final
}

// MARK: - 입력되는 논리 자모

enum Jamo: Equatable {

    // 현대 자음
    case giyeok
    case ssangGiyeok
    case nieun
    case digeut
    case ssangDigeut
    case rieul
    case mieum
    case bieup
    case ssangBieup
    case siot
    case ssangSiot
    case ieung
    case jieut
    case ssangJieut
    case chieut
    case kieuk
    case tieut
    case pieup
    case hieut

    // 현대 모음
    case a
    case ae
    case ya
    case yae
    case eo
    case e
    case yeo
    case ye
    case o
    case wa
    case wae
    case oe
    case yo
    case u
    case wo
    case we
    case wi
    case yu
    case eu
    case ui
    case i

    // 옛한글
    case yesIeung      // ㆁ
    case araea         // ㆍ
    case yeorinHieut   // ㆆ
    case bansieot      // ㅿ
}
extension Jamo {

    var isVowel: Bool {
        switch self {

        case .a, .ae, .ya, .yae,
             .eo, .e, .yeo, .ye,
             .o, .wa, .wae, .oe, .yo,
             .u, .wo, .we, .wi, .yu,
             .eu, .ui, .i,
             .araea:

            return true

        default:
            return false
        }
    }

    var isConsonant: Bool {
        !isVowel
    }
}
struct SyllableState: Equatable {

    var initial: Jamo?
    var medial: Jamo?
    var final: Jamo?

    var isEmpty: Bool {
        initial == nil &&
        medial == nil &&
        final == nil
    }

    mutating func reset() {
        initial = nil
        medial = nil
        final = nil
    }
}//
//  JamoModel.swift
//  _28hangul
//
//  Created by 김한울 on 9/18/26.
//

