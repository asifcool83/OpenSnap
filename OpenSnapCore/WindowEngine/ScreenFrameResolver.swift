import Foundation

/// Resolves the display frame that should be used for a window operation.
public struct ScreenFrameResolver: Sendable {
    public init() {}

    /// Chooses the screen with the largest overlap with the window.
    ///
    /// If the window does not overlap any screen, the resolver falls back to
    /// the screen whose center is nearest to the window center. This handles
    /// windows restored from stale coordinates after display changes.
    public func screenFrame(for windowFrame: WindowFrame, in screenFrames: [WindowFrame]) -> WindowFrame? {
        guard !screenFrames.isEmpty else {
            return nil
        }

        let intersectingScreen = screenFrames
            .map { screenFrame in
                (screenFrame: screenFrame, overlap: screenFrame.intersectionArea(with: windowFrame))
            }
            .filter { $0.overlap > 0 }
            .max { $0.overlap < $1.overlap }?
            .screenFrame

        if let intersectingScreen {
            return intersectingScreen
        }

        return screenFrames.min { left, right in
            left.center.squaredDistance(to: windowFrame.center) < right.center.squaredDistance(to: windowFrame.center)
        }
    }
}
