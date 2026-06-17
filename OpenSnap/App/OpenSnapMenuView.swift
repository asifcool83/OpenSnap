import SwiftUI

struct OpenSnapMenuView: View {
    @ObservedObject var model: OpenSnapAppModel

    var body: some View {
        Button("Request Accessibility Permission") {
            model.requestAccessibilityPermission()
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

        Divider()

        Button("Quit OpenSnap") {
            NSApplication.shared.terminate(nil)
        }
    }
}
