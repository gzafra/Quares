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
}

struct GridPosition: Hashable {
    let x: Int
    let y: Int

    static func area(from start: GridPosition, to end: GridPosition) -> [GridPosition] {
        let minX = min(start.x, end.x)
        let maxX = max(start.x, end.x)
        let minY = min(start.y, end.y)
        let maxY = max(start.y, end.y)

        var positions: [GridPosition] = []
        for x in minX...maxX {
            for y in minY...maxY {
                positions.append(GridPosition(x: x, y: y))
            }
        }
        return positions
    }

    static func corners(from start: GridPosition, to end: GridPosition) -> [GridPosition] {
        let minX = min(start.x, end.x)
        let maxX = max(start.x, end.x)
        let minY = min(start.y, end.y)
        let maxY = max(start.y, end.y)

        return [
            GridPosition(x: minX, y: minY),
            GridPosition(x: maxX, y: minY),
            GridPosition(x: minX, y: maxY),
            GridPosition(x: maxX, y: maxY)
        ]
    }
}

struct Square {
    var colorIndex: Int
    var isEmpty: Bool = false
}

final class Brain {
    // MARK: - Properties

    weak var delegate: BrainDelegate?

    private(set) var configuration: GameConfiguration
    private(set) var grid: [[Square]]
    private(set) var score: Int = 0
    private(set) var health: Double = 1.0
    private(set) var isGameOver: Bool = false
    private(set) var selectedPosition: GridPosition?

    private var healthDrainTimer: Timer?
    private var lastUpdateTime: Date?

    var currentHealthDrainDuration: TimeInterval {
        let difficultyLevel = score / configuration.difficultyIncreasePerScore
        let speedIncrease = Double(difficultyLevel) * configuration.drainSpeedIncreasePercentage
        let newDuration = configuration.initialHealthDrainDuration * (1.0 - speedIncrease)
        return max(newDuration, configuration.minimumHealthDrainDuration)
    }

    var multiplier: Double {
        configuration.baseMultiplier
    }

    // MARK: - Initialization

    init(configuration: GameConfiguration = GameConfiguration()) {
        self.configuration = configuration
        self.grid = []
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

        addScore(forSquaresCleared: squaresCleared)
        regenerateHealth()
        regenerateSquares(in: area)

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

    // MARK: - Scoring

    func addScore(forSquaresCleared count: Int) {
        let points = Int(Double(count) * multiplier)
        score += points
        delegate?.brainDidUpdateScore(self, score: score)
    }

    func calculateScore(forArea start: GridPosition, to end: GridPosition) -> Int {
        let area = GridPosition.area(from: start, to: end)
        return Int(Double(area.count) * multiplier)
    }

    // MARK: - Health Management

    func regenerateHealth() {
        health = min(1.0, health + configuration.healthRegenerationPercentage)
        delegate?.brainDidUpdateHealth(self, health: health)
    }

    func drainHealth(deltaTime: TimeInterval) {
        guard !isGameOver else { return }

        let drainAmount = deltaTime / currentHealthDrainDuration
        health = max(0, health - drainAmount)

        delegate?.brainDidUpdateHealth(self, health: health)

        if health <= 0 {
            triggerGameOver()
        }
    }

    // MARK: - Game State

    func startGame() {
        resetGame()
        startHealthDrain()
    }

    func resetGame() {
        score = 0
        health = 1.0
        isGameOver = false
        selectedPosition = nil
        initializeGrid()

        delegate?.brainDidUpdateGrid(self)
        delegate?.brainDidUpdateScore(self, score: score)
        delegate?.brainDidUpdateHealth(self, health: health)
        delegate?.brainDidClearSelection(self)
    }

    func pauseGame() {
        stopHealthDrain()
    }

    func resumeGame() {
        guard !isGameOver else { return }
        startHealthDrain()
    }

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

    private func triggerGameOver() {
        isGameOver = true
        stopHealthDrain()
        delegate?.brainDidGameOver(self)
    }
}
