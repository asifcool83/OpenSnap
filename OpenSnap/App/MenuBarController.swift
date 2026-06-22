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

@MainActor
protocol ErrorPresenting {
    func showClipboardFailure()
}

/// Owns menu actions while delegating all report content to DiagnosticsService.
@MainActor
final class MenuBarController: ObservableObject {
    @Published private(set) var permissions: PermissionSnapshot
    @Published private(set) var latestSnapActivity: SnapActivity?

    var readiness: MenuBarReadiness {
        permissions.isReady ? .ready : .setupRequired
    }

    private let diagnosticsService: any DiagnosticsServicing
    private let clipboard: any ClipboardWriting
    private let aboutPresenter: any AboutPresenting
    private let errorPresenter: any ErrorPresenting
    private let terminate: () -> Void

    init(
        diagnosticsService: any DiagnosticsServicing = OpenSnapDiagnosticsService(),
        clipboard: any ClipboardWriting = SystemClipboard(),
        aboutPresenter: any AboutPresenting = SystemAboutPresenter(),
        errorPresenter: any ErrorPresenting = SystemErrorPresenter(),
        terminate: @escaping () -> Void = { NSApplication.shared.terminate(nil) }
    ) {
        self.diagnosticsService = diagnosticsService
        self.clipboard = clipboard
        self.aboutPresenter = aboutPresenter
        self.errorPresenter = errorPresenter
        self.terminate = terminate
        permissions = diagnosticsService.permissionSnapshot()
        latestSnapActivity = diagnosticsService.latestSnapActivity()
    }

    func refreshPermissions() {
        permissions = diagnosticsService.permissionSnapshot()
        latestSnapActivity = diagnosticsService.latestSnapActivity()
    }

    @discardableResult
    func copyDiagnosticReport() -> Bool {
        let didCopy = clipboard.write(diagnosticsService.diagnosticReport())
        if !didCopy {
            errorPresenter.showClipboardFailure()
        }
        return didCopy
    }

    func showAbout() {
        aboutPresenter.showAbout(buildInfo: diagnosticsService.buildInfo)
    }

    func quit() {
        terminate()
    }
}

@MainActor
private struct SystemErrorPresenter: ErrorPresenting {
    func showClipboardFailure() {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Couldn’t Copy Diagnostic Report"
        alert.informativeText = "OpenSnap couldn’t access the clipboard. Try again."
        alert.addButton(withTitle: "OK")
        NSApplication.shared.activate()
        alert.runModal()
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
