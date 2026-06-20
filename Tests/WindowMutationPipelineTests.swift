import Foundation
import OpenSnapCore
import Testing
@testable import OpenSnap

@MainActor
struct WindowMutationPipelineTests {
    private let requestedFrame = WindowFrame(x: 100, y: 80, width: 900, height: 700)

    @Test func exactReadBackIsSuccess() {
        let window = MutationWindow(observedFrame: requestedFrame)
        let pipeline = WindowMutationPipeline()

        let result = pipeline.apply(requestedFrame, to: window)

        #expect(
            result == .success(
                WindowMutationVerification(
                    requestedFrame: requestedFrame,
                    observedFrame: requestedFrame,
                    tolerance: WindowMutationPipeline.defaultTolerance
                )
            )
        )
        #expect(window.calls == [.setSize, .setPosition, .readFrame])
    }

    @Test func readBackWithinToleranceIsSuccess() {
        let observedFrame = WindowFrame(x: 100.5, y: 79.5, width: 900.5, height: 699.5)
        let pipeline = WindowMutationPipeline(tolerance: 0.5)

        let result = pipeline.apply(requestedFrame, to: MutationWindow(observedFrame: observedFrame))

        #expect(
            result == .success(
                WindowMutationVerification(
                    requestedFrame: requestedFrame,
                    observedFrame: observedFrame,
                    tolerance: 0.5
                )
            )
        )
    }

    @Test func materiallyDifferentReadBackIsConstrained() {
        let observedFrame = WindowFrame(x: 100, y: 80, width: 820, height: 650)
        let pipeline = WindowMutationPipeline()

        let result = pipeline.apply(requestedFrame, to: MutationWindow(observedFrame: observedFrame))

        #expect(
            result == .constrained(
                WindowMutationVerification(
                    requestedFrame: requestedFrame,
                    observedFrame: observedFrame,
                    tolerance: WindowMutationPipeline.defaultTolerance
                )
            )
        )
    }

    @Test func invalidRequestFailsBeforeWriting() {
        let invalidFrame = WindowFrame(x: 0, y: 0, width: 0, height: 700)
        let window = MutationWindow(observedFrame: requestedFrame)

        let result = WindowMutationPipeline().apply(invalidFrame, to: window)

        #expect(
            result == .failure(
                WindowMutationFailure(
                    requestedFrame: invalidFrame,
                    stage: .validation,
                    reason: .invalidFrame
                )
            )
        )
        #expect(window.calls.isEmpty)
    }

    @Test func resizeAccessibilityErrorPreservesTypedContextAndStopsThePipeline() {
        let window = MutationWindow(
            observedFrame: requestedFrame,
            resizeError: WindowEngineError.accessibilityWriteFailed(attribute: "AXSize", code: -25205)
        )

        let result = WindowMutationPipeline().apply(requestedFrame, to: window)

        #expect(
            result == .failure(
                WindowMutationFailure(
                    requestedFrame: requestedFrame,
                    observedFrame: requestedFrame,
                    stage: .resize,
                    reason: .systemError(
                        .accessibilityWriteFailed(attribute: "AXSize", code: -25205)
                    )
                )
            )
        )
        #expect(window.calls == [.setSize, .readFrame])
    }

    @Test func positionErrorStopsBeforeReadBack() {
        let window = MutationWindow(
            observedFrame: requestedFrame,
            positionError: MutationTestError.denied
        )

        let result = WindowMutationPipeline().apply(requestedFrame, to: window)

        #expect(
            result == .failure(
                WindowMutationFailure(
                    requestedFrame: requestedFrame,
                    observedFrame: requestedFrame,
                    stage: .position,
                    reason: .systemError(.other(description: "Mutation denied"))
                )
            )
        )
        #expect(window.calls == [.setSize, .setPosition, .readFrame])
    }

    @Test func supplementaryReadFailureDoesNotReplaceWriteFailure() {
        let writeError = WindowEngineError.accessibilityWriteFailed(
            attribute: "AXPosition",
            code: -25205
        )
        let window = MutationWindow(
            observedFrame: requestedFrame,
            positionError: writeError,
            readError: MutationTestError.unavailable
        )

        let result = WindowMutationPipeline().apply(requestedFrame, to: window)

        #expect(
            result == .failure(
                WindowMutationFailure(
                    requestedFrame: requestedFrame,
                    stage: .position,
                    reason: .systemError(
                        .accessibilityWriteFailed(attribute: "AXPosition", code: -25205)
                    )
                )
            )
        )
        #expect(window.calls == [.setSize, .setPosition, .readFrame])
    }

    @Test func readBackErrorIsFailure() {
        let window = MutationWindow(
            observedFrame: requestedFrame,
            readError: MutationTestError.unavailable
        )

        let result = WindowMutationPipeline().apply(requestedFrame, to: window)

        #expect(
            result == .failure(
                WindowMutationFailure(
                    requestedFrame: requestedFrame,
                    stage: .readBack,
                    reason: .systemError(.other(description: "Frame unavailable"))
                )
            )
        )
        #expect(window.calls == [.setSize, .setPosition, .readFrame])
    }

    @Test func invalidReadBackIsFailureWithObservedFrame() {
        let invalidFrame = WindowFrame(x: 100, y: 80, width: .nan, height: 700)

        let result = WindowMutationPipeline().apply(
            requestedFrame,
            to: MutationWindow(observedFrame: invalidFrame)
        )

        guard case let .failure(failure) = result else {
            Issue.record("Expected invalid read-back to fail")
            return
        }

        #expect(failure.requestedFrame == requestedFrame)
        #expect(failure.observedFrame?.width.isNaN == true)
        #expect(failure.stage == .readBack)
        #expect(failure.reason == .invalidFrame)
    }
}

@MainActor
private final class MutationWindow: AccessibilityWindowAccessing {
    enum Call: Equatable {
        case setSize
        case setPosition
        case readFrame
    }

    let observedFrame: WindowFrame
    let resizeError: Error?
    let positionError: Error?
    let readError: Error?
    private(set) var calls: [Call] = []

    init(
        observedFrame: WindowFrame,
        resizeError: Error? = nil,
        positionError: Error? = nil,
        readError: Error? = nil
    ) {
        self.observedFrame = observedFrame
        self.resizeError = resizeError
        self.positionError = positionError
        self.readError = readError
    }

    func frame() throws -> WindowFrame {
        calls.append(.readFrame)

        if let readError {
            throw readError
        }

        return observedFrame
    }

    func setPosition(_ origin: WindowPoint) throws {
        calls.append(.setPosition)

        if let positionError {
            throw positionError
        }
    }

    func setSize(_ size: WindowSize) throws {
        calls.append(.setSize)

        if let resizeError {
            throw resizeError
        }
    }

    func canMove() throws -> Bool { true }
    func canResize() throws -> Bool { true }
}

private enum MutationTestError: LocalizedError {
    case denied
    case unavailable

    var errorDescription: String? {
        switch self {
        case .denied:
            return "Mutation denied"
        case .unavailable:
            return "Frame unavailable"
        }
    }
}
