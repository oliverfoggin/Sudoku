import ComposableArchitecture

struct BoardState: Equatable {
	var fixedNumbers: [Int: Int] = [
		0: 5,
	]
	var coloredCells: [Int: FillColor] = [:]
	var bigNumbers: [Int: Int] = [:]
	var centerNumbers: [Int: Set<Int>] = [:]
	var selectedCells: Set<Int> = []

	var finalNumbers: [Int: Int] {
		bigNumbers.merging(fixedNumbers) { a, _ in a }
	}

	var errorCells: Set<Int> {
		var errors: Set<Int> = []
		bigNumbers.forEach { index, value in
			SudokuEngine.visibleCells(from: index).filter {
				finalNumbers[$0] == value
			}
			.forEach {
				errors.insert(index)
				errors.insert($0)
			}
		}
		return errors
	}
}

struct GameCore: ReducerProtocol {
	struct State: Equatable {
		var boardState: BoardState = .init()

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
		case deleteTapped

		case cellTapped(Int)
		case cellDragged(Int)
		case dragEnded
	}

	var body: some ReducerProtocol<State, Action> {
		Reduce { state, action in
			switch action {
			case .colorTapped(let color):
				let allColored = state.boardState.selectedCells.allSatisfy { cell in
					state.boardState.coloredCells[cell] == color
				}

				state.boardState.selectedCells.forEach { cell in
					if allColored {
						state.boardState.coloredCells[cell] = nil
					} else {
						state.boardState.coloredCells[cell] = color
					}
				}
				return .none

			case .selectionModeTapped(let mode):
				state.selectionMode = mode
				return .none

			case .numberTapped(let value):
				let allCenterNumber = state.boardState.selectedCells.allSatisfy { cell in
					state.boardState.centerNumbers[cell]?.contains(value) ?? false
				}
				let allBigNumber = state.boardState.selectedCells.allSatisfy { cell in
					state.boardState.finalNumbers[cell] == value
				}
				state.boardState.selectedCells
					.filter { state.boardState.fixedNumbers[$0] == nil }
					.forEach { cell in
						switch state.entryMode {
						case .big:

							if allBigNumber {
								state.boardState.bigNumbers[cell] = nil
							} else {
								state.boardState.bigNumbers[cell] = value

								SudokuEngine.visibleCells(from: cell)
									.forEach {
										state.boardState.centerNumbers[$0]?.remove(value)
									}
							}
						case .center:
							var values = state.boardState.centerNumbers[cell] ?? []
							if allCenterNumber {
								values.remove(value)
							} else {
								values.insert(value)
							}
							state.boardState.centerNumbers[cell] = values
						}
					}
				return .none

			case .entryModeTapped(let mode):
				state.entryMode = mode
				return .none

			case .clearSelectionTapped:
				state.boardState.selectedCells = []
				return .none

			case .deleteTapped:
				let allBigNumber = state.boardState.selectedCells.allSatisfy { cell in
					state.boardState.finalNumbers[cell] != nil
				}
				let hasBigNumbers = state.boardState.selectedCells.contains { cell in
					state.boardState.bigNumbers[cell] != nil
				}

				switch state.entryMode {
				case _ where allBigNumber:
					state.boardState.selectedCells.forEach { cell in
						state.boardState.bigNumbers[cell] = nil
					}
				case .big where hasBigNumbers:
					state.boardState.selectedCells.forEach { cell in
						state.boardState.bigNumbers[cell] = nil
					}
				case .big, .center:
					state.boardState.selectedCells.forEach { cell in
						state.boardState.centerNumbers[cell] = nil
					}
				}
				return .none

			case .cellTapped(let cell):
				state.touchMode = .tap

				switch state.selectionMode {
				case .single:
					state.boardState.selectedCells = [cell]
				case .multiple:
					if state.boardState.selectedCells.contains(cell) {
						state.boardState.selectedCells.remove(cell)
					} else {
						state.boardState.selectedCells.insert(cell)
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
					state.dragUpdate = state.boardState.selectedCells.contains(cell) ? .remove : .addition
				}

				switch state.dragUpdate {
				case .remove:
					state.boardState.selectedCells.remove(cell)
				case .addition:
					state.boardState.selectedCells.insert(cell)
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
