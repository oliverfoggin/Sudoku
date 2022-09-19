import SwiftUI
import ComposableArchitecture

@main
struct SudokuApp: App {
	var body: some Scene {
		WindowGroup {
			StartScreen(
				store: .init(
					initialState: .init(),
					reducer: StartMenu()
						.debug()
				)
			)
			.preferredColorScheme(.light)
		}
	}
}
