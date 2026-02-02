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

        let insetRect = frame.insetBy(dx: inset, dy: inset)
        self.path = CGPath(roundedRect: insetRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
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
        let scaleDown = SKAction.scale(to: 0.1, duration: 0.12)
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.12)
        let shrinkAndFade = SKAction.group([scaleDown, fadeOut])

        let updateColor = SKAction.run { [weak self] in
            self?.fillColor = newColor
        }

        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        let growAndAppear = SKAction.group([scaleUp, fadeIn])

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
