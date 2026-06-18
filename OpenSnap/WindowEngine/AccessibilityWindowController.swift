import Foundation
import OpenSnapCore

/// Orchestrates focused-window operations through injected platform adapters.
@MainActor
public final class AccessibilityWindowController: WindowControlling {
    private struct FocusedWindowContext {
        let application: FrontmostApplication
        let window: any AccessibilityWindowAccessing
    }

    private let permissionProvider: AccessibilityPermissionProviding
    private let frontmostApplicationProvider: FrontmostApplicationProviding
    private let focusedWindowProvider: FocusedWindowProviding
    private let screenFrameProvider: ScreenFrameProviding
    private let screenFrameResolver: ScreenFrameResolver
    private let layoutCalculator: LayoutCalculator
    private let mutationPipeline = WindowMutationPipeline()

    public init(
        permissionProvider: AccessibilityPermissionProviding = SystemAccessibilityPermissionProvider(),
        frontmostApplicationProvider: FrontmostApplicationProviding = AccessibilityFrontmostApplicationProvider(),
        focusedWindowProvider: FocusedWindowProviding = AXFocusedWindowProvider(),
        screenFrameProvider: ScreenFrameProviding = AppKitScreenFrameProvider(),
        screenFrameResolver: ScreenFrameResolver = ScreenFrameResolver(),
        layoutCalculator: LayoutCalculator = LayoutCalculator()
    ) {
        self.permissionProvider = permissionProvider
        self.frontmostApplicationProvider = frontmostApplicationProvider
        self.focusedWindowProvider = focusedWindowProvider
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
        let windowFrame = try validatedFrame(for: context.window)
        try updateDiagnostics(application: context.application, window: context.window, windowFrame: windowFrame)
        return windowFrame
    }

    public func moveFocusedWindow(to origin: WindowPoint) throws {
        #if DEBUG
        DeveloperDiagnosticsCenter.shared.recordOperation("Move Window")
        #endif

        try requireAccessibilityPermission()

        let context = try focusedWindowContext()
        try context.window.setPosition(origin)
        let windowFrame = try validatedFrame(for: context.window)
        try updateDiagnostics(application: context.application, window: context.window, windowFrame: windowFrame)
    }

    public func resizeFocusedWindow(to size: WindowSize) throws {
        #if DEBUG
        DeveloperDiagnosticsCenter.shared.recordOperation("Resize Window")
        #endif

        try requireAccessibilityPermission()
        try validate(size)

        let context = try focusedWindowContext()
        try context.window.setSize(size)
        let windowFrame = try validatedFrame(for: context.window)
        try updateDiagnostics(application: context.application, window: context.window, windowFrame: windowFrame)
    }

    @discardableResult
    public func setFocusedWindowFrame(_ frame: WindowFrame) throws -> WindowMutationResult {
        #if DEBUG
        DeveloperDiagnosticsCenter.shared.recordOperation("Set Window Frame")
        #endif

        try requireAccessibilityPermission()

        do {
            try validate(frame)
        } catch {
            return .failure(
                WindowMutationFailure(
                    requestedFrame: frame,
                    stage: .validation,
                    reason: .invalidFrame
                )
            )
        }

        let context = try focusedWindowContext()
        let result = mutationPipeline.apply(frame, to: context.window)
        try? updateDiagnostics(for: result, context: context)
        return result
    }

    @discardableResult
    public func perform(_ operation: WindowOperation) throws -> WindowMutationResult {
        #if DEBUG
        DeveloperDiagnosticsCenter.shared.recordOperation("WindowEngine \(String(describing: operation))")
        #endif

        try requireAccessibilityPermission()

        let context = try focusedWindowContext()

        switch operation {
        case let .layout(command):
            let currentFrame = try validatedFrame(for: context.window)
            let screenFrames = try screenFrameProvider.visibleScreenFrames()

            guard let screenFrame = screenFrameResolver.screenFrame(for: currentFrame, in: screenFrames) else {
                throw WindowEngineError.screenUnavailable
            }

            let newFrame = layoutCalculator.frame(for: command, in: screenFrame)
            let result = mutationPipeline.apply(newFrame, to: context.window)
            try? updateDiagnostics(for: result, context: context, visibleFrame: screenFrame)
            return result
        }
    }

    private func requireAccessibilityPermission() throws {
        guard permissionProvider.isTrusted else {
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

        #if DEBUG
        DeveloperDiagnosticsCenter.shared.record(
            .info,
            "Focused \(frontmostApplication.localizedName ?? "Unknown Application")"
        )
        #endif

        return FocusedWindowContext(
            application: frontmostApplication,
            window: try focusedWindowProvider.focusedWindow(for: frontmostApplication)
        )
    }

    private func validatedFrame(for window: any AccessibilityWindowAccessing) throws -> WindowFrame {
        let frame = try window.frame()
        try validate(frame)
        return frame
    }

    private func updateDiagnostics(
        for result: WindowMutationResult,
        context: FocusedWindowContext,
        visibleFrame: WindowFrame? = nil
    ) throws {
        guard let observedFrame = result.observedFrame else {
            return
        }

        try updateDiagnostics(
            application: context.application,
            window: context.window,
            windowFrame: observedFrame,
            visibleFrame: visibleFrame
        )
    }

    #if DEBUG
    private func updateDiagnostics(
        application: FrontmostApplication,
        window: any AccessibilityWindowAccessing,
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
        let windowDiagnostics = window as? AccessibilityWindowDiagnosticsProviding

        DeveloperDiagnosticsCenter.shared.update { snapshot in
            snapshot.frontmostApplication = application.localizedName ?? "Unknown"
            snapshot.bundleIdentifier = application.bundleIdentifier ?? "Unavailable"
            snapshot.windowTitle = windowDiagnostics?.windowTitle ?? "Unavailable"
            snapshot.windowID = windowDiagnostics?.windowID.map(String.init) ?? "Unavailable"
            snapshot.windowFrame = DeveloperFormatting.frame(windowFrame)
            snapshot.visibleFrame = visibleFrame.map(DeveloperFormatting.frame) ?? "Unavailable"
            snapshot.screenBeingUsed = screenIndex.map { "Screen \($0 + 1)" } ?? "Unavailable"
            snapshot.screenDimensions = visibleFrame.map {
                DeveloperFormatting.size(width: $0.width, height: $0.height)
            } ?? "Unavailable"
            snapshot.accessibilityPermissionStatus = "Granted"
            snapshot.isWindowMovable = windowDiagnostics?.isMovable ?? "Unknown"
            snapshot.isWindowResizable = windowDiagnostics?.isResizable ?? "Unknown"
        }
    }
    #else
    private func updateDiagnostics(
        application: FrontmostApplication,
        window: any AccessibilityWindowAccessing,
        windowFrame: WindowFrame,
        visibleFrame providedVisibleFrame: WindowFrame? = nil
    ) throws {}
    #endif

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
