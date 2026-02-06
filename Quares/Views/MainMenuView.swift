import SwiftUI

struct MainMenuView: View {
    @StateObject private var viewModel = MainMenuViewModel()

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ZStack {
                backgroundGradient

                VStack(spacing: 40) {
                    titleSection
                    gameModeSelector
                    menuButtons
                }
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .game(let mode):
                    GameView(gameMode: mode, onDismiss: { viewModel.navigateToRoot() })
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

    private var gameModeSelector: some View {
        VStack(spacing: 15) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(GameMode.allCases) { mode in
                        GameModeCard(
                            mode: mode,
                            isSelected: viewModel.selectedMode == mode
                        ) {
                            viewModel.selectedMode = mode
                        }
                    }
                }
                .padding(.horizontal, 40)
            }

            Text(viewModel.selectedMode.description)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .frame(height: 40)
                .padding(.horizontal, 40)
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

struct GameModeCard: View {
    let mode: GameMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: mode.icon)
                    .font(.system(size: 30))
                
                Text(mode.displayName)
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(isSelected ? .white : .gray)
            .frame(width: 100, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    MainMenuView()
}
