import ApplicationServices
import Foundation

/// Reads and requests macOS Accessibility permission for OpenSnap.
public enum AccessibilityPermission {
    private static let trustedCheckOptionPrompt = "AXTrustedCheckOptionPrompt"

    public static var isTrusted: Bool {
        AXIsProcessTrusted()
    }

    @discardableResult
    public static func requestIfNeeded() -> Bool {
        let options = [
            trustedCheckOptionPrompt: true
        ] as CFDictionary

        return AXIsProcessTrustedWithOptions(options)
    }
}
