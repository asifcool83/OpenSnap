import SwiftUI

struct OpenSnapMenuView: View {
    @ObservedObject var controller: MenuBarController

    var body: some View {
        Text(controller.accessibilityStatus.title)

        Divider()

        Button("Copy Diagnostic Report") {
            controller.copyDiagnosticReport()
        }

        Button("About OpenSnap") {
            controller.showAbout()
        }

        Divider()

        Button("Quit OpenSnap") {
            controller.quit()
        }
        .onAppear {
            controller.refreshAccessibilityStatus()
        }
    }
}
