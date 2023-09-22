import Foundation

public enum Tab {
    case home
}

extension Tab {
    var icon: String {
        switch self {
        case .home:
            return "house"
        }
    }
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        }
    }
}
