import SpriteKit

final class TimerBoard: SKNode {
    private let label: SKLabelNode

    init(position: CGPoint) {
        self.label = SKLabelNode(fontNamed: "Helvetica-Bold")
        self.label.fontSize = 24
        self.label.fontColor = .white
        self.label.horizontalAlignmentMode = .center
        self.label.text = "00:00"

        super.init()
        self.position = position
        addChild(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(time: TimeInterval) {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        label.text = String(format: "%02d:%02d", minutes, seconds)
    }
}
