import Foundation

@MainActor
final class PermissionController: ObservableObject {
    @Published private(set) var permissions: PermissionSnapshot

    private let service: any PermissionServicing

    init(service: any PermissionServicing = SystemPermissionService()) {
        self.service = service
        permissions = service.snapshot()
    }

    func refresh() {
        permissions = service.snapshot()
    }

    func requestAccessibility() {
        service.requestAccessibility()
        refresh()
    }

    func requestInputMonitoring() {
        service.requestInputMonitoring()
        refresh()
    }

    func openAccessibilitySettings() {
        service.openAccessibilitySettings()
    }

    func openInputMonitoringSettings() {
        service.openInputMonitoringSettings()
    }
}
