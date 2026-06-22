import Foundation
import Testing
@testable import OpenSnap

@MainActor
struct FirstUserExperienceTests {
    @Test func permissionSnapshotRequiresBothPermissions() {
        #expect(
            PermissionSnapshot(
                accessibilityGranted: true,
                inputMonitoringGranted: true
            ).isReady
        )
        #expect(
            !PermissionSnapshot(
                accessibilityGranted: true,
                inputMonitoringGranted: false
            ).isReady
        )
        #expect(
            !PermissionSnapshot(
                accessibilityGranted: false,
                inputMonitoringGranted: true
            ).isReady
        )
    }

    @Test func systemPermissionServiceKeepsStatusRequestsAndRecoverySeparate() {
        let accessibility = UXAccessibilityProvider(isTrusted: false)
        let inputMonitoring = UXInputProvider(isTrusted: true)
        var accessibilityRequestCount = 0
        var inputRequestCount = 0
        var openedURLs: [URL] = []
        let service = SystemPermissionService(
            accessibilityProvider: accessibility,
            inputMonitoringProvider: inputMonitoring,
            requestAccessibility: {
                accessibilityRequestCount += 1
                return false
            },
            requestInputMonitoring: {
                inputRequestCount += 1
                return true
            },
            openURL: { openedURLs.append($0) }
        )

        #expect(
            service.snapshot()
                == PermissionSnapshot(
                    accessibilityGranted: false,
                    inputMonitoringGranted: true
                )
        )
        #expect(accessibilityRequestCount == 0)
        #expect(inputRequestCount == 0)

        _ = service.requestAccessibility()
        _ = service.requestInputMonitoring()
        service.openAccessibilitySettings()
        service.openInputMonitoringSettings()

        #expect(accessibilityRequestCount == 1)
        #expect(inputRequestCount == 1)
        #expect(openedURLs.count == 2)
        #expect(openedURLs[0].absoluteString.contains("Privacy_Accessibility"))
        #expect(openedURLs[1].absoluteString.contains("Privacy_ListenEvent"))
    }

    @Test func permissionControllerRefreshesAfterEveryExplicitRequest() {
        let service = UXPermissionService()
        let controller = PermissionController(service: service)

        #expect(!controller.permissions.isReady)

        service.permissions = PermissionSnapshot(
            accessibilityGranted: true,
            inputMonitoringGranted: false
        )
        controller.requestAccessibility()

        #expect(controller.permissions.accessibilityGranted)
        #expect(service.accessibilityRequestCount == 1)

        service.permissions = PermissionSnapshot(
            accessibilityGranted: true,
            inputMonitoringGranted: true
        )
        controller.requestInputMonitoring()

        #expect(controller.permissions.isReady)
        #expect(service.inputRequestCount == 1)
    }

    @Test func firstRunCompletionPersistsAcrossStateInstances() throws {
        let suiteName = "OpenSnapFirstRunTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let first = FirstRunState(defaults: defaults)
        #expect(!first.hasCompletedOnboarding)

        first.completeOnboarding()

        #expect(first.hasCompletedOnboarding)
        #expect(FirstRunState(defaults: defaults).hasCompletedOnboarding)
    }
}

private final class UXAccessibilityProvider: AccessibilityPermissionProviding {
    let isTrusted: Bool

    init(isTrusted: Bool) {
        self.isTrusted = isTrusted
    }
}

private final class UXInputProvider: InputMonitoringPermissionProviding {
    let isTrusted: Bool

    init(isTrusted: Bool) {
        self.isTrusted = isTrusted
    }
}

@MainActor
private final class UXPermissionService: PermissionServicing {
    var permissions = PermissionSnapshot(
        accessibilityGranted: false,
        inputMonitoringGranted: false
    )
    private(set) var accessibilityRequestCount = 0
    private(set) var inputRequestCount = 0

    func snapshot() -> PermissionSnapshot { permissions }

    func requestAccessibility() -> Bool {
        accessibilityRequestCount += 1
        return permissions.accessibilityGranted
    }

    func requestInputMonitoring() -> Bool {
        inputRequestCount += 1
        return permissions.inputMonitoringGranted
    }

    func openAccessibilitySettings() {}
    func openInputMonitoringSettings() {}
}
