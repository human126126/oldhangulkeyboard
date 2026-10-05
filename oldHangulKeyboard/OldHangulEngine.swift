import Foundation

final class OldHangulEngine {

    struct Result {
        let committed: String
        let composing: String
    }

    private struct Buffer {

        var choseong: UInt32?
        var jungseong: UInt32?
        var jongseong: UInt32?

        var stack: [UInt32] = []

        var isEmpty: Bool {
            choseong == nil
            && jungseong == nil
            && jongseong == nil
        }

        mutating func clear() {
            choseong = nil
            jungseong = nil
            jongseong = nil
            stack.removeAll()
        }

        mutating func push(
            _ scalar: UInt32
        ) {

            if HangulJamoUnicode.isChoseong(
                scalar
            ) {

                choseong = scalar

            } else if HangulJamoUnicode.isJungseong(
                scalar
            ) {

                jungseong = scalar

            } else if HangulJamoUnicode.isJongseong(
                scalar
            ) {

                jongseong = scalar
            }

            stack.append(scalar)
        }

        mutating func pop() -> UInt32? {
            stack.popLast()
        }

        func peek() -> UInt32? {
            stack.last
        }
    }

    private var buffer = Buffer()

    var hasComposition: Bool {
        !buffer.isEmpty
    }

    private func combine(
        _ first: UInt32,
        _ second: UInt32
    ) -> UInt32? {

        guard let combined =
            HangulCombinationTable.full[
                JamoPair(
                    first: first,
                    second: second
                )
            ]
        else {
            return nil
        }

        guard
            HangulCompositionPolicy.allows(
                first: first,
                second: second,
                result: combined
            )

                else {
            return nil
        }

        return combined
    }
   
    private func scalarString(
        _ scalar: UInt32
    ) -> String {

        guard let value =
            UnicodeScalar(scalar)
        else {
            return ""
        }

        return String(
            Character(value)
        )
    }

    private func scalarsString(
        _ scalars: [UInt32]
    ) -> String {

        scalars
            .compactMap(UnicodeScalar.init)
            .map {
                String(Character($0))
            }
            .joined()
    }

    func currentComposition() -> String {

        var values: [UInt32] = []

        if let choseong =
            buffer.choseong {

            values.append(choseong)
        }

        if let jungseong =
            buffer.jungseong {

            values.append(jungseong)
        }

        if let jongseong =
            buffer.jongseong {

            values.append(jongseong)
        }

        return scalarsString(values)
    }

    private func commitCurrent() -> String {

        let text =
            currentComposition()

        buffer.clear()

        return text
    }

    func finish() -> String {

        commitCurrent()
    }

    func process(
        _ scalar: UInt32
    ) -> Result {

        var committed = ""

        if !HangulJamoUnicode.isJamo(
            scalar
        ) {

            committed +=
                commitCurrent()

            committed +=
                scalarString(scalar)

            return Result(
                committed: committed,
                composing: ""
            )
        }

        if buffer.jongseong != nil {

            processAfterJongseong(
                scalar,
                committed: &committed
            )

        } else if buffer.jungseong != nil {

            processAfterJungseong(
                scalar,
                committed: &committed
            )

        } else if buffer.choseong != nil {

            processAfterChoseong(
                scalar,
                committed: &committed
            )

        } else {

            buffer.push(scalar)
        }

        return Result(
            committed: committed,
            composing: currentComposition()
        )
    }

    private func processAfterChoseong(
        _ scalar: UInt32,
        committed: inout String
    ) {

        guard let current =
            buffer.choseong
        else {
            buffer.push(scalar)
            return
        }

        if HangulJamoUnicode.isChoseong(
            scalar
        ) {

            if let combined =
                combine(
                    current,
                    scalar
                ) {

                if HangulJamoUnicode.isJongseong(
                    combined
                ) {

                    buffer.choseong = nil

                    if let popped =
                        buffer.pop(),
                       let jong =
                        HangulJamoConversion
                            .choseongToJongseong(
                                popped
                            ) {

                        buffer.push(jong)
                    }
                }

                buffer.push(combined)

            } else {

                committed +=
                    commitCurrent()

                buffer.push(scalar)
            }

            return
        }

        if HangulJamoUnicode.isJungseong(
            scalar
        ) {

            buffer.push(scalar)
            return
        }

        committed +=
            commitCurrent()

        buffer.push(scalar)
    }

    private func processAfterJungseong(
        _ scalar: UInt32,
        committed: inout String
    ) {

        guard let currentJung =
            buffer.jungseong
        else {
            buffer.push(scalar)
            return
        }

        if HangulJamoUnicode.isChoseong(
            scalar
        ) {

            if buffer.choseong != nil,
               let jong =
                HangulJamoConversion
                    .choseongToJongseong(
                        scalar
                    ),
               HangulJamoUnicode
                    .isJongseong(jong) {

                buffer.push(jong)

            } else {

                committed +=
                    commitCurrent()

                buffer.push(scalar)
            }

            return
        }

        if HangulJamoUnicode.isJungseong(
            scalar
        ) {

            if let combined =
                combine(
                    currentJung,
                    scalar
                ),
               HangulJamoUnicode
                    .isJungseong(
                        combined
                    ) {

                buffer.push(combined)

            } else {

                committed +=
                    commitCurrent()

                buffer.push(scalar)
            }

            return
        }

        committed +=
            commitCurrent()

        buffer.push(scalar)
    }

    private func processAfterJongseong(
        _ scalar: UInt32,
        committed: inout String
    ) {

        guard let currentJong =
            buffer.jongseong
        else {
            buffer.push(scalar)
            return
        }

        if HangulJamoUnicode.isChoseong(
            scalar
        ) {

            if let newJong =
                HangulJamoConversion
                    .choseongToJongseong(
                        scalar
                    ),
               let combined =
                combine(
                    currentJong,
                    newJong
                ),
               HangulJamoUnicode
                   .isJongseong(
                       combined
                   ) {

                buffer.push(combined)

            } else {

                committed +=
                    commitCurrent()

                buffer.push(scalar)
            }

            return
        }

        if HangulJamoUnicode.isJungseong(
            scalar
        ) {

            let popped =
                buffer.pop()

            let previous =
                buffer.peek()

            if let previous,
               HangulJamoUnicode
                    .isJongseong(
                        previous
                    ) {

                if let moved =
                    HangulJamoConversion
                        .jongseongDiff(
                            previous: previous,
                            current: currentJong
                        ) {

                    buffer.jongseong =
                        previous

                    committed +=
                        commitCurrent()

                    buffer.push(moved)
                    buffer.push(scalar)

                } else {

                    committed +=
                        commitCurrent()

                    buffer.push(scalar)
                }

            } else {

                buffer.jongseong =
                    nil

                committed +=
                    commitCurrent()

                if let popped,
                   let moved =
                    HangulJamoConversion
                        .jongseongToChoseong(
                            popped
                        ) {

                    buffer.push(moved)
                }

                buffer.push(scalar)
            }

            return
        }

        committed +=
            commitCurrent()

        buffer.push(scalar)
    }

    @discardableResult
    func backspace() -> Bool {

        guard let removed =
            buffer.pop()
        else {
            return false
        }

        if buffer.stack.isEmpty {

            buffer.clear()
            return true
        }

        let previous =
            buffer.peek()

        if HangulJamoUnicode
            .isChoseong(
                removed
            ) {

            if let previous,
               HangulJamoUnicode
                    .isChoseong(
                        previous
                    ) {

                buffer.choseong =
                    previous

            } else {

                buffer.choseong =
                    nil
            }

        } else if HangulJamoUnicode
            .isJungseong(
                removed
            ) {

            if let previous,
               HangulJamoUnicode
                    .isJungseong(
                        previous
                    ) {

                buffer.jungseong =
                    previous

            } else {

                buffer.jungseong =
                    nil
            }

        } else if HangulJamoUnicode
            .isJongseong(
                removed
            ) {

            if let previous,
               HangulJamoUnicode
                    .isJongseong(
                        previous
                    ) {

                buffer.jongseong =
                    previous

            } else {

                buffer.jongseong =
                    nil
            }
        }

        return true
    }
}
