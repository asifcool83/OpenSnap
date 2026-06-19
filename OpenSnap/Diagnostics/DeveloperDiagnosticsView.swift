#if DEBUG || BETA

import AppKit
import SwiftUI

struct OpenSnapInspectorView: View {
    @ObservedObject var inspector: OpenSnapInspector
    let refresh: @MainActor () -> Void
    @State private var message: String?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    section("Status") {
                        fields([
                            ("App version", inspector.snapshot.appVersion),
                            ("Build", inspector.snapshot.buildNumber),
                            ("Accessibility", inspector.snapshot.accessibilityStatus),
                            ("Keyboard hook", inspector.snapshot.keyboardHookStatus),
                            ("Window engine", inspector.snapshot.windowEngineStatus)
                        ])
                    }

                    section("Last Action") {
                        fields([
                            ("Shortcut", inspector.snapshot.lastShortcut),
                            ("Timestamp", formatted(inspector.snapshot.lastActionTimestamp)),
                            ("Target application", inspector.snapshot.targetApplication),
                            ("Target window", inspector.snapshot.windowTitle),
                            ("Result", inspector.snapshot.lastActionResult)
                        ])
                    }

                    section("Current Window") {
                        fields([
                            ("Window title", inspector.snapshot.windowTitle),
                            ("Bundle identifier", inspector.snapshot.bundleIdentifier),
                            ("Window ID", inspector.snapshot.windowID),
                            ("Current frame", inspector.snapshot.currentFrame),
                            ("Target frame", inspector.snapshot.targetFrame),
                            ("Actual frame", inspector.snapshot.actualFrame)
                        ])
                    }

                    section("Diagnostics") {
                        VStack(alignment: .leading, spacing: 10) {
                            fields([("Last error", inspector.snapshot.lastError)])

                            Divider()

                            ForEach(inspector.events) { event in
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text(event.severity.rawValue)
                                        .foregroundStyle(color(for: event.severity))
                                    Text(event.category.rawValue)
                                        .foregroundStyle(.secondary)
                                    Text(event.message)
                                    if event.repeatCount > 0 {
                                        Text("Repeated \(event.repeatCount) times")
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(event.timestamp, style: .time)
                                        .foregroundStyle(.secondary)
                                }
                                .font(.system(.caption, design: .monospaced))
                            }
                        }
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                if let message {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("Copy Diagnostics") {
                    copyDiagnostics()
                }

                Button("Export Report…") {
                    exportReport()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(minWidth: 720, minHeight: 640)
        .task {
            while !Task.isCancelled {
                refresh()
                try? await Task.sleep(nanoseconds: InspectorConfiguration.refreshIntervalNanoseconds)
            }
        }
    }

    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        GroupBox(title) {
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        }
    }

    private func fields(_ values: [(String, String)]) -> some View {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 6) {
            ForEach(Array(values.enumerated()), id: \.offset) { _, value in
                GridRow {
                    Text(value.0)
                        .foregroundStyle(.secondary)
                    Text(value.1)
                        .textSelection(.enabled)
                }
            }
        }
        .font(.system(.caption, design: .monospaced))
    }

    private func copyDiagnostics() {
        let report = InspectorReport(buildInfo: .current, snapshot: inspector.snapshot, events: inspector.events)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(report.humanReadable, forType: .string)
        message = "Diagnostics copied"
    }

    private func exportReport() {
        let report = InspectorReport(buildInfo: .current, snapshot: inspector.snapshot, events: inspector.events)
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.zip]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = "OpenSnap-Report-\(String(report.reportID.uuidString.prefix(8))).zip"

        guard panel.runModal() == .OK, let url = panel.url else {
            return
        }

        do {
            try InspectorReportExporter.export(report, to: url)
            message = "Report exported"
        } catch {
            message = "Export failed: \(error.localizedDescription)"
        }
    }

    private func formatted(_ date: Date?) -> String {
        date.map(InspectorReport.dateString) ?? "Unavailable"
    }

    private func color(for severity: InspectorEvent.Severity) -> Color {
        switch severity {
        case .info: .secondary
        case .warning: .orange
        case .error: .red
        }
    }
}

#endif
