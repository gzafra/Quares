import Foundation
import SwiftUI

protocol BrainDelegate: AnyObject {
    func brainDidUpdateGrid(_ brain: Brain)
    func brainDidUpdateHealth(_ brain: Brain, health: Double)
    func brainDidUpdateScore(_ brain: Brain, score: Int)
    func brainDidGameOver(_ brain: Brain)
    func brainDidSelectSquares(_ brain: Brain, squares: Set<GridPosition>)
    func brainDidClearSelection(_ brain: Brain)
    func brainDidClearSquares(_ brain: Brain, from: GridPosition, to: GridPosition)
    func brainDidFailSelection(_ brain: Brain, from: GridPosition, to: GridPosition)
    func brainDidTriggerCombo(_ brain: Brain, comboCount: Int)
    func brainDidUpdateTimer(_ brain: Brain, time: TimeInterval)
    func brainDidUpdateLevel(_ brain: Brain, level: Int, experience: Int, experienceToNextLevel: Int)
}

extension BrainDelegate {
    func brainDidUpdateTimer(_ brain: Brain, time: TimeInterval) {}
    func brainDidUpdateLevel(_ brain: Brain, level: Int, experience: Int, experienceToNextLevel: Int) {}
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
    private var survivalTimer: Timer?

    var score: Int { scoreHandler.score }
    var currentCombo: Int { comboHandler.currentCombo }
    var gameMode: GameMode { gameModeLogic.mode }

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
        self.gameModeLogic = gameModeLogic ?? ClassicModeLogic()
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

    func setGameModeLogic(_ logic: GameModeLogic) {
        self.gameModeLogic = logic
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

        regenerateHealth(forSquaresCleared: squaresCleared)
        regenerateSquares(in: area)
        gameModeLogic.onSuccessfulMatch(squaresCleared: squaresCleared, brain: self)

        updateLevelIfNeeded()

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
        startSurvivalTimerIfNeeded()
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
    }

    func pauseGame() {
        stopHealthDrain()
        stopSurvivalTimer()
    }

    func resumeGame() {
        guard !isGameOver else { return }
        startHealthDrain()
        startSurvivalTimerIfNeeded()
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

    private func startSurvivalTimerIfNeeded() {
        guard gameModeLogic.shouldShowTimer() else { return }
        survivalTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let survivalLogic = self.gameModeLogic as? SurvivalModeLogic else { return }
            self.delegate?.brainDidUpdateTimer(self, time: survivalLogic.getSurvivalTime())
        }
    }

    private func stopSurvivalTimer() {
        survivalTimer?.invalidate()
        survivalTimer = nil
    }

    private func updateLevelIfNeeded() {
        guard let classicLogic = gameModeLogic as? ClassicModeLogic else { return }
        let progress = classicLogic.getLevelProgress()
        delegate?.brainDidUpdateLevel(self, level: progress.level, experience: progress.experience, experienceToNextLevel: progress.experienceToNextLevel)
    }

    private func triggerGameOver() {
        isGameOver = true
        stopHealthDrain()
        stopSurvivalTimer()
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