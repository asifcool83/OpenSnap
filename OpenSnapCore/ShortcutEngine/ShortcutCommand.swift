import Foundation

/// Commands emitted by the shortcut layer.
public enum ShortcutCommand: Equatable, Sendable {
    case layout(LayoutCommand)
    case smartSnap(SmartSnapSide)
}
