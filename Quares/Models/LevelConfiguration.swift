import Foundation

struct LevelConfiguration {
    var maxLevels: Int = 100
    var baseExperienceRequired: Int = 50
    var experienceIncreasePercentage: Double = 0.5
    var experiencePerSquare: Int = 1
    var healthDrainSpeedIncreasePerLevel: Double = 0.05
    var maxHealthDrainSpeedMultiplier: Double = 3.0
    
    func experienceRequiredForLevel(_ level: Int) -> Int {
        guard level < maxLevels else { return Int.max }
        
        let levelIndex = level - 1
        let multiplier = pow(1.0 + experienceIncreasePercentage, Double(levelIndex))
        return Int(Double(baseExperienceRequired) * multiplier)
    }
    
    func healthDrainSpeedMultiplierForLevel(_ level: Int) -> Double {
        let rawMultiplier = 1.0 + (Double(level - 1) * healthDrainSpeedIncreasePerLevel)
        return min(rawMultiplier, maxHealthDrainSpeedMultiplier)
    }
}
