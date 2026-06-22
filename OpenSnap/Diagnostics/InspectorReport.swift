import Foundation

struct InspectorReport {
    static func dateString(_ date: Date) -> String {
        date.formatted(.iso8601)
    }

    let reportID: UUID
    let generatedAt: Date
    let buildInfo: BuildInfo
    let snapshot: InspectorSnapshot
    let events: [InspectorEvent]

    init(
        reportID: UUID = UUID(),
        generatedAt: Date = Date(),
        buildInfo: BuildInfo,
        snapshot: InspectorSnapshot,
        events: [InspectorEvent]
    ) {
        self.reportID = reportID
        self.generatedAt = generatedAt
        self.buildInfo = buildInfo
        self.snapshot = snapshot
        self.events = events
    }

    var humanReadable: String {
        """
        OPENSNAP — DIAGNOSTIC REPORT
        ============================
        Report ID: \(reportID.uuidString)
        Generated: \(Self.dateString(generatedAt))

        BUILD IDENTITY
        --------------
        Version: \(buildInfo.version)
        Build: \(buildInfo.buildNumber)
        Git commit: \(buildInfo.gitCommit ?? "Unavailable")
        Branch: \(buildInfo.branch ?? "Unavailable")
        macOS: \(buildInfo.macOSVersion)
        Architecture: \(buildInfo.cpuArchitecture)

        STATUS
        ------
        Accessibility: \(snapshot.accessibilityStatus)
        Keyboard hook: \(snapshot.keyboardHookStatus)
        Window engine: \(snapshot.windowEngineStatus)

        LAST ACTION
        -----------
        Shortcut: \(snapshot.lastShortcut)
        Timestamp: \(snapshot.lastActionTimestamp.map(Self.dateString) ?? "Unavailable")
        Target application: \(snapshot.targetApplication)
        Result: \(snapshot.lastActionResult)

        CURRENT WINDOW
        --------------
        Title: \(snapshot.windowTitle)
        Bundle identifier: \(snapshot.bundleIdentifier)
        Window ID: \(snapshot.windowID)
        Current frame: \(snapshot.currentFrame)
        Target frame: \(snapshot.targetFrame)
        Actual frame: \(snapshot.actualFrame)

        LAST ERROR
        ----------
        \(snapshot.lastError)

        RECENT DIAGNOSTICS
        ------------------
        \(logsText)
        """
    }

    private var logsText: String {
        guard !events.isEmpty else { return "No diagnostic events recorded." }
        return events.map {
            let repetition = $0.occurrenceCount > 1 ? " — Repeated \($0.occurrenceCount) times" : ""
            return "\(Self.dateString($0.timestamp)) [\($0.severity.rawValue)] [\($0.category.rawValue)] \($0.message)\(repetition)"
        }.joined(separator: "\n")
    }
}
