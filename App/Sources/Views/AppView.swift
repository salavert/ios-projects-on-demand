import ComposableArchitecture
import Foundation
import Logger
import MisticaCommon
import MisticaSwiftUI
import SwiftUI
import Tweaks

public struct AppReducer: Reducer {
    @Dependency(\.mainQueue) var mainQueue

    public struct State: Equatable {
        var selectedTab: Tab
        var areDeveloperSettingsPresented: Bool

        public init(
            selectedTab: Tab = .home
        ) {
            self.selectedTab = selectedTab
            areDeveloperSettingsPresented = false
        }
        
        var areDeveloperSettingsEnabled: Bool {
            BuildType.current.areDeveloperSettingsEnabled
        }
    }

    public enum Action: Equatable {
        case developerSettings(isPresented: Bool)
        case didChangeScenePhase(ScenePhase)
        case didFinishLaunching
        case onBackToForeground
        case onOpenURL(URL)
        case selectedTabChanged(Tab)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        self.core
    }

    @ReducerBuilder<State, Action>
    var core: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .didFinishLaunching:
                return .none

            case .didChangeScenePhase(.inactive):
                state.areDeveloperSettingsPresented = false
                return .none

            case let .selectedTabChanged(tab):
                state.selectedTab = tab
                return .none

            case let .onOpenURL(url):
                Log.debug(.app, "Open url \(url)")
                return .none
            
            case let .developerSettings(isPresented: isPresented):
                if state.areDeveloperSettingsEnabled {
                    state.areDeveloperSettingsPresented = isPresented
                }
                return .none

            case .didChangeScenePhase:
                return .none
            
            case .onBackToForeground:
                return .none
            }
        }
    }
}

struct AppView: View {
    @SwiftUI.Environment(\.scenePhase) var scenePhase

    let store: StoreOf<AppReducer>
    @ObservedObject var viewStore: ViewStore<ViewState, AppReducer.Action>
    let tweakStore: TweakStore

    init(
        store: StoreOf<AppReducer>,
        tweakStore: TweakStore
    ) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
        self.tweakStore = tweakStore
    }

    struct ViewState: Equatable {
        let areDeveloperSettingsEnabled: Bool
        let areDeveloperSettingsPresented: Bool
        let selectedTab: Tab

        init(state: AppReducer.State) {
            areDeveloperSettingsEnabled = state.areDeveloperSettingsEnabled
            areDeveloperSettingsPresented = state.areDeveloperSettingsPresented
            selectedTab = state.selectedTab
        }
    }

    var body: some View {
        VStack {
            NavigationView {
                TabView(selection: viewStore.binding(get: \.selectedTab, send: AppReducer.Action.selectedTabChanged)) {
                    VStack {
                        Spacer()
                        Text("🌎 Hello world")
                        Spacer()
                    }
                        .tabItem {
                            Image(systemName: Tab.home.icon)
                        }
                        .tag(Tab.home)
                }
                .onAppear {
                    UITabBar.appearance().backgroundColor = .white
                }
                .misticaTabViewStyle()
                .navigationViewStyle(.stack)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(Tab.home.title)
            }
            .misticaNavigationViewStyle()
        }
        .background(Color.background.edgesIgnoringSafeArea(.all))
        .onShake {
            if viewStore.areDeveloperSettingsEnabled {
                viewStore.send(.developerSettings(isPresented: true))
            }
        }
        .presentDeveloperSettings(
            isPresented: viewStore.binding(
                get: \.areDeveloperSettingsPresented,
                send: AppReducer.Action.developerSettings(isPresented:)
            ),
            tweakStore: tweakStore,
            modalPresentationStyle: .pageSheet
        )
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                viewStore.send(.onBackToForeground)
            }
        }
    }
}
