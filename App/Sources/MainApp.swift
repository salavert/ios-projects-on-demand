import MisticaSwiftUI
import SwiftUI
import Tweaks

@main
struct MainApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @SwiftUI.Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            AppView(
                store: appDelegate.store,
                tweakStore: appDelegate.tweaks.tweakStore
            )
            .onOpenURL {
                appDelegate.store.send(.onOpenURL($0))
            }
        }
        .onChange(of: self.scenePhase) {
            appDelegate.store.send(.didChangeScenePhase($0))
        }
    }
}
