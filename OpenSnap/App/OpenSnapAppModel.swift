import Foundation

@MainActor
final class OpenSnapAppModel: ObservableObject {
    private var globalHotkeyService: GlobalHotkeyService?

    init() {
        startGlobalHotkeys()
    }

    private func startGlobalHotkeys() {
        let service = GlobalHotkeyService { [weak self] result in
            self?.handleGlobalHotkeyResult(result)
        }

        service.start()
        globalHotkeyService = service
        #if DEBUG || BETA
        OpenSnapInspector.shared.update { snapshot in
            snapshot.keyboardHookStatus = service.isRunning ? "Active" : "Unavailable"
        }
        #endif
    }

    private func handleGlobalHotkeyResult(_ result: Result<WindowMutationResult, Error>) {
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
