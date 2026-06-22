import ApplicationServices
import Foundation

public enum MouseWindowResolutionError: LocalizedError, Equatable, Sendable {
    case cursorLocationUnavailable
    case hitTestFailed(code: Int)
    case windowUnavailable
    case windowNotMovable
    case windowNotResizable

    public var errorDescription: String? {
        switch self {
        case .cursorLocationUnavailable:
            return "OpenSnap could not determine the mouse location."
        case let .hitTestFailed(code):
            return "OpenSnap could not inspect the window under the mouse. AXError \(code)."
        case .windowUnavailable:
            return "OpenSnap could not find a window under the mouse."
        case .windowNotMovable:
            return "The window under the mouse cannot be moved."
        case .windowNotResizable:
            return "The window under the mouse cannot be resized."
        }
    }
}

@MainActor
public protocol MouseWindowResolving {
    func windowUnderMouse() throws -> any AccessibilityWindowAccessing
}

@MainActor
public final class MouseWindowResolver: MouseWindowResolving {
    private let targetReader: any MouseWindowTargetReading

    public convenience init() {
        self.init(targetReader: AXMouseWindowTargetReader())
    }

    init(targetReader: any MouseWindowTargetReading) {
        self.targetReader = targetReader
    }

    public func windowUnderMouse() throws -> any AccessibilityWindowAccessing {
        let window = try targetReader.windowUnderMouse()

        guard try window.canMove() else {
            throw MouseWindowResolutionError.windowNotMovable
        }

        guard try window.canResize() else {
            throw MouseWindowResolutionError.windowNotResizable
        }

        return window
    }
}

@MainActor
protocol MouseWindowTargetReading {
    func windowUnderMouse() throws -> any AccessibilityWindowAccessing
}

@MainActor
struct AXMouseWindowTargetReader: MouseWindowTargetReading {
    private let cursorLocation: () -> CGPoint?

    init(cursorLocation: @escaping () -> CGPoint? = { CGEvent(source: nil)?.location }) {
        self.cursorLocation = cursorLocation
    }

    func windowUnderMouse() throws -> any AccessibilityWindowAccessing {
        guard let location = cursorLocation() else {
            throw MouseWindowResolutionError.cursorLocationUnavailable
        }
        let systemWideElement = AXUIElementCreateSystemWide()
        var hitElement: AXUIElement?
        let result = AXUIElementCopyElementAtPosition(
            systemWideElement,
            Float(location.x),
            Float(location.y),
            &hitElement
        )

        guard result == .success else {
            throw MouseWindowResolutionError.hitTestFailed(code: Int(result.rawValue))
        }

        guard let hitElement, let windowElement = windowAncestor(startingAt: hitElement) else {
            throw MouseWindowResolutionError.windowUnavailable
        }

        return AXAccessibilityWindow(element: windowElement)
    }

    private func windowAncestor(startingAt element: AXUIElement) -> AXUIElement? {
        var current = element

        for _ in 0..<64 {
            if stringAttribute(kAXRoleAttribute, from: current) == kAXWindowRole {
                return current
            }

            guard let parent = elementAttribute(kAXParentAttribute, from: current) else {
                return nil
            }

            current = parent
        }

        return nil
    }

    private func stringAttribute(_ attribute: String, from element: AXUIElement) -> String? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, attribute as CFString, &value)
        return result == .success ? value as? String : nil
    }

    private func elementAttribute(_ attribute: String, from element: AXUIElement) -> AXUIElement? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, attribute as CFString, &value)

        guard result == .success,
              let value,
              CFGetTypeID(value) == AXUIElementGetTypeID() else {
            return nil
        }

        return unsafeDowncast(value, to: AXUIElement.self)
    }
}
