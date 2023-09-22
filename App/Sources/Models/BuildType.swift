import Foundation

enum BuildType: Sendable {
    case debug
    case enterprise
    case release
}

extension BuildType {
    public static var current: BuildType = .release
    
    public var areDeveloperSettingsEnabled: Bool {
        switch self {
        case .debug,
             .enterprise:
            return true
        case .release:
            return false
        }
    }
}
