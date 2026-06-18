import Foundation

/// A high-level action OpenSnap can apply to the focused window.
public enum WindowOperation: Equatable, Sendable {
    case layout(LayoutCommand)
}
