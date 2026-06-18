import AppKit
import ApplicationServices
import Foundation

/// A lightweight description of the frontmost application.
public struct FrontmostApplication: Equatable, Sendable {
    public let processIdentifier: pid_t
    public let localizedName: String?
    public let bundleIdentifier: String?

    public init(processIdentifier: pid_t, localizedName: String?, bundleIdentifier: String?) {
        self.processIdentifier = processIdentifier
        self.localizedName = localizedName
        self.bundleIdentifier = bundleIdentifier
    }
}

/// Provides the application that currently owns keyboard focus.
public protocol FrontmostApplicationProviding {
    func frontmostApplication() throws -> FrontmostApplication
}

/// Reads the frontmost application from the current workspace.
public final class WorkspaceFrontmostApplicationProvider: FrontmostApplicationProviding {
    public init() {}

    public func frontmostApplication() throws -> FrontmostApplication {
        guard let application = NSWorkspace.shared.frontmostApplication else {
            throw WindowEngineError.frontmostApplicationUnavailable
        }

        return FrontmostApplication(
            processIdentifier: application.processIdentifier,
            localizedName: application.localizedName,
            bundleIdentifier: application.bundleIdentifier
        )
    }
}

/// Reads the focused application from Accessibility, falling back to `NSWorkspace`.
public final class AccessibilityFrontmostApplicationProvider: FrontmostApplicationProviding {
    private enum Attribute {
        static let focusedApplication = "AXFocusedApplication"
    }

    private let fallbackProvider: FrontmostApplicationProviding

    public init(fallbackProvider: FrontmostApplicationProviding = WorkspaceFrontmostApplicationProvider()) {
        self.fallbackProvider = fallbackProvider
    }

    public func frontmostApplication() throws -> FrontmostApplication {
        do {
            let systemWideElement = AXUIElementCreateSystemWide()
            let applicationElement = try focusedApplicationElement(from: systemWideElement)
            var processIdentifier: pid_t = 0
            let pidResult = AXUIElementGetPid(applicationElement, &processIdentifier)

            guard pidResult == .success, processIdentifier > 0 else {
                throw WindowEngineError.accessibilityReadFailed(
                    attribute: "pid",
                    code: Int(pidResult.rawValue)
                )
            }

            let runningApplication = NSRunningApplication(processIdentifier: processIdentifier)

            return FrontmostApplication(
                processIdentifier: processIdentifier,
                localizedName: runningApplication?.localizedName,
                bundleIdentifier: runningApplication?.bundleIdentifier
            )
        } catch {
            return try fallbackProvider.frontmostApplication()
        }
    }

    private func focusedApplicationElement(from element: AXUIElement) throws -> AXUIElement {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(
            element,
            Attribute.focusedApplication as CFString,
            &value
        )

        guard result == .success, let value else {
            throw WindowEngineError.accessibilityReadFailed(
                attribute: Attribute.focusedApplication,
                code: Int(result.rawValue)
            )
        }

        guard CFGetTypeID(value) == AXUIElementGetTypeID() else {
            throw WindowEngineError.frontmostApplicationUnavailable
        }

        return unsafeDowncast(value, to: AXUIElement.self)
    }
}
