import SpriteKit

final class LevelBoard: SKNode {
    private let levelLabel: SKLabelNode
    private let expBarBackground: SKShapeNode
    private let expBarFill: SKShapeNode
    private let expLabel: SKLabelNode
    
    private let barWidth: CGFloat
    private let barHeight: CGFloat
    
    init(position: CGPoint, width: CGFloat = 120, height: CGFloat = 8) {
        self.barWidth = width
        self.barHeight = height
        
        // Level label (e.g., "Lv. 1")
        levelLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        levelLabel.text = "Lv. 1"
        levelLabel.fontSize = 18
        levelLabel.fontColor = .white
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.verticalAlignmentMode = .top
        levelLabel.position = CGPoint(x: 0, y: 0)
        
        // EXP bar background
        let barY: CGFloat = -28
        let barRect = CGRect(x: 0, y: 0, width: width, height: height)
        let cornerRadius = height / 2
        
        expBarBackground = SKShapeNode(rect: barRect, cornerRadius: cornerRadius)
        expBarBackground.fillColor = SKColor(white: 0.3, alpha: 1.0)
        expBarBackground.strokeColor = .clear
        expBarBackground.position = CGPoint(x: 0, y: barY)
        
        // EXP bar fill
        expBarFill = SKShapeNode(rect: barRect, cornerRadius: cornerRadius)
        expBarFill.fillColor = SKColor.cyan
        expBarFill.strokeColor = .clear
        expBarFill.position = CGPoint(x: 0, y: barY)
        
        // EXP label (e.g., "25/50")
        expLabel = SKLabelNode(fontNamed: "Helvetica")
        expLabel.text = "0/50"
        expLabel.fontSize = 12
        expLabel.fontColor = SKColor(white: 0.8, alpha: 1.0)
        expLabel.horizontalAlignmentMode = .left
        expLabel.verticalAlignmentMode = .top
        expLabel.position = CGPoint(x: 0, y: barY - 4)
        
        super.init()
        
        self.position = position
        addChild(levelLabel)
        addChild(expBarBackground)
        addChild(expBarFill)
        addChild(expLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(level: Int, currentExp: Int, requiredExp: Int) {
        levelLabel.text = "Lv. \(level)"
        expLabel.text = "\(currentExp)/\(requiredExp)"
        
        // Update exp bar fill
        let progress = requiredExp > 0 ? CGFloat(currentExp) / CGFloat(requiredExp) : 0
        let fillWidth = max(barWidth * progress, 0)
        let cornerRadius = barHeight / 2
        
        let newPath = CGPath(
            roundedRect: CGRect(x: 0, y: 0, width: fillWidth, height: barHeight),
            cornerWidth: cornerRadius,
            cornerHeight: cornerRadius,
            transform: nil
        )
        expBarFill.path = newPath
        
        // Color based on progress
        if progress >= 1.0 {
            expBarFill.fillColor = .green
        } else if progress > 0.7 {
            expBarFill.fillColor = SKColor.cyan
        } else if progress > 0.3 {
            expBarFill.fillColor = SKColor.yellow
        } else {
            expBarFill.fillColor = SKColor.orange
        }
    }
    
    func showLevelUpAnimation() {
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.15)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        
        levelLabel.run(pulse)
        
        // Flash effect
        let flash = SKShapeNode(rectOf: CGSize(width: barWidth + 20, height: 50))
        flash.fillColor = .white
        flash.alpha = 0.5
        flash.position = CGPoint(x: barWidth / 2, y: -15)
        addChild(flash)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        flash.run(SKAction.sequence([fadeOut, remove]))
    }
}