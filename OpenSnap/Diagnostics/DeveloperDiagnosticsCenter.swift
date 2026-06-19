import Foundation
import OpenSnapCore

@MainActor
final class OpenSnapInspector: ObservableObject {
    static let shared = OpenSnapInspector()

    @Published private(set) var snapshot: InspectorSnapshot
    @Published private(set) var events: [InspectorEvent] = []

    private let maximumEventCount: Int

    init(buildInfo: BuildInfo = .current, maximumEventCount: Int = 100) {
        self.maximumEventCount = maximumEventCount
        snapshot = InspectorSnapshot(
            appVersion: buildInfo.version,
            buildNumber: buildInfo.buildNumber
        )
    }

    func update(_ update: (inout InspectorSnapshot) -> Void) {
        update(&snapshot)
    }

    func record(
        _ severity: InspectorEvent.Severity,
        category: InspectorEvent.Category,
        _ message: String,
        timestamp: Date = Date()
    ) {
        if let latest = events.first,
           latest.severity == severity,
           latest.category == category,
           latest.message == message {
            events[0] = InspectorEvent(
                id: latest.id,
                timestamp: timestamp,
                severity: severity,
                category: category,
                message: message,
                occurrenceCount: latest.occurrenceCount + 1
            )
            return
        }

        events.insert(
            InspectorEvent(
                timestamp: timestamp,
                severity: severity,
                category: category,
                message: message
            ),
            at: 0
        )

        if events.count > maximumEventCount {
            events.removeLast(events.count - maximumEventCount)
        }
    }

    func recordShortcut(_ command: LayoutCommand, timestamp: Date = Date()) {
        let shortcut = InspectorDescriptions.layout(command)
        snapshot.lastShortcut = shortcut
        snapshot.lastActionTimestamp = timestamp
        snapshot.lastActionResult = "In progress"
        record(.info, category: .shortcut, "Shortcut \(shortcut)", timestamp: timestamp)
    }

    func recordOperation(_ operation: String) {
        snapshot.windowEngineStatus = operation
        record(.info, category: .windowEngine, operation)
    }

    func recordResult(_ result: WindowMutationResult) {
        snapshot.targetFrame = InspectorFormatting.frame(result.requestedFrame)
        snapshot.actualFrame = result.observedFrame.map(InspectorFormatting.frame) ?? "Unavailable"

        switch result {
        case .success:
            snapshot.windowEngineStatus = "Ready"
            snapshot.lastActionResult = "Success"
            record(.info, category: .windowEngine, "Window mutation succeeded")
        case .constrained:
            snapshot.windowEngineStatus = "Constrained"
            snapshot.lastActionResult = "Constrained"
            record(.warning, category: .windowEngine, "Window mutation was constrained")
        case let .failure(failure):
            snapshot.windowEngineStatus = "Failure"
            snapshot.lastActionResult = "Failure"
            recordError(failure)
        }
    }

    func recordError(_ error: Error) {
        snapshot.windowEngineStatus = "Failure"
        snapshot.lastError = error.localizedDescription
        snapshot.lastActionResult = "Failure"
        record(.error, category: .windowEngine, error.localizedDescription)
    }

    func recordAccessibilityMissing(recordEvent: Bool = true) {
        let explanation = "Accessibility permission is required to inspect the active window."
        snapshot.accessibilityStatus = "Permission required"
        snapshot.targetApplication = explanation
        snapshot.windowTitle = explanation
        snapshot.bundleIdentifier = explanation
        snapshot.windowID = explanation
        snapshot.currentFrame = explanation
        snapshot.targetFrame = explanation
        snapshot.actualFrame = explanation
        if recordEvent {
            record(.warning, category: .accessibility, "Accessibility permission missing")
        }
    }
}

enum InspectorDescriptions {
    static func layout(_ command: LayoutCommand) -> String {
        switch command {
        case .leftSixty: "Snap Left (60%)"
        case .rightForty: "Snap Right (40%)"
        case .leftHalf: "Snap Left (50%)"
        case .rightHalf: "Snap Right (50%)"
        case .leftThird: "Snap Left Third"
        case .centerThird: "Snap Center Third"
        case .rightThird: "Snap Right Third"
        case .maximize: "Maximize"
        case .center: "Center"
        case let .smartSnap(side, step):
            "Snap \(side == .left ? "Left" : "Right") (\(Int((step.ratio * 100).rounded()))%)"
        }
    }
}

struct InspectorSnapshot: Equatable, Codable {
    var appVersion: String
    var buildNumber: String
    var accessibilityStatus = "Unknown"
    var keyboardHookStatus = "Unknown"
    var windowEngineStatus = "Idle"
    var lastShortcut = "None"
    var lastActionTimestamp: Date?
    var lastActionResult = "None"
    var targetApplication = "Unavailable"
    var windowTitle = "Unavailable"
    var bundleIdentifier = "Unavailable"
    var windowID = "Unavailable"
    var currentFrame = "Unavailable"
    var targetFrame = "Unavailable"
    var actualFrame = "Unavailable"
    var visibleFrame = "Unavailable"
    var screenBeingUsed = "Unavailable"
    var screenDimensions = "Unavailable"
    var isWindowMovable = "Unknown"
    var isWindowResizable = "Unknown"
    var currentSmartSnapState = "Initial"
    var lastError = "None"
}

struct InspectorEvent: Identifiable, Equatable, Codable {
    enum Severity: String, Equatable, Codable {
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
    }

    enum Category: String, Equatable, Codable {
        case accessibility = "Accessibility"
        case app = "App"
        case shortcut = "Shortcut"
        case windowEngine = "WindowEngine"
    }

    let id: UUID
    let timestamp: Date
    let severity: Severity
    let category: Category
    let message: String
    let occurrenceCount: Int

    init(
        id: UUID = UUID(),
        timestamp: Date,
        severity: Severity,
        category: Category,
        message: String,
        occurrenceCount: Int = 1
    ) {
        self.id = id
        self.timestamp = timestamp
        self.severity = severity
        self.category = category
        self.message = message
        self.occurrenceCount = occurrenceCount
    }
}
