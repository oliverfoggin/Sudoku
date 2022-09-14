import SwiftUI
import ComposableArchitecture

struct GameView: View {
	let store: StoreOf<GameCore>
	@ObservedObject var viewStore: ViewStoreOf<GameCore>

	init(store: StoreOf<GameCore>) {
		self.store = store
		viewStore = ViewStore(store)
	}

	var body: some View {
		VStack {
			GameBoard(store: store.scope(state: \.boardState))

			HStack {
				ForEach(FillColor.allCases, id: \.self) { color in
					Button {
						viewStore.send(.colorTapped(color))
					} label: {
						color.color.frame(width: 44, height: 44)
							.continuousCornerRadius(8)
					}
				}
			}

			HStack {
				ForEach(SelectionMode.allCases, id: \.self) { value in
					Button {
						viewStore.send(.selectionModeTapped(value))
					} label: {
						Text(value.rawValue)
							.padding(10)
							.background(viewStore.selectionMode == value ? Color.green : .gray)
							.continuousCornerRadius(8)
							.foregroundColor(.white)
					}
				}
			}

			Button("Clear selection") {
				viewStore.send(.clearSelectionTapped)
			}

			HStack {
				ForEach(EntryMode.allCases, id: \.self) { value in
					Button {
						viewStore.send(.entryModeTapped(value))
					} label: {
						Text(value.rawValue)
							.padding(10)
							.background(viewStore.entryMode == value ? Color.green : .gray)
							.continuousCornerRadius(8)
							.foregroundColor(.white)
					}
				}
			}

			HStack {
				ForEach(1..<10) { value in
					Button {
						viewStore.send(.numberTapped(value))
					} label: {
						Text("\(value)")
							.frame(width: 35, height: 35)
							.overlay {
								RoundedRectangle(cornerRadius: 8, style: .continuous)
									.stroke(.black, lineWidth: 1)
							}
					}
				}
			}

			Text(viewStore.touchMode.rawValue)
		}
	}
}

struct GameView_Previews: PreviewProvider {
	static var previews: some View {
		GameView(
			store: .init(
				initialState: .init(),
				reducer: GameCore()
			)
		)
	}
}

extension FillColor {
	var color: Color {
		switch self {
		case .red: return .red.opacity(0.4)
		case .yellow: return .yellow.opacity(0.4)
		case .blue: return .blue.opacity(0.4)
		case .green: return .green.opacity(0.4)
		}
	}
}
