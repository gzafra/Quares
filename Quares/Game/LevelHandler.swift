import Foundation

protocol LevelHandlerDelegate: AnyObject {
    func levelHandler(_ handler: LevelHandler, didUpdateLevel level: Int)
    func levelHandler(_ handler: LevelHandler, didUpdateExperience experience: Int, requiredForNextLevel: Int)
    func levelHandler(_ handler: LevelHandler, didLevelUpFrom oldLevel: Int, to newLevel: Int)
}

final class LevelHandler {
    weak var delegate: LevelHandlerDelegate?
    
    private let configuration: LevelConfiguration
    
    private(set) var currentLevel: Int = 1
    private(set) var currentExperience: Int = 0
    
    var experienceRequiredForNextLevel: Int {
        configuration.experienceRequiredForLevel(currentLevel)
    }
    
    var experienceProgressPercentage: Double {
        Double(currentExperience) / Double(experienceRequiredForNextLevel)
    }
    
    var healthDrainSpeedMultiplier: Double {
        configuration.healthDrainSpeedMultiplierForLevel(currentLevel)
    }
    
    init(configuration: LevelConfiguration = LevelConfiguration()) {
        self.configuration = configuration
    }
    
    func resetLevel() {
        currentLevel = 1
        currentExperience = 0
        notifyDelegates()
    }
    
    func addExperience(forSquaresCleared count: Int) {
        let experienceToAdd = count * configuration.experiencePerSquare
        currentExperience += experienceToAdd
        
        checkForLevelUp()
        delegate?.levelHandler(self, didUpdateExperience: currentExperience, requiredForNextLevel: experienceRequiredForNextLevel)
    }
    
    private func checkForLevelUp() {
        while currentExperience >= experienceRequiredForNextLevel && currentLevel < configuration.maxLevels {
            currentExperience -= experienceRequiredForNextLevel
            let oldLevel = currentLevel
            currentLevel += 1
            delegate?.levelHandler(self, didLevelUpFrom: oldLevel, to: currentLevel)
        }
        
        delegate?.levelHandler(self, didUpdateLevel: currentLevel)
    }
    
    private func notifyDelegates() {
        delegate?.levelHandler(self, didUpdateLevel: currentLevel)
        delegate?.levelHandler(self, didUpdateExperience: currentExperience, requiredForNextLevel: experienceRequiredForNextLevel)
    }
}
