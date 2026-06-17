import OSLog

/// Centralized logging categories for OpenSnap.
public enum OpenSnapLog {
    public static let app = Logger(subsystem: "dev.opensnap.OpenSnap", category: "App")
    public static let shortcuts = Logger(subsystem: "dev.opensnap.OpenSnap", category: "Shortcuts")
    public static let windowEngine = Logger(subsystem: "dev.opensnap.OpenSnap", category: "WindowEngine")
}
