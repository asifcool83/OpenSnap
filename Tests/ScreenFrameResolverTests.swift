import Testing
@testable import OpenSnapCore

struct ScreenFrameResolverTests {
    private let resolver = ScreenFrameResolver()

    private func display(
        frame: WindowFrame,
        visibleFrame: WindowFrame? = nil,
        scaleFactor: Double = 2
    ) -> DisplayGeometry {
        DisplayGeometry(
            frame: frame,
            visibleFrame: visibleFrame ?? frame,
            scaleFactor: scaleFactor
        )
    }

    @Test func choosesScreenWithLargestWindowOverlap() {
        let leftScreen = WindowFrame(x: 0, y: 0, width: 1_000, height: 800)
        let rightScreen = WindowFrame(x: 1_000, y: 0, width: 1_000, height: 800)
        let window = WindowFrame(x: 850, y: 100, width: 500, height: 400)

        let resolved = resolver.screenFrame(for: window, in: [leftScreen, rightScreen])

        #expect(resolved == rightScreen)
    }

    @Test func fallsBackToNearestScreenWhenWindowDoesNotOverlapDisplays() {
        let leftScreen = WindowFrame(x: 0, y: 0, width: 1_000, height: 800)
        let rightScreen = WindowFrame(x: 1_000, y: 0, width: 1_000, height: 800)
        let window = WindowFrame(x: 1_300, y: 1_500, width: 200, height: 200)

        let resolved = resolver.screenFrame(for: window, in: [leftScreen, rightScreen])

        #expect(resolved == rightScreen)
    }

    @Test func returnsNilWhenNoScreensAreAvailable() {
        let window = WindowFrame(x: 0, y: 0, width: 100, height: 100)

        #expect(resolver.screenFrame(for: window, in: []) == nil)
    }

    @Test func returnsVisibleFrameFromDisplaySelectedUsingFullFrame() {
        let left = display(
            frame: WindowFrame(x: 0, y: 0, width: 1_000, height: 800),
            visibleFrame: WindowFrame(x: 80, y: 24, width: 920, height: 776)
        )
        let right = display(
            frame: WindowFrame(x: 1_000, y: 0, width: 1_000, height: 800),
            visibleFrame: WindowFrame(x: 1_000, y: 24, width: 1_000, height: 776)
        )
        let window = WindowFrame(x: 20, y: 100, width: 950, height: 500)

        #expect(resolver.display(for: window, in: [left, right]) == left)
        #expect(resolver.display(for: window, in: [left, right])?.visibleFrame == left.visibleFrame)
    }

    @Test func resolvesDisplaysWithNegativeHorizontalCoordinates() {
        let left = display(frame: WindowFrame(x: -1_920, y: 0, width: 1_920, height: 1_080))
        let main = display(frame: WindowFrame(x: 0, y: 0, width: 2_560, height: 1_440))
        let window = WindowFrame(x: -1_500, y: 120, width: 900, height: 700)

        #expect(resolver.display(for: window, in: [main, left]) == left)
    }

    @Test func resolvesDisplaysInVerticalArrangements() {
        let lower = display(frame: WindowFrame(x: 0, y: -900, width: 1_440, height: 900))
        let main = display(frame: WindowFrame(x: 0, y: 0, width: 1_440, height: 900))
        let upper = display(frame: WindowFrame(x: 0, y: 900, width: 1_440, height: 900))

        #expect(
            resolver.display(
                for: WindowFrame(x: 300, y: 1_100, width: 800, height: 500),
                in: [main, lower, upper]
            ) == upper
        )
        #expect(
            resolver.display(
                for: WindowFrame(x: 300, y: -800, width: 800, height: 500),
                in: [main, lower, upper]
            ) == lower
        )
    }

    @Test func overlapTiePrefersDisplayContainingWindowCenter() {
        let left = display(frame: WindowFrame(x: 0, y: 0, width: 1_000, height: 800))
        let right = display(frame: WindowFrame(x: 1_000, y: 0, width: 1_000, height: 800))
        let window = WindowFrame(x: 750, y: 100, width: 500, height: 400)

        #expect(resolver.display(for: window, in: [left, right]) == right)
    }

    @Test func exactTiePreservesSuppliedDisplayOrder() {
        let first = display(
            frame: WindowFrame(x: -1_000, y: 0, width: 1_000, height: 800),
            scaleFactor: 1
        )
        let second = display(
            frame: WindowFrame(x: 1_000, y: 0, width: 1_000, height: 800),
            scaleFactor: 2
        )
        let offscreenWindow = WindowFrame(x: -50, y: 100, width: 100, height: 100)

        #expect(resolver.display(for: offscreenWindow, in: [first, second]) == first)
    }

    @Test func scaleFactorDoesNotChangeLogicalPointSelection() {
        let standard = display(
            frame: WindowFrame(x: 0, y: 0, width: 1_440, height: 900),
            scaleFactor: 1
        )
        let retina = display(
            frame: WindowFrame(x: 1_440, y: 0, width: 1_440, height: 900),
            scaleFactor: 2
        )
        let window = WindowFrame(x: 1_600, y: 100, width: 800, height: 600)

        #expect(resolver.display(for: window, in: [standard, retina]) == retina)
    }
}
