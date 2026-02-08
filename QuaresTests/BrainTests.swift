import XCTest
@testable import Quares

final class BrainTests: XCTestCase {
    var brain: Brain!
    var delegate: MockBrainDelegate!

    override func setUp() {
        super.setUp()
        let config = GameConfiguration()
        brain = Brain(configuration: config)
        delegate = MockBrainDelegate()
        brain.delegate = delegate
    }

    override func tearDown() {
        brain = nil
        delegate = nil
        super.tearDown()
    }

    // MARK: - Grid Tests

    func testGridInitialization() {
        XCTAssertEqual(brain.grid.count, 10)
        XCTAssertEqual(brain.grid[0].count, 10)
    }

    func testGridInitializationWithCustomSize() {
        var config = GameConfiguration()
        config.gridSize = 5
        let customBrain = Brain(configuration: config)

        XCTAssertEqual(customBrain.grid.count, 5)
        XCTAssertEqual(customBrain.grid[0].count, 5)
    }

    func testSquareAtValidPosition() {
        let position = GridPosition(x: 0, y: 0)
        let square = brain.square(at: position)

        XCTAssertNotNil(square)
        XCTAssertFalse(square!.isEmpty)
    }

    func testSquareAtInvalidPosition() {
        let position = GridPosition(x: 100, y: 100)
        let square = brain.square(at: position)

        XCTAssertNil(square)
    }

    func testIsValidPosition() {
        XCTAssertTrue(brain.isValidPosition(GridPosition(x: 0, y: 0)))
        XCTAssertTrue(brain.isValidPosition(GridPosition(x: 9, y: 9)))
        XCTAssertFalse(brain.isValidPosition(GridPosition(x: -1, y: 0)))
        XCTAssertFalse(brain.isValidPosition(GridPosition(x: 10, y: 0)))
        XCTAssertFalse(brain.isValidPosition(GridPosition(x: 0, y: 10)))
    }

    // MARK: - GridPosition Tests

    func testGridPositionArea() {
        let start = GridPosition(x: 1, y: 1)
        let end = GridPosition(x: 3, y: 3)
        let area = GridPosition.area(from: start, to: end)

        XCTAssertEqual(area.count, 9) // 3x3 = 9 squares
    }

    func testGridPositionAreaReversed() {
        let start = GridPosition(x: 3, y: 3)
        let end = GridPosition(x: 1, y: 1)
        let area = GridPosition.area(from: start, to: end)

        XCTAssertEqual(area.count, 9)
    }

    func testGridPositionCorners() {
        let start = GridPosition(x: 1, y: 1)
        let end = GridPosition(x: 4, y: 4)
        let corners = GridPosition.corners(from: start, to: end)

        XCTAssertEqual(corners.count, 4)
        XCTAssertTrue(corners.contains(GridPosition(x: 1, y: 1)))
        XCTAssertTrue(corners.contains(GridPosition(x: 4, y: 1)))
        XCTAssertTrue(corners.contains(GridPosition(x: 1, y: 4)))
        XCTAssertTrue(corners.contains(GridPosition(x: 4, y: 4)))
    }

    func testGridPositionCornersReversed() {
        let start = GridPosition(x: 4, y: 4)
        let end = GridPosition(x: 1, y: 1)
        let corners = GridPosition.corners(from: start, to: end)

        XCTAssertEqual(corners.count, 4)
        XCTAssertTrue(corners.contains(GridPosition(x: 1, y: 1)))
        XCTAssertTrue(corners.contains(GridPosition(x: 4, y: 4)))
    }

    // MARK: - Selection Tests

    func testSelectSquare() {
        let position = GridPosition(x: 0, y: 0)
        brain.selectSquare(at: position)

        XCTAssertEqual(brain.selectedPosition, position)
        XCTAssertTrue(delegate.selectedSquaresCalled)
    }

    func testDeselectSameSquare() {
        let position = GridPosition(x: 0, y: 0)
        brain.selectSquare(at: position)
        brain.selectSquare(at: position)

        XCTAssertNil(brain.selectedPosition)
        XCTAssertTrue(delegate.clearSelectionCalled)
    }

    func testClearSelection() {
        let position = GridPosition(x: 0, y: 0)
        brain.selectSquare(at: position)
        brain.clearSelection()

        XCTAssertNil(brain.selectedPosition)
        XCTAssertTrue(delegate.clearSelectionCalled)
    }

    func testPreviewSelection() {
        let start = GridPosition(x: 0, y: 0)
        let end = GridPosition(x: 2, y: 2)
        let preview = brain.previewSelection(from: start, to: end)

        XCTAssertEqual(preview.count, 9)
    }

    // MARK: - Match Tests

    func testCheckCornersMatch_AllSame() {
        // Manually set up corners with same color
        brain.grid[0][0] = Square(colorIndex: 0)
        brain.grid[0][2] = Square(colorIndex: 0)
        brain.grid[2][0] = Square(colorIndex: 0)
        brain.grid[2][2] = Square(colorIndex: 0)

        let corners = [
            GridPosition(x: 0, y: 0),
            GridPosition(x: 2, y: 0),
            GridPosition(x: 0, y: 2),
            GridPosition(x: 2, y: 2)
        ]

        XCTAssertTrue(brain.checkCornersMatch(corners))
    }

    func testCheckCornersMatch_Different() {
        brain.grid[0][0] = Square(colorIndex: 0)
        brain.grid[0][2] = Square(colorIndex: 1)
        brain.grid[2][0] = Square(colorIndex: 0)
        brain.grid[2][2] = Square(colorIndex: 0)

        let corners = [
            GridPosition(x: 0, y: 0),
            GridPosition(x: 2, y: 0),
            GridPosition(x: 0, y: 2),
            GridPosition(x: 2, y: 2)
        ]

        XCTAssertFalse(brain.checkCornersMatch(corners))
    }

    func testCheckCornersMatch_NotEnoughCorners() {
        let corners = [GridPosition(x: 0, y: 0)]
        XCTAssertFalse(brain.checkCornersMatch(corners))
    }

    // MARK: - Scoring Tests

    func testAddScore() {
        brain.addScore(forSquaresCleared: 9)

        XCTAssertEqual(brain.score, 9) // 9 * 1.0 multiplier
        XCTAssertTrue(delegate.updateScoreCalled)
    }

    func testCalculateScore() {
        let start = GridPosition(x: 0, y: 0)
        let end = GridPosition(x: 2, y: 2)
        let expectedScore = brain.calculateScore(forArea: start, to: end)

        XCTAssertEqual(expectedScore, 9)
    }

    // MARK: - Health Tests

    func testInitialHealth() {
        XCTAssertEqual(brain.health, 1.0)
    }

    func testRegenerateHealth() {
        brain.drainHealth(deltaTime: 10.0)
        let healthBefore = brain.health
        brain.regenerateHealth(forSquaresCleared: 9)

        XCTAssertGreaterThan(brain.health, healthBefore)
        XCTAssertTrue(delegate.updateHealthCalled)
    }

    func testHealthRegenerationCap() {
        brain.regenerateHealth(forSquaresCleared: 1)

        XCTAssertEqual(brain.health, 1.0)
    }

    func testHealthRegenerationProportionalToSelectionSize() {
        brain.drainHealth(deltaTime: 100.0)
        let healthBeforeLow = brain.health
        brain.regenerateHealth(forSquaresCleared: 1)
        let healthAfterSmall = brain.health

        brain.drainHealth(deltaTime: 100.0)
        brain.regenerateHealth(forSquaresCleared: 100)
        let healthAfterFull = brain.health

        XCTAssertGreaterThan(healthAfterFull, healthAfterSmall)
        XCTAssertEqual(healthAfterFull, 1.0)
    }

    func testDrainHealth() {
        let initialHealth = brain.health
        brain.drainHealth(deltaTime: 1.0)

        XCTAssertLessThan(brain.health, initialHealth)
        XCTAssertTrue(delegate.updateHealthCalled)
    }

    func testGameOverWhenHealthDepleted() {
        brain.drainHealth(deltaTime: 100.0)

        XCTAssertTrue(brain.isGameOver)
        XCTAssertTrue(delegate.gameOverCalled)
    }

    // MARK: - Difficulty Tests

    func testCurrentHealthDrainDuration_Initial() {
        XCTAssertEqual(brain.currentHealthDrainDuration, 30.0)
    }

    func testCurrentHealthDrainDuration_IncreasesWithScore() {
        brain.addScore(forSquaresCleared: 100)
        let duration1 = brain.currentHealthDrainDuration

        brain.addScore(forSquaresCleared: 100)
        let duration2 = brain.currentHealthDrainDuration

        XCTAssertLessThan(duration2, duration1)
    }

    func testCurrentHealthDrainDuration_MinimumCap() {
        // Add a lot of score to hit the minimum
        for _ in 0..<100 {
            brain.addScore(forSquaresCleared: 100)
        }

        XCTAssertGreaterThanOrEqual(brain.currentHealthDrainDuration, 2.0)
    }

    // MARK: - Game State Tests

    func testResetGame() {
        brain.addScore(forSquaresCleared: 100)
        brain.drainHealth(deltaTime: 10.0)
        brain.resetGame()

        XCTAssertEqual(brain.score, 0)
        XCTAssertEqual(brain.health, 1.0)
        XCTAssertFalse(brain.isGameOver)
        XCTAssertNil(brain.selectedPosition)
    }

    func testNoSelectionWhenGameOver() {
        brain.drainHealth(deltaTime: 100.0)
        XCTAssertTrue(brain.isGameOver)

        delegate.selectedSquaresCalled = false
        brain.selectSquare(at: GridPosition(x: 0, y: 0))

        XCTAssertFalse(delegate.selectedSquaresCalled)
    }

    // MARK: - Level Tests

    func testInitialLevel() {
        XCTAssertEqual(brain.currentLevel, 1)
    }

    func testLevelUpOnMatch() {
        // Set up a match
        brain.grid[0][0] = Square(colorIndex: 0)
        brain.grid[0][9] = Square(colorIndex: 0)
        brain.grid[9][0] = Square(colorIndex: 0)
        brain.grid[9][9] = Square(colorIndex: 0)
        
        // 10x10 = 100 squares. Level 1 needs 50 exp. 
        brain.attemptMatch(from: GridPosition(x: 0, y: 0), to: GridPosition(x: 9, y: 9))
        
        XCTAssertEqual(brain.currentLevel, 2)
        XCTAssertTrue(delegate.updateLevelCalled)
        XCTAssertTrue(delegate.levelUpCalled)
    }

    func testResetGameResetsLevel() {
        // Set up a match to level up
        brain.grid[0][0] = Square(colorIndex: 0)
        brain.grid[0][9] = Square(colorIndex: 0)
        brain.grid[9][0] = Square(colorIndex: 0)
        brain.grid[9][9] = Square(colorIndex: 0)
        brain.attemptMatch(from: GridPosition(x: 0, y: 0), to: GridPosition(x: 9, y: 9))
        
        brain.resetGame()
        XCTAssertEqual(brain.currentLevel, 1)
    }

    func testHealthDrainDurationDecreasesWithLevel() {
        let durationLevel1 = brain.currentHealthDrainDuration
        
        // Level up to level 2
        brain.grid[0][0] = Square(colorIndex: 0)
        brain.grid[0][9] = Square(colorIndex: 0)
        brain.grid[9][0] = Square(colorIndex: 0)
        brain.grid[9][9] = Square(colorIndex: 0)
        brain.attemptMatch(from: GridPosition(x: 0, y: 0), to: GridPosition(x: 9, y: 9))
        
        let durationLevel2 = brain.currentHealthDrainDuration
        XCTAssertLessThan(durationLevel2, durationLevel1)
    }

    // MARK: - Integration Tests

    func testSuccessfulMatch() {
        // Set up a matching square pattern
        brain.grid[0][0] = Square(colorIndex: 0)
        brain.grid[0][2] = Square(colorIndex: 0)
        brain.grid[2][0] = Square(colorIndex: 0)
        brain.grid[2][2] = Square(colorIndex: 0)

        let initialScore = brain.score
        brain.attemptMatch(from: GridPosition(x: 0, y: 0), to: GridPosition(x: 2, y: 2))

        XCTAssertGreaterThan(brain.score, initialScore)
        XCTAssertTrue(delegate.clearSquaresCalled)
        XCTAssertTrue(delegate.updateGridCalled)
    }

    func testUnsuccessfulMatch() {
        // Set up non-matching corners
        brain.grid[0][0] = Square(colorIndex: 0)
        brain.grid[0][2] = Square(colorIndex: 1)
        brain.grid[2][0] = Square(colorIndex: 2)
        brain.grid[2][2] = Square(colorIndex: 3)

        let initialScore = brain.score
        brain.attemptMatch(from: GridPosition(x: 0, y: 0), to: GridPosition(x: 2, y: 2))

        XCTAssertEqual(brain.score, initialScore)
        XCTAssertTrue(delegate.failSelectionCalled)
        XCTAssertTrue(delegate.clearSelectionCalled)
    }
}

// MARK: - Mock Delegate

final class MockBrainDelegate: BrainDelegate {
    var updateGridCalled = false
    var updateHealthCalled = false
    var updateScoreCalled = false
    var gameOverCalled = false
    var selectedSquaresCalled = false
    var clearSelectionCalled = false
    var clearSquaresCalled = false
    var failSelectionCalled = false
    var updateLevelCalled = false
    var updateExperienceCalled = false
    var levelUpCalled = false

    var lastHealth: Double = 0
    var lastScore: Int = 0
    var lastLevel: Int = 0
    var lastProgress: Double = 0
    var lastSelectedSquares: Set<GridPosition> = []

    func brainDidUpdateGrid(_ brain: Brain) {
        updateGridCalled = true
    }

    func brainDidUpdateHealth(_ brain: Brain, health: Double) {
        updateHealthCalled = true
        lastHealth = health
    }

    func brainDidUpdateScore(_ brain: Brain, score: Int) {
        updateScoreCalled = true
        lastScore = score
    }

    func brainDidUpdateLevel(_ brain: Brain, level: Int) {
        updateLevelCalled = true
        lastLevel = level
    }

    func brainDidUpdateExperience(_ brain: Brain, progress: Double) {
        updateExperienceCalled = true
        lastProgress = progress
    }

    func brainDidLevelUp(_ brain: Brain, from oldLevel: Int, to newLevel: Int) {
        levelUpCalled = true
    }

    func brainDidGameOver(_ brain: Brain) {
        gameOverCalled = true
    }

    func brainDidSelectSquares(_ brain: Brain, squares: Set<GridPosition>) {
        selectedSquaresCalled = true
        lastSelectedSquares = squares
    }

    func brainDidClearSelection(_ brain: Brain) {
        clearSelectionCalled = true
    }

    func brainDidClearSquares(_ brain: Brain, from: GridPosition, to: GridPosition) {
        clearSquaresCalled = true
    }

    func brainDidFailSelection(_ brain: Brain, from: GridPosition, to: GridPosition) {
        failSelectionCalled = true
    }
}
