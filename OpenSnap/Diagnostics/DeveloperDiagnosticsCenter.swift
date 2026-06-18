#if DEBUG

import Foundation
import OpenSnapCore

@MainActor
final class DeveloperDiagnosticsCenter: ObservableObject {
    static let shared = DeveloperDiagnosticsCenter()

    @Published private(set) var snapshot = DeveloperDiagnosticsSnapshot()
    @Published private(set) var logs: [DeveloperLogEntry] = []

    private let maximumLogCount = 300

    private init() {}

    func update(_ update: (inout DeveloperDiagnosticsSnapshot) -> Void) {
        update(&snapshot)
    }

    func record(_ level: DeveloperLogLevel, _ message: String) {
        let entry = DeveloperLogEntry(level: level, message: message, date: Date())
        logs.insert(entry, at: 0)

        if logs.count > maximumLogCount {
            logs.removeLast(logs.count - maximumLogCount)
        }
    }

    func recordShortcut(_ command: ShortcutCommand) {
        snapshot.currentShortcut = String(describing: command)
        record(.info, "Shortcut \(String(describing: command))")
    }

    func recordOperation(_ operation: String) {
        snapshot.lastWindowEngineOperation = operation
        record(.info, operation)
    }

    func recordError(_ error: Error) {
        snapshot.lastError = error.localizedDescription
        record(.error, error.localizedDescription)
    }
}

struct DeveloperDiagnosticsSnapshot: Equatable {
    var frontmostApplication = "Unavailable"
    var bundleIdentifier = "Unavailable"
    var windowTitle = "Unavailable"
    var windowID = "Unavailable"
    var windowFrame = "Unavailable"
    var visibleFrame = "Unavailable"
    var screenBeingUsed = "Unavailable"
    var screenDimensions = "Unavailable"
    var accessibilityPermissionStatus = "Unknown"
    var isWindowMovable = "Unknown"
    var isWindowResizable = "Unknown"
    var currentSmartSnapState = "Initial"
    var currentShortcut = "None"
    var lastWindowEngineOperation = "None"
    var lastError = "None"
}

struct DeveloperLogEntry: Identifiable, Equatable {
    let id = UUID()
    let level: DeveloperLogLevel
    let message: String
    let date: Date
}

enum DeveloperLogLevel: String, Equatable {
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

#endif
