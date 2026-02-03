import Foundation

protocol LevelHandlerDelegate: AnyObject {
    func levelHandler(_ handler: LevelHandler, didUpdateLevel level: Int)
    func levelHandler(_ handler: LevelHandler, didUpdateExperience currentExp: Double, requiredExp: Double)
}

final class LevelHandler {
    weak var delegate: LevelHandlerDelegate?
    
    private let configuration: GameConfiguration
    
    private(set) var currentLevel: Int = 1
    private(set) var currentExperience: Double = 0.0
    private(set) var experienceRequiredForNextLevel: Double = 0.0
    
    init(configuration: GameConfiguration) {
        self.configuration = configuration
        self.experienceRequiredForNextLevel = calculateExperienceRequired(forLevel: 1)
    }
    
    func resetLevel() {
        currentLevel = 1
        currentExperience = 0.0
        experienceRequiredForNextLevel = calculateExperienceRequired(forLevel: 1)
        notifyUpdate()
    }
    
    func addExperience(fromSquaresCleared squaresCleared: Int) {
        guard currentLevel < configuration.maxLevels else { return }
        
        let expGained = Double(squaresCleared)
        currentExperience += expGained
        
        // Check for level up
        while currentExperience >= experienceRequiredForNextLevel && currentLevel < configuration.maxLevels {
            levelUp()
        }
        
        notifyUpdate()
    }
    
    private func levelUp() {
        currentExperience -= experienceRequiredForNextLevel
        currentLevel += 1
        
        if currentLevel < configuration.maxLevels {
            experienceRequiredForNextLevel = calculateExperienceRequired(forLevel: currentLevel)
        } else {
            experienceRequiredForNextLevel = Double.infinity
            currentExperience = 0
        }
        
        delegate?.levelHandler(self, didUpdateLevel: currentLevel)
    }
    
    private func calculateExperienceRequired(forLevel level: Int) -> Double {
        guard level > 0 else { return configuration.baseExperienceRequired }
        
        var required = configuration.baseExperienceRequired
        for _ in 1..<level {
            required *= (1.0 + configuration.experienceIncreasePercentage)
        }
        return required
    }
    
    private func notifyUpdate() {
        delegate?.levelHandler(self, didUpdateExperience: currentExperience, requiredExp: experienceRequiredForNextLevel)
    }
    
    /// Returns the health drain multiplier based on current level
    /// Higher levels = faster drain
    var healthDrainMultiplier: Double {
        1.0 + (Double(currentLevel - 1) * configuration.healthDrainIncreasePerLevel)
    }
}
