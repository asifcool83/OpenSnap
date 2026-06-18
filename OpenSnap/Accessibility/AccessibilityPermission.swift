import ApplicationServices
import Foundation

/// Provides the current macOS Accessibility trust state.
public protocol AccessibilityPermissionProviding {
    var isTrusted: Bool { get }

    @discardableResult
    func requestIfNeeded() -> Bool
}

/// Reads and requests Accessibility permission through the system API.
public struct SystemAccessibilityPermissionProvider: AccessibilityPermissionProviding, Sendable {
    private static let trustedCheckOptionPrompt = "AXTrustedCheckOptionPrompt"

    public init() {}

    public var isTrusted: Bool {
        AXIsProcessTrusted()
    }

    @discardableResult
    public func requestIfNeeded() -> Bool {
        let options = [
            Self.trustedCheckOptionPrompt: true
        ] as CFDictionary

        return AXIsProcessTrustedWithOptions(options)
    }
}

/// Compatibility facade for call sites that do not require injection.
public enum AccessibilityPermission {
    private static let provider = SystemAccessibilityPermissionProvider()

    public static var isTrusted: Bool {
        provider.isTrusted
    }

    @discardableResult
    public static func requestIfNeeded() -> Bool {
        provider.requestIfNeeded()
    }
}
