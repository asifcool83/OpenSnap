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

        #if DEBUG || BETA
        Window("OpenSnap Inspector", id: "opensnap-inspector") {
            OpenSnapInspectorView(
                inspector: .shared,
                refresh: appModel.refreshInspector
            )
        }
        .defaultSize(width: 820, height: 640)
        #endif
    }
}
