import SpriteKit

final class LevelBoard: SKNode {
    private let levelLabel: SKLabelNode
    private let expBarBackground: SKShapeNode
    private let expBarFill: SKShapeNode
    private let barWidth: CGFloat = 120
    private let barHeight: CGFloat = 8

    init(position: CGPoint) {
        self.levelLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.levelLabel.fontSize = 18
        self.levelLabel.fontColor = .white
        self.levelLabel.horizontalAlignmentMode = .right
        self.levelLabel.text = "Level 1"

        self.expBarBackground = SKShapeNode(rect: CGRect(x: -barWidth, y: -15, width: barWidth, height: barHeight), cornerRadius: 4)
        self.expBarBackground.fillColor = SKColor(white: 0.2, alpha: 1.0)
        self.expBarBackground.strokeColor = .white
        self.expBarBackground.lineWidth = 1

        self.expBarFill = SKShapeNode(rect: CGRect(x: -barWidth, y: -15, width: 0, height: barHeight), cornerRadius: 4)
        self.expBarFill.fillColor = .blue
        self.expBarFill.strokeColor = .clear

        super.init()
        self.position = position

        addChild(levelLabel)
        addChild(expBarBackground)
        addChild(expBarFill)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(level: Int, experience: Int, experienceToNextLevel: Int) {
        levelLabel.text = "Level \(level)"
        
        let progress = CGFloat(experience) / CGFloat(experienceToNextLevel)
        let fillWidth = barWidth * max(0, min(1.0, progress))
        
        expBarFill.path = CGPath(roundedRect: CGRect(x: -barWidth, y: -15, width: fillWidth, height: barHeight), cornerWidth: 4, cornerHeight: 4, transform: nil)
    }
}
