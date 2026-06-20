import Foundation
import Testing
@testable import OpenSnap

@MainActor
struct MenuBarControllerTests {
    @Test func initializesAndRefreshesAccessibilityStatusFromDiagnosticsService() {
        let diagnostics = MenuDiagnosticsService(status: .permissionRequired)
        let controller = makeController(diagnostics: diagnostics)

        #expect(controller.accessibilityStatus == .permissionRequired)
        #expect(diagnostics.statusCallCount == 1)

        diagnostics.status = .granted
        controller.refreshAccessibilityStatus()

        #expect(controller.accessibilityStatus == .granted)
        #expect(diagnostics.statusCallCount == 2)
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
        let controller = makeController(clipboard: clipboard)

        #expect(!controller.copyDiagnosticReport())
        #expect(clipboard.writtenTexts.count == 1)
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

    @Test func accessibilityLabelsAreExplicit() {
        #expect(AccessibilityMenuStatus.granted.title == "Accessibility: Granted")
        #expect(
            AccessibilityMenuStatus.permissionRequired.title
                == "Accessibility: Permission Required"
        )
    }

    private func makeController(
        diagnostics: MenuDiagnosticsService = MenuDiagnosticsService(),
        clipboard: MenuClipboard = MenuClipboard(),
        about: MenuAboutPresenter = MenuAboutPresenter(),
        terminate: @escaping () -> Void = {}
    ) -> MenuBarController {
        MenuBarController(
            diagnosticsService: diagnostics,
            clipboard: clipboard,
            aboutPresenter: about,
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
    var status: AccessibilityMenuStatus
    var report: String
    private(set) var statusCallCount = 0
    private(set) var reportCallCount = 0

    init(
        buildInfo: BuildInfo = BuildInfo(
            infoDictionary: [:],
            macOSVersion: "macOS Test",
            cpuArchitecture: "arm64"
        ),
        status: AccessibilityMenuStatus = .granted,
        report: String = "report"
    ) {
        self.buildInfo = buildInfo
        self.status = status
        self.report = report
    }

    func accessibilityStatus() -> AccessibilityMenuStatus {
        statusCallCount += 1
        return status
    }

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
