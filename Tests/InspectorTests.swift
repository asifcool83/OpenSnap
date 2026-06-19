import Foundation
import Testing
@testable import OpenSnap

@Suite("OpenSnap Inspector")
@MainActor
struct InspectorTests {
    private let buildInfo = BuildInfo(
        infoDictionary: [
            "CFBundleDisplayName": "OpenSnap",
            "CFBundleShortVersionString": "1.2.3",
            "CFBundleVersion": "42",
            "OpenSnapGitCommit": "abc123"
        ],
        macOSVersion: "macOS Test",
        cpuArchitecture: "arm64"
    )

    @Test("Retains only the configured number of structured events")
    func eventRetention() {
        let inspector = OpenSnapInspector(buildInfo: buildInfo, maximumEventCount: 2)

        inspector.record(.info, category: .app, "First")
        inspector.record(.warning, category: .accessibility, "Second")
        inspector.record(.error, category: .windowEngine, "Third")

        #expect(inspector.events.map(\.message) == ["Third", "Second"])
        #expect(inspector.events[0].severity == .error)
        #expect(inspector.events[1].category == .accessibility)
    }

    @Test("Collapses consecutive identical events")
    func repeatedEvents() {
        let inspector = OpenSnapInspector(buildInfo: buildInfo)

        inspector.record(.warning, category: .accessibility, "Accessibility permission missing")
        inspector.record(.warning, category: .accessibility, "Accessibility permission missing")
        inspector.record(.warning, category: .accessibility, "Accessibility permission missing")

        #expect(inspector.events.count == 1)
        #expect(inspector.events[0].occurrenceCount == 3)
    }

    @Test("Uses user-facing layout descriptions")
    func layoutDescriptions() {
        #expect(InspectorDescriptions.layout(.smartSnap(.left, .sixtyPercent)) == "Snap Left (60%)")
        #expect(InspectorDescriptions.layout(.center) == "Center")
        #expect(InspectorDescriptions.layout(.rightForty) == "Snap Right (40%)")
    }

    @Test("Explains missing window data when Accessibility is unavailable")
    func accessibilityContext() {
        let inspector = OpenSnapInspector(buildInfo: buildInfo)

        inspector.recordAccessibilityMissing()

        #expect(inspector.snapshot.accessibilityStatus == "Permission required")
        #expect(inspector.snapshot.windowTitle.contains("Accessibility permission"))
        #expect(inspector.snapshot.currentFrame.contains("Accessibility permission"))
    }

    @Test("Report contains the required support files and BuildInfo identity")
    func reportFiles() throws {
        let snapshot = InspectorSnapshot(appVersion: "1.2.3", buildNumber: "42")
        let event = InspectorEvent(
            timestamp: Date(timeIntervalSince1970: 1_700_000_000),
            severity: .warning,
            category: .windowEngine,
            message: "Window constrained"
        )
        let report = InspectorReport(
            reportID: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!,
            generatedAt: Date(timeIntervalSince1970: 1_700_000_001),
            buildInfo: buildInfo,
            snapshot: snapshot,
            events: [event]
        )

        #expect(Set(try report.files.keys) == ["report.json", "logs.txt", "system.json", "version.json"])
        #expect(report.humanReadable.contains("Version: 1.2.3"))
        #expect(report.humanReadable.hasPrefix("OPEN SNAP — DIAGNOSTIC REPORT"))
        #expect(report.humanReadable.contains("Window constrained"))

        let version = String(decoding: try #require(report.files["version.json"]), as: UTF8.self)
        #expect(version.contains("abc123"))
        #expect(version.contains("42"))
    }

    @Test("Detects whether an appcast contains a release")
    func updateFeedInspection() {
        let emptyFeed = Data("<rss><channel></channel></rss>".utf8)
        let unrelatedElement = Data("<rss><channel><items /></channel></rss>".utf8)
        let publishedFeed = Data("<rss><channel><item><title>Beta</title></item></channel></rss>".utf8)

        #expect(!UpdateFeedInspector.containsRelease(in: emptyFeed))
        #expect(!UpdateFeedInspector.containsRelease(in: unrelatedElement))
        #expect(UpdateFeedInspector.containsRelease(in: publishedFeed))
    }

    @Test("Exported ZIP contains all support files")
    func exportedZipContents() throws {
        let report = InspectorReport(
            buildInfo: buildInfo,
            snapshot: InspectorSnapshot(appVersion: "1.2.3", buildNumber: "42"),
            events: []
        )
        let destination = FileManager.default.temporaryDirectory
            .appendingPathComponent("OpenSnap-InspectorTests-\(UUID().uuidString).zip")
        defer { try? FileManager.default.removeItem(at: destination) }

        try InspectorReportExporter.export(report, to: destination)

        let process = Process()
        let output = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-Z1", destination.path]
        process.standardOutput = output
        try process.run()
        process.waitUntilExit()

        #expect(process.terminationStatus == 0)
        let listing = String(decoding: output.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        let files = Set(listing.split(separator: "\n").map(String.init))
        #expect(files == ["report.json", "logs.txt", "system.json", "version.json"])
    }
}
