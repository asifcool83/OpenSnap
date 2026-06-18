import Testing
@testable import OpenSnapCore

struct LayoutCalculatorTests {
    private let calculator = LayoutCalculator()
    private let screen = WindowFrame(x: 0, y: 25, width: 1_200, height: 775)

    @Test func leftSixtyUsesLeftEdgeAndSixtyPercentWidth() {
        let frame = calculator.frame(for: .leftSixty, in: screen)

        #expect(frame == WindowFrame(x: 0, y: 25, width: 720, height: 775))
    }

    @Test func rightFortyUsesRightEdgeAndFortyPercentWidth() {
        let frame = calculator.frame(for: .rightForty, in: screen)

        #expect(frame == WindowFrame(x: 720, y: 25, width: 480, height: 775))
    }

    @Test func halvesUseEqualWidths() {
        #expect(calculator.frame(for: .leftHalf, in: screen) == WindowFrame(x: 0, y: 25, width: 600, height: 775))
        #expect(calculator.frame(for: .rightHalf, in: screen) == WindowFrame(x: 600, y: 25, width: 600, height: 775))
    }

    @Test func thirdsDivideScreenIntoThreeColumns() {
        #expect(calculator.frame(for: .leftThird, in: screen) == WindowFrame(x: 0, y: 25, width: 400, height: 775))
        #expect(calculator.frame(for: .centerThird, in: screen) == WindowFrame(x: 400, y: 25, width: 400, height: 775))
        #expect(calculator.frame(for: .rightThird, in: screen) == WindowFrame(x: 800, y: 25, width: 400, height: 775))
    }

    @Test func maximizeReturnsVisibleScreenFrame() {
        #expect(calculator.frame(for: .maximize, in: screen) == screen)
    }

    @Test func smartSnapAnchorsToRequestedSide() {
        let left = calculator.frame(for: .smartSnap(.left, .quarter), in: screen)
        let right = calculator.frame(for: .smartSnap(.right, .quarter), in: screen)

        #expect(left == WindowFrame(x: 0, y: 25, width: 300, height: 775))
        #expect(right == WindowFrame(x: 900, y: 25, width: 300, height: 775))
    }
}
