import Combine
#if canImport(Sparkle)
import Sparkle
#endif

@MainActor
final class OpenSnapUpdater: ObservableObject {
    @Published private(set) var canCheckForUpdates = false

    #if canImport(Sparkle)
    private let updaterController: SPUStandardUpdaterController
    #endif

    init() {
        #if canImport(Sparkle)
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )

        updaterController.updater
            .publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
        #endif
    }

    func checkForUpdates() {
        #if canImport(Sparkle)
        updaterController.checkForUpdates(nil)
        #endif
    }
}
