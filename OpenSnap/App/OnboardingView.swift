import AppKit
import SwiftUI

struct OnboardingView: View {
    @ObservedObject var permissions: PermissionController
    @ObservedObject var firstRun: FirstRunState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Image(systemName: "rectangle.split.2x1.fill")
                    .font(.system(size: 42, weight: .medium))
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)

                Text("Welcome to OpenSnap")
                    .font(.largeTitle.weight(.semibold))

                Text("Arrange the window under your pointer with one keystroke.")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Text("Private by design. Nothing is sent anywhere.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 24)

            GroupBox {
                VStack(spacing: 16) {
                    PermissionRow(
                        title: "Accessibility",
                        explanation: "Allows OpenSnap to move and resize the window you choose.",
                        isGranted: permissions.permissions.accessibilityGranted,
                        requestAccess: permissions.requestAccessibility,
                        openSettings: permissions.openAccessibilitySettings
                    )

                    Divider()

                    PermissionRow(
                        title: "Input Monitoring",
                        explanation: "Allows OpenSnap to detect Shift–1 and Shift–2 while you use other apps.",
                        isGranted: permissions.permissions.inputMonitoringGranted,
                        requestAccess: permissions.requestInputMonitoring,
                        openSettings: permissions.openInputMonitoringSettings
                    )
                }
                .padding(8)
            } label: {
                Text("Required Permissions")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Point to a window, then press:")
                    .font(.headline)

                ShortcutGuideRow(keys: "⇧1", title: "Snap Left", detail: "60%")
                ShortcutGuideRow(keys: "⇧2", title: "Snap Right", detail: "40%")
            }
            .padding(.vertical, 24)

            HStack {
                Button("Check Again") {
                    permissions.refresh()
                }

                Spacer()

                Button("Start Using OpenSnap") {
                    firstRun.completeOnboarding()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(!permissions.permissions.isReady)
            }
        }
        .padding(32)
        .frame(width: 560)
        .onAppear {
            NSApplication.shared.activate()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            permissions.refresh()
        }
    }
}

struct ShortcutGuideRow: View {
    let keys: String
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: 12) {
            Text(keys)
                .font(.system(.body, design: .rounded, weight: .semibold))
                .frame(width: 42, height: 28)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
            Text(title)
            Spacer()
            Text(detail)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}
