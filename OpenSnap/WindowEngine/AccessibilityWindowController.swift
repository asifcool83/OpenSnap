import AppKit
import ApplicationServices
import Foundation

/// Controls the focused macOS window through the Accessibility API.
public final class AccessibilityWindowController: WindowControlling {
    private let layoutCalculator: LayoutCalculator

    public init(layoutCalculator: LayoutCalculator = LayoutCalculator()) {
        self.layoutCalculator = layoutCalculator
    }

    public func perform(_ operation: WindowOperation) throws {
        guard AccessibilityPermission.isTrusted else {
            throw WindowEngineError.accessibilityPermissionRequired
        }

        let focusedWindow = try focusedWindow()

        switch operation {
        case let .layout(command):
            let screenFrame = try visibleScreenFrame(for: focusedWindow)
            let newFrame = layoutCalculator.frame(for: command, in: screenFrame)
            try setFrame(newFrame, for: focusedWindow)
        }
    }

    private func focusedWindow() throws -> AXUIElement {
        let systemWideElement = AXUIElementCreateSystemWide()
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(
            systemWideElement,
            kAXFocusedWindowAttribute as CFString,
            &value
        )

        guard result == .success, let window = value else {
            throw WindowEngineError.focusedWindowUnavailable
        }

        return unsafeDowncast(window, to: AXUIElement.self)
    }

    private func visibleScreenFrame(for window: AXUIElement) throws -> WindowFrame {
        let currentFrame = try frame(for: window)
        let screen = NSScreen.screens.first { screen in
            screen.visibleFrame.contains(NSPoint(x: currentFrame.x, y: currentFrame.y))
        } ?? NSScreen.main

        guard let visibleFrame = screen?.visibleFrame else {
            throw WindowEngineError.screenUnavailable
        }

        return WindowFrame(
            x: visibleFrame.origin.x,
            y: visibleFrame.origin.y,
            width: visibleFrame.width,
            height: visibleFrame.height
        )
    }

    private func frame(for window: AXUIElement) throws -> WindowFrame {
        let position = try cgPointAttribute(kAXPositionAttribute, for: window)
        let size = try cgSizeAttribute(kAXSizeAttribute, for: window)

        return WindowFrame(
            x: position.x,
            y: position.y,
            width: size.width,
            height: size.height
        )
    }

    private func setFrame(_ frame: WindowFrame, for window: AXUIElement) throws {
        var position = CGPoint(x: frame.x, y: frame.y)
        var size = CGSize(width: frame.width, height: frame.height)

        guard let positionValue = AXValueCreate(.cgPoint, &position),
              let sizeValue = AXValueCreate(.cgSize, &size) else {
            throw WindowEngineError.invalidAccessibilityValue
        }

        let positionResult = AXUIElementSetAttributeValue(
            window,
            kAXPositionAttribute as CFString,
            positionValue
        )
        let sizeResult = AXUIElementSetAttributeValue(
            window,
            kAXSizeAttribute as CFString,
            sizeValue
        )

        guard positionResult == .success, sizeResult == .success else {
            throw WindowEngineError.unableToSetWindowFrame
        }
    }

    private func cgPointAttribute(_ attribute: String, for window: AXUIElement) throws -> CGPoint {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(window, attribute as CFString, &value)

        guard result == .success,
              let value,
              CFGetTypeID(value) == AXValueGetTypeID() else {
            throw WindowEngineError.invalidAccessibilityValue
        }

        let axValue = unsafeDowncast(value, to: AXValue.self)
        var point = CGPoint.zero
        guard AXValueGetValue(axValue, .cgPoint, &point) else {
            throw WindowEngineError.invalidAccessibilityValue
        }

        return point
    }

    private func cgSizeAttribute(_ attribute: String, for window: AXUIElement) throws -> CGSize {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(window, attribute as CFString, &value)

        guard result == .success,
              let value,
              CFGetTypeID(value) == AXValueGetTypeID() else {
            throw WindowEngineError.invalidAccessibilityValue
        }

        let axValue = unsafeDowncast(value, to: AXValue.self)
        var size = CGSize.zero
        guard AXValueGetValue(axValue, .cgSize, &size) else {
            throw WindowEngineError.invalidAccessibilityValue
        }

        return size
    }
}
