import Foundation
import OpenSnapCore

@MainActor
final class OpenSnapAppModel: ObservableObject {
    let settings = AppSettings()

    @Published private(set) var permissionGranted: Bool
    @Published var lastErrorMessage: String?

    private let permissionProvider: AccessibilityPermissionProviding
    private let windowController: WindowControlling
    private var smartSnapController = SmartSnapController()
    private var shortcutMonitor: ShortcutMonitor?

    init(
        permissionProvider: AccessibilityPermissionProviding = SystemAccessibilityPermissionProvider(),
        windowController: WindowControlling = AccessibilityWindowController()
    ) {
        self.permissionProvider = permissionProvider
        self.windowController = windowController
        permissionGranted = permissionProvider.isTrusted
        startShortcuts()
    }

    func requestAccessibilityPermission() {
        permissionGranted = permissionProvider.requestIfNeeded()
        #if DEBUG || BETA
        OpenSnapInspector.shared.update { snapshot in
            snapshot.accessibilityStatus = permissionGranted ? "Granted" : "Missing"
        }
        #endif
    }

    func perform(_ command: ShortcutCommand) {
        #if DEBUG || BETA
        OpenSnapInspector.shared.recordShortcut(command)
        #endif

        do {
            let layoutCommand = layoutCommand(for: command)
            let result = try windowController.perform(.layout(layoutCommand))

            if case let .failure(failure) = result {
                lastErrorMessage = failure.localizedDescription
                #if DEBUG || BETA
                OpenSnapInspector.shared.recordResult(result)
                #endif
                return
            }

            lastErrorMessage = nil
            #if DEBUG || BETA
            OpenSnapInspector.shared.recordResult(result)
            OpenSnapInspector.shared.update { snapshot in
                snapshot.lastError = "None"
            }
            #endif
        } catch {
            lastErrorMessage = error.localizedDescription
            #if DEBUG || BETA
            OpenSnapInspector.shared.recordError(error)
            #endif
        }
    }

    #if DEBUG || BETA
    func refreshInspector() {
        do {
            _ = try windowController.focusedWindowFrame()
            lastErrorMessage = nil
        } catch WindowEngineError.accessibilityPermissionRequired {
            OpenSnapInspector.shared.update { snapshot in
                snapshot.accessibilityStatus = "Missing"
            }
        } catch {
            OpenSnapInspector.shared.update { snapshot in
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
        #if DEBUG || BETA
        OpenSnapInspector.shared.update { snapshot in
            snapshot.keyboardHookStatus = monitor.isRunning ? "Active" : "Unavailable"
        }
        #endif
    }

    private func layoutCommand(for command: ShortcutCommand) -> LayoutCommand {
        switch command {
        case let .layout(layoutCommand):
            smartSnapController.reset()
            #if DEBUG || BETA
            OpenSnapInspector.shared.update { snapshot in
                snapshot.currentSmartSnapState = "Reset"
            }
            #endif
            return layoutCommand
        case let .smartSnap(side):
            let step = smartSnapController.nextStep(for: side)
            #if DEBUG || BETA
            OpenSnapInspector.shared.update { snapshot in
                snapshot.currentSmartSnapState = "\(side) \(Int(step.ratio * 100))%"
            }
            #endif
            return .smartSnap(side, step)
        }
    }
}
