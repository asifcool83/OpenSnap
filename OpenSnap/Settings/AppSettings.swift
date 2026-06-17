import Foundation

/// User-configurable OpenSnap settings.
@MainActor
public final class AppSettings: ObservableObject {
    @Published public var launchAtLogin: Bool
    @Published public var showMenuBarIcon: Bool

    public init(launchAtLogin: Bool = false, showMenuBarIcon: Bool = true) {
        self.launchAtLogin = launchAtLogin
        self.showMenuBarIcon = showMenuBarIcon
    }
}
