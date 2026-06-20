import AppKit
import Foundation
import OpenSnapCore
import Testing
@testable import OpenSnap

@MainActor
struct GlobalHotkeyServiceTests {
    private let screen = WindowFrame(x: 0, y: 25, width: 1_200, height: 775)

    @Test func defaultShortcutsRegisterOnlyShiftOneAndShiftTwo() {
        #expect(
            DefaultShortcuts.all == [
                KeyboardShortcut(keyCode: 18, modifiers: [.shift], command: .layout(.leftSixty)),
                KeyboardShortcut(keyCode: 19, modifiers: [.shift], command: .layout(.rightForty))
            ]
        )
    }

    @Test func shiftOneDispatchesLeftSixtyThroughMutationPipeline() throws {
        let initial = WindowFrame(x: 300, y: 100, width: 500, height: 500)
        let window = HotkeyWindow(frame: initial)
        let service = makeService(window: window)

        let result = try service.dispatch(.layout(.leftSixty))
        let expected = WindowFrame(x: 0, y: 25, width: 720, height: 775)

        #expect(result == success(for: expected))
        #expect(window.calls == mutationCalls(initialFrame: initial, requestedFrame: expected))
    }

    @Test func shiftTwoDispatchesRightFortyThroughMutationPipeline() throws {
        let initial = WindowFrame(x: 100, y: 100, width: 700, height: 500)
        let window = HotkeyWindow(frame: initial)
        let service = makeService(window: window)

        let result = try service.dispatch(.layout(.rightForty))
        let expected = WindowFrame(x: 720, y: 25, width: 480, height: 775)

        #expect(result == success(for: expected))
        #expect(window.calls == mutationCalls(initialFrame: initial, requestedFrame: expected))
    }

    @Test func constrainedReadBackIsReturnedWithoutTranslation() throws {
        let constrained = WindowFrame(x: 0, y: 25, width: 680, height: 740)
        let window = HotkeyWindow(
            frame: WindowFrame(x: 200, y: 100, width: 500, height: 500),
            frameAfterMutation: constrained
        )
        let service = makeService(window: window)
        let requested = WindowFrame(x: 0, y: 25, width: 720, height: 775)

        let result = try service.dispatch(.layout(.leftSixty))

        #expect(
            result == .constrained(
                WindowMutationVerification(
                    requestedFrame: requested,
                    observedFrame: constrained,
                    tolerance: WindowMutationPipeline.defaultTolerance
                )
            )
        )
    }

    @Test func mutationFailureIsReturnedWithoutTranslation() throws {
        let window = HotkeyWindow(sizeError: HotkeyWindowError.denied)
        let service = makeService(window: window)
        let requested = WindowFrame(x: 0, y: 25, width: 720, height: 775)

        let result = try service.dispatch(.layout(.leftSixty))

        #expect(
            result == .failure(
                WindowMutationFailure(
                    requestedFrame: requested,
                    observedFrame: window.initialFrame,
                    stage: .resize,
                    reason: .systemError(.other(description: "Mutation denied"))
                )
            )
        )
    }

    @Test func unsupportedCommandStopsBeforeWindowResolution() {
        let resolver = HotkeyMouseResolver(window: HotkeyWindow())
        let service = makeService(resolver: resolver)

        #expect(throws: GlobalHotkeyError.unsupportedCommand) {
            _ = try service.dispatch(.layout(.maximize))
        }
        #expect(resolver.callCount == 0)
    }

    @Test func missingScreenStopsBeforeMutation() {
        let window = HotkeyWindow()
        let service = makeService(window: window, frames: [])

        do {
            _ = try service.dispatch(.layout(.leftSixty))
            Issue.record("Expected screen resolution to fail")
        } catch WindowEngineError.screenUnavailable {
            // Expected.
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
        #expect(window.calls == [.readFrame(window.initialFrame)])
    }

    @Test func monitorDispatchReportsTypedResult() throws {
        let monitor = HotkeyMonitor()
        let window = HotkeyWindow()
        var receivedResult: Result<WindowMutationResult, Error>?
        let service = makeService(window: window, monitor: monitor) { receivedResult = $0 }

        service.start()
        monitor.send(.layout(.leftSixty))

        #expect(service.isRunning)
        #expect(try receivedResult?.get() == success(for: WindowFrame(x: 0, y: 25, width: 720, height: 775)))
    }

    private func makeService(
        window: HotkeyWindow,
        frames: [WindowFrame]? = nil,
        monitor: HotkeyMonitor = HotkeyMonitor(),
        resultHandler: @escaping GlobalHotkeyService.ResultHandler = { _ in }
    ) -> GlobalHotkeyService {
        makeService(
            resolver: HotkeyMouseResolver(window: window),
            frames: frames,
            monitor: monitor,
            resultHandler: resultHandler
        )
    }

    private func makeService(
        resolver: HotkeyMouseResolver,
        frames: [WindowFrame]? = nil,
        monitor: HotkeyMonitor = HotkeyMonitor(),
        resultHandler: @escaping GlobalHotkeyService.ResultHandler = { _ in }
    ) -> GlobalHotkeyService {
        GlobalHotkeyService(
            mouseWindowResolver: resolver,
            screenFrameProvider: HotkeyScreenProvider(frames: frames ?? [screen]),
            monitorFactory: { handler in
                monitor.handler = handler
                return monitor
            },
            resultHandler: resultHandler
        )
    }

    private func success(for frame: WindowFrame) -> WindowMutationResult {
        .success(
            WindowMutationVerification(
                requestedFrame: frame,
                observedFrame: frame,
                tolerance: WindowMutationPipeline.defaultTolerance
            )
        )
    }

    private func mutationCalls(
        initialFrame: WindowFrame,
        requestedFrame: WindowFrame
    ) -> [HotkeyWindow.Call] {
        [
            .readFrame(initialFrame),
            .setSize(WindowSize(width: requestedFrame.width, height: requestedFrame.height)),
            .setPosition(WindowPoint(x: requestedFrame.x, y: requestedFrame.y)),
            .readFrame(requestedFrame)
        ]
    }
}

@MainActor
private final class HotkeyMouseResolver: MouseWindowResolving {
    let window: any AccessibilityWindowAccessing
    private(set) var callCount = 0

    init(window: any AccessibilityWindowAccessing) {
        self.window = window
    }

    func windowUnderMouse() throws -> any AccessibilityWindowAccessing {
        callCount += 1
        return window
    }
}

private struct HotkeyScreenProvider: ScreenFrameProviding {
    let frames: [WindowFrame]
    func visibleScreenFrames() throws -> [WindowFrame] { frames }
}

@MainActor
private final class HotkeyMonitor: ShortcutMonitoring {
    var handler: ((ShortcutCommand) -> Void)?
    private(set) var isRunning = false

    func start() { isRunning = true }
    func stop() { isRunning = false }
    func send(_ command: ShortcutCommand) { handler?(command) }
}

@MainActor
private final class HotkeyWindow: AccessibilityWindowAccessing {
    enum Call: Equatable {
        case readFrame(WindowFrame)
        case setPosition(WindowPoint)
        case setSize(WindowSize)
    }

    let initialFrame: WindowFrame
    let frameAfterMutation: WindowFrame?
    let sizeError: Error?
    private var currentFrame: WindowFrame
    private var didMutate = false
    private(set) var calls: [Call] = []

    init(
        frame: WindowFrame = WindowFrame(x: 200, y: 100, width: 500, height: 500),
        frameAfterMutation: WindowFrame? = nil,
        sizeError: Error? = nil
    ) {
        initialFrame = frame
        currentFrame = frame
        self.frameAfterMutation = frameAfterMutation
        self.sizeError = sizeError
    }

    func frame() throws -> WindowFrame {
        let frame = didMutate ? frameAfterMutation ?? currentFrame : currentFrame
        calls.append(.readFrame(frame))
        return frame
    }

    func setPosition(_ origin: WindowPoint) throws {
        currentFrame = WindowFrame(
            x: origin.x,
            y: origin.y,
            width: currentFrame.width,
            height: currentFrame.height
        )
        didMutate = true
        calls.append(.setPosition(origin))
    }

    func setSize(_ size: WindowSize) throws {
        if let sizeError { throw sizeError }
        currentFrame = WindowFrame(
            x: currentFrame.x,
            y: currentFrame.y,
            width: size.width,
            height: size.height
        )
        didMutate = true
        calls.append(.setSize(size))
    }

    func canMove() throws -> Bool { true }
    func canResize() throws -> Bool { true }
}

private enum HotkeyWindowError: LocalizedError {
    case denied

    var errorDescription: String? { "Mutation denied" }
}
