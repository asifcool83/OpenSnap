import AppKit
import Foundation
import OpenSnapCore

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
