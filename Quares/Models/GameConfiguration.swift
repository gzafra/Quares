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

    // Available colors for squares
    static let availableColors: [Color] = [
        .red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan
    ]

    func colors() -> [Color] {
        Array(Self.availableColors.prefix(numberOfColors))
    }
}
