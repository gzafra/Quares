import Foundation
import SwiftUI

enum NavigationDestination: Hashable {
    case game
    case options
}

final class MainMenuViewModel: ObservableObject {
    @Published var navigationPath = NavigationPath()

    func navigateToGame() {
        navigationPath.append(NavigationDestination.game)
    }

    func navigateToOptions() {
        navigationPath.append(NavigationDestination.options)
    }

    func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}
