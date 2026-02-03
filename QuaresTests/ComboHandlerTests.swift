import XCTest
@testable import Quares

final class ComboHandlerTests: XCTestCase {
    var comboHandler: ComboHandler!
    var delegate: MockComboHandlerDelegate!

    override func setUp() {
        super.setUp()
        comboHandler = ComboHandler(
            comboThreshold: 3.0,
            comboBaseBonusPercentage: 0.10,
            comboIncrementPercentage: 0.05
        )
        delegate = MockComboHandlerDelegate()
        comboHandler.delegate = delegate
    }

    override func tearDown() {
        comboHandler = nil
        delegate = nil
        super.tearDown()
    }

    // MARK: - Combo Increment Tests

    func testUpdateCombo_FirstSuccess() {
        comboHandler.updateCombo()

        XCTAssertEqual(comboHandler.currentCombo, 1)
        XCTAssertFalse(delegate.comboTriggeredCalled)
    }

    func testUpdateCombo_SecondSuccessWithinThreshold() {
        comboHandler.updateCombo()
        comboHandler.updateCombo()

        XCTAssertEqual(comboHandler.currentCombo, 2)
        XCTAssertTrue(delegate.comboTriggeredCalled)
        XCTAssertEqual(delegate.lastComboCount, 2)
    }

    func testUpdateCombo_ThirdSuccessWithinThreshold() {
        comboHandler.updateCombo()
        comboHandler.updateCombo()
        comboHandler.updateCombo()

        XCTAssertEqual(comboHandler.currentCombo, 3)
        XCTAssertEqual(delegate.lastComboCount, 3)
    }

    func testUpdateCombo_SuccessAfterThresholdExceeded() {
        comboHandler.updateCombo()
        comboHandler.updateCombo()

        // Simulate time passing beyond threshold by resetting lastSuccessTime
        comboHandler = ComboHandler(
            comboThreshold: 0.001,
            comboBaseBonusPercentage: 0.10,
            comboIncrementPercentage: 0.05
        )
        comboHandler.delegate = delegate

        // Wait for threshold to pass
        Thread.sleep(forTimeInterval: 0.01)

        comboHandler.updateCombo()

        // Should reset to 1 since lastSuccessTime is nil (threshold exceeded)
        XCTAssertEqual(comboHandler.currentCombo, 1)
    }

    // MARK: - Combo Multiplier Tests

    func testComboMultiplier_NoCombo() {
        XCTAssertEqual(comboHandler.comboMultiplier, 1.0)
    }

    func testComboMultiplier_Combo2() {
        // x2 = 1.0 + 0.10 = 1.10
        comboHandler.updateCombo()
        comboHandler.updateCombo()

        XCTAssertEqual(comboHandler.currentCombo, 2)
        XCTAssertEqual(comboHandler.comboMultiplier, 1.10, accuracy: 0.001)
    }

    func testComboMultiplier_Combo3() {
        // x3 = 1.0 + 0.10 + 0.05 = 1.15
        comboHandler.updateCombo()
        comboHandler.updateCombo()
        comboHandler.updateCombo()

        XCTAssertEqual(comboHandler.currentCombo, 3)
        XCTAssertEqual(comboHandler.comboMultiplier, 1.15, accuracy: 0.001)
    }

    func testComboMultiplier_Combo4() {
        // x4 = 1.0 + 0.10 + 0.05 + 0.05 = 1.20
        comboHandler.updateCombo()
        comboHandler.updateCombo()
        comboHandler.updateCombo()
        comboHandler.updateCombo()

        XCTAssertEqual(comboHandler.currentCombo, 4)
        XCTAssertEqual(comboHandler.comboMultiplier, 1.20, accuracy: 0.001)
    }

    func testComboMultiplier_Combo5() {
        // x5 = 1.0 + 0.10 + 0.05*3 = 1.25
        for _ in 0..<5 {
            comboHandler.updateCombo()
        }

        XCTAssertEqual(comboHandler.currentCombo, 5)
        XCTAssertEqual(comboHandler.comboMultiplier, 1.25, accuracy: 0.001)
    }

    // MARK: - Delegate Tests

    func testDelegateCalled_OnlyWhenComboGreaterThan1() {
        comboHandler.updateCombo()
        XCTAssertFalse(delegate.comboTriggeredCalled)

        comboHandler.updateCombo()
        XCTAssertTrue(delegate.comboTriggeredCalled)
        XCTAssertEqual(delegate.lastComboCount, 2)
    }

    func testDelegateNotCalled_FirstSuccess() {
        comboHandler.updateCombo()

        XCTAssertFalse(delegate.comboTriggeredCalled)
    }

    // MARK: - Reset Tests

    func testResetCombo() {
        comboHandler.updateCombo()
        comboHandler.updateCombo()
        XCTAssertEqual(comboHandler.currentCombo, 2)

        comboHandler.resetCombo()

        XCTAssertEqual(comboHandler.currentCombo, 0)
        XCTAssertNil(comboHandler.lastSuccessTime)
        XCTAssertEqual(comboHandler.comboMultiplier, 1.0)
    }

    func testResetCombo_AfterResetFirstSuccessIsCombo1() {
        comboHandler.updateCombo()
        comboHandler.updateCombo()
        comboHandler.resetCombo()

        delegate.comboTriggeredCalled = false
        comboHandler.updateCombo()

        XCTAssertEqual(comboHandler.currentCombo, 1)
        XCTAssertFalse(delegate.comboTriggeredCalled)
    }
}

// MARK: - Mock Delegate

final class MockComboHandlerDelegate: ComboHandlerDelegate {
    var comboTriggeredCalled = false
    var lastComboCount: Int = 0

    func comboHandler(_ handler: ComboHandler, didTriggerCombo comboCount: Int) {
        comboTriggeredCalled = true
        lastComboCount = comboCount
    }
}
