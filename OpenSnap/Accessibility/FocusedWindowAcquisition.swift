import ApplicationServices
import Foundation

/// A typed reason why one Accessibility window candidate could not be used.
public enum FocusedWindowCandidateFailure: Error, Equatable, Sendable {
    case attributeReadFailed(code: Int)
    case missingValue
    case invalidElement
}

/// Reports both candidate failures when no usable focused window can be acquired.
public struct FocusedWindowAcquisitionError: LocalizedError, Equatable, Sendable {
    public let focusedWindowFailure: FocusedWindowCandidateFailure
    public let mainWindowFailure: FocusedWindowCandidateFailure

    public init(
        focusedWindowFailure: FocusedWindowCandidateFailure,
        mainWindowFailure: FocusedWindowCandidateFailure
    ) {
        self.focusedWindowFailure = focusedWindowFailure
        self.mainWindowFailure = mainWindowFailure
    }

    public var errorDescription: String? {
        "OpenSnap could not find the focused window."
    }
}

/// Acquires the focused window for an application.
@MainActor
public protocol FocusedWindowProviding {
    func focusedWindow(
        for application: FrontmostApplication
    ) throws(FocusedWindowAcquisitionError) -> any AccessibilityWindowAccessing
}

/// Implements focused-window selection with an explicit main-window fallback.
@MainActor
public final class AXFocusedWindowProvider: FocusedWindowProviding {
    private let targetReader: any FocusedWindowTargetReading

    public convenience init() {
        self.init(targetReader: AXFocusedWindowTargetReader())
    }

    init(targetReader: any FocusedWindowTargetReading) {
        self.targetReader = targetReader
    }

    public func focusedWindow(
        for application: FrontmostApplication
    ) throws(FocusedWindowAcquisitionError) -> any AccessibilityWindowAccessing {
        switch targetReader.window(for: application, target: .focusedWindow) {
        case let .success(window):
            return window
        case let .failure(focusedWindowFailure):
            #if DEBUG || BETA
            OpenSnapInspector.shared.record(.warning, category: .accessibility, "Unable to obtain AXFocusedWindow")
            #endif

            switch targetReader.window(for: application, target: .mainWindow) {
            case let .success(window):
                return window
            case let .failure(mainWindowFailure):
                throw FocusedWindowAcquisitionError(
                    focusedWindowFailure: focusedWindowFailure,
                    mainWindowFailure: mainWindowFailure
                )
            }
        }
    }
}

enum FocusedWindowTarget: Equatable {
    case focusedWindow
    case mainWindow

    var attribute: String {
        switch self {
        case .focusedWindow:
            return "AXFocusedWindow"
        case .mainWindow:
            return "AXMainWindow"
        }
    }
}

@MainActor
protocol FocusedWindowTargetReading {
    func window(
        for application: FrontmostApplication,
        target: FocusedWindowTarget
    ) -> Result<any AccessibilityWindowAccessing, FocusedWindowCandidateFailure>
}

@MainActor
private struct AXFocusedWindowTargetReader: FocusedWindowTargetReading {
    func window(
        for application: FrontmostApplication,
        target: FocusedWindowTarget
    ) -> Result<any AccessibilityWindowAccessing, FocusedWindowCandidateFailure> {
        let applicationElement = AXUIElementCreateApplication(application.processIdentifier)
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(
            applicationElement,
            target.attribute as CFString,
            &value
        )

        guard result == .success else {
            return .failure(.attributeReadFailed(code: Int(result.rawValue)))
        }

        guard let value else {
            return .failure(.missingValue)
        }

        guard CFGetTypeID(value) == AXUIElementGetTypeID() else {
            return .failure(.invalidElement)
        }

        return .success(AXAccessibilityWindow(element: unsafeDowncast(value, to: AXUIElement.self)))
    }
}
