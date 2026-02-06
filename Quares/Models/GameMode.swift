import Foundation

enum GameMode: String, CaseIterable, Identifiable {
    case training = "Training"
    case classic = "Classic"
    case survival = "Survival"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var description: String {
        switch self {
        case .training:
            return "Practice without health or score"
        case .classic:
            return "Play through levels with increasing difficulty"
        case .survival:
            return "Survive as long as you can against time"
        }
    }
    
    var icon: String {
        switch self {
        case .training:
            return "graduationcap.fill"
        case .classic:
            return "star.fill"
        case .survival:
            return "flame.fill"
        }
    }
}