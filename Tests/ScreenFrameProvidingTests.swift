import CoreGraphics
import OpenSnapCore
import Testing
@testable import OpenSnap

struct ScreenFrameProvidingTests {
    private let primaryScreen = CGRect(x: 0, y: 0, width: 1_440, height: 900)

    @Test func convertsPrimaryVisibleFrameToAccessibilityCoordinates() {
        let visibleFrame = CGRect(x: 0, y: 0, width: 1_440, height: 875)

        let result = AppKitScreenFrameProvider.accessibilityFrame(
            for: visibleFrame,
            primaryScreenFrame: primaryScreen
        )

        #expect(result == WindowFrame(x: 0, y: 25, width: 1_440, height: 875))
    }

    @Test func convertsScreenAbovePrimaryToNegativeAccessibilityY() {
        let visibleFrame = CGRect(x: 100, y: 900, width: 1_200, height: 775)

        let result = AppKitScreenFrameProvider.accessibilityFrame(
            for: visibleFrame,
            primaryScreenFrame: primaryScreen
        )

        #expect(result == WindowFrame(x: 100, y: -775, width: 1_200, height: 775))
    }

    @Test func convertsScreenBelowPrimaryToPositiveAccessibilityY() {
        let visibleFrame = CGRect(x: -1_920, y: -1_080, width: 1_920, height: 1_080)

        let result = AppKitScreenFrameProvider.accessibilityFrame(
            for: visibleFrame,
            primaryScreenFrame: primaryScreen
        )

        #expect(result == WindowFrame(x: -1_920, y: 900, width: 1_920, height: 1_080))
    }
}
