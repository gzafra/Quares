import SpriteKit

protocol PauseButtonDelegate: AnyObject {
    func pauseButtonDidTap(_ button: PauseButton)
}

final class PauseButton: SKNode {
    weak var delegate: PauseButtonDelegate?
    
    private let button: SKShapeNode
    
    init(size: CGFloat, position: CGPoint) {
        
        button = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size, height: size), cornerRadius: 8)
        button.name = "pauseButton"
        button.fillColor = SKColor(white: 0.3, alpha: 1.0)
        button.strokeColor = .white
        
        super.init()
        
        self.position = position
        self.isUserInteractionEnabled = true
        
        addChild(button)
        
        // Add pause icon (two vertical bars)
        let barWidth: CGFloat = 4
        let barHeight: CGFloat = 16
        let barSpacing: CGFloat = 6
        
        let leftBar = SKShapeNode(rect: CGRect(x: -barSpacing - barWidth, y: -barHeight / 2, width: barWidth, height: barHeight), cornerRadius: 1)
        leftBar.fillColor = .white
        leftBar.strokeColor = .clear
        
        let rightBar = SKShapeNode(rect: CGRect(x: barSpacing, y: -barHeight / 2, width: barWidth, height: barHeight), cornerRadius: 1)
        rightBar.fillColor = .white
        rightBar.strokeColor = .clear
        
        button.addChild(leftBar)
        button.addChild(rightBar)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if button.contains(location) {
            delegate?.pauseButtonDidTap(self)
        }
    }
}
