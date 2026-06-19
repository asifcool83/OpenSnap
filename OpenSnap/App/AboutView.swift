import SwiftUI

struct AboutView: View {
    @Environment(\.openWindow) private var openWindow

    let buildInfo: BuildInfo
    let canCheckForUpdates: Bool
    let checkForUpdates: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Text(buildInfo.appName)
                    .font(.system(size: 28, weight: .semibold))

                Text("Version \(buildInfo.versionAndBuild)")
                    .foregroundStyle(.secondary)
            }

            Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 8) {
                row("Version", buildInfo.version)
                row("Build", buildInfo.buildNumber)

                if let gitCommit = buildInfo.gitCommit {
                    row("Git Commit", gitCommit)
                }

                if let branch = buildInfo.branch {
                    row("Branch", branch)
                }

                if let buildDate = buildInfo.buildDate {
                    row("Build Date", buildDate)
                }

                row("macOS", buildInfo.macOSVersion)
                row("Architecture", buildInfo.cpuArchitecture)
            }
            .textSelection(.enabled)

            Divider()

            HStack {
                Button("Open Inspector") {
                    openWindow(id: "developer-diagnostics")
                }
                .disabled(!Self.inspectorAvailable)

                Spacer()

                Button("Check for Updates") {
                    checkForUpdates()
                }
                .disabled(!canCheckForUpdates)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 460)
    }

    private func row(_ label: String, _ value: String) -> some View {
        GridRow {
            Text(label)
                .foregroundStyle(.secondary)
            Text(value)
        }
    }

    private static var inspectorAvailable: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }
}

struct OpenSnapCommands: Commands {
    @Environment(\.openWindow) private var openWindow
    @ObservedObject var updater: OpenSnapUpdater

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("About OpenSnap") {
                openWindow(id: "about-opensnap")
            }

            Divider()

            Button("Check for Updates…") {
                updater.checkForUpdates()
            }
            .disabled(!updater.canCheckForUpdates)
        }
    }
}
