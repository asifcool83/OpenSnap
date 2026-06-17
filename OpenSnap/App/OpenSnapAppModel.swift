import Foundation

@MainActor
final class OpenSnapAppModel: ObservableObject {
    let settings = AppSettings()

    @Published private(set) var permissionGranted: Bool
    @Published var lastErrorMessage: String?

    private let windowController: WindowControlling
    private var smartSnapController = SmartSnapController()
    private var shortcutMonitor: ShortcutMonitor?

    init(windowController: WindowControlling = AccessibilityWindowController()) {
        self.windowController = windowController
        permissionGranted = AccessibilityPermission.isTrusted
        startShortcuts()
    }

    func requestAccessibilityPermission() {
        permissionGranted = AccessibilityPermission.requestIfNeeded()
    }

    func perform(_ command: ShortcutCommand) {
        do {
            try windowController.perform(.layout(layoutCommand(for: command)))
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = error.localizedDescription
            OpenSnapLog.windowEngine.error("\(error.localizedDescription, privacy: .public)")
        }
    }

    private func startShortcuts() {
        let monitor = ShortcutMonitor { [weak self] command in
            self?.perform(command)
        }

        monitor.start()
        shortcutMonitor = monitor
    }

    private func layoutCommand(for command: ShortcutCommand) -> LayoutCommand {
        switch command {
        case let .layout(layoutCommand):
            smartSnapController.reset()
            return layoutCommand
        case let .smartSnap(side):
            let step = smartSnapController.nextStep(for: side)
            return .smartSnap(side, step)
        }
    }
}
