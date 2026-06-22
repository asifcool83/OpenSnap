import Foundation
import OpenSnapCore

/// The verified outcome of applying a requested frame to one acquired window.
public enum WindowMutationResult: Equatable, Sendable {
    case success(WindowMutationVerification)
    case constrained(WindowMutationVerification)
    case failure(WindowMutationFailure)

    public var requestedFrame: WindowFrame {
        switch self {
        case let .success(verification), let .constrained(verification):
            return verification.requestedFrame
        case let .failure(failure):
            return failure.requestedFrame
        }
    }

    public var observedFrame: WindowFrame? {
        switch self {
        case let .success(verification), let .constrained(verification):
            return verification.observedFrame
        case let .failure(failure):
            return failure.observedFrame
        }
    }
}

/// The requested and observed frames used to classify a completed mutation.
public struct WindowMutationVerification: Equatable, Sendable {
    public let requestedFrame: WindowFrame
    public let observedFrame: WindowFrame
    public let tolerance: Double

    public init(requestedFrame: WindowFrame, observedFrame: WindowFrame, tolerance: Double) {
        self.requestedFrame = requestedFrame
        self.observedFrame = observedFrame
        self.tolerance = tolerance
    }
}

/// The stage at which a mutation could no longer produce a reliable outcome.
public enum WindowMutationStage: String, Equatable, Sendable {
    case validation
    case resize
    case position
    case readBack
}

/// A typed reason why a mutation stage failed.
public enum WindowMutationFailureReason: Equatable, Sendable {
    case invalidFrame
    case systemError(WindowMutationSystemError)
}

/// System error context preserved for mutation diagnostics.
public enum WindowMutationSystemError: Equatable, Sendable {
    case invalidAccessibilityValue
    case accessibilityReadFailed(attribute: String, code: Int)
    case accessibilityWriteFailed(attribute: String, code: Int)
    case other(description: String)
}

/// A failed mutation with enough context for diagnostics and recovery decisions.
public struct WindowMutationFailure: LocalizedError, Equatable, Sendable {
    public let requestedFrame: WindowFrame
    public let observedFrame: WindowFrame?
    public let stage: WindowMutationStage
    public let reason: WindowMutationFailureReason

    public init(
        requestedFrame: WindowFrame,
        observedFrame: WindowFrame? = nil,
        stage: WindowMutationStage,
        reason: WindowMutationFailureReason
    ) {
        self.requestedFrame = requestedFrame
        self.observedFrame = observedFrame
        self.stage = stage
        self.reason = reason
    }

    public var errorDescription: String? {
        switch stage {
        case .validation:
            return "OpenSnap received an invalid window frame."
        case .resize:
            return "OpenSnap could not resize the window."
        case .position:
            return "OpenSnap could not move the window."
        case .readBack:
            return "OpenSnap could not verify the window frame."
        }
    }
}
