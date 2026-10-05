import Foundation

enum HangulCompositionPolicy {

    private static let atomicInputScalars:
        Set<UInt32> = {

        let characters =
            Set(KeyLayout.modernKeys.values)
            .union(
                KeyLayout.oldHangulKeys.values
            )

        return Set(
            characters.compactMap {
                JamoMapper.input($0)
            }
        )
    }()

    private static let compatibilityScalars:
        Set<UInt32> = {

        var result =
            Set<UInt32>()

        for value in
            UInt32(0x3130)...UInt32(0x318F) {

            guard let scalar =
                UnicodeScalar(value)
            else {
                continue
            }

            let compatibility =
                String(
                    Character(scalar)
                )

            let decomposed =
                Array(
                    compatibility
                        .decomposedStringWithCompatibilityMapping
                        .unicodeScalars
                )

            guard
                decomposed.count == 1,
                let mapped =
                    decomposed.first
            else {
                continue
            }

            let mappedValue =
                mapped.value

            if HangulJamoUnicode.isJamo(
                mappedValue
            ) {
                result.insert(
                    mappedValue
                )
            }
        }

        return result
    }()

    static func allows(
        first: UInt32,
        second: UInt32,
        result: UInt32
    ) -> Bool {

        let pair =
            JamoPair(
                first: first,
                second: second
            )

        if HangulCombinationTable.defaultRules[pair] == result {

            return true
        }

        if atomicInputScalars.contains(
            result
        ) {
            return false
        }

        if compatibilityScalars.contains(
            result
        ) {
            return true
        }

        return false
    }
}
