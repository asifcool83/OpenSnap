import OpenSnapCore
import Testing
@testable import OpenSnap

@MainActor
struct FocusedWindowAcquisitionTests {
    private let application = FrontmostApplication(
        processIdentifier: 42,
        localizedName: "Test Application",
        bundleIdentifier: "org.opensnap.test"
    )

    @Test func returnsFocusedWindowWithoutReadingMainWindow() throws {
        let focusedWindow = AcquisitionWindow()
        let reader = TargetReader(
            focusedWindowResult: .success(focusedWindow),
            mainWindowResult: .failure(.missingValue)
        )
        let provider = AXFocusedWindowProvider(targetReader: reader)

        let result = try provider.focusedWindow(for: application)

        #expect(result === focusedWindow)
        #expect(reader.requestedTargets == [.focusedWindow])
    }

    @Test func fallsBackToMainWindowWhenFocusedWindowIsUnavailable() throws {
        let mainWindow = AcquisitionWindow()
        let reader = TargetReader(
            focusedWindowResult: .failure(.attributeReadFailed(code: -25204)),
            mainWindowResult: .success(mainWindow)
        )
        let provider = AXFocusedWindowProvider(targetReader: reader)

        let result = try provider.focusedWindow(for: application)

        #expect(result === mainWindow)
        #expect(reader.requestedTargets == [.focusedWindow, .mainWindow])
    }

    @Test func reportsBothTypedFailuresWhenNoCandidateIsUsable() {
        let focusedFailure = FocusedWindowCandidateFailure.invalidElement
        let mainFailure = FocusedWindowCandidateFailure.attributeReadFailed(code: -25205)
        let reader = TargetReader(
            focusedWindowResult: .failure(focusedFailure),
            mainWindowResult: .failure(mainFailure)
        )
        let provider = AXFocusedWindowProvider(targetReader: reader)

        do {
            _ = try provider.focusedWindow(for: application)
            Issue.record("Expected focused-window acquisition to fail")
        } catch {
            #expect(
                error == FocusedWindowAcquisitionError(
                    focusedWindowFailure: focusedFailure,
                    mainWindowFailure: mainFailure
                )
            )
            #expect(error.errorDescription == "OpenSnap could not find the focused window.")
        }

        #expect(reader.requestedTargets == [.focusedWindow, .mainWindow])
    }
}

@MainActor
private final class TargetReader: FocusedWindowTargetReading {
    let focusedWindowResult: Result<any AccessibilityWindowAccessing, FocusedWindowCandidateFailure>
    let mainWindowResult: Result<any AccessibilityWindowAccessing, FocusedWindowCandidateFailure>
    private(set) var requestedTargets: [FocusedWindowTarget] = []

    init(
        focusedWindowResult: Result<any AccessibilityWindowAccessing, FocusedWindowCandidateFailure>,
        mainWindowResult: Result<any AccessibilityWindowAccessing, FocusedWindowCandidateFailure>
    ) {
        self.focusedWindowResult = focusedWindowResult
        self.mainWindowResult = mainWindowResult
    }

    func window(
        for application: FrontmostApplication,
        target: FocusedWindowTarget
    ) -> Result<any AccessibilityWindowAccessing, FocusedWindowCandidateFailure> {
        requestedTargets.append(target)

        switch target {
        case .focusedWindow:
            return focusedWindowResult
        case .mainWindow:
            return mainWindowResult
        }
    }
}

@MainActor
private final class AcquisitionWindow: AccessibilityWindowAccessing {
    func frame() throws -> WindowFrame {
        WindowFrame(x: 0, y: 0, width: 800, height: 600)
    }

    func setPosition(_ origin: WindowPoint) throws {}

    func setSize(_ size: WindowSize) throws {}
}
