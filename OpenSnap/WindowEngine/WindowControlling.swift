import Foundation

/// Applies window operations to the user's currently focused window.
public protocol WindowControlling: AnyObject {
    func perform(_ operation: WindowOperation) throws
}
