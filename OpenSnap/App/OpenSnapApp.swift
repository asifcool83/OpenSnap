import SwiftUI

@main
struct OpenSnapApp: App {
    @StateObject private var appModel = OpenSnapAppModel()
    @StateObject private var updater = OpenSnapUpdater()

    var body: some Scene {
        MenuBarExtra("OpenSnap", systemImage: "rectangle.inset.filled.and.person.filled") {
            OpenSnapMenuView(model: appModel)
        }
        .menuBarExtraStyle(.menu)
        .commands {
            OpenSnapCommands(updater: updater)
        }

        Window("About OpenSnap", id: "about-opensnap") {
            AboutView(
                buildInfo: .current,
                canCheckForUpdates: updater.canCheckForUpdates,
                checkForUpdates: updater.checkForUpdates
            )
        }
        .windowResizability(.contentSize)

        Settings {
            SettingsView(settings: appModel.settings)
        }

        #if DEBUG
        Window("Developer Diagnostics", id: "developer-diagnostics") {
            DeveloperDiagnosticsView(
                diagnostics: .shared,
                refresh: appModel.refreshDeveloperDiagnostics
            )
        }
        .defaultSize(width: 820, height: 640)
        #endif
    }
}
