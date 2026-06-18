import Foundation
import OpenSnapCore

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
        #if DEBUG
        DeveloperDiagnosticsCenter.shared.update { snapshot in
            snapshot.accessibilityPermissionStatus = permissionGranted ? "Granted" : "Missing"
        }
        #endif
    }

    func perform(_ command: ShortcutCommand) {
        #if DEBUG
        DeveloperDiagnosticsCenter.shared.recordShortcut(command)
        #endif

        do {
            let layoutCommand = layoutCommand(for: command)
            try windowController.perform(.layout(layoutCommand))
            lastErrorMessage = nil
            #if DEBUG
            DeveloperDiagnosticsCenter.shared.update { snapshot in
                snapshot.lastError = "None"
            }
            #endif
        } catch {
            lastErrorMessage = error.localizedDescription
            #if DEBUG
            DeveloperDiagnosticsCenter.shared.recordError(error)
            #endif
        }
    }

    #if DEBUG
    func refreshDeveloperDiagnostics() {
        guard DebugConfiguration.isDeveloperDiagnosticsEnabled else {
            return
        }

        do {
            _ = try windowController.focusedWindowFrame()
            lastErrorMessage = nil
        } catch WindowEngineError.accessibilityPermissionRequired {
            DeveloperDiagnosticsCenter.shared.update { snapshot in
                snapshot.accessibilityPermissionStatus = "Missing"
            }
        } catch {
            DeveloperDiagnosticsCenter.shared.update { snapshot in
                snapshot.lastError = error.localizedDescription
            }
        }
    }
    #endif

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
            #if DEBUG
            DeveloperDiagnosticsCenter.shared.update { snapshot in
                snapshot.currentSmartSnapState = "Reset"
            }
            #endif
            return layoutCommand
        case let .smartSnap(side):
            let step = smartSnapController.nextStep(for: side)
            #if DEBUG
            DeveloperDiagnosticsCenter.shared.update { snapshot in
                snapshot.currentSmartSnapState = "\(side) \(Int(step.ratio * 100))%"
            }
            #endif
            return .smartSnap(side, step)
        }
    }
}
