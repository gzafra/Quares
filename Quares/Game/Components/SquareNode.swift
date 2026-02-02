import SpriteKit
import SwiftUI

final class SquareNode: SKShapeNode {
    let gridX: Int
    let gridY: Int

    private let inset: CGFloat = 2
    private let cornerRadius: CGFloat = 4

    init(gridX: Int, gridY: Int, frame: CGRect) {
        self.gridX = gridX
        self.gridY = gridY
        super.init()

        let insetSize = CGSize(
            width: frame.width - inset * 2,
            height: frame.height - inset * 2
        )
        let centeredRect = CGRect(
            x: -insetSize.width / 2,
            y: -insetSize.height / 2,
            width: insetSize.width,
            height: insetSize.height
        )
        self.path = CGPath(roundedRect: centeredRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        self.position = CGPoint(x: frame.midX, y: frame.midY)
        self.name = "square_\(gridX)_\(gridY)"
        self.strokeColor = .clear
        self.lineWidth = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Appearance

    func setColor(_ color: SKColor) {
        fillColor = color
    }

    func setHighlighted(_ highlighted: Bool) {
        strokeColor = highlighted ? .white : .clear
        lineWidth = highlighted ? 3 : 0
    }

    // MARK: - Animations

    func animateSuccessfulClear(newColor: SKColor, completion: (() -> Void)? = nil) {
        let scaleDown = SKAction.scale(to: 0.1, duration: 0.3)
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.3)
        let shrinkAndFade = SKAction.group([scaleDown, fadeOut])

        let updateColor = SKAction.run { [weak self] in
            self?.fillColor = newColor
            self?.xScale = 1
            self?.yScale = 1
        }

        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        let growAndAppear = SKAction.group([fadeIn])

        let sequence = SKAction.sequence([shrinkAndFade, updateColor, growAndAppear])

        run(sequence) {
            completion?()
        }
    }

    func animateFailedSelection(completion: (() -> Void)? = nil) {
        let scaleDown = SKAction.scale(to: 0.8, duration: 0.08)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.08)
        let sequence = SKAction.sequence([scaleDown, scaleUp])

        run(sequence) {
            completion?()
        }
    }
}
