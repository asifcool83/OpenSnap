import Testing
@testable import OpenSnapCore

struct WindowGeometryTests {
    @Test func intersectionAreaHandlesNegativeCoordinates() {
        let left = WindowFrame(x: -1_000, y: -800, width: 1_000, height: 800)
        let overlapping = WindowFrame(x: -250, y: -200, width: 500, height: 400)

        #expect(left.intersectionArea(with: overlapping) == 50_000)
        #expect(overlapping.intersectionArea(with: left) == 50_000)
    }

    @Test func intersectionAreaIsZeroForTouchingEdges() {
        let left = WindowFrame(x: 0, y: 0, width: 500, height: 500)
        let right = WindowFrame(x: 500, y: 0, width: 500, height: 500)

        #expect(left.intersectionArea(with: right) == 0)
    }

    @Test func centerUsesGlobalCoordinates() {
        let frame = WindowFrame(x: -1_200, y: 900, width: 800, height: 600)

        #expect(frame.center == WindowPoint(x: -800, y: 1_200))
    }
}
