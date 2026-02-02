import SwiftUI

enum ColorMode: String, CaseIterable, Identifiable {
    case normal
    case bright
    case protanopia
    case deuteranopia
    case tritanopia

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .normal:
            return "Normal"
        case .bright:
            return "Bright"
        case .protanopia:
            return "Protanopia"
        case .deuteranopia:
            return "Deuteranopia"
        case .tritanopia:
            return "Tritanopia"
        }
    }

    var colors: [Color] {
        switch self {
        case .normal:
            return [
                Color(hex: "E63946"),  // Red
                Color(hex: "457B9D"),  // Blue
                Color(hex: "2A9D8F"),  // Teal/Green
                Color(hex: "F4A261"),  // Orange
                Color(hex: "9B5DE5")   // Purple
            ]
        case .bright:
            return [
                Color(hex: "FF0000"),  // Full Red
                Color(hex: "0066FF"),  // Full Blue
                Color(hex: "228B22"),  // Forest Green (darker grass green)
                Color(hex: "FFE600"),  // Bright Yellow
                Color(hex: "FF6600")   // Bright Orange
            ]
        case .protanopia:
            // Optimized for red-blindness: avoids red, uses distinguishable blues/yellows
            // Based on Paul Tol's colorblind-safe palette
            return [
                Color(hex: "4477AA"),  // Blue
                Color(hex: "CCBB44"),  // Yellow
                Color(hex: "66CCEE"),  // Cyan
                Color(hex: "AA3377"),  // Purple/Magenta
                Color(hex: "BBBBBB")   // Gray
            ]
        case .deuteranopia:
            // Optimized for green-blindness: avoids green, uses distinguishable blues/oranges
            // Based on Paul Tol's colorblind-safe palette
            return [
                Color(hex: "4477AA"),  // Blue
                Color(hex: "EE6677"),  // Coral/Pink (visible as distinct from blue)
                Color(hex: "CCBB44"),  // Yellow
                Color(hex: "66CCEE"),  // Cyan
                Color(hex: "AA3377")   // Purple/Magenta
            ]
        case .tritanopia:
            // Optimized for blue-blindness: avoids blue-yellow confusion
            // Uses reds, greens, pinks that remain distinguishable
            return [
                Color(hex: "EE6677"),  // Coral/Red
                Color(hex: "228833"),  // Green
                Color(hex: "CC3399"),  // Magenta/Pink
                Color(hex: "009988"),  // Teal
                Color(hex: "888888")   // Gray
            ]
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let red, green, blue: UInt64
        switch hex.count {
        case 6:
            (red, green, blue) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (red, green, blue) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: 1
        )
    }
}
