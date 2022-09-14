import SwiftUI
import ComposableArchitecture

@main
struct SudokuApp: App {
	var body: some Scene {
		WindowGroup {
			GameView(
				store: .init(
					initialState: .init(),
					reducer: GameCore()
				)
			)
			.preferredColorScheme(.light)
		}
	}
}
