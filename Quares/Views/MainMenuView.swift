import SwiftUI

struct MainMenuView: View {
    @StateObject private var viewModel = MainMenuViewModel()

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ZStack {
                backgroundGradient

                VStack(spacing: 40) {
                    titleSection
                    menuButtons
                }
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .game:
                    GameView(onDismiss: { viewModel.navigateToRoot() })
                        .navigationBarBackButtonHidden(true)
                case .options:
                    OptionsView()
                }
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(white: 0.15), Color(white: 0.05)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var titleSection: some View {
        VStack(spacing: 10) {
            Text("QUARES")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Match the corners")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)
        }
    }

    private var menuButtons: some View {
        VStack(spacing: 20) {
            MenuButton(title: "Play", color: .green) {
                viewModel.navigateToGame()
            }

            MenuButton(title: "Options", color: .blue) {
                viewModel.navigateToOptions()
            }
        }
    }
}

struct MenuButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 200, height: 60)
                .background(color.opacity(0.8))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color, lineWidth: 2)
                )
        }
    }
}

#Preview {
    MainMenuView()
}
