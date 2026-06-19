import SwiftUI

struct OpenSnapMenuView: View {
    @Environment(\.openWindow) private var openWindow

    @ObservedObject var model: OpenSnapAppModel

    var body: some View {
        Button("Request Accessibility Permission") {
            model.requestAccessibilityPermission()
        }

        Divider()

        Button("About OpenSnap") {
            openWindow(id: "about-opensnap")
        }

        Divider()

        Button("Left Smart Snap") {
            model.perform(.smartSnap(.left))
        }

        Button("Right Smart Snap") {
            model.perform(.smartSnap(.right))
        }

        Button("Maximize") {
            model.perform(.layout(.maximize))
        }

        Button("Center") {
            model.perform(.layout(.center))
        }

        if let message = model.lastErrorMessage {
            Divider()
            Text(message)
        }

        #if DEBUG || BETA
        Divider()

        Button("OpenSnap Inspector") {
            openWindow(id: "opensnap-inspector")
        }
        #endif

        Divider()

        Button("Quit OpenSnap") {
            NSApplication.shared.terminate(nil)
        }
    }
}
