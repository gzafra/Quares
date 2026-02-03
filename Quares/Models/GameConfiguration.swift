import Foundation
import SwiftUI

struct GameConfiguration {
    // Grid settings
    var gridSize: Int = 10
    var numberOfColors: Int = 5

    // Health settings
    var initialHealthDrainDuration: TimeInterval = 30.0
    var minimumHealthDrainDuration: TimeInterval = 2.0
    var healthRegenerationPercentage: Double = 0.15

    // Scoring settings
    var baseMultiplier: Double = 1.0
    var difficultyIncreasePerScore: Int = 100
    var drainSpeedIncreasePercentage: Double = 0.1

    // Combo settings
    var comboThreshold: TimeInterval = 3.0
    var comboBaseBonusPercentage: Double = 0.10
    var comboIncrementPercentage: Double = 0.05

    // Color mode for accessibility
    var colorMode: ColorMode = {
        let rawValue = UserDefaults.standard.string(forKey: "colorMode") ?? ColorMode.normal.rawValue
        return ColorMode(rawValue: rawValue) ?? .normal
    }()

    func colors() -> [Color] {
        Array(colorMode.colors.prefix(numberOfColors))
    }
}
