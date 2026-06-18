import ApplicationServices
import Foundation
import OpenSnapCore

/// A focused window that can be read and mutated without exposing AXUIElement.
@MainActor
public protocol AccessibilityWindowAccessing: AnyObject {
    func frame() throws -> WindowFrame
    func setPosition(_ origin: WindowPoint) throws
    func setSize(_ size: WindowSize) throws
}

/// Acquires the focused window for an application.
@MainActor
public protocol FocusedWindowProviding {
    func focusedWindow(for application: FrontmostApplication) throws -> any AccessibilityWindowAccessing
}

/// Acquires focused windows through macOS Accessibility.
@MainActor
public final class AXFocusedWindowProvider: FocusedWindowProviding {
    public init() {}

    public func focusedWindow(for application: FrontmostApplication) throws -> any AccessibilityWindowAccessing {
        let applicationElement = AXUIElementCreateApplication(application.processIdentifier)

        do {
            return AXAccessibilityWindow(
                element: try windowAttribute(AccessibilityAttribute.focusedWindow, from: applicationElement)
            )
        } catch {
            #if DEBUG
            DeveloperDiagnosticsCenter.shared.record(.warning, "Unable to obtain AXFocusedWindow")
            #endif

            return AXAccessibilityWindow(
                element: try windowAttribute(AccessibilityAttribute.mainWindow, from: applicationElement)
            )
        }
    }

    private func windowAttribute(_ attribute: String, from element: AXUIElement) throws -> AXUIElement {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, attribute as CFString, &value)

        guard result == .success, let value else {
            throw WindowEngineError.accessibilityReadFailed(
                attribute: attribute,
                code: Int(result.rawValue)
            )
        }

        guard CFGetTypeID(value) == AXUIElementGetTypeID() else {
            throw WindowEngineError.focusedWindowUnavailable
        }

        return unsafeDowncast(value, to: AXUIElement.self)
    }
}

private enum AccessibilityAttribute {
    static let focusedWindow = "AXFocusedWindow"
    static let mainWindow = "AXMainWindow"
    static let position = "AXPosition"
    static let size = "AXSize"
    static let title = "AXTitle"
    static let windowNumber = "AXWindowNumber"
}

@MainActor
private final class AXAccessibilityWindow: AccessibilityWindowAccessing {
    private let element: AXUIElement

    init(element: AXUIElement) {
        self.element = element
    }

    func frame() throws -> WindowFrame {
        let position = try pointAttribute(AccessibilityAttribute.position)
        let size = try sizeAttribute(AccessibilityAttribute.size)

        return WindowFrame(
            x: position.x,
            y: position.y,
            width: size.width,
            height: size.height
        )
    }

    func setPosition(_ origin: WindowPoint) throws {
        var point = CGPoint(x: origin.x, y: origin.y)

        guard let value = AXValueCreate(.cgPoint, &point) else {
            throw WindowEngineError.invalidAccessibilityValue
        }

        try setAttribute(AccessibilityAttribute.position, value: value)
    }

    func setSize(_ size: WindowSize) throws {
        var cgSize = CGSize(width: size.width, height: size.height)

        guard let value = AXValueCreate(.cgSize, &cgSize) else {
            throw WindowEngineError.invalidAccessibilityValue
        }

        try setAttribute(AccessibilityAttribute.size, value: value)
    }

    private func pointAttribute(_ attribute: String) throws -> WindowPoint {
        let value = try accessibilityValueAttribute(attribute)
        var point = CGPoint.zero

        guard AXValueGetValue(value, .cgPoint, &point) else {
            throw WindowEngineError.invalidAccessibilityValue
        }

        return WindowPoint(x: point.x, y: point.y)
    }

    private func sizeAttribute(_ attribute: String) throws -> WindowSize {
        let value = try accessibilityValueAttribute(attribute)
        var size = CGSize.zero

        guard AXValueGetValue(value, .cgSize, &size) else {
            throw WindowEngineError.invalidAccessibilityValue
        }

        return WindowSize(width: size.width, height: size.height)
    }

    private func accessibilityValueAttribute(_ attribute: String) throws -> AXValue {
        let value = try copyAttribute(attribute)

        guard CFGetTypeID(value) == AXValueGetTypeID() else {
            throw WindowEngineError.invalidAccessibilityValue
        }

        return unsafeDowncast(value, to: AXValue.self)
    }

    private func copyAttribute(_ attribute: String) throws -> CFTypeRef {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, attribute as CFString, &value)

        guard result == .success, let value else {
            throw WindowEngineError.accessibilityReadFailed(
                attribute: attribute,
                code: Int(result.rawValue)
            )
        }

        return value
    }

    private func setAttribute(_ attribute: String, value: CFTypeRef) throws {
        let result = AXUIElementSetAttributeValue(element, attribute as CFString, value)

        guard result == .success else {
            throw WindowEngineError.accessibilityWriteFailed(
                attribute: attribute,
                code: Int(result.rawValue)
            )
        }
    }
}

#if DEBUG
@MainActor
protocol AccessibilityWindowDiagnosticsProviding: AnyObject {
    var windowTitle: String? { get }
    var windowID: Int? { get }
    var isMovable: String { get }
    var isResizable: String { get }
}

extension AXAccessibilityWindow: AccessibilityWindowDiagnosticsProviding {
    var windowTitle: String? {
        optionalAttribute(AccessibilityAttribute.title) as? String
    }

    var windowID: Int? {
        optionalAttribute(AccessibilityAttribute.windowNumber) as? Int
    }

    var isMovable: String {
        isAttributeSettable(AccessibilityAttribute.position)
    }

    var isResizable: String {
        isAttributeSettable(AccessibilityAttribute.size)
    }

    private func optionalAttribute(_ attribute: String) -> CFTypeRef? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, attribute as CFString, &value)
        return result == .success ? value : nil
    }

    private func isAttributeSettable(_ attribute: String) -> String {
        var settable = DarwinBoolean(false)
        let result = AXUIElementIsAttributeSettable(element, attribute as CFString, &settable)

        guard result == .success else {
            return "Unknown"
        }

        return settable.boolValue ? "Yes" : "No"
    }
}
#endif
