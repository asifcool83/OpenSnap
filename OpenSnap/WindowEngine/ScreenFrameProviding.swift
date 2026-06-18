import AppKit
import Foundation
import OpenSnapCore

/// Provides visible screen frames in the same coordinate space used by AppKit window placement.
public protocol ScreenFrameProviding {
    func visibleScreenFrames() throws -> [WindowFrame]
}

/// Reads visible screen frames from `NSScreen`.
public final class AppKitScreenFrameProvider: ScreenFrameProviding {
    public init() {}

    public func visibleScreenFrames() throws -> [WindowFrame] {
        let frames = NSScreen.screens.map(\.visibleFrame).map { frame in
            WindowFrame(
                x: frame.origin.x,
                y: frame.origin.y,
                width: frame.width,
                height: frame.height
            )
        }

        guard !frames.isEmpty else {
            throw WindowEngineError.screenUnavailable
        }

        return frames
    }
}
