import Foundation
import OpenSnapCore

enum InspectorFormatting {
    static func frame(_ frame: WindowFrame) -> String {
        "x: \(rounded(frame.x)), y: \(rounded(frame.y)), w: \(rounded(frame.width)), h: \(rounded(frame.height))"
    }

    static func size(width: Double, height: Double) -> String {
        "w: \(rounded(width)), h: \(rounded(height))"
    }

    private static func rounded(_ value: Double) -> String {
        String(format: "%.0f", value)
    }
}
