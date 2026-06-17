import Foundation

/// Errors produced while reading or controlling macOS windows.
public enum WindowEngineError: LocalizedError, Sendable {
    case accessibilityPermissionRequired
    case focusedWindowUnavailable
    case screenUnavailable
    case invalidAccessibilityValue
    case unableToSetWindowFrame

    public var errorDescription: String? {
        switch self {
        case .accessibilityPermissionRequired:
            return "OpenSnap needs Accessibility permission before it can move windows."
        case .focusedWindowUnavailable:
            return "OpenSnap could not find the focused window."
        case .screenUnavailable:
            return "OpenSnap could not determine the current screen."
        case .invalidAccessibilityValue:
            return "OpenSnap received an invalid Accessibility value."
        case .unableToSetWindowFrame:
            return "OpenSnap could not move or resize the focused window."
        }
    }
}
