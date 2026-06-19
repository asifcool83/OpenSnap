import AppKit
import Foundation
import OpenSnapCore

/// Monitors global key-down events and dispatches matching OpenSnap commands.
@MainActor
public final class ShortcutMonitor {
    private let shortcuts: [KeyboardShortcut]
    private let handler: (ShortcutCommand) -> Void
    private var monitor: Any?

    public var isRunning: Bool {
        monitor != nil
    }

    public init(
        shortcuts: [KeyboardShortcut] = DefaultShortcuts.all,
        handler: @escaping (ShortcutCommand) -> Void
    ) {
        self.shortcuts = shortcuts
        self.handler = handler
    }

    public func start() {
        stop()

        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            Task { @MainActor in
                self?.handle(event)
            }
        }
    }

    public func stop() {
        guard let monitor else {
            return
        }

        NSEvent.removeMonitor(monitor)
        self.monitor = nil
    }

    private func handle(_ event: NSEvent) {
        guard let shortcut = shortcuts.first(where: { $0.matches(event) }) else {
            return
        }

        handler(shortcut.command)
    }
}

private extension KeyboardShortcut {
    func matches(_ event: NSEvent) -> Bool {
        let relevantModifiers: NSEvent.ModifierFlags = [.command, .option, .control, .shift]

        return keyCode == event.keyCode
            && modifiers == event.modifierFlags.intersection(relevantModifiers)
    }
}
