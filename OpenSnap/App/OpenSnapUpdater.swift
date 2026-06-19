import AppKit
import Combine
import Foundation
#if canImport(Sparkle)
import Sparkle
#endif

@MainActor
final class OpenSnapUpdater: ObservableObject {
    @Published private(set) var canCheckForUpdates = false

    #if canImport(Sparkle)
    private let updaterController: SPUStandardUpdaterController
    private let feedURL: URL?
    private var isChecking = false
    #endif

    init(feedURL: URL? = OpenSnapUpdater.configuredFeedURL) {
        #if canImport(Sparkle)
        self.feedURL = feedURL
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
        guard !isChecking else { return }
        isChecking = true

        Task {
            defer { isChecking = false }

            guard let feedURL else {
                showNoUpdatesMessage()
                return
            }

            do {
                let (data, response) = try await URLSession.shared.data(from: feedURL)
                guard let httpResponse = response as? HTTPURLResponse,
                      (200..<300).contains(httpResponse.statusCode),
                      UpdateFeedInspector.containsRelease(in: data) else {
                    showNoUpdatesMessage()
                    return
                }

                updaterController.checkForUpdates(nil)
            } catch {
                showNoUpdatesMessage()
            }
        }
        #endif
    }

    private static var configuredFeedURL: URL? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "SUFeedURL") as? String else {
            return nil
        }
        return URL(string: value)
    }

    #if canImport(Sparkle)
    private func showNoUpdatesMessage() {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "No Updates Available"
        alert.informativeText = "No updates are currently available. You’re already running the latest available beta."
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    #endif
}

enum UpdateFeedInspector {
    static func containsRelease(in data: Data) -> Bool {
        let appcast = String(decoding: data, as: UTF8.self)
        return appcast.range(of: "<item(?:\\s|>)", options: .regularExpression) != nil
    }
}
