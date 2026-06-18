import Foundation

/// A single width step in the Smart Snap cycle.
public struct SmartSnapStep: Equatable, Sendable {
    public let ratio: Double

    public init(ratio: Double) {
        self.ratio = ratio
    }

    public static let sixtyPercent = SmartSnapStep(ratio: 0.60)
    public static let half = SmartSnapStep(ratio: 0.50)
    public static let third = SmartSnapStep(ratio: 1.0 / 3.0)
    public static let quarter = SmartSnapStep(ratio: 0.25)

    public static let defaultCycle: [SmartSnapStep] = [
        .sixtyPercent,
        .half,
        .third,
        .quarter
    ]
}
