import Foundation
import Testing
@testable import OpenSnap

@MainActor
struct DiagnosticsServiceTests {
    @Test func reportsGrantedAccessibilityFromCurrentPermissionState() {
        let permission = MenuPermissionProvider(isTrusted: true)
        let service = OpenSnapDiagnosticsService(
            permissionProvider: permission,
            inspector: OpenSnapInspector(buildInfo: testBuildInfo),
            buildInfo: testBuildInfo
        )

        #expect(service.accessibilityStatus() == .granted)

        permission.isTrusted = false
        #expect(service.accessibilityStatus() == .permissionRequired)
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
            inspector: inspector,
            buildInfo: testBuildInfo
        )

        let report = service.diagnosticReport()

        #expect(report.contains("Accessibility: Permission required"))
        #expect(inspector.snapshot.accessibilityStatus == "Unknown")
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
