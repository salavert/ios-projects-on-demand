import ComposableArchitecture
import Logger
import MisticaCommon
import SwiftUI
import Tweaks

final class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var tweaks = Tweaks()

    var store = Store(initialState: AppReducer.State()) {
        AppReducer()
    }

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        configureBuildType()
        configureLogger()
        configureMistica()
        tweaks.configure()
        NSTimeZone.resetSystemTimeZone()

        if !_XCTIsTesting {
            store.send(.didFinishLaunching)
        }

        return true
    }
}

// MARK: Private extension

private extension AppDelegate {
    func configureBuildType() {
        #if ENTERPRISE
            BuildType.current = .enterprise
        #elseif DEBUG
            BuildType.current = .debug
        #else
            BuildType.current = .release
        #endif
    }
    
    func configureLogger() {
        #if DEBUG
            Log.enable()
            Log.set(minLevel: .trace)
        #else
            Log.disable()
        #endif
    }

    func configureMistica() {
        MisticaConfig.brandStyle = .movistar
    }
}
