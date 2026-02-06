import SpriteKit

extension GameScene: BrainDelegate {
    func brainDidUpdateGrid(_ brain: Brain) {
        updateGridColors()
    }

    func brainDidUpdateHealth(_ brain: Brain, health: Double) {
        healthBar?.update(health: health)
    }

    func brainDidUpdateScore(_ brain: Brain, score: Int) {
        scoreBoard?.update(score: score)
    }

    func brainDidGameOver(_ brain: Brain) {
        showGameOver()
    }

    func brainDidSelectSquares(_ brain: Brain, squares: Set<GridPosition>) {
        highlightSquares(squares)
    }

    func brainDidClearSelection(_ brain: Brain) {
        clearHighlights()
    }

    func brainDidClearSquares(_ brain: Brain, from: GridPosition, to: GridPosition) {
        animateSuccessfulSelection(from: from, to: to)
    }

    func brainDidFailSelection(_ brain: Brain, from: GridPosition, to: GridPosition) {
        animateFailedSelection(from: from, to: to)
    }

    func brainDidTriggerCombo(_ brain: Brain, comboCount: Int) {
        showComboLabel(comboCount: comboCount)
    }

    func brainDidUpdateTimer(_ brain: Brain, time: TimeInterval) {
        timerBoard?.update(time: time)
    }

    func brainDidUpdateLevel(_ brain: Brain, level: Int, experience: Int, experienceToNextLevel: Int) {
        levelBoard?.update(level: level, experience: experience, experienceToNextLevel: experienceToNextLevel)
    }
}
