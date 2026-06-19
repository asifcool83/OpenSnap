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
        OPEN SNAP — DIAGNOSTIC REPORT
        =============================
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

    var files: [String: Data] {
        get throws {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

            let report = ReportDocument(
                reportID: reportID,
                generatedAt: generatedAt,
                status: snapshot,
                events: events
            )
            let system = SystemDocument(
                macOSVersion: buildInfo.macOSVersion,
                cpuArchitecture: buildInfo.cpuArchitecture
            )
            let version = VersionDocument(
                appName: buildInfo.appName,
                version: buildInfo.version,
                buildNumber: buildInfo.buildNumber,
                gitCommit: buildInfo.gitCommit,
                branch: buildInfo.branch,
                buildDate: buildInfo.buildDate
            )

            return [
                "report.json": try encoder.encode(report),
                "logs.txt": Data(logsText.utf8),
                "system.json": try encoder.encode(system),
                "version.json": try encoder.encode(version)
            ]
        }
    }

    private var logsText: String {
        guard !events.isEmpty else { return "No diagnostic events recorded." }
        return events.map {
            let repetition = $0.repeatCount > 0 ? " — Repeated \($0.repeatCount) times" : ""
            return "\(Self.dateString($0.timestamp)) [\($0.severity.rawValue)] [\($0.category.rawValue)] \($0.message)\(repetition)"
        }.joined(separator: "\n")
    }
}

enum InspectorReportExporter {
    static func export(_ report: InspectorReport, to destination: URL) throws {
        let fileManager = FileManager.default
        let directory = fileManager.temporaryDirectory
            .appendingPathComponent("OpenSnap-Report-\(report.reportID.uuidString)", isDirectory: true)
        defer { try? fileManager.removeItem(at: directory) }

        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        for (name, data) in try report.files {
            try data.write(to: directory.appendingPathComponent(name), options: .atomic)
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
        process.arguments = ["-c", "-k", "--norsrc", directory.path, destination.path]
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw CocoaError(.fileWriteUnknown)
        }
    }
}

private struct ReportDocument: Codable {
    let reportID: UUID
    let generatedAt: Date
    let status: InspectorSnapshot
    let events: [InspectorEvent]
}

private struct SystemDocument: Codable {
    let macOSVersion: String
    let cpuArchitecture: String
}

private struct VersionDocument: Codable {
    let appName: String
    let version: String
    let buildNumber: String
    let gitCommit: String?
    let branch: String?
    let buildDate: String?
}
