#if DEBUG

import SwiftUI

struct DeveloperDiagnosticsView: View {
    @ObservedObject var diagnostics: DeveloperDiagnosticsCenter
    let refresh: @MainActor () -> Void

    private let columns = [
        GridItem(.fixed(220), alignment: .leading),
        GridItem(.flexible(), alignment: .leading)
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                    field("Frontmost application", diagnostics.snapshot.frontmostApplication)
                    field("Bundle identifier", diagnostics.snapshot.bundleIdentifier)
                    field("Window title", diagnostics.snapshot.windowTitle)
                    field("Window ID", diagnostics.snapshot.windowID)
                    field("Window frame", diagnostics.snapshot.windowFrame)
                    field("Visible frame", diagnostics.snapshot.visibleFrame)
                    field("Screen being used", diagnostics.snapshot.screenBeingUsed)
                    field("Screen dimensions", diagnostics.snapshot.screenDimensions)
                    field("Accessibility permission", diagnostics.snapshot.accessibilityPermissionStatus)
                    field("Window movable", diagnostics.snapshot.isWindowMovable)
                    field("Window resizable", diagnostics.snapshot.isWindowResizable)
                    field("Smart Snap state", diagnostics.snapshot.currentSmartSnapState)
                    field("Current shortcut", diagnostics.snapshot.currentShortcut)
                    field("Last WindowEngine operation", diagnostics.snapshot.lastWindowEngineOperation)
                    field("Last error", diagnostics.snapshot.lastError)
                }
                .padding()
            }
            .frame(minHeight: 320)

            Divider()

            List(diagnostics.logs) { entry in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("[\(entry.level.rawValue)]")
                        .font(.system(.caption, design: .monospaced).weight(.semibold))
                        .foregroundStyle(color(for: entry.level))
                    Text(entry.message)
                        .font(.system(.caption, design: .monospaced))
                    Spacer()
                    Text(entry.date, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(minHeight: 220)
        }
        .frame(minWidth: 760, minHeight: 560)
        .task {
            while !Task.isCancelled {
                refresh()
                try? await Task.sleep(nanoseconds: DebugConfiguration.diagnosticsRefreshIntervalNanoseconds)
            }
        }
    }

    private func field(_ title: String, _ value: String) -> some View {
        Group {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)
        }
    }

    private func color(for level: DeveloperLogLevel) -> Color {
        switch level {
        case .info:
            return .secondary
        case .warning:
            return .orange
        case .error:
            return .red
        }
    }
}

#endif
