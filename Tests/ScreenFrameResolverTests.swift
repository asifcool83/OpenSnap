import Testing
@testable import OpenSnapCore

struct ScreenFrameResolverTests {
    private let resolver = ScreenFrameResolver()

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
}
