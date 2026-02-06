import XCTest
@testable import Quares

final class LevelHandlerTests: XCTestCase {
    var levelHandler: LevelHandler!
    var delegate: MockLevelHandlerDelegate!
    var configuration: GameConfiguration!

    override func setUp() {
        super.setUp()
        configuration = GameConfiguration()
        levelHandler = LevelHandler(configuration: configuration)
        delegate = MockLevelHandlerDelegate()
        levelHandler.delegate = delegate
    }

    override func tearDown() {
        levelHandler = nil
        delegate = nil
        configuration = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialLevel() {
        XCTAssertEqual(levelHandler.currentLevel, 1)
    }

    func testInitialExperience() {
        XCTAssertEqual(levelHandler.currentExperience, 0.0)
    }

    func testInitialExperienceRequired() {
        XCTAssertEqual(levelHandler.experienceRequiredForNextLevel, configuration.baseExperienceRequired)
    }

    func testInitialHealthDrainMultiplier() {
        XCTAssertEqual(levelHandler.healthDrainMultiplier, 1.0)
    }

    // MARK: - Add Experience Tests

    func testAddExperience_SingleSquare() {
        levelHandler.addExperience(fromSquaresCleared: 1)

        XCTAssertEqual(levelHandler.currentExperience, 1.0)
        XCTAssertEqual(levelHandler.currentLevel, 1)
    }

    func testAddExperience_MultipleSquares() {
        levelHandler.addExperience(fromSquaresCleared: 10)

        XCTAssertEqual(levelHandler.currentExperience, 10.0)
    }

    func testAddExperience_Accumulates() {
        levelHandler.addExperience(fromSquaresCleared: 5)
        levelHandler.addExperience(fromSquaresCleared: 10)

        XCTAssertEqual(levelHandler.currentExperience, 15.0)
    }

    // MARK: - Level Up Tests

    func testLevelUp_WhenExperienceReachesThreshold() {
        // Add exactly enough experience to level up (base = 50)
        levelHandler.addExperience(fromSquaresCleared: 50)

        XCTAssertEqual(levelHandler.currentLevel, 2)
        XCTAssertEqual(levelHandler.currentExperience, 0.0)
    }

    func testLevelUp_ExcessExperienceCarriesOver() {
        // Add more than needed to level up
        levelHandler.addExperience(fromSquaresCleared: 60)

        XCTAssertEqual(levelHandler.currentLevel, 2)
        XCTAssertEqual(levelHandler.currentExperience, 10.0)
    }

    func testLevelUp_MultipleLevels() {
        // Level 1: requires 50
        // Level 2: requires 50 * 1.5 = 75
        // Total to reach level 3: 50 + 75 = 125
        levelHandler.addExperience(fromSquaresCleared: 125)

        XCTAssertEqual(levelHandler.currentLevel, 3)
        XCTAssertEqual(levelHandler.currentExperience, 0.0)
    }

    func testLevelUp_ExperienceCalculation() {
        // Level 1: requires 50
        // Level 2: requires 50 * 1.5 = 75
        // Level 3: requires 75 * 1.5 = 112.5
        levelHandler.addExperience(fromSquaresCleared: 125) // Level 2
        levelHandler.addExperience(fromSquaresCleared: 113) // Level 3

        XCTAssertEqual(levelHandler.currentLevel, 3)
        XCTAssertEqual(levelHandler.experienceRequiredForNextLevel, 112.5, accuracy: 0.01)
    }

    // MARK: - Max Level Tests

    func testMaxLevel_CannotExceedMax() {
        // Manually set to max level
        for _ in 1..<configuration.maxLevels {
            levelHandler.addExperience(fromSquaresCleared: Int(levelHandler.experienceRequiredForNextLevel) + 1)
        }

        XCTAssertEqual(levelHandler.currentLevel, configuration.maxLevels)

        // Try to add more experience - should not change anything
        let previousExp = levelHandler.currentExperience
        levelHandler.addExperience(fromSquaresCleared: 1000)

        XCTAssertEqual(levelHandler.currentExperience, previousExp)
        XCTAssertEqual(levelHandler.currentLevel, configuration.maxLevels)
    }

    func testMaxLevel_InfiniteExperienceRequired() {
        // Manually set to max level
        for _ in 1..<configuration.maxLevels {
            levelHandler.addExperience(fromSquaresCleared: Int(levelHandler.experienceRequiredForNextLevel) + 1)
        }

        XCTAssertEqual(levelHandler.experienceRequiredForNextLevel, Double.infinity)
        XCTAssertEqual(levelHandler.currentExperience, 0.0)
    }

    // MARK: - Reset Tests

    func testResetLevel() {
        levelHandler.addExperience(fromSquaresCleared: 100)
        levelHandler.resetLevel()

        XCTAssertEqual(levelHandler.currentLevel, 1)
        XCTAssertEqual(levelHandler.currentExperience, 0.0)
        XCTAssertEqual(levelHandler.experienceRequiredForNextLevel, configuration.baseExperienceRequired)
    }

    // MARK: - Health Drain Multiplier Tests

    func testHealthDrainMultiplier_Level1() {
        XCTAssertEqual(levelHandler.healthDrainMultiplier, 1.0)
    }

    func testHealthDrainMultiplier_Level2() {
        levelHandler.addExperience(fromSquaresCleared: 50)
        // Level 2: 1.0 + (1 * 0.02) = 1.02
        XCTAssertEqual(levelHandler.healthDrainMultiplier, 1.02, accuracy: 0.001)
    }

    func testHealthDrainMultiplier_Level10() {
        // Level 10: 1.0 + (9 * 0.02) = 1.18
        for _ in 1..<10 {
            levelHandler.addExperience(fromSquaresCleared: Int(levelHandler.experienceRequiredForNextLevel) + 1)
        }

        XCTAssertEqual(levelHandler.currentLevel, 10)
        XCTAssertEqual(levelHandler.healthDrainMultiplier, 1.18, accuracy: 0.001)
    }

    func testHealthDrainMultiplier_MaxLevel() {
        // Level 100: 1.0 + (99 * 0.02) = 2.98
        for _ in 1..<configuration.maxLevels {
            levelHandler.addExperience(fromSquaresCleared: Int(levelHandler.experienceRequiredForNextLevel) + 1)
        }

        XCTAssertEqual(levelHandler.healthDrainMultiplier, 2.98, accuracy: 0.001)
    }

    // MARK: - Delegate Tests

    func testDelegate_CalledOnExperienceUpdate() {
        levelHandler.addExperience(fromSquaresCleared: 10)

        XCTAssertTrue(delegate.didUpdateExperienceCalled)
        XCTAssertEqual(delegate.lastCurrentExp, 10.0)
        XCTAssertEqual(delegate.lastRequiredExp, configuration.baseExperienceRequired)
    }

    func testDelegate_CalledOnLevelUp() {
        levelHandler.addExperience(fromSquaresCleared: 50)

        XCTAssertTrue(delegate.didUpdateLevelCalled)
        XCTAssertEqual(delegate.lastLevel, 2)
    }

    func testDelegate_CalledOnReset() {
        levelHandler.addExperience(fromSquaresCleared: 50)
        delegate.reset()
        levelHandler.resetLevel()

        XCTAssertTrue(delegate.didUpdateLevelCalled)
        XCTAssertTrue(delegate.didUpdateExperienceCalled)
        XCTAssertEqual(delegate.lastLevel, 1)
        XCTAssertEqual(delegate.lastCurrentExp, 0.0)
    }
}

// MARK: - Mock Delegate

class MockLevelHandlerDelegate: LevelHandlerDelegate {
    var didUpdateLevelCalled = false
    var didUpdateExperienceCalled = false
    var lastLevel: Int = 0
    var lastCurrentExp: Double = 0.0
    var lastRequiredExp: Double = 0.0

    func reset() {
        didUpdateLevelCalled = false
        didUpdateExperienceCalled = false
        lastLevel = 0
        lastCurrentExp = 0.0
        lastRequiredExp = 0.0
    }

    func levelHandler(_ handler: LevelHandler, didUpdateLevel level: Int) {
        didUpdateLevelCalled = true
        lastLevel = level
    }

    func levelHandler(_ handler: LevelHandler, didUpdateExperience currentExp: Double, requiredExp: Double) {
        didUpdateExperienceCalled = true
        lastCurrentExp = currentExp
        lastRequiredExp = requiredExp
    }
}
