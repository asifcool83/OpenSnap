import AppKit
import Foundation
import OpenSnapCore

/// Default keyboard shortcuts for OpenSnap.
public enum DefaultShortcuts {
    private enum KeyCode {
        static let leftArrow: UInt16 = 123
        static let rightArrow: UInt16 = 124
        static let upArrow: UInt16 = 126
        static let downArrow: UInt16 = 125
        static let one: UInt16 = 18
        static let two: UInt16 = 19
        static let three: UInt16 = 20
    }

    public static let all: [KeyboardShortcut] = [
        KeyboardShortcut(
            keyCode: KeyCode.leftArrow,
            modifiers: [.command, .option],
            command: .smartSnap(.left)
        ),
        KeyboardShortcut(
            keyCode: KeyCode.rightArrow,
            modifiers: [.command, .option],
            command: .smartSnap(.right)
        ),
        KeyboardShortcut(
            keyCode: KeyCode.upArrow,
            modifiers: [.command, .option],
            command: .layout(.maximize)
        ),
        KeyboardShortcut(
            keyCode: KeyCode.downArrow,
            modifiers: [.command, .option],
            command: .layout(.center)
        ),
        KeyboardShortcut(
            keyCode: KeyCode.one,
            modifiers: [.command, .option, .control],
            command: .layout(.leftThird)
        ),
        KeyboardShortcut(
            keyCode: KeyCode.two,
            modifiers: [.command, .option, .control],
            command: .layout(.centerThird)
        ),
        KeyboardShortcut(
            keyCode: KeyCode.three,
            modifiers: [.command, .option, .control],
            command: .layout(.rightThird)
        )
    ]
}
