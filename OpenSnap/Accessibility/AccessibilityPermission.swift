import ApplicationServices
import Foundation

/// Provides the current macOS Accessibility trust state.
public protocol AccessibilityPermissionProviding {
    var isTrusted: Bool { get }
}

/// Reads Accessibility permission through the system API without prompting.
public struct SystemAccessibilityPermissionProvider: AccessibilityPermissionProviding, Sendable {
    public init() {}

    public var isTrusted: Bool {
        AXIsProcessTrusted()
    }

}
