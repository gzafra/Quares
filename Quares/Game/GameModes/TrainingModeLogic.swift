import Foundation

final class TrainingModeLogic: GameModeLogic {
    var mode: GameMode { .training }
    
    func shouldShowHealthBar() -> Bool { false }
    func shouldShowScore() -> Bool { false }
    func shouldShowLevel() -> Bool { false }
    func shouldShowTimer() -> Bool { false }
    
    func calculateHealthDrainDuration(baseDuration: TimeInterval, score: Int, configuration: GameConfiguration) -> TimeInterval {
        TimeInterval.infinity
    }
    
    func calculateHealthRegeneration(baseRegeneration: Double, squaresCleared: Int, configuration: GameConfiguration) -> Double {
        0
    }
    
    func calculateScore(squaresCleared: Int, baseMultiplier: Double, comboMultiplier: Double) -> Int {
        0
    }
    
    func shouldGameOver(health: Double) -> Bool {
        false
    }
    
    func onSuccessfulMatch(squaresCleared: Int, brain: Brain) {}
    
    func onGameStart(brain: Brain) {}
    
    func onGameOver(brain: Brain) -> GameModeResult {
        GameModeResult(primaryDisplay: "Practice Complete", secondaryDisplay: nil)
    }
}