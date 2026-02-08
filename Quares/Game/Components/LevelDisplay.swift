import SpriteKit

final class LevelDisplay: SKNode {
    private let levelLabel: SKLabelNode
    private let experienceBar: ExperienceBar
    private let verticalSpacing: CGFloat = 4
    
    init(position: CGPoint, barWidth: CGFloat, barHeight: CGFloat = 8) {
        levelLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        levelLabel.text = "Level: 1"
        levelLabel.fontSize = 20
        levelLabel.fontColor = .white
        levelLabel.horizontalAlignmentMode = .right
        levelLabel.verticalAlignmentMode = .top
        
        experienceBar = ExperienceBar(
            width: barWidth,
            height: barHeight,
            position: CGPoint(x: 0, y: -levelLabel.fontSize - verticalSpacing)
        )
        
        super.init()
        
        self.position = position
        addChild(levelLabel)
        addChild(experienceBar)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(level: Int) {
        levelLabel.text = "Level: \(level)"
    }
    
    func updateExperience(progress: Double) {
        experienceBar.update(progress: progress)
    }
}

final class ExperienceBar: SKNode {
    private let background: SKSpriteNode
    private let fill: SKSpriteNode
    private let barWidth: CGFloat
    private let barHeight: CGFloat
    
    init(width: CGFloat, height: CGFloat, position: CGPoint) {
        self.barWidth = width
        self.barHeight = height
        
        background = SKSpriteNode(color: SKColor(white: 0.3, alpha: 1.0), size: CGSize(width: width, height: height))
        background.anchorPoint = CGPoint(x: 1, y: 0.5) // Anchor to right
        background.position = .zero
        
        fill = SKSpriteNode(color: SKColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0), size: CGSize(width: width, height: height))
        fill.anchorPoint = CGPoint(x: 0, y: 0.5) // Anchor to left
        fill.position = CGPoint(x: -width, y: 0) // Start at left edge
        
        super.init()
        
        self.position = position
        addChild(background)
        addChild(fill)
        
        update(progress: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(progress: Double) {
        let clampedProgress = max(0, min(1, progress))
        fill.xScale = CGFloat(clampedProgress)
    }
}
