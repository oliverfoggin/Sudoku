import ComposableArchitecture

struct GameCore: ReducerProtocol {
	struct State: Equatable {
		var fixedNumbers: [Int: Int] = [
			0: 5,
		]
		var selectedCells: Set<Int> = []
		var coloredCells: [Int: FillColor] = [:]
		var bigNumbers: [Int: Int] = [:]
		var centerNumbers: [Int: [Int]] = [:]
		var entryMode: EntryMode = .big
		var selectionMode: SelectionMode = .single
		var touchMode: TouchMode = .tap
		var dragUpdate: DragUpdate? = nil
		var previousDraggedCell: Int? = nil

		private let boxes: [Set<Int>] = [
			[0, 1, 2, 9, 10, 11, 18, 19, 20],
			[3, 4, 5, 12, 13, 14, 21, 22, 23],
			[6, 7, 8, 15, 16, 17, 24, 25, 26],
			[27, 28, 29, 36, 37, 38, 45, 46, 47],
			[30, 31, 32, 39, 40, 41, 48, 49, 50],
			[33, 34, 35, 42, 43, 44, 51, 52, 53],
			[54, 55, 56, 63, 64, 65, 72, 73, 74],
			[57, 58, 59, 66, 67, 68, 75, 76, 77],
			[60, 61, 62, 69, 70, 71, 78, 79, 80],
		]

		func visibleCells(from cell: Int) -> Set<Int> {
			var cells: Set<Int> = []

			let mod = cell % 9
			stride(from: 0, to: 9*9, by: 9)
				.map { $0 + mod }
				.forEach { cells.insert($0) }

			let div = cell / 9
			let start = 9 * div
			let end = start + 8
			(start...end).forEach { cells.insert($0) }

			boxes.filter { $0.contains(cell) }
				.first?
				.forEach { cells.insert($0) }

			cells.remove(cell)
			return cells
		}

		var finalNumbers: [Int: Int] {
			bigNumbers.merging(fixedNumbers) { a, _ in a }
		}

		var errorCells: Set<Int> {
			var errors: Set<Int> = []
			bigNumbers.forEach { index, value in
				visibleCells(from: index).filter {
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
				let allThisNumber = state.selectedCells.allSatisfy { cell in
					state.finalNumbers[cell] == value
				}

				state.selectedCells
					.filter { state.fixedNumbers[$0] == nil }
					.forEach { cell in
						switch state.entryMode {
						case .big:
							if allThisNumber {
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
