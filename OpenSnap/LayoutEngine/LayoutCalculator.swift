import Foundation

/// Calculates platform-independent window frames for layout commands.
public struct LayoutCalculator: Sendable {
    private enum Constants {
        static let centerWidthRatio = 0.60
        static let centerHeightRatio = 0.72
    }

    public init() {}

    public func frame(for command: LayoutCommand, in screen: WindowFrame) -> WindowFrame {
        switch command {
        case .leftSixty:
            return anchoredFrame(side: .left, ratio: 0.60, in: screen)
        case .rightForty:
            return anchoredFrame(side: .right, ratio: 0.40, in: screen)
        case .leftHalf:
            return anchoredFrame(side: .left, ratio: 0.50, in: screen)
        case .rightHalf:
            return anchoredFrame(side: .right, ratio: 0.50, in: screen)
        case .leftThird:
            return thirdFrame(index: 0, in: screen)
        case .centerThird:
            return thirdFrame(index: 1, in: screen)
        case .rightThird:
            return thirdFrame(index: 2, in: screen)
        case .maximize:
            return screen
        case .center:
            return centeredFrame(in: screen)
        case let .smartSnap(side, step):
            return anchoredFrame(side: side, ratio: step.ratio, in: screen)
        }
    }

    private func anchoredFrame(side: SmartSnapSide, ratio: Double, in screen: WindowFrame) -> WindowFrame {
        let width = screen.width * ratio
        let x = side == .left ? screen.x : screen.x + screen.width - width

        return WindowFrame(
            x: x.rounded(.toNearestOrAwayFromZero),
            y: screen.y,
            width: width.rounded(.toNearestOrAwayFromZero),
            height: screen.height
        )
    }

    private func thirdFrame(index: Int, in screen: WindowFrame) -> WindowFrame {
        let width = screen.width / 3.0

        return WindowFrame(
            x: (screen.x + width * Double(index)).rounded(.toNearestOrAwayFromZero),
            y: screen.y,
            width: width.rounded(.toNearestOrAwayFromZero),
            height: screen.height
        )
    }

    private func centeredFrame(in screen: WindowFrame) -> WindowFrame {
        let width = screen.width * Constants.centerWidthRatio
        let height = screen.height * Constants.centerHeightRatio

        return WindowFrame(
            x: (screen.x + (screen.width - width) / 2.0).rounded(.toNearestOrAwayFromZero),
            y: (screen.y + (screen.height - height) / 2.0).rounded(.toNearestOrAwayFromZero),
            width: width.rounded(.toNearestOrAwayFromZero),
            height: height.rounded(.toNearestOrAwayFromZero)
        )
    }
}
