import Foundation

/// A semantic window layout command.
public enum LayoutCommand: Equatable, Sendable {
    case leftSixty
    case rightForty
    case leftHalf
    case rightHalf
    case leftThird
    case centerThird
    case rightThird
    case maximize
    case center
    case smartSnap(SmartSnapSide, SmartSnapStep)
}

/// The horizontal edge used by Smart Snap.
public enum SmartSnapSide: Equatable, Sendable {
    case left
    case right
}
