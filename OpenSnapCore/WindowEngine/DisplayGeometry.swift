import Foundation

/// Platform-independent display geometry expressed in logical points.
public struct DisplayGeometry: Equatable, Sendable {
    /// The complete display bounds in the shared global coordinate space.
    public let frame: WindowFrame

    /// The area available to windows after system UI such as the Dock and menu bar.
    public let visibleFrame: WindowFrame

    /// The number of backing pixels represented by one logical point.
    public let scaleFactor: Double

    public init(frame: WindowFrame, visibleFrame: WindowFrame, scaleFactor: Double) {
        self.frame = frame
        self.visibleFrame = visibleFrame
        self.scaleFactor = scaleFactor
    }
}
