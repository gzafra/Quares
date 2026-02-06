import Foundation

final class ClassicModeLogic: GameModeLogic {
    var mode: GameMode { .classic }
    
    private var level: Int = 1
    private var experience: Int = 0
    private var experienceToNextLevel: Int = 50
    
    func shouldShowHealthBar() -> Bool { true }
    func shouldShowScore() -> Bool { true }
    func shouldShowLevel() -> Bool { true }
    func shouldShowTimer() -> Bool { false }
    
    func calculateHealthDrainDuration(baseDuration: TimeInterval, score: Int, configuration: GameConfiguration) -> TimeInterval {
        let difficultyLevel = score / configuration.difficultyIncreasePerScore
        let speedIncrease = Double(difficultyLevel) * configuration.drainSpeedIncreasePercentage
        let newDuration = baseDuration * (1.0 - speedIncrease)
        return max(newDuration, configuration.minimumHealthDrainDuration)
    }
    
    func calculateHealthRegeneration(baseRegeneration: Double, squaresCleared: Int, configuration: GameConfiguration) -> Double {
        let maxAdditionalRegeneration = 1.0 - baseRegeneration
        let maxSquares = configuration.gridSize * configuration.gridSize
        let proportionalAdditional = Double(squaresCleared) / Double(maxSquares) * maxAdditionalRegeneration
        return baseRegeneration + proportionalAdditional
    }
    
    func shouldGameOver(health: Double) -> Bool {
        health <= 0
    }
    
    func onSuccessfulMatch(squaresCleared: Int, brain: Brain) {
        addExperience(squaresCleared, brain: brain)
    }
    
    func onGameStart(brain: Brain) {
        level = 1
        experience = 0
        experienceToNextLevel = 50
    }
    
    func onGameOver(brain: Brain) -> GameModeResult {
        GameModeResult(
            primaryDisplay: "Score: \(brain.score)",
            secondaryDisplay: "Level \(level)"
        )
    }
    
    private func addExperience(_ squaresCleared: Int, brain: Brain) {
        experience += squaresCleared
        
        while experience >= experienceToNextLevel {
            experience -= experienceToNextLevel
            level += 1
            experienceToNextLevel = Int(Double(experienceToNextLevel) * 1.5)
        }
    }
    
    func getLevelProgress() -> (level: Int, experience: Int, experienceToNextLevel: Int) {
        (level, experience, experienceToNextLevel)
    }
}