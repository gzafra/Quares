import Foundation

protocol ScoreHandlerDelegate: AnyObject {
    func scoreHandler(_ handler: ScoreHandler, didUpdateScore score: Int)
}

final class ScoreHandler {
    weak var delegate: ScoreHandlerDelegate?
    
    private(set) var score: Int = 0
    
    private let baseMultiplier: Double
    
    init(baseMultiplier: Double) {
        self.baseMultiplier = baseMultiplier
    }
    
    func resetScore() {
        score = 0
    }
    
    func addScore(forSquaresCleared count: Int, comboMultiplier: Double = 1.0) {
        let points = Int(Double(count) * baseMultiplier * comboMultiplier)
        score += points
        delegate?.scoreHandler(self, didUpdateScore: score)
    }
    
    func addRawScore(_ points: Int) {
        score += points
        delegate?.scoreHandler(self, didUpdateScore: score)
    }
    
    func calculateScore(forArea start: GridPosition, to end: GridPosition) -> Int {
        let area = GridPosition.area(from: start, to: end)
        return Int(Double(area.count) * baseMultiplier)
    }
}
