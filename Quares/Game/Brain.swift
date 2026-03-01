import Foundation
import SwiftUI

protocol BrainDelegate: AnyObject {
    func brainDidUpdateGrid(_ brain: Brain)
    func brainDidUpdateHealth(_ brain: Brain, health: Double)
    func brainDidUpdateScore(_ brain: Brain, score: Int)
    func brainDidUpdateLevel(_ brain: Brain, level: Int)
    func brainDidUpdateExperience(_ brain: Brain, progress: Double)
    func brainDidLevelUp(_ brain: Brain, from oldLevel: Int, to newLevel: Int)
    func brainDidUpdateTimer(_ brain: Brain, time: TimeInterval)
    func brainDidGameOver(_ brain: Brain)
    func brainDidSelectSquares(_ brain: Brain, squares: Set<GridPosition>)
    func brainDidClearSelection(_ brain: Brain)
    func brainDidClearSquares(_ brain: Brain, from: GridPosition, to: GridPosition)
    func brainDidFailSelection(_ brain: Brain, from: GridPosition, to: GridPosition)
    func brainDidTriggerCombo(_ brain: Brain, comboCount: Int)
}

extension BrainDelegate {
    func brainDidUpdateTimer(_ brain: Brain, time: TimeInterval) {}
    func brainDidUpdateLevel(_ brain: Brain, level: Int) {}
    func brainDidUpdateExperience(_ brain: Brain, progress: Double) {}
    func brainDidLevelUp(_ brain: Brain, from oldLevel: Int, to newLevel: Int) {}
}

final class Brain {
    // MARK: - Properties

    weak var delegate: BrainDelegate?
    private(set) var gameModeLogic: GameModeLogic

    private(set) var configuration: GameConfiguration
    private(set) var grid: [[Square]]
    private(set) var health: Double = 1.0
    private(set) var isGameOver: Bool = false
    private(set) var selectedPosition: GridPosition?

    private let comboHandler: ComboHandler
    private let scoreHandler: ScoreHandler

    private var healthDrainTimer: Timer?
    private var lastUpdateTime: Date?
    private var timerUpdateTimer: Timer?

    var score: Int { scoreHandler.score }
    var currentCombo: Int { comboHandler.currentCombo }
    var gameMode: GameMode { gameModeLogic.mode }

    var currentLevel: Int {
        gameModeLogic.getLevelProgress()?.level ?? 1
    }

    var currentHealthDrainDuration: TimeInterval {
        gameModeLogic.calculateHealthDrainDuration(
            baseDuration: configuration.initialHealthDrainDuration,
            score: scoreHandler.score,
            configuration: configuration
        )
    }

    var multiplier: Double {
        configuration.baseMultiplier
    }

    // MARK: - Initialization

    init(configuration: GameConfiguration = GameConfiguration(), gameModeLogic: GameModeLogic? = nil) {
        self.configuration = configuration
        self.grid = []
        self.gameModeLogic = gameModeLogic ?? ClassicModeLogic(levelConfiguration: configuration.levelConfiguration)
        self.comboHandler = ComboHandler(
            comboThreshold: configuration.comboThreshold,
            comboBaseBonusPercentage: configuration.comboBaseBonusPercentage,
            comboIncrementPercentage: configuration.comboIncrementPercentage
        )
        self.scoreHandler = ScoreHandler(baseMultiplier: configuration.baseMultiplier)
        self.comboHandler.delegate = self
        self.scoreHandler.delegate = self
        initializeGrid()
    }

    // MARK: - Grid Management

    func initializeGrid() {
        grid = (0..<configuration.gridSize).map { _ in
            (0..<configuration.gridSize).map { _ in
                Square(colorIndex: Int.random(in: 0..<configuration.numberOfColors))
            }
        }
    }

    func square(at position: GridPosition) -> Square? {
        guard isValidPosition(position) else { return nil }
        return grid[position.y][position.x]
    }

    func colorIndex(at position: GridPosition) -> Int? {
        square(at: position)?.colorIndex
    }

    func isValidPosition(_ position: GridPosition) -> Bool {
        position.x >= 0 && position.x < configuration.gridSize &&
        position.y >= 0 && position.y < configuration.gridSize
    }

    // MARK: - Selection Logic

    func selectSquare(at position: GridPosition) {
        guard !isGameOver, isValidPosition(position) else { return }

        if let currentSelection = selectedPosition {
            if currentSelection == position {
                clearSelection()
            } else {
                attemptMatch(from: currentSelection, to: position)
            }
        } else {
            selectedPosition = position
            delegate?.brainDidSelectSquares(self, squares: [position])
        }
    }

    func clearSelection() {
        selectedPosition = nil
        delegate?.brainDidClearSelection(self)
    }

    func previewSelection(from start: GridPosition, to end: GridPosition) -> Set<GridPosition> {
        guard isValidPosition(start), isValidPosition(end) else { return [] }
        return Set(GridPosition.area(from: start, to: end))
    }

    // MARK: - Match Logic

    func attemptMatch(from start: GridPosition, to end: GridPosition) {
        let corners = GridPosition.corners(from: start, to: end)

        if checkCornersMatch(corners) {
            handleSuccessfulMatch(from: start, to: end)
        } else {
            delegate?.brainDidFailSelection(self, from: start, to: end)
            clearSelection()
        }
    }

    func checkCornersMatch(_ corners: [GridPosition]) -> Bool {
        guard corners.count == 4 else { return false }

        let colorIndices = corners.compactMap { colorIndex(at: $0) }
        guard colorIndices.count == 4 else { return false }

        return Set(colorIndices).count == 1
    }

    private func handleSuccessfulMatch(from start: GridPosition, to end: GridPosition) {
        let area = GridPosition.area(from: start, to: end)
        let squaresCleared = area.count

        comboHandler.updateCombo()

        let modeScore = gameModeLogic.calculateScore(
            squaresCleared: squaresCleared,
            baseMultiplier: configuration.baseMultiplier,
            comboMultiplier: comboHandler.comboMultiplier
        )
        scoreHandler.addRawScore(modeScore)

        let previousLevel = currentLevel
        gameModeLogic.onSuccessfulMatch(squaresCleared: squaresCleared, brain: self)

        regenerateHealth(forSquaresCleared: squaresCleared)
        regenerateSquares(in: area)

        updateLevelIfNeeded(previousLevel: previousLevel)

        delegate?.brainDidClearSquares(self, from: start, to: end)
        clearSelection()
        delegate?.brainDidUpdateGrid(self)
    }

    private func regenerateSquares(in positions: [GridPosition]) {
        for position in positions {
            grid[position.y][position.x] = Square(
                colorIndex: Int.random(in: 0..<configuration.numberOfColors)
            )
        }
    }

    func calculateScore(forArea start: GridPosition, to end: GridPosition) -> Int {
        scoreHandler.calculateScore(forArea: start, to: end)
    }

    // MARK: - Health Management

    func regenerateHealth(forSquaresCleared squaresCleared: Int) {
        let regeneration = gameModeLogic.calculateHealthRegeneration(
            baseRegeneration: configuration.healthRegenerationPercentage,
            squaresCleared: squaresCleared,
            comboMultiplier: comboHandler.comboMultiplier,
            configuration: configuration
        )

        health = min(1.0, health + regeneration)
        delegate?.brainDidUpdateHealth(self, health: health)
    }

    func drainHealth(deltaTime: TimeInterval) {
        guard !isGameOver else { return }

        let drainAmount = deltaTime / currentHealthDrainDuration
        health = max(0, health - drainAmount)

        delegate?.brainDidUpdateHealth(self, health: health)

        if gameModeLogic.shouldGameOver(health: health) {
            triggerGameOver()
        }
    }

    // MARK: - Game State

    func startGame() {
        resetGame()
        gameModeLogic.onGameStart(brain: self)
        startHealthDrain()
        startTimerUpdateIfNeeded()
    }

    func resetGame() {
        scoreHandler.resetScore()
        health = 1.0
        isGameOver = false
        selectedPosition = nil
        comboHandler.resetCombo()
        initializeGrid()

        delegate?.brainDidUpdateGrid(self)
        delegate?.brainDidUpdateScore(self, score: scoreHandler.score)
        delegate?.brainDidUpdateHealth(self, health: health)
        delegate?.brainDidClearSelection(self)

        if let progress = gameModeLogic.getLevelProgress() {
            delegate?.brainDidUpdateLevel(self, level: progress.level)
            let expProgress = progress.experienceToNextLevel > 0
                ? Double(progress.experience) / Double(progress.experienceToNextLevel)
                : 0
            delegate?.brainDidUpdateExperience(self, progress: expProgress)
        }
    }

    func pauseGame() {
        stopHealthDrain()
        stopTimerUpdate()
        if let survival = gameModeLogic as? SurvivalModeLogic {
            survival.pauseTimer()
        }
    }

    func resumeGame() {
        guard !isGameOver else { return }
        startHealthDrain()
        startTimerUpdateIfNeeded()
        if let survival = gameModeLogic as? SurvivalModeLogic {
            survival.resumeTimer()
        }
    }

    func getGameOverResult() -> GameModeResult {
        gameModeLogic.onGameOver(brain: self)
    }

    // MARK: - Timer Management

    private func startHealthDrain() {
        lastUpdateTime = Date()
        healthDrainTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.updateHealthDrain()
        }
    }

    private func stopHealthDrain() {
        healthDrainTimer?.invalidate()
        healthDrainTimer = nil
        lastUpdateTime = nil
    }

    private func updateHealthDrain() {
        let now = Date()
        if let lastUpdate = lastUpdateTime {
            let deltaTime = now.timeIntervalSince(lastUpdate)
            drainHealth(deltaTime: deltaTime)
        }
        lastUpdateTime = now
    }

    private func startTimerUpdateIfNeeded() {
        guard gameModeLogic.shouldShowTimer() else { return }
        timerUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let time = self.gameModeLogic.getTimerValue() else { return }
            self.delegate?.brainDidUpdateTimer(self, time: time)
        }
    }

    private func stopTimerUpdate() {
        timerUpdateTimer?.invalidate()
        timerUpdateTimer = nil
    }

    private func updateLevelIfNeeded(previousLevel: Int) {
        guard let progress = gameModeLogic.getLevelProgress() else { return }
        let expProgress = progress.experienceToNextLevel > 0
            ? Double(progress.experience) / Double(progress.experienceToNextLevel)
            : 0
        delegate?.brainDidUpdateExperience(self, progress: expProgress)
        delegate?.brainDidUpdateLevel(self, level: progress.level)

        if progress.level > previousLevel {
            delegate?.brainDidLevelUp(self, from: previousLevel, to: progress.level)
        }
    }

    private func triggerGameOver() {
        isGameOver = true
        stopHealthDrain()
        stopTimerUpdate()
        delegate?.brainDidGameOver(self)
    }
}

// MARK: - ComboHandlerDelegate

extension Brain: ComboHandlerDelegate {
    func comboHandler(_ handler: ComboHandler, didTriggerCombo comboCount: Int) {
        delegate?.brainDidTriggerCombo(self, comboCount: comboCount)
    }
}

// MARK: - ScoreHandlerDelegate

extension Brain: ScoreHandlerDelegate {
    func scoreHandler(_ handler: ScoreHandler, didUpdateScore score: Int) {
        delegate?.brainDidUpdateScore(self, score: score)
    }
}
