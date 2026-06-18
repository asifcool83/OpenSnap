import Foundation

/// Resolves the display frame that should be used for a window operation.
public struct ScreenFrameResolver: Sendable {
    public init() {}

    /// Chooses the display with the largest full-frame overlap with the window.
    ///
    /// Ties prefer the display containing the window center, then the nearest
    /// display center, then the first display in the supplied order. If the
    /// window does not overlap any display, the nearest display is returned.
    public func display(for windowFrame: WindowFrame, in displays: [DisplayGeometry]) -> DisplayGeometry? {
        guard let firstDisplay = displays.first else {
            return nil
        }

        let windowCenter = windowFrame.center
        var bestDisplay = firstDisplay
        var bestOverlap = firstDisplay.frame.intersectionArea(with: windowFrame)

        for display in displays.dropFirst() {
            let overlap = display.frame.intersectionArea(with: windowFrame)

            if isPreferred(
                display,
                overlap: overlap,
                over: bestDisplay,
                bestOverlap: bestOverlap,
                windowCenter: windowCenter
            ) {
                bestDisplay = display
                bestOverlap = overlap
            }
        }

        return bestDisplay
    }

    /// Compatibility API for callers that currently provide usable frames only.
    public func screenFrame(for windowFrame: WindowFrame, in screenFrames: [WindowFrame]) -> WindowFrame? {
        let displays = screenFrames.map {
            DisplayGeometry(frame: $0, visibleFrame: $0, scaleFactor: 1)
        }

        return display(for: windowFrame, in: displays)?.visibleFrame
    }

    private func isPreferred(
        _ candidate: DisplayGeometry,
        overlap: Double,
        over current: DisplayGeometry,
        bestOverlap: Double,
        windowCenter: WindowPoint
    ) -> Bool {
        if overlap != bestOverlap {
            return overlap > bestOverlap
        }

        let candidateContainsCenter = candidate.frame.contains(windowCenter)
        let currentContainsCenter = current.frame.contains(windowCenter)

        if candidateContainsCenter != currentContainsCenter {
            return candidateContainsCenter
        }

        return candidate.frame.center.squaredDistance(to: windowCenter)
            < current.frame.center.squaredDistance(to: windowCenter)
    }
}
