import SpriteKit

final class ScoreBoard: SKNode {
    private let scoreLabel: SKLabelNode

    init(position: CGPoint) {
        scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top

        super.init()

        self.position = position
        addChild(scoreLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(score: Int) {
        scoreLabel.text = "Score: \(score)"
    }
}
