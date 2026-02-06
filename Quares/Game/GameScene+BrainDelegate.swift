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
        SoundManager.shared.stopGameMusic()
        SoundManager.shared.startMenuMusic()
        SoundManager.shared.play(.gameOver)
        showGameOver()
    }

    func brainDidSelectSquares(_ brain: Brain, squares: Set<GridPosition>) {
        SoundManager.shared.play(.squareTap)
        highlightSquares(squares)
    }

    func brainDidClearSelection(_ brain: Brain) {
        clearHighlights()
    }

    func brainDidClearSquares(_ brain: Brain, from: GridPosition, to: GridPosition) {
        SoundManager.shared.play(.success)
        animateSuccessfulSelection(from: from, to: to)
    }

    func brainDidFailSelection(_ brain: Brain, from: GridPosition, to: GridPosition) {
        SoundManager.shared.play(.failure)
        animateFailedSelection(from: from, to: to)
    }

    func brainDidTriggerCombo(_ brain: Brain, comboCount: Int) {
        SoundManager.shared.play(.levelUp)
        showComboLabel(comboCount: comboCount)
    }
}
