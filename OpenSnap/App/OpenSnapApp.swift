import SwiftUI

@main
struct OpenSnapApp: App {
    @StateObject private var appModel = OpenSnapAppModel()
    @StateObject private var menuBarController = MenuBarController()

    var body: some Scene {
        MenuBarExtra("OpenSnap", systemImage: "rectangle.inset.filled.and.person.filled") {
            OpenSnapMenuView(controller: menuBarController)
        }
        .menuBarExtraStyle(.menu)
    }
}
