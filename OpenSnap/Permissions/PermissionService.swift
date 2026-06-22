import ApplicationServices
import AppKit
import CoreGraphics
import Foundation

struct PermissionSnapshot: Equatable, Sendable {
    let accessibilityGranted: Bool
    let inputMonitoringGranted: Bool

    var isReady: Bool {
        accessibilityGranted && inputMonitoringGranted
    }
}

protocol InputMonitoringPermissionProviding {
    var isTrusted: Bool { get }
}

struct SystemInputMonitoringPermissionProvider: InputMonitoringPermissionProviding, Sendable {
    var isTrusted: Bool {
        CGPreflightListenEventAccess()
    }
}

@MainActor
protocol PermissionServicing {
    func snapshot() -> PermissionSnapshot
    @discardableResult func requestAccessibility() -> Bool
    @discardableResult func requestInputMonitoring() -> Bool
    func openAccessibilitySettings()
    func openInputMonitoringSettings()
}

/// Owns explicit permission requests and recovery links. Status reads never prompt.
@MainActor
struct SystemPermissionService: PermissionServicing {
    private enum SettingsURL {
        static let accessibility = URL(
            string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        )!
        static let inputMonitoring = URL(
            string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"
        )!
    }

    private let accessibilityProvider: any AccessibilityPermissionProviding
    private let inputMonitoringProvider: any InputMonitoringPermissionProviding
    private let requestAccessibilityAction: () -> Bool
    private let requestInputMonitoringAction: () -> Bool
    private let openURL: (URL) -> Void

    init(
        accessibilityProvider: any AccessibilityPermissionProviding = SystemAccessibilityPermissionProvider(),
        inputMonitoringProvider: any InputMonitoringPermissionProviding = SystemInputMonitoringPermissionProvider(),
        requestAccessibility: @escaping () -> Bool = {
            let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
            return AXIsProcessTrustedWithOptions(options)
        },
        requestInputMonitoring: @escaping () -> Bool = {
            CGRequestListenEventAccess()
        },
        openURL: @escaping (URL) -> Void = { NSWorkspace.shared.open($0) }
    ) {
        self.accessibilityProvider = accessibilityProvider
        self.inputMonitoringProvider = inputMonitoringProvider
        requestAccessibilityAction = requestAccessibility
        requestInputMonitoringAction = requestInputMonitoring
        self.openURL = openURL
    }

    func snapshot() -> PermissionSnapshot {
        PermissionSnapshot(
            accessibilityGranted: accessibilityProvider.isTrusted,
            inputMonitoringGranted: inputMonitoringProvider.isTrusted
        )
    }

    func requestAccessibility() -> Bool {
        requestAccessibilityAction()
    }

    func requestInputMonitoring() -> Bool {
        requestInputMonitoringAction()
    }

    func openAccessibilitySettings() {
        openURL(SettingsURL.accessibility)
    }

    func openInputMonitoringSettings() {
        openURL(SettingsURL.inputMonitoring)
    }
}
