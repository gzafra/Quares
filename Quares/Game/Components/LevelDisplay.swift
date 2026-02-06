import SpriteKit

final class LevelDisplay: SKNode {
    private let levelLabel: SKLabelNode
    private let experienceBarBackground: SKShapeNode
    private let experienceBarFill: SKShapeNode
    
    private let barWidth: CGFloat
    private let barHeight: CGFloat = 8
    
    init(width: CGFloat, position: CGPoint) {
        self.barWidth = width
        
        // Level label
        levelLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        levelLabel.text = "Level: 1"
        levelLabel.fontSize = 20
        levelLabel.fontColor = .white
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.verticalAlignmentMode = .top
        
        // Experience bar background
        let barRect = CGRect(x: 0, y: 0, width: width, height: barHeight)
        experienceBarBackground = SKShapeNode(rect: barRect, cornerRadius: barHeight / 2)
        experienceBarBackground.fillColor = SKColor(white: 0.3, alpha: 1.0)
        experienceBarBackground.strokeColor = .clear
        
        // Experience bar fill
        experienceBarFill = SKShapeNode(rect: barRect, cornerRadius: barHeight / 2)
        experienceBarFill.fillColor = SKColor.cyan
        experienceBarFill.strokeColor = .clear
        
        super.init()
        
        self.position = position
        
        // Position elements
        levelLabel.position = CGPoint(x: 0, y: 0)
        experienceBarBackground.position = CGPoint(x: 0, y: -barHeight - 4)
        experienceBarFill.position = CGPoint(x: 0, y: -barHeight - 4)
        
        addChild(levelLabel)
        addChild(experienceBarBackground)
        addChild(experienceBarFill)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(level: Int, currentExp: Double, requiredExp: Double) {
        levelLabel.text = "Level: \(level)"
        
        let progress: Double
        if requiredExp.isInfinite || requiredExp <= 0 {
            progress = 1.0
        } else {
            progress = min(currentExp / requiredExp, 1.0)
        }
        
        let fillWidth = max(barWidth * CGFloat(progress), 0)
        let cornerRadius = barHeight / 2
        
        let newPath = CGPath(
            roundedRect: CGRect(x: 0, y: 0, width: fillWidth, height: barHeight),
            cornerWidth: cornerRadius,
            cornerHeight: cornerRadius,
            transform: nil
        )
        experienceBarFill.path = newPath
    }
}
