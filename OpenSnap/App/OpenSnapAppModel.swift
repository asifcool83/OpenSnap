import Foundation
import OpenSnapCore

@MainActor
final class OpenSnapAppModel: ObservableObject {
    private var globalHotkeyService: GlobalHotkeyService?

    init() {
        startGlobalHotkeys()
    }

    private func startGlobalHotkeys() {
        let service = GlobalHotkeyService { [weak self] command, result in
            self?.handleGlobalHotkeyResult(command: command, result: result)
        }

        service.start()
        globalHotkeyService = service
        #if DEBUG || BETA
        OpenSnapInspector.shared.update { snapshot in
            snapshot.keyboardHookStatus = service.isRunning ? "Active" : "Unavailable"
        }
        #endif
    }

    private func handleGlobalHotkeyResult(
        command: ShortcutCommand,
        result: Result<WindowMutationResult, Error>
    ) {
        #if DEBUG || BETA
        if case let .layout(layoutCommand) = command {
            OpenSnapInspector.shared.recordShortcut(layoutCommand)
        }
        #endif

        switch result {
        case let .success(mutationResult):
            #if DEBUG || BETA
            OpenSnapInspector.shared.recordResult(mutationResult)
            #endif
        case let .failure(error):
            #if DEBUG || BETA
            OpenSnapInspector.shared.recordError(error)
            #endif
        }
    }
}
