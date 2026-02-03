import XCTest
@testable import Quares

final class ScoreHandlerTests: XCTestCase {
    var scoreHandler: ScoreHandler!
    var delegate: MockScoreHandlerDelegate!

    override func setUp() {
        super.setUp()
        scoreHandler = ScoreHandler(baseMultiplier: 1.0)
        delegate = MockScoreHandlerDelegate()
        scoreHandler.delegate = delegate
    }

    override func tearDown() {
        scoreHandler = nil
        delegate = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialScore() {
        XCTAssertEqual(scoreHandler.score, 0)
    }

    // MARK: - Add Score Tests (Without Combo)

    func testAddScore_SingleSquare() {
        scoreHandler.addScore(forSquaresCleared: 1)

        XCTAssertEqual(scoreHandler.score, 1)
    }

    func testAddScore_MultipleSquares() {
        scoreHandler.addScore(forSquaresCleared: 9)

        XCTAssertEqual(scoreHandler.score, 9)
    }

    func testAddScore_Accumulates() {
        scoreHandler.addScore(forSquaresCleared: 5)
        scoreHandler.addScore(forSquaresCleared: 3)

        XCTAssertEqual(scoreHandler.score, 8)
    }

    // MARK: - Add Score Tests (With Combo Multiplier)

    func testAddScore_WithComboMultiplier() {
        scoreHandler.addScore(forSquaresCleared: 10, comboMultiplier: 1.10)

        XCTAssertEqual(scoreHandler.score, 11)
    }

    func testAddScore_WithHigherCombo() {
        scoreHandler.addScore(forSquaresCleared: 10, comboMultiplier: 1.25)

        XCTAssertEqual(scoreHandler.score, 12)
    }

    func testAddScore_ComboMultiplierOf1() {
        scoreHandler.addScore(forSquaresCleared: 10, comboMultiplier: 1.0)

        XCTAssertEqual(scoreHandler.score, 10)
    }

    // MARK: - Calculate Score Tests

    func testCalculateScore_SingleSquare() {
        let start = GridPosition(x: 0, y: 0)
        let end = GridPosition(x: 0, y: 0)
        let calculated = scoreHandler.calculateScore(forArea: start, to: end)

        XCTAssertEqual(calculated, 1)
    }

    func testCalculateScore_3x3Area() {
        let start = GridPosition(x: 0, y: 0)
        let end = GridPosition(x: 2, y: 2)
        let calculated = scoreHandler.calculateScore(forArea: start, to: end)

        XCTAssertEqual(calculated, 9)
    }

    func testCalculateScore_5x5Area() {
        let start = GridPosition(x: 0, y: 0)
        let end = GridPosition(x: 4, y: 4)
        let calculated = scoreHandler.calculateScore(forArea: start, to: end)

        XCTAssertEqual(calculated, 25)
    }

    func testCalculateScore_DoesNotModifyScore() {
        let start = GridPosition(x: 0, y: 0)
        let end = GridPosition(x: 2, y: 2)
        _ = scoreHandler.calculateScore(forArea: start, to: end)

        XCTAssertEqual(scoreHandler.score, 0)
    }

    // MARK: - Reset Score Tests

    func testResetScore() {
        scoreHandler.addScore(forSquaresCleared: 100)
        XCTAssertEqual(scoreHandler.score, 100)

        scoreHandler.resetScore()

        XCTAssertEqual(scoreHandler.score, 0)
    }

    func testResetScore_AfterResetAddsCorrectly() {
        scoreHandler.addScore(forSquaresCleared: 50)
        scoreHandler.resetScore()
        scoreHandler.addScore(forSquaresCleared: 10)

        XCTAssertEqual(scoreHandler.score, 10)
    }

    // MARK: - Delegate Tests

    func testDelegateCalled_OnScoreUpdate() {
        scoreHandler.addScore(forSquaresCleared: 10)

        XCTAssertTrue(delegate.scoreUpdatedCalled)
        XCTAssertEqual(delegate.lastScore, 10)
    }

    func testDelegateCalled_WithCorrectScore_AfterMultipleAdds() {
        scoreHandler.addScore(forSquaresCleared: 5)
        XCTAssertEqual(delegate.lastScore, 5)

        scoreHandler.addScore(forSquaresCleared: 5)
        XCTAssertEqual(delegate.lastScore, 10)
    }

    func testDelegateNotCalled_OnReset() {
        scoreHandler.addScore(forSquaresCleared: 10)
        delegate.scoreUpdatedCalled = false

        scoreHandler.resetScore()

        XCTAssertFalse(delegate.scoreUpdatedCalled)
    }

    func testDelegateNotCalled_OnCalculate() {
        let start = GridPosition(x: 0, y: 0)
        let end = GridPosition(x: 2, y: 2)
        _ = scoreHandler.calculateScore(forArea: start, to: end)

        XCTAssertFalse(delegate.scoreUpdatedCalled)
    }

    // MARK: - Custom Base Multiplier Tests

    func testCustomBaseMultiplier() {
        let customHandler = ScoreHandler(baseMultiplier: 2.0)
        customHandler.addScore(forSquaresCleared: 5)

        XCTAssertEqual(customHandler.score, 10)
    }

    func testCustomBaseMultiplier_WithCombo() {
        let customHandler = ScoreHandler(baseMultiplier: 2.0)
        customHandler.addScore(forSquaresCleared: 5, comboMultiplier: 1.5)

        // 5 * 2.0 * 1.5 = 15
        XCTAssertEqual(customHandler.score, 15)
    }
}

// MARK: - Mock Delegate

final class MockScoreHandlerDelegate: ScoreHandlerDelegate {
    var scoreUpdatedCalled = false
    var lastScore: Int = 0

    func scoreHandler(_ handler: ScoreHandler, didUpdateScore score: Int) {
        scoreUpdatedCalled = true
        lastScore = score
    }
}
