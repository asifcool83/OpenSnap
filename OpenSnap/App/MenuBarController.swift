import AppKit
import Foundation

@MainActor
protocol ClipboardWriting {
    @discardableResult
    func write(_ text: String) -> Bool
}

@MainActor
protocol AboutPresenting {
    func showAbout(buildInfo: BuildInfo)
}

/// Owns menu actions while delegating all report content to DiagnosticsService.
@MainActor
final class MenuBarController: ObservableObject {
    @Published private(set) var accessibilityStatus: AccessibilityMenuStatus

    private let diagnosticsService: any DiagnosticsServicing
    private let clipboard: any ClipboardWriting
    private let aboutPresenter: any AboutPresenting
    private let terminate: () -> Void

    init(
        diagnosticsService: any DiagnosticsServicing = OpenSnapDiagnosticsService(),
        clipboard: any ClipboardWriting = SystemClipboard(),
        aboutPresenter: any AboutPresenting = SystemAboutPresenter(),
        terminate: @escaping () -> Void = { NSApplication.shared.terminate(nil) }
    ) {
        self.diagnosticsService = diagnosticsService
        self.clipboard = clipboard
        self.aboutPresenter = aboutPresenter
        self.terminate = terminate
        accessibilityStatus = diagnosticsService.accessibilityStatus()
    }

    func refreshAccessibilityStatus() {
        accessibilityStatus = diagnosticsService.accessibilityStatus()
    }

    @discardableResult
    func copyDiagnosticReport() -> Bool {
        clipboard.write(diagnosticsService.diagnosticReport())
    }

    func showAbout() {
        aboutPresenter.showAbout(buildInfo: diagnosticsService.buildInfo)
    }

    func quit() {
        terminate()
    }
}

@MainActor
private struct SystemClipboard: ClipboardWriting {
    func write(_ text: String) -> Bool {
        NSPasteboard.general.clearContents()
        return NSPasteboard.general.setString(text, forType: .string)
    }
}

@MainActor
struct SystemAboutPresenter: AboutPresenting {
    func showAbout(buildInfo: BuildInfo) {
        NSApplication.shared.orderFrontStandardAboutPanel(options: Self.options(for: buildInfo))
        NSApplication.shared.activate()
    }

    static func options(for buildInfo: BuildInfo) -> [NSApplication.AboutPanelOptionKey: Any] {
        var options: [NSApplication.AboutPanelOptionKey: Any] = [
            .applicationName: buildInfo.appName,
            .applicationVersion: buildInfo.version,
            .version: buildInfo.buildNumber
        ]

        if let gitCommit = buildInfo.gitCommit {
            options[.credits] = NSAttributedString(string: "Git commit: \(gitCommit)")
        }

        return options
    }
}
