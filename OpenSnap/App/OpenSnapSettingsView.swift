import AppKit
import SwiftUI

struct OpenSnapSettingsView: View {
    @ObservedObject var permissions: PermissionController

    var body: some View {
        Form {
            Section("Permissions") {
                PermissionRow(
                    title: "Accessibility",
                    explanation: "Move and resize the window under your pointer.",
                    isGranted: permissions.permissions.accessibilityGranted,
                    requestAccess: permissions.requestAccessibility,
                    openSettings: permissions.openAccessibilitySettings
                )

                PermissionRow(
                    title: "Input Monitoring",
                    explanation: "Detect Shift–1 and Shift–2 while other apps are active.",
                    isGranted: permissions.permissions.inputMonitoringGranted,
                    requestAccess: permissions.requestInputMonitoring,
                    openSettings: permissions.openInputMonitoringSettings
                )
            }

            Section("Keyboard Shortcuts") {
                ShortcutGuideRow(keys: "⇧1", title: "Snap Left", detail: "60%")
                ShortcutGuideRow(keys: "⇧2", title: "Snap Right", detail: "40%")
                Text("Shortcuts are fixed in this beta.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 520, height: 390)
        .onAppear {
            permissions.refresh()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            permissions.refresh()
        }
    }
}
