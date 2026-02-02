import Foundation
import SpriteKit
import SwiftUI

final class GameViewModel: ObservableObject {
    @Published var shouldDismiss = false

    private var scene: GameScene?
    private let brain: Brain
    private let configuration: GameConfiguration

    init(configuration: GameConfiguration = GameConfiguration()) {
        self.configuration = configuration
        self.brain = Brain(configuration: configuration)
    }

    func getOrCreateScene(size: CGSize) -> GameScene {
        if let existingScene = scene {
            return existingScene
        }

        let gameScene = GameScene(brain: brain, size: size)
        gameScene.scaleMode = .resizeFill
        gameScene.gameDelegate = self
        scene = gameScene
        return gameScene
    }

    func restartGame() {
        brain.resetGame()
        brain.startGame()
    }
}

extension GameViewModel: GameSceneDelegate {
    func gameSceneDidRequestExit(_ scene: GameScene) {
        brain.pauseGame()
        DispatchQueue.main.async {
            self.shouldDismiss = true
        }
    }

    func gameSceneDidRequestRestart(_ scene: GameScene) {
        restartGame()
    }
}
