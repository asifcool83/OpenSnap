import AppKit
import Foundation
import OpenSnapCore

/// Default keyboard shortcuts for OpenSnap.
public enum DefaultShortcuts {
    private enum KeyCode {
        static let one: UInt16 = 18
        static let two: UInt16 = 19
    }

    public static let all: [KeyboardShortcut] = [
        KeyboardShortcut(
            keyCode: KeyCode.one,
            modifiers: [.shift],
            command: .layout(.leftSixty)
        ),
        KeyboardShortcut(
            keyCode: KeyCode.two,
            modifiers: [.shift],
            command: .layout(.rightForty)
        )
    ]
}
