import Foundation
import OpenSnapCore

@MainActor
protocol ShortcutMonitoring: AnyObject {
    var isRunning: Bool { get }
    func start()
    func stop()
}

extension ShortcutMonitor: ShortcutMonitoring {}

/// Resolves and snaps the window under the mouse when a registered global shortcut fires.
@MainActor
public final class GlobalHotkeyService {
    public typealias ResultHandler = (ShortcutCommand, Result<WindowMutationResult, Error>) -> Void

    private let mouseWindowResolver: any MouseWindowResolving
    private let screenFrameProvider: any ScreenFrameProviding
    private let screenFrameResolver: ScreenFrameResolver
    private let layoutCalculator: LayoutCalculator
    private let mutationPipeline: WindowMutationPipeline
    private let monitorFactory: (@escaping (ShortcutCommand) -> Void) -> any ShortcutMonitoring
    private let resultHandler: ResultHandler
    private var monitor: (any ShortcutMonitoring)?

    public var isRunning: Bool {
        monitor?.isRunning == true
    }

    public init(
        mouseWindowResolver: any MouseWindowResolving = MouseWindowResolver(),
        screenFrameProvider: any ScreenFrameProviding = AppKitScreenFrameProvider(),
        screenFrameResolver: ScreenFrameResolver = ScreenFrameResolver(),
        layoutCalculator: LayoutCalculator = LayoutCalculator(),
        resultHandler: @escaping ResultHandler = { _, _ in }
    ) {
        self.mouseWindowResolver = mouseWindowResolver
        self.screenFrameProvider = screenFrameProvider
        self.screenFrameResolver = screenFrameResolver
        self.layoutCalculator = layoutCalculator
        mutationPipeline = WindowMutationPipeline()
        monitorFactory = { handler in ShortcutMonitor(handler: handler) }
        self.resultHandler = resultHandler
    }

    init(
        mouseWindowResolver: any MouseWindowResolving,
        screenFrameProvider: any ScreenFrameProviding,
        screenFrameResolver: ScreenFrameResolver = ScreenFrameResolver(),
        layoutCalculator: LayoutCalculator = LayoutCalculator(),
        mutationPipeline: WindowMutationPipeline = WindowMutationPipeline(),
        monitorFactory: @escaping (@escaping (ShortcutCommand) -> Void) -> any ShortcutMonitoring,
        resultHandler: @escaping ResultHandler = { _, _ in }
    ) {
        self.mouseWindowResolver = mouseWindowResolver
        self.screenFrameProvider = screenFrameProvider
        self.screenFrameResolver = screenFrameResolver
        self.layoutCalculator = layoutCalculator
        self.mutationPipeline = mutationPipeline
        self.monitorFactory = monitorFactory
        self.resultHandler = resultHandler
    }

    public func start() {
        stop()
        let monitor = monitorFactory { [weak self] command in
            self?.handle(command)
        }
        monitor.start()
        self.monitor = monitor
    }

    public func stop() {
        monitor?.stop()
        monitor = nil
    }

    @discardableResult
    public func dispatch(_ command: ShortcutCommand) throws -> WindowMutationResult {
        let layoutCommand = try supportedLayoutCommand(for: command)
        let window = try mouseWindowResolver.windowUnderMouse()
        let currentFrame = try window.frame()
        let screenFrames = try screenFrameProvider.visibleScreenFrames()

        guard let screenFrame = screenFrameResolver.screenFrame(for: currentFrame, in: screenFrames) else {
            throw WindowEngineError.screenUnavailable
        }

        let requestedFrame = layoutCalculator.frame(for: layoutCommand, in: screenFrame)
        return mutationPipeline.apply(requestedFrame, to: window)
    }

    private func handle(_ command: ShortcutCommand) {
        do {
            resultHandler(command, .success(try dispatch(command)))
        } catch {
            resultHandler(command, .failure(error))
        }
    }

    private func supportedLayoutCommand(for command: ShortcutCommand) throws -> LayoutCommand {
        switch command {
        case .layout(.leftSixty):
            return .leftSixty
        case .layout(.rightForty):
            return .rightForty
        default:
            throw GlobalHotkeyError.unsupportedCommand
        }
    }
}

public enum GlobalHotkeyError: LocalizedError, Equatable, Sendable {
    case unsupportedCommand

    public var errorDescription: String? {
        "OpenSnap received an unsupported global hotkey command."
    }
}
