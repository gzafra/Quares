import Foundation

protocol LevelHandlerDelegate: AnyObject {
    func levelHandler(_ handler: LevelHandler, didUpdateLevel level: Int)
    func levelHandler(_ handler: LevelHandler, didUpdateExperience currentExp: Int, requiredExp: Int)
    func levelHandlerDidLevelUp(_ handler: LevelHandler, newLevel: Int)
}

final class LevelHandler {
    weak var delegate: LevelHandlerDelegate?
    
    private let baseExpRequired: Int
    private let expIncreasePercentage: Double
    private let maxLevel: Int
    private let expPerSquare: Int
    
    private(set) var currentLevel: Int = 1
    private(set) var currentExperience: Int = 0
    private(set) var experienceRequiredForNextLevel: Int = 0
    
    /// Calculates the health drain speed multiplier based on current level
    /// Higher levels drain health faster
    var healthDrainMultiplier: Double {
        // Each level increases drain speed by 2%
        return 1.0 + (Double(currentLevel - 1) * 0.02)
    }
    
    init(
        baseExpRequired: Int = 50,
        expIncreasePercentage: Double = 0.5,
        maxLevel: Int = 100,
        expPerSquare: Int = 1
    ) {
        self.baseExpRequired = baseExpRequired
        self.expIncreasePercentage = expIncreasePercentage
        self.maxLevel = maxLevel
        self.expPerSquare = expPerSquare
        self.experienceRequiredForNextLevel = baseExpRequired
    }
    
    func reset() {
        currentLevel = 1
        currentExperience = 0
        experienceRequiredForNextLevel = baseExpRequired
        delegate?.levelHandler(self, didUpdateLevel: currentLevel)
        delegate?.levelHandler(self, didUpdateExperience: currentExperience, requiredExp: experienceRequiredForNextLevel)
    }
    
    func addExperience(forSquaresCleared squaresCleared: Int) {
        guard currentLevel < maxLevel else { return }
        
        let expGained = squaresCleared * expPerSquare
        currentExperience += expGained
        
        // Check for level up
        while currentExperience >= experienceRequiredForNextLevel && currentLevel < maxLevel {
            levelUp()
        }
        
        delegate?.levelHandler(self, didUpdateExperience: currentExperience, requiredExp: experienceRequiredForNextLevel)
    }
    
    private func levelUp() {
        currentExperience -= experienceRequiredForNextLevel
        currentLevel += 1
        
        // Calculate new required experience (increases by 50% each level)
        let increaseMultiplier = 1.0 + expIncreasePercentage
        experienceRequiredForNextLevel = Int(Double(experienceRequiredForNextLevel) * increaseMultiplier)
        
        delegate?.levelHandler(self, didUpdateLevel: currentLevel)
        delegate?.levelHandlerDidLevelUp(self, newLevel: currentLevel)
    }
    
    /// Returns the experience progress as a percentage (0.0 to 1.0)
    var experienceProgress: Double {
        guard experienceRequiredForNextLevel > 0 else { return 0.0 }
        return Double(currentExperience) / Double(experienceRequiredForNextLevel)
    }
    
    /// Calculates the required experience for a specific level
    func experienceRequiredForLevel(_ level: Int) -> Int {
        guard level > 1 else { return baseExpRequired }
        
        var required = Double(baseExpRequired)
        for _ in 2...level {
            required *= (1.0 + expIncreasePercentage)
        }
        return Int(required)
    }
}