import Foundation
import Testing
@testable import OpenSnap

@MainActor
struct DiagnosticsServiceTests {
    @Test func reportsBothCurrentPermissionStates() {
        let permission = MenuPermissionProvider(isTrusted: true)
        let inputMonitoring = MenuInputPermissionProvider(isTrusted: false)
        let service = OpenSnapDiagnosticsService(
            permissionProvider: permission,
            inputMonitoringProvider: inputMonitoring,
            inspector: OpenSnapInspector(buildInfo: testBuildInfo),
            buildInfo: testBuildInfo
        )

        #expect(
            service.permissionSnapshot()
                == PermissionSnapshot(
                    accessibilityGranted: true,
                    inputMonitoringGranted: false
                )
        )

        permission.isTrusted = false
        inputMonitoring.isTrusted = true
        #expect(
            service.permissionSnapshot()
                == PermissionSnapshot(
                    accessibilityGranted: false,
                    inputMonitoringGranted: true
                )
        )
    }

    @Test func plainTextReportReusesInspectorStateAndIncludesBuildIdentity() {
        let inspector = OpenSnapInspector(buildInfo: testBuildInfo)
        inspector.update { snapshot in
            snapshot.windowEngineStatus = "Constrained"
            snapshot.lastError = "Window constrained"
        }
        inspector.record(.warning, category: .windowEngine, "Constraint observed")
        let service = OpenSnapDiagnosticsService(
            permissionProvider: MenuPermissionProvider(isTrusted: true),
            inputMonitoringProvider: MenuInputPermissionProvider(isTrusted: true),
            inspector: inspector,
            buildInfo: testBuildInfo
        )

        let report = service.diagnosticReport()

        #expect(report.hasPrefix("OPENSNAP — DIAGNOSTIC REPORT"))
        #expect(report.contains("Version: 1.7.0"))
        #expect(report.contains("Build: 107"))
        #expect(report.contains("Git commit: abc1234"))
        #expect(report.contains("Accessibility: Granted"))
        #expect(report.contains("Window engine: Constrained"))
        #expect(report.contains("Constraint observed"))
    }

    @Test func reportUsesLivePermissionStatusWithoutMutatingInspectorSnapshot() {
        let inspector = OpenSnapInspector(buildInfo: testBuildInfo)
        inspector.update { $0.accessibilityStatus = "Unknown" }
        let service = OpenSnapDiagnosticsService(
            permissionProvider: MenuPermissionProvider(isTrusted: false),
            inputMonitoringProvider: MenuInputPermissionProvider(isTrusted: false),
            inspector: inspector,
            buildInfo: testBuildInfo
        )

        let report = service.diagnosticReport()

        #expect(report.contains("Accessibility: Permission required"))
        #expect(report.contains("Keyboard hook: Input Monitoring permission required"))
        #expect(inspector.snapshot.accessibilityStatus == "Unknown")
    }

    @Test func translatesTechnicalFailuresIntoActionableRecoveryCopy() {
        let inspector = OpenSnapInspector(buildInfo: testBuildInfo)
        inspector.update {
            $0.lastActionResult = "Failure"
            $0.lastError = "The window under the mouse cannot be resized."
        }
        let service = OpenSnapDiagnosticsService(
            permissionProvider: MenuPermissionProvider(isTrusted: true),
            inputMonitoringProvider: MenuInputPermissionProvider(isTrusted: true),
            inspector: inspector,
            buildInfo: testBuildInfo
        )

        #expect(
            service.latestSnapActivity()
                == SnapActivity(
                    kind: .failure,
                    title: "Last snap didn’t work",
                    detail: "That window doesn’t support snapping. Try another window."
                )
        )
    }

    private var testBuildInfo: BuildInfo {
        BuildInfo(
            infoDictionary: [
                "CFBundleDisplayName": "OpenSnap",
                "CFBundleShortVersionString": "1.7.0",
                "CFBundleVersion": "107",
                "OpenSnapGitCommit": "abc1234"
            ],
            macOSVersion: "macOS Test",
            cpuArchitecture: "arm64"
        )
    }
}

private final class MenuPermissionProvider: AccessibilityPermissionProviding {
    var isTrusted: Bool

    init(isTrusted: Bool) {
        self.isTrusted = isTrusted
    }

}

private final class MenuInputPermissionProvider: InputMonitoringPermissionProviding {
    var isTrusted: Bool

    init(isTrusted: Bool) {
        self.isTrusted = isTrusted
    }
}
