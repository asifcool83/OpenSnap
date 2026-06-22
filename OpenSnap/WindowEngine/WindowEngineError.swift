import Foundation
import OpenSnapCore

/// Errors produced while reading or controlling macOS windows.
public enum WindowEngineError: LocalizedError, Sendable {
    case accessibilityPermissionRequired
    case frontmostApplicationUnavailable
    case screenUnavailable
    case invalidWindowFrame(WindowFrame)
    case invalidAccessibilityValue
    case accessibilityReadFailed(attribute: String, code: Int)
    case accessibilityWriteFailed(attribute: String, code: Int)

    public var errorDescription: String? {
        switch self {
        case .accessibilityPermissionRequired:
            return "OpenSnap needs Accessibility permission before it can move windows."
        case .frontmostApplicationUnavailable:
            return "OpenSnap could not determine the frontmost application."
        case .screenUnavailable:
            return "OpenSnap could not determine the current screen."
        case .invalidWindowFrame:
            return "OpenSnap received an invalid window frame."
        case .invalidAccessibilityValue:
            return "OpenSnap received an invalid Accessibility value."
        case let .accessibilityReadFailed(attribute, code):
            return "OpenSnap could not read \(attribute) from Accessibility. AXError \(code)."
        case let .accessibilityWriteFailed(attribute, code):
            return "OpenSnap could not write \(attribute) through Accessibility. AXError \(code)."
        }
    }
}
