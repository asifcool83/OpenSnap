import SwiftUI

@main
struct OpenSnapApp: App {
    @StateObject private var appModel = OpenSnapAppModel()
    @StateObject private var menuBarController = MenuBarController()
    @StateObject private var permissionController = PermissionController()
    @StateObject private var firstRun = FirstRunState()

    var body: some Scene {
        MenuBarExtra("OpenSnap", systemImage: "rectangle.inset.filled.and.person.filled") {
            OpenSnapMenuView(controller: menuBarController)
        }
        .menuBarExtraStyle(.menu)

        Window("Welcome to OpenSnap", id: "onboarding") {
            OnboardingView(permissions: permissionController, firstRun: firstRun)
        }
        .defaultLaunchBehavior(firstRun.hasCompletedOnboarding ? .suppressed : .presented)
        .restorationBehavior(.disabled)
        .windowResizability(.contentSize)

        Settings {
            OpenSnapSettingsView(permissions: permissionController)
        }
        .windowResizability(.contentSize)
    }
}
