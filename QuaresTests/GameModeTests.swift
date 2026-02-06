import XCTest
@testable import Quares

final class GameModeTests: XCTestCase {
    
    func testTrainingMode() {
        let logic = TrainingModeLogic()
        XCTAssertEqual(logic.mode, .training)
        XCTAssertFalse(logic.shouldShowHealthBar())
        XCTAssertFalse(logic.shouldShowScore())
        XCTAssertFalse(logic.shouldShowLevel())
        XCTAssertFalse(logic.shouldShowTimer())
        XCTAssertEqual(logic.calculateHealthDrainDuration(baseDuration: 30, score: 0, configuration: GameConfiguration()), .infinity)
        XCTAssertEqual(logic.calculateScore(squaresCleared: 10, baseMultiplier: 1.0, comboMultiplier: 1.0), 0)
    }
    
    func testClassicModeDifficultyScaling() {
        let logic = ClassicModeLogic()
        let config = GameConfiguration()
        
        // At 0 score, duration should be initial
        let duration0 = logic.calculateHealthDrainDuration(baseDuration: 30, score: 0, configuration: config)
        XCTAssertEqual(duration0, 30)
        
        // At 100 score, duration should decrease by 10% (drainSpeedIncreasePercentage)
        let duration100 = logic.calculateHealthDrainDuration(baseDuration: 30, score: 100, configuration: config)
        XCTAssertEqual(duration100, 27) // 30 * (1 - 0.1)
    }
    
    func testSurvivalModeTimer() {
        let logic = SurvivalModeLogic()
        XCTAssertTrue(logic.shouldShowTimer())
        XCTAssertFalse(logic.shouldShowScore())
        
        let brain = Brain(gameModeLogic: logic)
        logic.onGameStart(brain: brain)
        
        XCTAssertEqual(logic.getSurvivalTime(), 0)
        
        // We can't easily test the timer ticking without wait, but we can verify it's survival mode
        XCTAssertEqual(logic.calculateHealthDrainDuration(baseDuration: 30, score: 0, configuration: GameConfiguration()), 3.0)
    }
}
