import SwiftUI
import ComposableArchitecture

struct StartMenu: ReducerProtocol {
	struct State: Equatable {
		@BindableState var gameState: GameCore.State? = nil
		@BindableState var settings: String? = nil

//		@BindableState var path: NavigationPath = .init()
	}

	enum Action: BindableAction, Equatable {
		case startGameTapped
		case settingsTapped

		case gameAction(GameCore.Action)

		case binding(BindingAction<State>)
	}

	var body: some ReducerProtocol<State, Action> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .startGameTapped:
				state.gameState = .init()
				return .none

			case .settingsTapped:
				state.settings = ""
				return .none

			case .gameAction:
				return .none

			case .binding:
				return .none
			}
		}
		.ifLet(\.gameState, action: /Action.gameAction) {
			GameCore()
		}
	}
}

struct StartScreen: View {
	let store: StoreOf<StartMenu>

	var body: some View {
		WithViewStore(store) { viewStore in
			NavigationStack {
				VStack {
					Button("Start gane") {
						viewStore.send(.startGameTapped)
					}
					.navigationDestination(isPresented: viewStore.binding(\.$gameState).isPresent()) {
						IfLetStore(store.scope(state: \.gameState, action: StartMenu.Action.gameAction)) { gameStore in
							GameView(store: gameStore)
						}
					}
				}
				.toolbar {
					ToolbarItem(placement: .navigationBarTrailing) {
						Image(systemName: "gear")
							.onTapGesture {
								viewStore.send(.settingsTapped)
							}
							.navigationDestination(isPresented: viewStore.binding(\.$settings).isPresent()) {
								SettingsScreen()
							}
					}
				}
				.navigationTitle("Sudokle")
			}
		}
	}
}

struct SettingsScreen: View {
	var body: some View {
		Text("Dark Mode and stuff")
			.navigationTitle("Settings")
	}
}

struct StartScreen_Previews: PreviewProvider {
	static var previews: some View {
		StartScreen(
			store: .init(
				initialState: .init(),
				reducer: StartMenu()
			)
		)
	}
}
