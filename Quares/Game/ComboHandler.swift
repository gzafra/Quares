import Foundation

protocol ComboHandlerDelegate: AnyObject {
    func comboHandler(_ handler: ComboHandler, didTriggerCombo comboCount: Int)
}

final class ComboHandler {
    weak var delegate: ComboHandlerDelegate?
    
    private(set) var currentCombo: Int = 0
    private(set) var lastSuccessTime: Date?
    
    private let comboThreshold: TimeInterval
    private let comboBaseBonusPercentage: Double
    private let comboIncrementPercentage: Double
    
    init(comboThreshold: TimeInterval, comboBaseBonusPercentage: Double, comboIncrementPercentage: Double) {
        self.comboThreshold = comboThreshold
        self.comboBaseBonusPercentage = comboBaseBonusPercentage
        self.comboIncrementPercentage = comboIncrementPercentage
    }
    
    func updateCombo() {
        let now = Date()
        if let lastSuccess = lastSuccessTime {
            let timeSinceLastSuccess = now.timeIntervalSince(lastSuccess)
            if timeSinceLastSuccess <= comboThreshold {
                currentCombo += 1
            } else {
                currentCombo = 1
            }
        } else {
            currentCombo = 1
        }
        lastSuccessTime = now

        if currentCombo > 1 {
            delegate?.comboHandler(self, didTriggerCombo: currentCombo)
        }
    }
    
    func resetCombo() {
        currentCombo = 0
        lastSuccessTime = nil
    }
    
    var comboMultiplier: Double {
        guard currentCombo > 1 else { return 1.0 }
        let bonus = comboBaseBonusPercentage + Double(currentCombo - 2) * comboIncrementPercentage
        return 1.0 + bonus
    }
}
