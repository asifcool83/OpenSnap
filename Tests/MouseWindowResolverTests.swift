import Foundation
import OpenSnapCore
import Testing
@testable import OpenSnap

@MainActor
struct MouseWindowResolverTests {
    @Test func returnsValidatedWindowAfterCheckingBothCapabilities() throws {
        let window = CapabilityWindow()
        let resolver = MouseWindowResolver(targetReader: MouseTargetReader(window: window))

        let resolved = try resolver.windowUnderMouse()

        #expect(resolved === window)
        #expect(window.capabilityReads == [.movable, .resizable])
    }

    @Test func rejectsImmovableWindowWithoutCheckingResize() {
        let window = CapabilityWindow(movable: false)
        let resolver = MouseWindowResolver(targetReader: MouseTargetReader(window: window))

        #expect(throws: MouseWindowResolutionError.windowNotMovable) {
            _ = try resolver.windowUnderMouse()
        }
        #expect(window.capabilityReads == [.movable])
    }

    @Test func rejectsNonResizableWindowAfterMoveValidation() {
        let window = CapabilityWindow(resizable: false)
        let resolver = MouseWindowResolver(targetReader: MouseTargetReader(window: window))

        #expect(throws: MouseWindowResolutionError.windowNotResizable) {
            _ = try resolver.windowUnderMouse()
        }
        #expect(window.capabilityReads == [.movable, .resizable])
    }

    @Test func targetFailurePropagatesWithoutCapabilityAccess() {
        let expected = MouseWindowResolutionError.hitTestFailed(code: -25204)
        let resolver = MouseWindowResolver(targetReader: MouseTargetReader(error: expected))

        #expect(throws: expected) {
            _ = try resolver.windowUnderMouse()
        }
    }

    @Test func capabilityReadFailurePropagates() {
        let expected = CapabilityError.unavailable
        let window = CapabilityWindow(moveError: expected)
        let resolver = MouseWindowResolver(targetReader: MouseTargetReader(window: window))

        #expect(throws: CapabilityError.unavailable) {
            _ = try resolver.windowUnderMouse()
        }
        #expect(window.capabilityReads == [.movable])
    }
}

@MainActor
private final class MouseTargetReader: MouseWindowTargetReading {
    let result: Result<any AccessibilityWindowAccessing, Error>

    init(window: any AccessibilityWindowAccessing) {
        result = .success(window)
    }

    init(error: Error) {
        result = .failure(error)
    }

    func windowUnderMouse() throws -> any AccessibilityWindowAccessing {
        try result.get()
    }
}

@MainActor
private final class CapabilityWindow: AccessibilityWindowAccessing {
    enum Capability: Equatable {
        case movable
        case resizable
    }

    let movable: Bool
    let resizable: Bool
    let moveError: Error?
    private(set) var capabilityReads: [Capability] = []

    init(movable: Bool = true, resizable: Bool = true, moveError: Error? = nil) {
        self.movable = movable
        self.resizable = resizable
        self.moveError = moveError
    }

    func frame() throws -> WindowFrame { WindowFrame(x: 0, y: 0, width: 100, height: 100) }
    func setPosition(_ origin: WindowPoint) throws {}
    func setSize(_ size: WindowSize) throws {}

    func canMove() throws -> Bool {
        capabilityReads.append(.movable)
        if let moveError { throw moveError }
        return movable
    }

    func canResize() throws -> Bool {
        capabilityReads.append(.resizable)
        return resizable
    }
}

private enum CapabilityError: Error, Equatable {
    case unavailable
}
