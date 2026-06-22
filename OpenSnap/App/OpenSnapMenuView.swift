import SwiftUI

struct OpenSnapMenuView: View {
    @ObservedObject var controller: MenuBarController
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Label(controller.readiness.title, systemImage: controller.readiness.systemImage)

        Text(controller.readiness.detail)

        if !controller.permissions.isReady {
            Button("Finish Setup…") {
                openOnboarding()
            }
        }

        Divider()

        Text("Point to a window, then press:")
        Text("⇧1   Snap Left (60%)")
        Text("⇧2   Snap Right (40%)")

        if let activity = controller.latestSnapActivity {
            Divider()
            Label(activity.title, systemImage: activity.systemImage)
            if let detail = activity.detail {
                Text(detail)
            }
        }

        Divider()

        Button("Getting Started…") {
            openOnboarding()
        }

        SettingsLink {
            Text("Settings…")
        }

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
            controller.refreshPermissions()
        }
    }

    private func openOnboarding() {
        openWindow(id: "onboarding")
        NSApplication.shared.activate()
    }
}
