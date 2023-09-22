import ComposableArchitecture
import Foundation
import Logger
import SwiftUI
import Tweaks

class Tweaks {
    lazy var tweakStore = TweakStore(
        userDefaultsClient: .live(),
        tweaks: [
            // Logs
            LogCategoryTweak(category: .app),

            LogLevelTweak()
        ]
    )

    func configure() {
        #if DEBUG
            _ = tweakStore
        #endif
    }
}

// MARK: Log category

extension LogCategory {
    static let tweaks = LogCategory("Tweaks")
}
