import Foundation
import Testing
@testable import OpenSnap

@MainActor
struct MenuBarControllerTests {
    @Test func initializesAndRefreshesPermissionStatusFromDiagnosticsService() {
        let diagnostics = MenuDiagnosticsService(
            permissions: PermissionSnapshot(
                accessibilityGranted: false,
                inputMonitoringGranted: false
            )
        )
        let controller = makeController(diagnostics: diagnostics)

        #expect(controller.permissions.accessibilityGranted == false)
        #expect(controller.readiness == .setupRequired)
        #expect(diagnostics.permissionCallCount == 1)

        diagnostics.permissions = PermissionSnapshot(
            accessibilityGranted: true,
            inputMonitoringGranted: true
        )
        controller.refreshPermissions()

        #expect(controller.permissions.isReady)
        #expect(controller.readiness == .ready)
        #expect(diagnostics.permissionCallCount == 2)
    }

    @Test func copyDiagnosticReportWritesExactPlainTextToClipboard() {
        let diagnostics = MenuDiagnosticsService(report: "plain-text diagnostic report")
        let clipboard = MenuClipboard(writeResult: true)
        let controller = makeController(diagnostics: diagnostics, clipboard: clipboard)

        let copied = controller.copyDiagnosticReport()

        #expect(copied)
        #expect(diagnostics.reportCallCount == 1)
        #expect(clipboard.writtenTexts == ["plain-text diagnostic report"])
    }

    @Test func copyDiagnosticReportReturnsClipboardFailure() {
        let clipboard = MenuClipboard(writeResult: false)
        let errors = MenuErrorPresenter()
        let controller = makeController(clipboard: clipboard, errors: errors)

        #expect(!controller.copyDiagnosticReport())
        #expect(clipboard.writtenTexts.count == 1)
        #expect(errors.clipboardFailureCount == 1)
    }

    @Test func aboutReceivesVersionBuildAndGitIdentity() {
        let diagnostics = MenuDiagnosticsService(buildInfo: testBuildInfo)
        let about = MenuAboutPresenter()
        let controller = makeController(diagnostics: diagnostics, about: about)

        controller.showAbout()

        #expect(about.presentedBuildInfo == [testBuildInfo])
    }

    @Test func nativeAboutOptionsShowVersionBuildAndGitCommit() throws {
        let options = SystemAboutPresenter.options(for: testBuildInfo)

        #expect(options[.applicationName] as? String == "OpenSnap")
        #expect(options[.applicationVersion] as? String == "1.7.0")
        #expect(options[.version] as? String == "107")
        let credits = try #require(options[.credits] as? NSAttributedString)
        #expect(credits.string == "Git commit: abc1234")
    }

    @Test func quitInvokesInjectedApplicationTermination() {
        var terminateCallCount = 0
        let controller = makeController {
            terminateCallCount += 1
        }

        controller.quit()

        #expect(terminateCallCount == 1)
    }

    @Test func readinessCopyExplainsBothReadyAndRecoveryStates() {
        #expect(MenuBarReadiness.ready.title == "OpenSnap is Ready")
        #expect(MenuBarReadiness.ready.detail.contains("Point to the window"))
        #expect(MenuBarReadiness.setupRequired.title == "Finish Setting Up OpenSnap")
        #expect(MenuBarReadiness.setupRequired.detail.contains("macOS permissions"))
    }

    @Test func refreshIncludesLatestSnapRecoveryMessage() {
        let activity = SnapActivity(
            kind: .failure,
            title: "Last snap didn’t work",
            detail: "Try another window."
        )
        let diagnostics = MenuDiagnosticsService(activity: activity)
        let controller = makeController(diagnostics: diagnostics)

        #expect(controller.latestSnapActivity == activity)

        diagnostics.activity = nil
        controller.refreshPermissions()

        #expect(controller.latestSnapActivity == nil)
    }

    private func makeController(
        diagnostics: MenuDiagnosticsService = MenuDiagnosticsService(),
        clipboard: MenuClipboard = MenuClipboard(),
        about: MenuAboutPresenter = MenuAboutPresenter(),
        errors: MenuErrorPresenter = MenuErrorPresenter(),
        terminate: @escaping () -> Void = {}
    ) -> MenuBarController {
        MenuBarController(
            diagnosticsService: diagnostics,
            clipboard: clipboard,
            aboutPresenter: about,
            errorPresenter: errors,
            terminate: terminate
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

@MainActor
private final class MenuDiagnosticsService: DiagnosticsServicing {
    var buildInfo: BuildInfo
    var permissions: PermissionSnapshot
    var report: String
    var activity: SnapActivity?
    private(set) var permissionCallCount = 0
    private(set) var reportCallCount = 0

    init(
        buildInfo: BuildInfo = BuildInfo(
            infoDictionary: [:],
            macOSVersion: "macOS Test",
            cpuArchitecture: "arm64"
        ),
        permissions: PermissionSnapshot = PermissionSnapshot(
            accessibilityGranted: true,
            inputMonitoringGranted: true
        ),
        activity: SnapActivity? = nil,
        report: String = "report"
    ) {
        self.buildInfo = buildInfo
        self.permissions = permissions
        self.activity = activity
        self.report = report
    }

    func permissionSnapshot() -> PermissionSnapshot {
        permissionCallCount += 1
        return permissions
    }

    func latestSnapActivity() -> SnapActivity? { activity }

    func diagnosticReport() -> String {
        reportCallCount += 1
        return report
    }
}

@MainActor
private final class MenuClipboard: ClipboardWriting {
    let writeResult: Bool
    private(set) var writtenTexts: [String] = []

    init(writeResult: Bool = true) {
        self.writeResult = writeResult
    }

    func write(_ text: String) -> Bool {
        writtenTexts.append(text)
        return writeResult
    }
}

@MainActor
private final class MenuAboutPresenter: AboutPresenting {
    private(set) var presentedBuildInfo: [BuildInfo] = []

    func showAbout(buildInfo: BuildInfo) {
        presentedBuildInfo.append(buildInfo)
    }
}

@MainActor
private final class MenuErrorPresenter: ErrorPresenting {
    private(set) var clipboardFailureCount = 0

    func showClipboardFailure() {
        clipboardFailureCount += 1
    }
}
