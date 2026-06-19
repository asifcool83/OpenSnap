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
        #expect(report.humanReadable.contains("Window constrained"))

        let version = String(decoding: try #require(report.files["version.json"]), as: UTF8.self)
        #expect(version.contains("abc123"))
        #expect(version.contains("42"))
    }
}
