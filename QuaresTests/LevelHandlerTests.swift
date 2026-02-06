import XCTest
@testable import Quares

final class LevelHandlerTests: XCTestCase {
    var handler: LevelHandler!
    
    override func setUp() {
        super.setUp()
        handler = LevelHandler(baseExpRequired: 50, expIncreasePercentage: 0.5, maxLevel: 100, expPerSquare: 1)
    }
    
    override func tearDown() {
        handler = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(handler.currentLevel, 1)
        XCTAssertEqual(handler.currentExperience, 0)
        XCTAssertEqual(handler.experienceRequiredForNextLevel, 50)
    }
    
    func testAddExperienceNoLevelUp() {
        handler.addExperience(forSquaresCleared: 10)
        XCTAssertEqual(handler.currentExperience, 10)
        XCTAssertEqual(handler.currentLevel, 1)
    }
    
    func testLevelUp() {
        // Gain 50 XP (enough for level 2)
        handler.addExperience(forSquaresCleared: 50)
        
        XCTAssertEqual(handler.currentLevel, 2)
        XCTAssertEqual(handler.currentExperience, 0)
        // Level 2 requirement: 50 * 1.5 = 75
        XCTAssertEqual(handler.experienceRequiredForNextLevel, 75)
    }
    
    func testMultipleLevelUp() {
        // Gain 150 XP
        // Level 1 -> 2: 50 XP (Remaining: 100)
        // Level 2 -> 3: 75 XP (Remaining: 25)
        handler.addExperience(forSquaresCleared: 150)
        
        XCTAssertEqual(handler.currentLevel, 3)
        XCTAssertEqual(handler.currentExperience, 25)
    }
    
    func testHealthDrainMultiplier() {
        XCTAssertEqual(handler.healthDrainMultiplier, 1.0) // Level 1
        
        handler.addExperience(forSquaresCleared: 50) // Level 2
        XCTAssertEqual(handler.healthDrainMultiplier, 1.02)
        
        handler.addExperience(forSquaresCleared: 100) // Level 3+
        XCTAssertGreaterThan(handler.healthDrainMultiplier, 1.02)
    }
    
    func testReset() {
        handler.addExperience(forSquaresCleared: 100)
        handler.reset()
        
        XCTAssertEqual(handler.currentLevel, 1)
        XCTAssertEqual(handler.currentExperience, 0)
    }
}
