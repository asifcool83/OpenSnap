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

    @Test("Plain-text report contains BuildInfo identity and diagnostics")
    func plainTextReport() {
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

        #expect(report.humanReadable.contains("Version: 1.2.3"))
        #expect(report.humanReadable.hasPrefix("OPENSNAP — DIAGNOSTIC REPORT"))
        #expect(report.humanReadable.contains("Git commit: abc123"))
        #expect(report.humanReadable.contains("Build: 42"))
        #expect(report.humanReadable.contains("Window constrained"))
    }
}
