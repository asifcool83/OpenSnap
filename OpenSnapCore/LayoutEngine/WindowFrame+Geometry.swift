import Foundation

public extension WindowFrame {
    var minX: Double { x }
    var minY: Double { y }
    var maxX: Double { x + width }
    var maxY: Double { y + height }
    var area: Double { max(0, width) * max(0, height) }
    var center: WindowPoint {
        WindowPoint(x: x + width / 2.0, y: y + height / 2.0)
    }

    func contains(_ point: WindowPoint) -> Bool {
        point.x >= minX && point.x < maxX && point.y >= minY && point.y < maxY
    }

    func intersectionArea(with other: WindowFrame) -> Double {
        let intersectionWidth = max(0, min(maxX, other.maxX) - max(minX, other.minX))
        let intersectionHeight = max(0, min(maxY, other.maxY) - max(minY, other.minY))

        return intersectionWidth * intersectionHeight
    }
}

/// A platform-independent point used by geometry calculations.
public struct WindowPoint: Equatable, Sendable {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public func squaredDistance(to other: WindowPoint) -> Double {
        let xDistance = x - other.x
        let yDistance = y - other.y

        return xDistance * xDistance + yDistance * yDistance
    }
}
