import Foundation

enum MenuBarReadiness: Equatable, Sendable {
    case ready
    case setupRequired

    var title: String {
        switch self {
        case .ready:
            return "OpenSnap is Ready"
        case .setupRequired:
            return "Finish Setting Up OpenSnap"
        }
    }

    var detail: String {
        switch self {
        case .ready:
            return "Point to the window you want to arrange."
        case .setupRequired:
            return "Allow the required macOS permissions to use shortcuts."
        }
    }

    var systemImage: String {
        switch self {
        case .ready:
            return "checkmark.circle.fill"
        case .setupRequired:
            return "exclamationmark.circle.fill"
        }
    }
}

struct SnapActivity: Equatable, Sendable {
    enum Kind: Equatable, Sendable {
        case success
        case constrained
        case failure
    }

    let kind: Kind
    let title: String
    let detail: String?

    var systemImage: String {
        switch kind {
        case .success:
            return "checkmark"
        case .constrained:
            return "arrow.left.and.right"
        case .failure:
            return "exclamationmark.triangle"
        }
    }
}

@MainActor
protocol DiagnosticsServicing {
    var buildInfo: BuildInfo { get }
    func permissionSnapshot() -> PermissionSnapshot
    func latestSnapActivity() -> SnapActivity?
    func diagnosticReport() -> String
}

/// Produces menu-bar diagnostics from the existing Inspector state.
@MainActor
final class OpenSnapDiagnosticsService: DiagnosticsServicing {
    let buildInfo: BuildInfo

    private let permissionProvider: any AccessibilityPermissionProviding
    private let inputMonitoringProvider: any InputMonitoringPermissionProviding
    private let inspector: OpenSnapInspector

    init(
        permissionProvider: any AccessibilityPermissionProviding = SystemAccessibilityPermissionProvider(),
        inputMonitoringProvider: any InputMonitoringPermissionProviding = SystemInputMonitoringPermissionProvider(),
        inspector: OpenSnapInspector = .shared,
        buildInfo: BuildInfo = .current
    ) {
        self.permissionProvider = permissionProvider
        self.inputMonitoringProvider = inputMonitoringProvider
        self.inspector = inspector
        self.buildInfo = buildInfo
    }

    func permissionSnapshot() -> PermissionSnapshot {
        PermissionSnapshot(
            accessibilityGranted: permissionProvider.isTrusted,
            inputMonitoringGranted: inputMonitoringProvider.isTrusted
        )
    }

    func latestSnapActivity() -> SnapActivity? {
        switch inspector.snapshot.lastActionResult {
        case "Success":
            return SnapActivity(kind: .success, title: "Last snap succeeded", detail: nil)
        case "Constrained":
            return SnapActivity(
                kind: .constrained,
                title: "Window used its closest allowed size",
                detail: nil
            )
        case "Failure":
            return SnapActivity(
                kind: .failure,
                title: "Last snap didn’t work",
                detail: Self.recoveryMessage(for: inspector.snapshot.lastError)
            )
        default:
            return nil
        }
    }

    func diagnosticReport() -> String {
        var snapshot = inspector.snapshot
        snapshot.accessibilityStatus = permissionProvider.isTrusted
            ? "Granted"
            : "Permission required"
        snapshot.keyboardHookStatus = inputMonitoringProvider.isTrusted
            ? snapshot.keyboardHookStatus
            : "Input Monitoring permission required"

        return InspectorReport(
            buildInfo: buildInfo,
            snapshot: snapshot,
            events: inspector.events
        ).humanReadable
    }

    private static func recoveryMessage(for error: String) -> String {
        if error.localizedCaseInsensitiveContains("permission") {
            return "Review permissions in Settings, then try again."
        }

        if error.localizedCaseInsensitiveContains("cannot be moved")
            || error.localizedCaseInsensitiveContains("cannot be resized") {
            return "That window doesn’t support snapping. Try another window."
        }

        if error.localizedCaseInsensitiveContains("under the mouse") {
            return "Point to a standard window, then try again."
        }

        return "Try another window. Copy the diagnostic report if the problem continues."
    }
}
