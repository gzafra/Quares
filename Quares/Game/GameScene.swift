import SpriteKit
import SwiftUI

protocol GameSceneDelegate: AnyObject {
    func gameSceneDidRequestExit(_ scene: GameScene)
    func gameSceneDidRequestRestart(_ scene: GameScene)
    func gameSceneDidRequestOptions(_ scene: GameScene)
}

final class GameScene: SKScene {
    // MARK: - Properties

    weak var gameDelegate: GameSceneDelegate?

    private(set) var brain: Brain
    private(set) var squareNodes: [[SquareNode]] = []
    private(set) var squareSize: CGFloat = 0
    private(set) var gridOrigin: CGPoint = .zero

    private(set) var healthBar: HealthBar?
    private(set) var scoreBoard: ScoreBoard?
    private var gameOverScreen: GameOverScreen?
    private var pauseMenuScreen: PauseMenuScreen?
    private var pauseButton: PauseButton?
    
    private(set) var isPausedState: Bool = false

    private var dragStartPosition: GridPosition?
    private var highlightedSquares: Set<GridPosition> = []

    private let gridPadding: CGFloat = 16
    private let healthBarHeight: CGFloat = 30
    private let uiSpacing: CGFloat = 12

    // MARK: - Initialization

    init(brain: Brain, size: CGSize) {
        self.brain = brain
        super.init(size: size)
        brain.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(white: 0.1, alpha: 1.0)
        setupGrid()
        setupHealthBar()
        setupScoreBoard()
        setupPauseButton()
        SoundManager.shared.stopMenuMusic()
        SoundManager.shared.startGameMusic()
        brain.startGame()
    }

    // MARK: - Setup

    private func setupGrid() {
        let availableWidth = size.width - (gridPadding * 2)
        let gridSize = availableWidth
        let topUISpace = healthBarHeight + uiSpacing * 3
        let bottomUISpace: CGFloat = 50

        squareSize = gridSize / CGFloat(brain.configuration.gridSize)

        let gridHeight = gridSize
        let totalContentHeight = topUISpace + gridHeight + bottomUISpace
        let verticalOffset = (size.height - totalContentHeight) / 2

        gridOrigin = CGPoint(
            x: gridPadding,
            y: verticalOffset + bottomUISpace
        )

        createSquareNodes()
        updateGridColors()
    }

    private func createSquareNodes() {
        squareNodes.forEach { row in row.forEach { $0.removeFromParent() } }
        squareNodes.removeAll()

        for y in 0..<brain.configuration.gridSize {
            var row: [SquareNode] = []
            for x in 0..<brain.configuration.gridSize {
                let frame = CGRect(
                    x: gridOrigin.x + CGFloat(x) * squareSize,
                    y: gridOrigin.y + CGFloat(y) * squareSize,
                    width: squareSize,
                    height: squareSize
                )
                let node = SquareNode(gridX: x, gridY: y, frame: frame)
                row.append(node)
                addChild(node)
            }
            squareNodes.append(row)
        }
    }

    private func setupHealthBar() {
        let barWidth = size.width - (gridPadding * 2)
        let gridTop = gridOrigin.y + (squareSize * CGFloat(brain.configuration.gridSize))
        let barY = gridTop + uiSpacing

        let bar = HealthBar(
            width: barWidth,
            height: healthBarHeight,
            position: CGPoint(x: gridPadding, y: barY)
        )
        healthBar = bar
        addChild(bar)
    }

    private func setupScoreBoard() {
        let scoreY = gridOrigin.y - uiSpacing
        let board = ScoreBoard(position: CGPoint(x: gridPadding, y: scoreY))
        scoreBoard = board
        addChild(board)
    }

    private func setupPauseButton() {
        let buttonSize: CGFloat = 40
        let buttonPosition = CGPoint(x: size.width - gridPadding - buttonSize, y: size.height - gridPadding - buttonSize)
        
        let button = PauseButton(size: buttonSize, position: buttonPosition)
        button.delegate = self
        
        pauseButton = button
        addChild(button)
    }

    // MARK: - Grid Updates

    func updateGridColors() {
        let colors = brain.configuration.colors()

        for y in 0..<brain.configuration.gridSize {
            for x in 0..<brain.configuration.gridSize {
                guard y < squareNodes.count, x < squareNodes[y].count else { continue }
                let node = squareNodes[y][x]

                if let colorIndex = brain.colorIndex(at: GridPosition(x: x, y: y)) {
                    node.setColor(SKColor(colors[colorIndex]))
                }
            }
        }
    }

    // MARK: - Selection Highlighting

    func highlightSquares(_ positions: Set<GridPosition>) {
        clearHighlights()
        highlightedSquares = positions

        for position in positions {
            guard let node = squareNode(at: position) else { continue }
            node.setHighlighted(true)
        }
    }

    func clearHighlights() {
        for position in highlightedSquares {
            guard let node = squareNode(at: position) else { continue }
            node.setHighlighted(false)
        }
        highlightedSquares.removeAll()
    }

    // MARK: - Animations

    func animateSuccessfulSelection(from start: GridPosition, to end: GridPosition) {
        let positions = GridPosition.area(from: start, to: end)
        let colors = brain.configuration.colors()

        for position in positions {
            guard let node = squareNode(at: position) else { continue }

            if let colorIndex = brain.colorIndex(at: position) {
                let newColor = SKColor(colors[colorIndex])
                node.animateSuccessfulClear(newColor: newColor)
            }
        }
    }

    func animateFailedSelection(from start: GridPosition, to end: GridPosition) {
        let positions = GridPosition.area(from: start, to: end)

        for position in positions {
            guard let node = squareNode(at: position) else { continue }
            node.animateFailedSelection()
        }
    }

    func showComboLabel(comboCount: Int) {
        let label = SKLabelNode(text: "Combo x\(comboCount)!")
        label.fontName = "Helvetica-Bold"
        label.fontSize = 48
        label.fontColor = .white
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.zPosition = 100
        addChild(label)

        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.3)
        let group = SKAction.group([fadeOut, scaleUp])
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([group, remove])

        label.run(sequence)
    }

    // MARK: - Game Over

    func showGameOver() {
        let screen = GameOverScreen(size: size, finalScore: brain.score)
        screen.delegate = self
        gameOverScreen = screen
        addChild(screen)
    }

    private func hideGameOver() {
        gameOverScreen?.removeFromParent()
        gameOverScreen = nil
    }

    // MARK: - Pause Menu

    func showPauseMenu() {
        guard pauseMenuScreen == nil else { return }

        isPausedState = true
        brain.pauseGame()
        SoundManager.shared.stopGameMusic()
        SoundManager.shared.startMenuMusic()

        let screen = PauseMenuScreen(size: size)
        screen.delegate = self
        pauseMenuScreen = screen
        addChild(screen)
    }

    private func hidePauseMenu() {
        pauseMenuScreen?.removeFromParent()
        pauseMenuScreen = nil
        isPausedState = false
    }

    func resumeGame() {
        hidePauseMenu()
        SoundManager.shared.stopMenuMusic()
        SoundManager.shared.startGameMusic()
        brain.resumeGame()
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Handle pause menu touches first
        if let pauseScreen = pauseMenuScreen {
            _ = pauseScreen.handleTouch(at: location)
            return
        }

        if let screen = gameOverScreen {
            _ = screen.handleTouch(at: location)
            return
        }

        if let position = gridPosition(from: location) {
            dragStartPosition = position
            highlightSquares([position])
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isPausedState else { return }
        guard let touch = touches.first, let startPosition = dragStartPosition else { return }
        guard gameOverScreen == nil else { return }

        let location = touch.location(in: self)

        if let currentPosition = gridPosition(from: location) {
            let preview = brain.previewSelection(from: startPosition, to: currentPosition)
            highlightSquares(preview)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isPausedState else { return }
        guard let touch = touches.first, let startPosition = dragStartPosition else { return }
        guard gameOverScreen == nil else { return }

        let location = touch.location(in: self)

        if let endPosition = gridPosition(from: location) {
            if startPosition == endPosition {
                brain.selectSquare(at: startPosition)
            } else {
                brain.attemptMatch(from: startPosition, to: endPosition)
            }
        } else {
            clearHighlights()
        }

        dragStartPosition = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        dragStartPosition = nil
        clearHighlights()
    }

    // MARK: - Utilities

    private func squareNode(at position: GridPosition) -> SquareNode? {
        guard position.y < squareNodes.count, position.x < squareNodes[position.y].count else {
            return nil
        }
        return squareNodes[position.y][position.x]
    }

    private func gridPosition(from location: CGPoint) -> GridPosition? {
        let gridSize = squareSize * CGFloat(brain.configuration.gridSize)
        let relativeX = location.x - gridOrigin.x
        let relativeY = location.y - gridOrigin.y

        guard relativeX >= 0, relativeX < gridSize,
              relativeY >= 0, relativeY < gridSize else {
            return nil
        }

        let x = Int(relativeX / squareSize)
        let y = Int(relativeY / squareSize)

        return GridPosition(x: x, y: y)
    }
}

// MARK: - GameOverScreenDelegate

extension GameScene: GameOverScreenDelegate {
    func gameOverScreenDidTapRestart(_ screen: GameOverScreen) {
        hideGameOver()
        gameDelegate?.gameSceneDidRequestRestart(self)
    }

    func gameOverScreenDidTapExit(_ screen: GameOverScreen) {
        gameDelegate?.gameSceneDidRequestExit(self)
    }
}

// MARK: - PauseMenuScreenDelegate

extension GameScene: PauseMenuScreenDelegate {
    func pauseMenuScreenDidTapContinue(_ screen: PauseMenuScreen) {
        resumeGame()
    }

    func pauseMenuScreenDidTapRestart(_ screen: PauseMenuScreen) {
        hidePauseMenu()
        gameDelegate?.gameSceneDidRequestRestart(self)
    }

    func pauseMenuScreenDidTapMainMenu(_ screen: PauseMenuScreen) {
        hidePauseMenu()
        gameDelegate?.gameSceneDidRequestExit(self)
    }

    func pauseMenuScreenDidTapOptions(_ screen: PauseMenuScreen) {
        // Note: We don't hide the pause menu here because the game should remain paused
        // while the Options sheet is presented. The pause menu stays visible behind the sheet,
        // and the user can continue from there after dismissing Options.
        gameDelegate?.gameSceneDidRequestOptions(self)
    }
}

// MARK: - PauseButtonDelegate

extension GameScene: PauseButtonDelegate {
    func pauseButtonDidTap(_ button: PauseButton) {
        showPauseMenu()
    }
}
