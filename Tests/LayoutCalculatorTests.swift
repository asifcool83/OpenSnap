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

    @Test func halvesShareOneRoundedEdgeOnOddWidthScreens() {
        let oddScreen = WindowFrame(x: 0, y: 25, width: 1_001, height: 775)
        let left = calculator.frame(for: .leftHalf, in: oddScreen)
        let right = calculator.frame(for: .rightHalf, in: oddScreen)

        #expect(left.maxX == right.minX)
        #expect(left.minX == oddScreen.minX)
        #expect(right.maxX == oddScreen.maxX)
    }

    @Test func sixtyFortyPartitionsOddWidthScreensWithoutGaps() {
        let oddScreen = WindowFrame(x: -1_001, y: -900, width: 1_001, height: 775)
        let left = calculator.frame(for: .leftSixty, in: oddScreen)
        let right = calculator.frame(for: .rightForty, in: oddScreen)

        #expect(left.maxX == right.minX)
        #expect(left.minX == oddScreen.minX)
        #expect(right.maxX == oddScreen.maxX)
        #expect(left.y == -900)
    }

    @Test func thirdsDivideScreenIntoThreeColumns() {
        #expect(calculator.frame(for: .leftThird, in: screen) == WindowFrame(x: 0, y: 25, width: 400, height: 775))
        #expect(calculator.frame(for: .centerThird, in: screen) == WindowFrame(x: 400, y: 25, width: 400, height: 775))
        #expect(calculator.frame(for: .rightThird, in: screen) == WindowFrame(x: 800, y: 25, width: 400, height: 775))
    }

    @Test func maximizeReturnsVisibleScreenFrame() {
        #expect(calculator.frame(for: .maximize, in: screen) == screen)
    }

    @Test func centerUsesSixtyPercentWidthAndSeventyTwoPercentHeight() {
        let frame = calculator.frame(for: .center, in: screen)

        #expect(frame == WindowFrame(x: 240, y: 134, width: 720, height: 558))
    }

    @Test func centerRemainsCenteredWithNegativeOriginsAndOddDimensions() {
        let oddScreen = WindowFrame(x: -1_601, y: -1_003, width: 1_001, height: 777)
        let frame = calculator.frame(for: .center, in: oddScreen)

        #expect(abs(frame.center.x - oddScreen.center.x) <= 0.5)
        #expect(abs(frame.center.y - oddScreen.center.y) <= 0.5)
        #expect(frame.minX >= oddScreen.minX)
        #expect(frame.maxX <= oddScreen.maxX)
        #expect(frame.minY >= oddScreen.minY)
        #expect(frame.maxY <= oddScreen.maxY)
    }

    @Test func smartSnapAnchorsToRequestedSide() {
        let left = calculator.frame(for: .smartSnap(.left, .quarter), in: screen)
        let right = calculator.frame(for: .smartSnap(.right, .quarter), in: screen)

        #expect(left == WindowFrame(x: 0, y: 25, width: 300, height: 775))
        #expect(right == WindowFrame(x: 900, y: 25, width: 300, height: 775))
    }

    @Test func layoutUsesLogicalPointsIndependentOfDisplayScale() {
        let logicalScreen = WindowFrame(x: 0, y: 24, width: 1_512, height: 958)

        #expect(
            calculator.frame(for: .leftSixty, in: logicalScreen)
                == WindowFrame(x: 0, y: 24, width: 907, height: 958)
        )
    }
}
