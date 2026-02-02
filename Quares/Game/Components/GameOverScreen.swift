import SpriteKit

protocol GameOverScreenDelegate: AnyObject {
    func gameOverScreenDidTapRestart(_ screen: GameOverScreen)
    func gameOverScreenDidTapExit(_ screen: GameOverScreen)
}

final class GameOverScreen: SKNode {
    weak var delegate: GameOverScreenDelegate?

    private let dimmer: SKShapeNode
    private let panel: SKShapeNode
    private let restartButton: SKShapeNode
    private let exitButton: SKShapeNode

    init(size: CGSize, finalScore: Int) {
        // Dimmer background
        dimmer = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        dimmer.fillColor = SKColor(white: 0, alpha: 0.7)
        dimmer.strokeColor = .clear

        // Panel
        let panelWidth: CGFloat = 300
        let panelHeight: CGFloat = 200
        panel = SKShapeNode(rect: CGRect(
            x: size.width / 2 - panelWidth / 2,
            y: size.height / 2 - panelHeight / 2,
            width: panelWidth,
            height: panelHeight
        ), cornerRadius: 20)
        panel.fillColor = SKColor(white: 0.2, alpha: 1.0)
        panel.strokeColor = .white
        panel.lineWidth = 2

        // Buttons
        restartButton = Self.createButton(name: "restartButton")
        exitButton = Self.createButton(name: "exitButton")

        super.init()

        self.name = "gameOverScreen"

        addChild(dimmer)
        addChild(panel)

        setupLabels(size: size, finalScore: finalScore)
        setupButtons(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLabels(size: CGSize, finalScore: Int) {
        let gameOverLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 36
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        addChild(gameOverLabel)

        let finalScoreLabel = SKLabelNode(fontNamed: "Helvetica")
        finalScoreLabel.text = "Final Score: \(finalScore)"
        finalScoreLabel.fontSize = 24
        finalScoreLabel.fontColor = .white
        finalScoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(finalScoreLabel)
    }

    private func setupButtons(size: CGSize) {
        restartButton.position = CGPoint(x: size.width / 2 - 70, y: size.height / 2 - 60)
        addButtonLabel(to: restartButton, text: "Restart")
        addChild(restartButton)

        exitButton.position = CGPoint(x: size.width / 2 + 70, y: size.height / 2 - 60)
        addButtonLabel(to: exitButton, text: "Exit")
        addChild(exitButton)
    }

    private static func createButton(name: String) -> SKShapeNode {
        let button = SKShapeNode(rect: CGRect(x: -50, y: -20, width: 100, height: 40), cornerRadius: 10)
        button.name = name
        button.fillColor = SKColor(white: 0.4, alpha: 1.0)
        button.strokeColor = .white
        return button
    }

    private func addButtonLabel(to button: SKShapeNode, text: String) {
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = text
        label.fontSize = 18
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        button.addChild(label)
    }

    func handleTouch(at location: CGPoint) -> Bool {
        let localLocation = convert(location, from: parent!)
        let nodes = self.nodes(at: localLocation)

        for node in nodes {
            if node.name == "restartButton" || node.parent?.name == "restartButton" {
                delegate?.gameOverScreenDidTapRestart(self)
                return true
            } else if node.name == "exitButton" || node.parent?.name == "exitButton" {
                delegate?.gameOverScreenDidTapExit(self)
                return true
            }
        }
        return false
    }
}
