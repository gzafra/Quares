import Foundation

final class ClassicModeLogic: GameModeLogic {
    var mode: GameMode { .classic }

    private let levelHandler: LevelHandler

    init(levelConfiguration: LevelConfiguration = LevelConfiguration()) {
        self.levelHandler = LevelHandler(configuration: levelConfiguration)
    }

    func shouldShowHealthBar() -> Bool { true }
    func shouldShowScore() -> Bool { true }
    func shouldShowLevel() -> Bool { true }
    func shouldShowTimer() -> Bool { false }

    func calculateHealthDrainDuration(baseDuration: TimeInterval, score: Int, configuration: GameConfiguration) -> TimeInterval {
        let difficultyLevel = score / configuration.difficultyIncreasePerScore
        let speedIncrease = Double(difficultyLevel) * configuration.drainSpeedIncreasePercentage
        let levelMultiplier = levelHandler.healthDrainSpeedMultiplier
        let newDuration = baseDuration * (1.0 - speedIncrease) / levelMultiplier
        return max(newDuration, configuration.minimumHealthDrainDuration)
    }

    func calculateHealthRegeneration(baseRegeneration: Double, squaresCleared: Int, comboMultiplier: Double, configuration: GameConfiguration) -> Double {
        let maxAdditionalRegeneration = 1.0 - baseRegeneration
        let maxSquares = configuration.gridSize * configuration.gridSize
        let proportionalAdditional = Double(squaresCleared) / Double(maxSquares) * maxAdditionalRegeneration
        var totalRegeneration = baseRegeneration + proportionalAdditional
        totalRegeneration *= comboMultiplier
        return totalRegeneration
    }

    func shouldGameOver(health: Double) -> Bool {
        health <= 0
    }

    func onSuccessfulMatch(squaresCleared: Int, brain: Brain) {
        levelHandler.addExperience(forSquaresCleared: squaresCleared)
    }

    func onGameStart(brain: Brain) {
        levelHandler.resetLevel()
    }

    func onGameOver(brain: Brain) -> GameModeResult {
        let progress = getLevelProgress()
        GameModeResult(
            primaryDisplay: "Score: \(brain.score)",
            secondaryDisplay: "Level \(progress?.level ?? 1)"
        )
    }

    func getLevelProgress() -> (level: Int, experience: Int, experienceToNextLevel: Int)? {
        (levelHandler.currentLevel, levelHandler.currentExperience, levelHandler.experienceRequiredForNextLevel)
    }
}
