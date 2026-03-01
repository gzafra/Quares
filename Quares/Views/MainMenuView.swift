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
            .onAppear {
                SoundManager.shared.startMenuMusic()
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(GameMode.allCases) { mode in
                    GameModeCard(
                        mode: mode,
                        isSelected: viewModel.selectedMode == mode
                    ) {
                        viewModel.selectedMode = mode
                    }
                }
            }
            .padding(.horizontal, 20)
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

struct GameModeCard: View {
    let mode: GameMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: mode.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .gray)

                Text(mode.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .gray)

                Text(mode.description)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .white.opacity(0.7) : .gray.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .frame(width: 110, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white.opacity(0.2) : Color(white: 0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
            )
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
