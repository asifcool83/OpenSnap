import Foundation
import OpenSnapCore
import Testing
@testable import OpenSnap

@MainActor
struct AccessibilityWindowControllerTests {
    private let application = FrontmostApplication(
        processIdentifier: 42,
        localizedName: "Test Application",
        bundleIdentifier: "org.opensnap.test"
    )

    @Test func missingPermissionStopsBeforeTargetAcquisition() throws {
        let permission = PermissionProvider(isTrusted: false)
        let frontmostApplicationProvider = FrontmostApplicationProvider(application: application)
        let focusedWindowProvider = FocusedWindowProvider(window: WindowAdapter())
        let controller = makeController(
            permission: permission,
            frontmostApplicationProvider: frontmostApplicationProvider,
            focusedWindowProvider: focusedWindowProvider
        )

        do {
            _ = try controller.focusedWindowFrame()
            Issue.record("Expected Accessibility permission to be required")
        } catch WindowEngineError.accessibilityPermissionRequired {
            // Expected.
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        #expect(frontmostApplicationProvider.callCount == 0)
        #expect(focusedWindowProvider.requestedApplications.isEmpty)
    }

    @Test func focusedWindowFrameUsesInjectedTargetAndAdapter() throws {
        let expectedFrame = WindowFrame(x: 100, y: 80, width: 900, height: 700)
        let window = WindowAdapter(frame: expectedFrame)
        let focusedWindowProvider = FocusedWindowProvider(window: window)
        let controller = makeController(focusedWindowProvider: focusedWindowProvider)

        let frame = try controller.focusedWindowFrame()

        #expect(frame == expectedFrame)
        #expect(focusedWindowProvider.requestedApplications == [application])
        #expect(window.calls == [.readFrame])
    }

    @Test func focusedWindowAcquisitionFailurePropagatesWithoutWindowAccess() {
        let expectedError = FocusedWindowAcquisitionError(
            focusedWindowFailure: .missingValue,
            mainWindowFailure: .invalidElement
        )
        let controller = makeController(
            focusedWindowProvider: FocusedWindowProvider(error: expectedError)
        )

        do {
            _ = try controller.focusedWindowFrame()
            Issue.record("Expected focused-window acquisition to fail")
        } catch let error as FocusedWindowAcquisitionError {
            #expect(error == expectedError)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func movingWindowPreservesMutationThenReadOrder() throws {
        let window = WindowAdapter()
        let controller = makeController(focusedWindowProvider: FocusedWindowProvider(window: window))
        let origin = WindowPoint(x: 240, y: 120)

        try controller.moveFocusedWindow(to: origin)

        #expect(window.calls == [.setPosition(origin), .readFrame])
    }

    @Test func resizingWindowValidatesBeforeTargetAcquisition() throws {
        let focusedWindowProvider = FocusedWindowProvider(window: WindowAdapter())
        let controller = makeController(focusedWindowProvider: focusedWindowProvider)

        do {
            try controller.resizeFocusedWindow(to: WindowSize(width: 0, height: 500))
            Issue.record("Expected an invalid frame error")
        } catch WindowEngineError.invalidWindowFrame {
            // Expected.
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        #expect(focusedWindowProvider.requestedApplications.isEmpty)
    }

    @Test func settingFramePreservesSizePositionThenReadOrder() throws {
        let window = WindowAdapter()
        let controller = makeController(focusedWindowProvider: FocusedWindowProvider(window: window))
        let frame = WindowFrame(x: 120, y: 60, width: 840, height: 640)

        try controller.setFocusedWindowFrame(frame)

        #expect(
            window.calls == [
                .setSize(WindowSize(width: frame.width, height: frame.height)),
                .setPosition(WindowPoint(x: frame.x, y: frame.y)),
                .readFrame
            ]
        )
    }

    @Test func layoutOperationCalculatesAndAppliesFrameThroughAdapter() throws {
        let window = WindowAdapter(frame: WindowFrame(x: 200, y: 100, width: 600, height: 500))
        let controller = makeController(focusedWindowProvider: FocusedWindowProvider(window: window))

        try controller.perform(.layout(.leftSixty))

        #expect(
            window.calls == [
                .readFrame,
                .setSize(WindowSize(width: 720, height: 775)),
                .setPosition(WindowPoint(x: 0, y: 25))
            ]
        )
    }

    private func makeController(
        permission: PermissionProvider = PermissionProvider(isTrusted: true),
        frontmostApplicationProvider: FrontmostApplicationProvider? = nil,
        focusedWindowProvider: FocusedWindowProvider,
        screenFrameProvider: ScreenFrameProvider = ScreenFrameProvider(
            frames: [WindowFrame(x: 0, y: 25, width: 1_200, height: 775)]
        )
    ) -> AccessibilityWindowController {
        AccessibilityWindowController(
            permissionProvider: permission,
            frontmostApplicationProvider: frontmostApplicationProvider
                ?? FrontmostApplicationProvider(application: application),
            focusedWindowProvider: focusedWindowProvider,
            screenFrameProvider: screenFrameProvider
        )
    }
}

private struct PermissionProvider: AccessibilityPermissionProviding {
    let isTrusted: Bool

    func requestIfNeeded() -> Bool {
        isTrusted
    }
}

private final class FrontmostApplicationProvider: FrontmostApplicationProviding {
    let application: FrontmostApplication
    private(set) var callCount = 0

    init(application: FrontmostApplication) {
        self.application = application
    }

    func frontmostApplication() throws -> FrontmostApplication {
        callCount += 1
        return application
    }
}

private final class FocusedWindowProvider: FocusedWindowProviding {
    let result: Result<any AccessibilityWindowAccessing, FocusedWindowAcquisitionError>
    private(set) var requestedApplications: [FrontmostApplication] = []

    init(window: any AccessibilityWindowAccessing) {
        result = .success(window)
    }

    init(error: FocusedWindowAcquisitionError) {
        result = .failure(error)
    }

    func focusedWindow(
        for application: FrontmostApplication
    ) throws(FocusedWindowAcquisitionError) -> any AccessibilityWindowAccessing {
        requestedApplications.append(application)
        return try result.get()
    }
}

private final class WindowAdapter: AccessibilityWindowAccessing {
    enum Call: Equatable {
        case readFrame
        case setPosition(WindowPoint)
        case setSize(WindowSize)
    }

    var currentFrame: WindowFrame
    private(set) var calls: [Call] = []

    init(frame: WindowFrame = WindowFrame(x: 100, y: 80, width: 900, height: 700)) {
        currentFrame = frame
    }

    func frame() throws -> WindowFrame {
        calls.append(.readFrame)
        return currentFrame
    }

    func setPosition(_ origin: WindowPoint) throws {
        calls.append(.setPosition(origin))
        currentFrame = WindowFrame(
            x: origin.x,
            y: origin.y,
            width: currentFrame.width,
            height: currentFrame.height
        )
    }

    func setSize(_ size: WindowSize) throws {
        calls.append(.setSize(size))
        currentFrame = WindowFrame(
            x: currentFrame.x,
            y: currentFrame.y,
            width: size.width,
            height: size.height
        )
    }
}

private struct ScreenFrameProvider: ScreenFrameProviding {
    let frames: [WindowFrame]

    func visibleScreenFrames() throws -> [WindowFrame] {
        frames
    }
}
