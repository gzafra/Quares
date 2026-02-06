import SwiftUI
import SpriteKit

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @State private var sceneSize: CGSize = .zero
    let onDismiss: () -> Void

    init(gameMode: GameMode = .classic, onDismiss: @escaping () -> Void) {
        self._viewModel = StateObject(wrappedValue: GameViewModel(gameMode: gameMode))
        self.onDismiss = onDismiss
    }

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
        .sheet(isPresented: $viewModel.shouldShowOptions) {
            OptionsView()
        }
    }
}

#Preview {
    GameView(onDismiss: {})
}
