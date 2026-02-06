import Foundation

protocol GameModeLogic: AnyObject {
    var mode: GameMode { get }
    
    func shouldShowHealthBar() -> Bool
    func shouldShowScore() -> Bool
    func shouldShowLevel() -> Bool
    func shouldShowTimer() -> Bool
    
    func calculateHealthDrainDuration(baseDuration: TimeInterval, score: Int, configuration: GameConfiguration) -> TimeInterval
    func calculateHealthRegeneration(baseRegeneration: Double, squaresCleared: Int, configuration: GameConfiguration) -> Double
    func calculateScore(squaresCleared: Int, baseMultiplier: Double, comboMultiplier: Double) -> Int
    func shouldGameOver(health: Double) -> Bool
    
    func onSuccessfulMatch(squaresCleared: Int, brain: Brain)
    func onGameStart(brain: Brain)
    func onGameOver(brain: Brain) -> GameModeResult
}

struct GameModeResult {
    let primaryDisplay: String
    let secondaryDisplay: String?
}

extension GameModeLogic {
    func calculateScore(squaresCleared: Int, baseMultiplier: Double, comboMultiplier: Double) -> Int {
        let baseScore = Double(squaresCleared) * baseMultiplier
        return Int(baseScore * comboMultiplier)
    }
}