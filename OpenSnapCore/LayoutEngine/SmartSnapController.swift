import Foundation

/// Tracks repeated Smart Snap commands and returns the next width step.
public struct SmartSnapController: Sendable {
    private var lastSide: SmartSnapSide?
    private var currentIndex: Int?
    private let steps: [SmartSnapStep]

    public init(steps: [SmartSnapStep] = SmartSnapStep.defaultCycle) {
        self.steps = steps
    }

    public mutating func nextStep(for side: SmartSnapSide) -> SmartSnapStep {
        guard !steps.isEmpty else {
            return .half
        }

        let nextIndex: Int
        if lastSide == side, let currentIndex {
            nextIndex = (currentIndex + 1) % steps.count
        } else {
            nextIndex = 0
        }

        lastSide = side
        currentIndex = nextIndex
        return steps[nextIndex]
    }

    public mutating func reset() {
        lastSide = nil
        currentIndex = nil
    }
}
