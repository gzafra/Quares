import XCTest
@testable import Quares

final class LevelHandlerTests: XCTestCase {
    var levelHandler: LevelHandler!
    var delegate: MockLevelHandlerDelegate!
    var config: LevelConfiguration!

    override func setUp() {
        super.setUp()
        config = LevelConfiguration(
            maxLevels: 100,
            baseExperienceRequired: 50,
            experienceIncreasePercentage: 0.5,
            experiencePerSquare: 1,
            healthDrainSpeedIncreasePerLevel: 0.05
        )
        levelHandler = LevelHandler(configuration: config)
        delegate = MockLevelHandlerDelegate()
        levelHandler.delegate = delegate
    }

    override func tearDown() {
        levelHandler = nil
        delegate = nil
        config = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(levelHandler.currentLevel, 1)
        XCTAssertEqual(levelHandler.currentExperience, 0)
        XCTAssertEqual(levelHandler.experienceRequiredForNextLevel, 50)
    }

    func testAddExperience_NoLevelUp() {
        levelHandler.addExperience(forSquaresCleared: 10)
        XCTAssertEqual(levelHandler.currentExperience, 10)
        XCTAssertEqual(levelHandler.currentLevel, 1)
        XCTAssertTrue(delegate.experienceUpdatedCalled)
    }

    func testAddExperience_LevelUp() {
        levelHandler.addExperience(forSquaresCleared: 50)
        XCTAssertEqual(levelHandler.currentLevel, 2)
        XCTAssertEqual(levelHandler.currentExperience, 0)
        XCTAssertTrue(delegate.levelUpdatedCalled)
        XCTAssertTrue(delegate.levelUpCalled)
        XCTAssertEqual(delegate.lastLevel, 2)
    }

    func testAddExperience_MultipleLevelUps() {
        // Level 1: 50 exp -> Level 2
        // Level 2: 50 * 1.5 = 75 exp -> Level 3
        // Total needed for Level 3: 125 exp
        levelHandler.addExperience(forSquaresCleared: 130)
        XCTAssertEqual(levelHandler.currentLevel, 3)
        XCTAssertEqual(levelHandler.currentExperience, 5)
    }

    func testHealthDrainSpeedMultiplier() {
        XCTAssertEqual(levelHandler.healthDrainSpeedMultiplier, 1.0)
        
        levelHandler.addExperience(forSquaresCleared: 50) // Level 2
        XCTAssertEqual(levelHandler.healthDrainSpeedMultiplier, 1.05)
        
        levelHandler.addExperience(forSquaresCleared: 75) // Level 3
        XCTAssertEqual(levelHandler.healthDrainSpeedMultiplier, 1.10)
    }

    func testResetLevel() {
        levelHandler.addExperience(forSquaresCleared: 50)
        levelHandler.resetLevel()
        XCTAssertEqual(levelHandler.currentLevel, 1)
        XCTAssertEqual(levelHandler.currentExperience, 0)
    }
}

final class MockLevelHandlerDelegate: LevelHandlerDelegate {
    var levelUpdatedCalled = false
    var experienceUpdatedCalled = false
    var levelUpCalled = false
    var lastLevel: Int = 0
    var lastExperience: Int = 0

    func levelHandler(_ handler: LevelHandler, didUpdateLevel level: Int) {
        levelUpdatedCalled = true
        lastLevel = level
    }

    func levelHandler(_ handler: LevelHandler, didUpdateExperience experience: Int, requiredForNextLevel: Int) {
        experienceUpdatedCalled = true
        lastExperience = experience
    }

    func levelHandler(_ handler: LevelHandler, didLevelUpFrom oldLevel: Int, to newLevel: Int) {
        levelUpCalled = true
    }
}
