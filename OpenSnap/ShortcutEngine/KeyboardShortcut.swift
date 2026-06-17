import AppKit
import Foundation

/// A keyboard shortcut that maps to a window layout command.
public struct KeyboardShortcut: Equatable, Sendable {
    public let keyCode: UInt16
    public let modifiers: NSEvent.ModifierFlags
    public let command: ShortcutCommand

    public init(keyCode: UInt16, modifiers: NSEvent.ModifierFlags, command: ShortcutCommand) {
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.command = command
    }
}

/// Commands emitted by the shortcut layer.
public enum ShortcutCommand: Equatable, Sendable {
    case layout(LayoutCommand)
    case smartSnap(SmartSnapSide)
}
