import AppKit
import ApplicationServices
import Foundation
import OpenSnapCore

/// Controls the focused macOS window through the Accessibility API.
@MainActor
public final class AccessibilityWindowController: WindowControlling {
    private enum Attribute {
        static let focusedWindow = "AXFocusedWindow"
        static let mainWindow = "AXMainWindow"
        static let position = "AXPosition"
        static let size = "AXSize"
        static let title = "AXTitle"
        static let windowNumber = "AXWindowNumber"
    }

    private struct FocusedWindowContext {
        let application: FrontmostApplication
        let window: AXUIElement
    }

    private let frontmostApplicationProvider: FrontmostApplicationProviding
    private let screenFrameProvider: ScreenFrameProviding
    private let screenFrameResolver: ScreenFrameResolver
    private let layoutCalculator: LayoutCalculator

    public init(
        frontmostApplicationProvider: FrontmostApplicationProviding = AccessibilityFrontmostApplicationProvider(),
        screenFrameProvider: ScreenFrameProviding = AppKitScreenFrameProvider(),
        screenFrameResolver: ScreenFrameResolver = ScreenFrameResolver(),
        layoutCalculator: LayoutCalculator = LayoutCalculator()
    ) {
        self.frontmostApplicationProvider = frontmostApplicationProvider
        self.screenFrameProvider = screenFrameProvider
        self.screenFrameResolver = screenFrameResolver
        self.layoutCalculator = layoutCalculator
    }

    public func focusedWindowFrame() throws -> WindowFrame {
        #if DEBUG
        DeveloperDiagnosticsCenter.shared.recordOperation("Read Focused Window Frame")
        #endif

        try requireAccessibilityPermission()

        let context = try focusedWindowContext()
        let windowFrame = try frame(for: context.window)
        try updateDiagnostics(application: context.application, window: context.window, windowFrame: windowFrame)
        return windowFrame
    }

    public func moveFocusedWindow(to origin: WindowPoint) throws {
        #if DEBUG
        DeveloperDiagnosticsCenter.shared.recordOperation("Move Window")
        #endif

        try requireAccessibilityPermission()

        let context = try focusedWindowContext()
        try setPosition(origin, for: context.window)
        let windowFrame = try frame(for: context.window)
        try updateDiagnostics(application: context.application, window: context.window, windowFrame: windowFrame)
    }

    public func resizeFocusedWindow(to size: WindowSize) throws {
        #if DEBUG
        DeveloperDiagnosticsCenter.shared.recordOperation("Resize Window")
        #endif

        try requireAccessibilityPermission()
        try validate(size)

        let context = try focusedWindowContext()
        try setSize(size, for: context.window)
        let windowFrame = try frame(for: context.window)
        try updateDiagnostics(application: context.application, window: context.window, windowFrame: windowFrame)
    }

    public func setFocusedWindowFrame(_ frame: WindowFrame) throws {
        #if DEBUG
        DeveloperDiagnosticsCenter.shared.recordOperation("Set Window Frame")
        #endif

        try requireAccessibilityPermission()
        try validate(frame)

        let context = try focusedWindowContext()
        try setFrame(frame, for: context.window)
        let windowFrame = try self.frame(for: context.window)
        try updateDiagnostics(application: context.application, window: context.window, windowFrame: windowFrame)
    }

    public func perform(_ operation: WindowOperation) throws {
        #if DEBUG
        DeveloperDiagnosticsCenter.shared.recordOperation("WindowEngine \(String(describing: operation))")
        #endif

        try requireAccessibilityPermission()

        let context = try focusedWindowContext()

        switch operation {
        case let .layout(command):
            let currentFrame = try frame(for: context.window)
            let screenFrames = try screenFrameProvider.visibleScreenFrames()

            guard let screenFrame = screenFrameResolver.screenFrame(for: currentFrame, in: screenFrames) else {
                throw WindowEngineError.screenUnavailable
            }

            let newFrame = layoutCalculator.frame(for: command, in: screenFrame)
            try setFrame(newFrame, for: context.window)
            try updateDiagnostics(
                application: context.application,
                window: context.window,
                windowFrame: newFrame,
                visibleFrame: screenFrame
            )
        }
    }

    private func requireAccessibilityPermission() throws {
        guard AccessibilityPermission.isTrusted else {
            #if DEBUG
            DeveloperDiagnosticsCenter.shared.update { snapshot in
                snapshot.accessibilityPermissionStatus = "Missing"
            }
            DeveloperDiagnosticsCenter.shared.record(.warning, "Accessibility permission missing")
            #endif
            throw WindowEngineError.accessibilityPermissionRequired
        }

        #if DEBUG
        DeveloperDiagnosticsCenter.shared.update { snapshot in
            snapshot.accessibilityPermissionStatus = "Granted"
        }
        #endif
    }

    private func focusedWindowContext() throws -> FocusedWindowContext {
        let frontmostApplication = try frontmostApplicationProvider.frontmostApplication()
        let application = AXUIElementCreateApplication(frontmostApplication.processIdentifier)

        #if DEBUG
        DeveloperDiagnosticsCenter.shared.record(
            .info,
            "Focused \(frontmostApplication.localizedName ?? "Unknown Application")"
        )
        #endif

        do {
            return FocusedWindowContext(
                application: frontmostApplication,
                window: try windowAttribute(Attribute.focusedWindow, for: application)
            )
        } catch {
            #if DEBUG
            DeveloperDiagnosticsCenter.shared.record(.warning, "Unable to obtain AXFocusedWindow")
            #endif

            return FocusedWindowContext(
                application: frontmostApplication,
                window: try windowAttribute(Attribute.mainWindow, for: application)
            )
        }
    }

    private func windowAttribute(_ attribute: String, for element: AXUIElement) throws -> AXUIElement {
        let value = try copyAttribute(attribute, from: element)

        guard CFGetTypeID(value) == AXUIElementGetTypeID() else {
            throw WindowEngineError.focusedWindowUnavailable
        }

        return unsafeDowncast(value, to: AXUIElement.self)
    }

    private func frame(for window: AXUIElement) throws -> WindowFrame {
        let position = try pointAttribute(Attribute.position, for: window)
        let size = try sizeAttribute(Attribute.size, for: window)
        let frame = WindowFrame(
            x: position.x,
            y: position.y,
            width: size.width,
            height: size.height
        )

        try validate(frame)
        return frame
    }

    private func setFrame(_ frame: WindowFrame, for window: AXUIElement) throws {
        try validate(frame)
        try setSize(WindowSize(width: frame.width, height: frame.height), for: window)
        try setPosition(WindowPoint(x: frame.x, y: frame.y), for: window)
    }

    private func setPosition(_ origin: WindowPoint, for window: AXUIElement) throws {
        var point = CGPoint(x: origin.x, y: origin.y)

        guard let value = AXValueCreate(.cgPoint, &point) else {
            throw WindowEngineError.invalidAccessibilityValue
        }

        try setAttribute(Attribute.position, value: value, for: window)
    }

    private func setSize(_ size: WindowSize, for window: AXUIElement) throws {
        try validate(size)

        var cgSize = CGSize(width: size.width, height: size.height)

        guard let value = AXValueCreate(.cgSize, &cgSize) else {
            throw WindowEngineError.invalidAccessibilityValue
        }

        try setAttribute(Attribute.size, value: value, for: window)
    }

    private func pointAttribute(_ attribute: String, for element: AXUIElement) throws -> WindowPoint {
        let value = try accessibilityValueAttribute(attribute, for: element)
        var point = CGPoint.zero

        guard AXValueGetValue(value, .cgPoint, &point) else {
            throw WindowEngineError.invalidAccessibilityValue
        }

        return WindowPoint(x: point.x, y: point.y)
    }

    private func sizeAttribute(_ attribute: String, for element: AXUIElement) throws -> WindowSize {
        let value = try accessibilityValueAttribute(attribute, for: element)
        var size = CGSize.zero

        guard AXValueGetValue(value, .cgSize, &size) else {
            throw WindowEngineError.invalidAccessibilityValue
        }

        return WindowSize(width: size.width, height: size.height)
    }

    private func accessibilityValueAttribute(_ attribute: String, for element: AXUIElement) throws -> AXValue {
        let value = try copyAttribute(attribute, from: element)

        guard CFGetTypeID(value) == AXValueGetTypeID() else {
            throw WindowEngineError.invalidAccessibilityValue
        }

        return unsafeDowncast(value, to: AXValue.self)
    }

    private func copyAttribute(_ attribute: String, from element: AXUIElement) throws -> CFTypeRef {
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

    #if DEBUG
    private func optionalAttribute(_ attribute: String, from element: AXUIElement) -> CFTypeRef? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, attribute as CFString, &value)

        guard result == .success else {
            return nil
        }

        return value
    }

    private func optionalStringAttribute(_ attribute: String, from element: AXUIElement) -> String? {
        guard let value = optionalAttribute(attribute, from: element),
              CFGetTypeID(value) == CFStringGetTypeID() else {
            return nil
        }

        return value as? String
    }

    private func optionalIntegerAttribute(_ attribute: String, from element: AXUIElement) -> Int? {
        guard let value = optionalAttribute(attribute, from: element),
              CFGetTypeID(value) == CFNumberGetTypeID() else {
            return nil
        }

        return value as? Int
    }

    private func isAttributeSettable(_ attribute: String, for element: AXUIElement) -> String {
        var settable = DarwinBoolean(false)
        let result = AXUIElementIsAttributeSettable(element, attribute as CFString, &settable)

        guard result == .success else {
            return "Unknown"
        }

        return settable.boolValue ? "Yes" : "No"
    }

    private func updateDiagnostics(
        application: FrontmostApplication,
        window: AXUIElement,
        windowFrame: WindowFrame,
        visibleFrame providedVisibleFrame: WindowFrame? = nil
    ) throws {
        let screenFrames = try screenFrameProvider.visibleScreenFrames()
        let visibleFrame = providedVisibleFrame ?? screenFrameResolver.screenFrame(
            for: windowFrame,
            in: screenFrames
        )
        let screenIndex = visibleFrame.flatMap { selectedFrame in
            screenFrames.firstIndex(of: selectedFrame)
        }

        DeveloperDiagnosticsCenter.shared.update { snapshot in
            snapshot.frontmostApplication = application.localizedName ?? "Unknown"
            snapshot.bundleIdentifier = application.bundleIdentifier ?? "Unavailable"
            snapshot.windowTitle = optionalStringAttribute(Attribute.title, from: window) ?? "Unavailable"
            snapshot.windowID = optionalIntegerAttribute(Attribute.windowNumber, from: window).map(String.init) ?? "Unavailable"
            snapshot.windowFrame = DeveloperFormatting.frame(windowFrame)
            snapshot.visibleFrame = visibleFrame.map(DeveloperFormatting.frame) ?? "Unavailable"
            snapshot.screenBeingUsed = screenIndex.map { "Screen \($0 + 1)" } ?? "Unavailable"
            snapshot.screenDimensions = visibleFrame.map {
                DeveloperFormatting.size(width: $0.width, height: $0.height)
            } ?? "Unavailable"
            snapshot.accessibilityPermissionStatus = "Granted"
            snapshot.isWindowMovable = isAttributeSettable(Attribute.position, for: window)
            snapshot.isWindowResizable = isAttributeSettable(Attribute.size, for: window)
        }
    }
    #else
    private func updateDiagnostics(
        application: FrontmostApplication,
        window: AXUIElement,
        windowFrame: WindowFrame,
        visibleFrame providedVisibleFrame: WindowFrame? = nil
    ) throws {}
    #endif

    private func setAttribute(_ attribute: String, value: CFTypeRef, for element: AXUIElement) throws {
        let result = AXUIElementSetAttributeValue(element, attribute as CFString, value)

        guard result == .success else {
            throw WindowEngineError.accessibilityWriteFailed(
                attribute: attribute,
                code: Int(result.rawValue)
            )
        }
    }

    private func validate(_ frame: WindowFrame) throws {
        guard frame.x.isFinite,
              frame.y.isFinite,
              frame.width.isFinite,
              frame.height.isFinite,
              frame.width > 0,
              frame.height > 0 else {
            throw WindowEngineError.invalidWindowFrame(frame)
        }
    }

    private func validate(_ size: WindowSize) throws {
        guard size.width.isFinite,
              size.height.isFinite,
              size.width > 0,
              size.height > 0 else {
            throw WindowEngineError.invalidWindowFrame(
                WindowFrame(x: 0, y: 0, width: size.width, height: size.height)
            )
        }
    }
}
