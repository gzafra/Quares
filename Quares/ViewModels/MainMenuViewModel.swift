import Foundation
import SwiftUI

enum NavigationDestination: Hashable {
    case game(GameMode)
    case options
}

final class MainMenuViewModel: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var selectedMode: GameMode = .classic

    func navigateToGame() {
        navigationPath.append(NavigationDestination.game(selectedMode))
    }

    func navigateToOptions() {
        navigationPath.append(NavigationDestination.options)
    }

    func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}
