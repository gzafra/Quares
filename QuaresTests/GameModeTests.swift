import XCTest
@testable import Quares

final class GameModeTests: XCTestCase {

    // MARK: - Training Mode Tests

    func testTrainingMode_Properties() {
        let logic = TrainingModeLogic()
        XCTAssertEqual(logic.mode, .training)
        XCTAssertFalse(logic.shouldShowHealthBar())
        XCTAssertFalse(logic.shouldShowScore())
        XCTAssertFalse(logic.shouldShowLevel())
        XCTAssertFalse(logic.shouldShowTimer())
    }

    func testTrainingMode_NoHealthDrain() {
        let logic = TrainingModeLogic()
        let duration = logic.calculateHealthDrainDuration(
            baseDuration: 30,
            score: 0,
            configuration: GameConfiguration()
        )
        XCTAssertEqual(duration, .infinity)
    }

    func testTrainingMode_NoScore() {
        let logic = TrainingModeLogic()
        let score = logic.calculateScore(
            squaresCleared: 10,
            baseMultiplier: 1.0,
            comboMultiplier: 1.0
        )
        XCTAssertEqual(score, 0)
    }

    func testTrainingMode_NeverGameOver() {
        let logic = TrainingModeLogic()
        XCTAssertFalse(logic.shouldGameOver(health: 0))
        XCTAssertFalse(logic.shouldGameOver(health: -1))
    }

    // MARK: - Classic Mode Tests

    func testClassicMode_Properties() {
        let logic = ClassicModeLogic()
        XCTAssertEqual(logic.mode, .classic)
        XCTAssertTrue(logic.shouldShowHealthBar())
        XCTAssertTrue(logic.shouldShowScore())
        XCTAssertTrue(logic.shouldShowLevel())
        XCTAssertFalse(logic.shouldShowTimer())
    }

    func testClassicMode_DifficultyScaling() {
        let logic = ClassicModeLogic()
        let config = GameConfiguration()

        let duration0 = logic.calculateHealthDrainDuration(
            baseDuration: 30,
            score: 0,
            configuration: config
        )
        XCTAssertEqual(duration0, 30)

        let duration100 = logic.calculateHealthDrainDuration(
            baseDuration: 30,
            score: 100,
            configuration: config
        )
        XCTAssertEqual(duration100, 27)
    }

    func testClassicMode_HealthRegeneration() {
        let logic = ClassicModeLogic()
        let config = GameConfiguration()

        let regen = logic.calculateHealthRegeneration(
            baseRegeneration: 0.15,
            squaresCleared: 9,
            comboMultiplier: 1.0,
            configuration: config
        )
        XCTAssertGreaterThan(regen, 0)
        XCTAssertLessThanOrEqual(regen, 1.0)
    }

    func testClassicMode_HealthRegenerationWithCombo() {
        let logic = ClassicModeLogic()
        let config = GameConfiguration()

        let regenNoCombo = logic.calculateHealthRegeneration(
            baseRegeneration: 0.15,
            squaresCleared: 9,
            comboMultiplier: 1.0,
            configuration: config
        )
        let regenWithCombo = logic.calculateHealthRegeneration(
            baseRegeneration: 0.15,
            squaresCleared: 9,
            comboMultiplier: 1.5,
            configuration: config
        )
        XCTAssertGreaterThan(regenWithCombo, regenNoCombo)
    }

    func testClassicMode_GameOverWhenHealthDepleted() {
        let logic = ClassicModeLogic()
        XCTAssertTrue(logic.shouldGameOver(health: 0))
        XCTAssertTrue(logic.shouldGameOver(health: -0.1))
        XCTAssertFalse(logic.shouldGameOver(health: 0.5))
    }

    func testClassicMode_LevelProgress() {
        let logic = ClassicModeLogic()
        let brain = Brain(gameModeLogic: logic)
        logic.onGameStart(brain: brain)

        let progress = logic.getLevelProgress()
        XCTAssertNotNil(progress)
        XCTAssertEqual(progress?.level, 1)
        XCTAssertEqual(progress?.experience, 0)
    }

    // MARK: - Survival Mode Tests

    func testSurvivalMode_Properties() {
        let logic = SurvivalModeLogic()
        XCTAssertEqual(logic.mode, .survival)
        XCTAssertTrue(logic.shouldShowHealthBar())
        XCTAssertFalse(logic.shouldShowScore())
        XCTAssertFalse(logic.shouldShowLevel())
        XCTAssertTrue(logic.shouldShowTimer())
    }

    func testSurvivalMode_ConstantHealthDrain() {
        let logic = SurvivalModeLogic()
        let duration = logic.calculateHealthDrainDuration(
            baseDuration: 30,
            score: 0,
            configuration: GameConfiguration()
        )
        XCTAssertEqual(duration, 3.0)
    }

    func testSurvivalMode_TimerStartsAtZero() {
        let logic = SurvivalModeLogic()
        let brain = Brain(gameModeLogic: logic)
        logic.onGameStart(brain: brain)

        XCTAssertEqual(logic.getTimerValue(), 0)
    }

    func testSurvivalMode_NoLevelProgress() {
        let logic = SurvivalModeLogic()
        XCTAssertNil(logic.getLevelProgress())
    }

    // MARK: - Brain Integration Tests

    func testBrainWithTrainingMode() {
        let brain = Brain(gameModeLogic: TrainingModeLogic())
        XCTAssertEqual(brain.gameMode, .training)
        XCTAssertEqual(brain.currentHealthDrainDuration, .infinity)
    }

    func testBrainWithClassicMode() {
        let brain = Brain(gameModeLogic: ClassicModeLogic())
        XCTAssertEqual(brain.gameMode, .classic)
        XCTAssertEqual(brain.currentHealthDrainDuration, 30.0)
    }

    func testBrainWithSurvivalMode() {
        let brain = Brain(gameModeLogic: SurvivalModeLogic())
        XCTAssertEqual(brain.gameMode, .survival)
        XCTAssertEqual(brain.currentHealthDrainDuration, 3.0)
    }

    func testBrainDefaultsToClassic() {
        let brain = Brain()
        XCTAssertEqual(brain.gameMode, .classic)
    }
}
