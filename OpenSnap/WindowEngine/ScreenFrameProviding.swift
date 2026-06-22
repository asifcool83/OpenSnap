import AppKit
import Foundation
import OpenSnapCore

/// Provides visible screen frames in the top-left-origin coordinate space used by Accessibility.
public protocol ScreenFrameProviding {
    func visibleScreenFrames() throws -> [WindowFrame]
}

/// Reads visible screen frames from `NSScreen`.
public final class AppKitScreenFrameProvider: ScreenFrameProviding {
    public init() {}

    public func visibleScreenFrames() throws -> [WindowFrame] {
        let screens = NSScreen.screens

        guard let primaryScreen = screens.first else {
            throw WindowEngineError.screenUnavailable
        }

        let frames = screens.map {
            Self.accessibilityFrame(
                for: $0.visibleFrame,
                primaryScreenFrame: primaryScreen.frame
            )
        }

        return frames
    }

    /// Converts AppKit's bottom-left-origin coordinates to the Accessibility coordinate space.
    static func accessibilityFrame(for frame: CGRect, primaryScreenFrame: CGRect) -> WindowFrame {
        WindowFrame(
            x: frame.minX,
            y: primaryScreenFrame.maxY - frame.maxY,
            width: frame.width,
            height: frame.height
        )
    }
}
