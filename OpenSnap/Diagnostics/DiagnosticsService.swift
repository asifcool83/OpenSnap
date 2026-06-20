import Foundation

enum AccessibilityMenuStatus: Equatable, Sendable {
    case granted
    case permissionRequired

    var title: String {
        switch self {
        case .granted:
            return "Accessibility: Granted"
        case .permissionRequired:
            return "Accessibility: Permission Required"
        }
    }
}

@MainActor
protocol DiagnosticsServicing {
    var buildInfo: BuildInfo { get }
    func accessibilityStatus() -> AccessibilityMenuStatus
    func diagnosticReport() -> String
}

/// Produces menu-bar diagnostics from the existing Inspector state.
@MainActor
final class OpenSnapDiagnosticsService: DiagnosticsServicing {
    let buildInfo: BuildInfo

    private let permissionProvider: any AccessibilityPermissionProviding
    private let inspector: OpenSnapInspector

    init(
        permissionProvider: any AccessibilityPermissionProviding = SystemAccessibilityPermissionProvider(),
        inspector: OpenSnapInspector = .shared,
        buildInfo: BuildInfo = .current
    ) {
        self.permissionProvider = permissionProvider
        self.inspector = inspector
        self.buildInfo = buildInfo
    }

    func accessibilityStatus() -> AccessibilityMenuStatus {
        permissionProvider.isTrusted ? .granted : .permissionRequired
    }

    func diagnosticReport() -> String {
        var snapshot = inspector.snapshot
        snapshot.accessibilityStatus = accessibilityStatus() == .granted
            ? "Granted"
            : "Permission required"

        return InspectorReport(
            buildInfo: buildInfo,
            snapshot: snapshot,
            events: inspector.events
        ).humanReadable
    }
}
