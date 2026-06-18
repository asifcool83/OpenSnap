import Foundation
import OpenSnapCore

/// Applies window operations to the user's currently focused window.
@MainActor
public protocol WindowControlling: AnyObject {
    func focusedWindowFrame() throws -> WindowFrame
    func moveFocusedWindow(to origin: WindowPoint) throws
    func resizeFocusedWindow(to size: WindowSize) throws
    @discardableResult
    func setFocusedWindowFrame(_ frame: WindowFrame) throws -> WindowMutationResult
    @discardableResult
    func perform(_ operation: WindowOperation) throws -> WindowMutationResult
}
