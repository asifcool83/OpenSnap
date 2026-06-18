import Foundation
import OpenSnapCore

/// Applies and verifies one requested frame against one already-acquired window.
@MainActor
struct WindowMutationPipeline {
    static let defaultTolerance = 1.0

    let tolerance: Double

    init(tolerance: Double = Self.defaultTolerance) {
        precondition(tolerance.isFinite && tolerance >= 0, "Mutation tolerance must be finite and non-negative")
        self.tolerance = tolerance
    }

    func apply(
        _ requestedFrame: WindowFrame,
        to window: any AccessibilityWindowAccessing
    ) -> WindowMutationResult {
        guard isValid(requestedFrame) else {
            return .failure(
                WindowMutationFailure(
                    requestedFrame: requestedFrame,
                    stage: .validation,
                    reason: .invalidFrame
                )
            )
        }

        do {
            try window.setSize(
                WindowSize(width: requestedFrame.width, height: requestedFrame.height)
            )
        } catch {
            return failure(
                for: requestedFrame,
                stage: .resize,
                error: error,
                observedFrame: try? window.frame()
            )
        }

        do {
            try window.setPosition(
                WindowPoint(x: requestedFrame.x, y: requestedFrame.y)
            )
        } catch {
            return failure(
                for: requestedFrame,
                stage: .position,
                error: error,
                observedFrame: try? window.frame()
            )
        }

        let observedFrame: WindowFrame

        do {
            observedFrame = try window.frame()
        } catch {
            return failure(for: requestedFrame, stage: .readBack, error: error)
        }

        guard isValid(observedFrame) else {
            return .failure(
                WindowMutationFailure(
                    requestedFrame: requestedFrame,
                    observedFrame: observedFrame,
                    stage: .readBack,
                    reason: .invalidFrame
                )
            )
        }

        let verification = WindowMutationVerification(
            requestedFrame: requestedFrame,
            observedFrame: observedFrame,
            tolerance: tolerance
        )

        return matches(requestedFrame, observedFrame) ? .success(verification) : .constrained(verification)
    }

    private func matches(_ requestedFrame: WindowFrame, _ observedFrame: WindowFrame) -> Bool {
        abs(requestedFrame.x - observedFrame.x) <= tolerance
            && abs(requestedFrame.y - observedFrame.y) <= tolerance
            && abs(requestedFrame.width - observedFrame.width) <= tolerance
            && abs(requestedFrame.height - observedFrame.height) <= tolerance
    }

    private func isValid(_ frame: WindowFrame) -> Bool {
        frame.x.isFinite
            && frame.y.isFinite
            && frame.width.isFinite
            && frame.height.isFinite
            && frame.width > 0
            && frame.height > 0
    }

    private func failure(
        for requestedFrame: WindowFrame,
        stage: WindowMutationStage,
        error: Error,
        observedFrame: WindowFrame? = nil
    ) -> WindowMutationResult {
        .failure(
            WindowMutationFailure(
                requestedFrame: requestedFrame,
                observedFrame: observedFrame,
                stage: stage,
                reason: .systemError(systemError(from: error))
            )
        )
    }

    private func systemError(from error: Error) -> WindowMutationSystemError {
        guard let windowEngineError = error as? WindowEngineError else {
            return .other(description: error.localizedDescription)
        }

        switch windowEngineError {
        case .invalidAccessibilityValue:
            return .invalidAccessibilityValue
        case let .accessibilityReadFailed(attribute, code):
            return .accessibilityReadFailed(attribute: attribute, code: code)
        case let .accessibilityWriteFailed(attribute, code):
            return .accessibilityWriteFailed(attribute: attribute, code: code)
        default:
            return .other(description: windowEngineError.localizedDescription)
        }
    }
}
