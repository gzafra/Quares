import SpriteKit

protocol PauseMenuScreenDelegate: AnyObject {
    func pauseMenuScreenDidTapContinue(_ screen: PauseMenuScreen)
    func pauseMenuScreenDidTapRestart(_ screen: PauseMenuScreen)
    func pauseMenuScreenDidTapMainMenu(_ screen: PauseMenuScreen)
    func pauseMenuScreenDidTapOptions(_ screen: PauseMenuScreen)
}

final class PauseMenuScreen: SKNode {
    weak var delegate: PauseMenuScreenDelegate?

    private let dimmer: SKShapeNode
    private let panel: SKShapeNode
    private let continueButton: SKShapeNode
    private let restartButton: SKShapeNode
    private let mainMenuButton: SKShapeNode
    private let optionsButton: SKShapeNode

    init(size: CGSize) {
        // Dimmer background
        dimmer = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        dimmer.fillColor = SKColor(white: 0, alpha: 0.7)
        dimmer.strokeColor = .clear

        // Panel
        let panelWidth: CGFloat = 300
        let panelHeight: CGFloat = 320
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
        continueButton = Self.createButton(name: "continueButton")
        restartButton = Self.createButton(name: "restartButton")
        mainMenuButton = Self.createButton(name: "mainMenuButton")
        optionsButton = Self.createButton(name: "optionsButton")

        super.init()

        self.name = "pauseMenuScreen"

        addChild(dimmer)
        addChild(panel)

        setupLabels(size: size)
        setupButtons(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLabels(size: CGSize) {
        let pauseLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        pauseLabel.text = "Paused"
        pauseLabel.fontSize = 36
        pauseLabel.fontColor = .white
        pauseLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 120)
        addChild(pauseLabel)
    }

    private func setupButtons(size: CGSize) {
        let buttonSpacing: CGFloat = 55
        let startY = size.height / 2 + 50

        continueButton.position = CGPoint(x: size.width / 2, y: startY)
        addButtonLabel(to: continueButton, text: "Continue")
        addChild(continueButton)

        restartButton.position = CGPoint(x: size.width / 2, y: startY - buttonSpacing)
        addButtonLabel(to: restartButton, text: "Restart")
        addChild(restartButton)

        mainMenuButton.position = CGPoint(x: size.width / 2, y: startY - buttonSpacing * 2)
        addButtonLabel(to: mainMenuButton, text: "Main Menu")
        addChild(mainMenuButton)

        optionsButton.position = CGPoint(x: size.width / 2, y: startY - buttonSpacing * 3)
        addButtonLabel(to: optionsButton, text: "Options")
        addChild(optionsButton)
    }

    private static func createButton(name: String) -> SKShapeNode {
        let button = SKShapeNode(rect: CGRect(x: -120, y: -20, width: 240, height: 40), cornerRadius: 10)
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
        guard let parent = parent else { return false }
        let localLocation = convert(location, from: parent)
        let nodes = self.nodes(at: localLocation)

        for node in nodes {
            let buttonName = node.name ?? node.parent?.name
            switch buttonName {
            case "continueButton":
                delegate?.pauseMenuScreenDidTapContinue(self)
                return true
            case "restartButton":
                delegate?.pauseMenuScreenDidTapRestart(self)
                return true
            case "mainMenuButton":
                delegate?.pauseMenuScreenDidTapMainMenu(self)
                return true
            case "optionsButton":
                delegate?.pauseMenuScreenDidTapOptions(self)
                return true
            default:
                continue
            }
        }
        return false
    }
}
