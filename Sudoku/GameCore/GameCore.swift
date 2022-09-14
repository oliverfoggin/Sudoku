import ComposableArchitecture

struct GameCore: ReducerProtocol {
	struct State: Equatable {
		var fixedNumbers: [Int: Int] = [:]

		var selectedCells: Set<Int> = []
		var coloredCells: [Int: FillColor] = [:]
		var bigNumbers: [Int: Int] = [:]
		var centerNumbers: [Int: [Int]] = [:]
		var entryMode: EntryMode = .big
		var selectionMode: SelectionMode = .single
		var touchMode: TouchMode = .tap
		var dragUpdate: DragUpdate? = nil
		var previousDraggedCell: Int? = nil
	}

	enum Action: Equatable {
		case colorTapped(FillColor)
		case selectionModeTapped(SelectionMode)
		case clearSelectionTapped
		case entryModeTapped(EntryMode)
		case numberTapped(Int)

		case cellTapped(Int)
		case cellDragged(Int)
		case dragEnded
	}

	var body: some ReducerProtocol<State, Action> {
		Reduce { state, action in
			switch action {
			case .colorTapped(let color):
				let allColored = state.selectedCells.allSatisfy { cell in
					state.coloredCells[cell] == color
				}

				state.selectedCells.forEach { cell in
					if allColored {
						state.coloredCells[cell] = nil
					} else {
						state.coloredCells[cell] = color
					}
				}
				return .none

			case .selectionModeTapped(let mode):
				state.selectionMode = mode
				return .none

			case .numberTapped(let value):
				state.selectedCells.forEach { cell in
					guard state.fixedNumbers[cell] == nil else {
						return
					}

					switch state.entryMode {
					case .big:
						if state.bigNumbers[cell] == value {
							state.bigNumbers[cell] = nil
						} else {
							state.bigNumbers[cell] = value
						}
					case .center:
						var values = Set(state.centerNumbers[cell] ?? [])
						if values.contains(value) {
							values.remove(value)
						} else {
							values.insert(value)
						}
						state.centerNumbers[cell] = values.sorted()
					}
				}
				return .none

			case .entryModeTapped(let mode):
				state.entryMode = mode
				return .none

			case .clearSelectionTapped:
				state.selectedCells = []
				return .none

			case .cellTapped(let cell):
				state.touchMode = .tap

				switch state.selectionMode {
				case .single:
					state.selectedCells = [cell]
				case .multiple:
					if state.selectedCells.contains(cell) {
						state.selectedCells.remove(cell)
					} else {
						state.selectedCells.insert(cell)
					}
				}
				return .none

			case .cellDragged(let cell):
				state.touchMode = .drag

				if cell == state.previousDraggedCell {
					return .none
				}

				state.previousDraggedCell = cell

				if state.dragUpdate == nil {
					state.dragUpdate = state.selectedCells.contains(cell) ? .remove : .addition
				}

				switch state.dragUpdate {
				case .remove:
					state.selectedCells.remove(cell)
				case .addition:
					state.selectedCells.insert(cell)
				case nil:
					break
				}
				return .none

			case .dragEnded:
				state.dragUpdate = nil
				return .none
			}
		}
	}
}
