import SwiftUI
import SpriteKit

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var sceneSize: CGSize = .zero
    let onDismiss: () -> Void

    var body: some View {
        GeometryReader { geometry in
            Group {
                if sceneSize != .zero {
                    SpriteView(scene: viewModel.getOrCreateScene(size: sceneSize))
                        .ignoresSafeArea()
                } else {
                    Color.black.ignoresSafeArea()
                }
            }
            .onAppear {
                sceneSize = geometry.size
            }
        }
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                onDismiss()
            }
        }
    }
}

#Preview {
    GameView(onDismiss: {})
}
