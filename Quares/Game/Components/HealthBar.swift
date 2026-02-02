import SpriteKit

final class HealthBar: SKNode {
    private let background: SKShapeNode
    private let fill: SKShapeNode

    private let barWidth: CGFloat
    private let barHeight: CGFloat
    private let barX: CGFloat
    private let barY: CGFloat

    init(width: CGFloat, height: CGFloat, position: CGPoint) {
        self.barWidth = width
        self.barHeight = height
        self.barX = position.x
        self.barY = position.y

        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        let cornerRadius = height / 2

        background = SKShapeNode(rect: rect, cornerRadius: cornerRadius)
        background.fillColor = SKColor(white: 0.3, alpha: 1.0)
        background.strokeColor = .clear

        fill = SKShapeNode(rect: rect, cornerRadius: cornerRadius)
        fill.fillColor = .green
        fill.strokeColor = .clear

        super.init()

        self.position = position
        addChild(background)
        addChild(fill)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(health: Double) {
        let fillWidth = max(barWidth * CGFloat(health), 0)
        let cornerRadius = barHeight / 2

        let newPath = CGPath(
            roundedRect: CGRect(x: 0, y: 0, width: fillWidth, height: barHeight),
            cornerWidth: cornerRadius,
            cornerHeight: cornerRadius,
            transform: nil
        )
        fill.path = newPath

        fill.fillColor = colorForHealth(health)
    }

    private func colorForHealth(_ health: Double) -> SKColor {
        if health > 0.5 {
            return .green
        } else if health > 0.25 {
            return .yellow
        } else {
            return .red
        }
    }
}
