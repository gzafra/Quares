import Foundation

final class SurvivalModeLogic: GameModeLogic {
    var mode: GameMode { .survival }
    
    private var survivalTime: TimeInterval = 0
    private var timer: Timer?
    private weak var brain: Brain?
    
    private enum Constants {
        static let healthDrainDuration: TimeInterval = 3.0
        static let healthRegenerationBoost: Double = 0.8
    }
    
    func shouldShowHealthBar() -> Bool { true }
    func shouldShowScore() -> Bool { false }
    func shouldShowLevel() -> Bool { false }
    func shouldShowTimer() -> Bool { true }
    
    func calculateHealthDrainDuration(baseDuration: TimeInterval, score: Int, configuration: GameConfiguration) -> TimeInterval {
        Constants.healthDrainDuration
    }
    
    func calculateHealthRegeneration(baseRegeneration: Double, squaresCleared: Int, configuration: GameConfiguration) -> Double {
        Constants.healthRegenerationBoost
    }
    
    func shouldGameOver(health: Double) -> Bool {
        health <= 0
    }
    
    func onSuccessfulMatch(squaresCleared: Int, brain: Brain) {}
    
    func onGameStart(brain: Brain) {
        self.brain = brain
        survivalTime = 0
        startTimer()
    }
    
    func onGameOver(brain: Brain) -> GameModeResult {
        stopTimer()
        let minutes = Int(survivalTime) / 60
        let seconds = Int(survivalTime) % 60
        let timeString = String(format: "%02d:%02d", minutes, seconds)
        
        return GameModeResult(
            primaryDisplay: "Survived: \(timeString)",
            secondaryDisplay: nil
        )
    }
    
    func getSurvivalTime() -> TimeInterval {
        survivalTime
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.survivalTime += 0.1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}