import SwiftUI

struct ContentView: View {
	@State var selectedCells: Set<Int> = []

	@State var coloredCells: [Int: Color] = [:]

	let fixedNumbers: [Int: Int] = [
		2: 8,
		17: 4,
	]

	@State var bigNumbers: [Int: Int] = [:]

	@State var centerNumbers: [Int: [Int]] = [:]

	let fillColors = [Color.red, .yellow, .blue, .green]
		.map { $0.opacity(0.4) }

	enum EntryMode: String, CaseIterable {
		case big = "Big"
		case center = "Center"
	}

	@State var entryMode: EntryMode = .big

	enum SelectionMode: String, CaseIterable {
		case single = "Single"
		case multiple = "Multiple"
	}

	@State var selectionMode: SelectionMode = .single

	enum TouchMode: String {
		case tap = "Tap"
		case drag = "Drag"
	}

	@State var touchMode: TouchMode = .tap

	enum DragUpdate: String {
		case addition = "Add"
		case remove = "Remove"
	}

	@State var dragUpdate: DragUpdate? = nil
	@State var previousDraggedCell: Int? = nil

	let gridSize: CGFloat = UIScreen.main.bounds.width - 20
	var cellSize: CGFloat { gridSize / 9 }

	var body: some View {
		VStack {
			Canvas(
				opaque: true,
				rendersAsynchronously: true) { context, size in
					let gridSize = size.width
					let boxSize = size.width / 3
					let cellSize = size.width / 9
					let rect = CGRect(origin: .zero, size: size)

					context.fill(Path(roundedRect: rect, cornerSize: .zero), with: .color(.white))

					coloredCells.forEach { cell, color in
						let cellPath = Path(CGRect(
							origin: pointForCell(cell: cell),
							size: CGSize(width: cellSize, height: cellSize)
						))

						context.fill(cellPath, with: .color(color))
					}

					context.stroke(
						pathFor(cells: selectedCells),
						with: .color(.purple.opacity(0.5)),
						lineWidth: 6
					)

					var boxPath = Path()
					boxPath.addLines([
						CGPoint(x: 1, y: 1),
						CGPoint(x: 1, y: gridSize - 1),
						CGPoint(x: gridSize - 1, y: gridSize - 1),
						CGPoint(x: gridSize - 1, y: 1),
						CGPoint(x: 1, y: 1),
					])
					boxPath.move(to: CGPoint(x: boxSize, y: 1))
					boxPath.addLine(to: CGPoint(x: boxSize, y: gridSize - 1))
					boxPath.move(to: CGPoint(x: 2 * boxSize, y: 1))
					boxPath.addLine(to: CGPoint(x: 2 * boxSize, y: gridSize - 1))

					boxPath.move(to: CGPoint(x: 1, y: boxSize))
					boxPath.addLine(to: CGPoint(x: gridSize - 1, y: boxSize))

					boxPath.move(to: CGPoint(x: 1, y: 2 * boxSize))
					boxPath.addLine(to: CGPoint(x: gridSize - 1, y: 2 * boxSize))

					context.stroke(boxPath, with: .color(.black), lineWidth: 2)

					var cellPath = Path()
					cellPath.move(to: CGPoint(x: cellSize, y: 1))
					cellPath.addLine(to: CGPoint(x: cellSize, y: gridSize - 1))
					cellPath.move(to: CGPoint(x: 2 * cellSize, y: 1))
					cellPath.addLine(to: CGPoint(x: 2 * cellSize, y: gridSize - 1))
					cellPath.move(to: CGPoint(x: 4 * cellSize, y: 1))
					cellPath.addLine(to: CGPoint(x: 4 * cellSize, y: gridSize - 1))
					cellPath.move(to: CGPoint(x: 5 * cellSize, y: 1))
					cellPath.addLine(to: CGPoint(x: 5 * cellSize, y: gridSize - 1))
					cellPath.move(to: CGPoint(x: 7 * cellSize, y: 1))
					cellPath.addLine(to: CGPoint(x: 7 * cellSize, y: gridSize - 1))
					cellPath.move(to: CGPoint(x: 8 * cellSize, y: 1))
					cellPath.addLine(to: CGPoint(x: 8 * cellSize, y: gridSize - 1))

					cellPath.move(to: CGPoint(x: 1, y: cellSize))
					cellPath.addLine(to: CGPoint(x: gridSize - 1, y: cellSize))
					cellPath.move(to: CGPoint(x: 1, y: 2 * cellSize))
					cellPath.addLine(to: CGPoint(x: gridSize - 1, y: 2 * cellSize))
					cellPath.move(to: CGPoint(x: 1, y: 4 * cellSize))
					cellPath.addLine(to: CGPoint(x: gridSize - 1, y: 4 * cellSize))
					cellPath.move(to: CGPoint(x: 1, y: 5 * cellSize))
					cellPath.addLine(to: CGPoint(x: gridSize - 1, y: 5 * cellSize))
					cellPath.move(to: CGPoint(x: 1, y: 7 * cellSize))
					cellPath.addLine(to: CGPoint(x: gridSize - 1, y: 7 * cellSize))
					cellPath.move(to: CGPoint(x: 1, y: 8 * cellSize))
					cellPath.addLine(to: CGPoint(x: gridSize - 1, y: 8 * cellSize))

					context.stroke(cellPath, with: .color(Color(white: 0.2)), lineWidth: 0.5)

					fixedNumbers.forEach { cell, value in
						let point = pointForCell(cell: cell)
							.applying(.init(translationX: cellSize * 0.5, y: cellSize * 0.5))

						context.draw(
							Text("\(value)")
								.font(.title)
								.fontWeight(.bold)
								.foregroundColor(.init(white: 0.4)),
							at: point
						)
					}

					bigNumbers
						.filter { cell, _ in
							!fixedNumbers.keys.contains(cell)
						}
						.forEach { cell, value in
							let point = pointForCell(cell: cell)
								.applying(.init(translationX: cellSize * 0.5, y: cellSize * 0.5))

							context.draw(
								Text("\(value)")
									.font(.title),
								at: point
							)
						}

					centerNumbers
						.filter { cell, _ in
							!bigNumbers.keys.contains(cell) &&
							!fixedNumbers.keys.contains(cell)
						}
						.forEach { cell, values in
							let point = pointForCell(cell: cell)
								.applying(.init(translationX: cellSize * 0.5, y: cellSize * 0.5))

							context.draw(
								Text(values.map(String.init).joined())
									.font(.caption),
								at: point
							)
						}
				}
				.gesture(gestures)
				.frame(width: gridSize, height: gridSize, alignment: .center)
				.background(Color.white)

			HStack {
				ForEach(fillColors, id: \.self) { color in
					Button {
						let allColored = selectedCells.allSatisfy { cell in
							coloredCells[cell] == color
						}

						selectedCells.forEach { cell in
							if allColored {
								coloredCells[cell] = nil
							} else {
								coloredCells[cell] = color
							}
						}
					} label: {
						color.frame(width: 44, height: 44)
							.continuousCornerRadius(8)
					}
				}
			}

			HStack {
				ForEach(SelectionMode.allCases, id: \.self) { value in
					Button {
						selectionMode = value
					} label: {
						Text(value.rawValue)
							.padding(10)
							.background(selectionMode == value ? Color.green : .gray)
							.continuousCornerRadius(8)
							.foregroundColor(.white)
					}
				}
			}

			Button("Clear selection") {
				selectedCells = []
			}

			HStack {
				ForEach(EntryMode.allCases, id: \.self) { value in
					Button {
						entryMode = value
					} label: {
						Text(value.rawValue)
							.padding(10)
							.background(entryMode == value ? Color.green : .gray)
							.continuousCornerRadius(8)
							.foregroundColor(.white)
					}
				}
			}

			HStack {
				ForEach(1..<10) { value in
					Button {
						selectedCells.forEach { cell in
							guard fixedNumbers[cell] == nil else {
								return
							}

							switch entryMode {
							case .big:
								if bigNumbers[cell] == value {
									bigNumbers[cell] = nil
								} else {
									bigNumbers[cell] = value
								}
							case .center:
								var values = Set(centerNumbers[cell] ?? [])
								if values.contains(value) {
									values.remove(value)
								} else {
									values.insert(value)
								}
								centerNumbers[cell] = values.sorted()
							}
						}
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

			Text(touchMode.rawValue)
		}
	}

	var gestures: some Gesture {
		ExclusiveGesture(
			DragGesture(minimumDistance: 3)
				.onChanged { value in
					touchMode = .drag

					let cell = cellForPoint(point: value.location)

					if cell == previousDraggedCell {
						return
					}

					previousDraggedCell = cell

					if dragUpdate == nil {
						dragUpdate = selectedCells.contains(cell) ? .remove : .addition
					}

					switch dragUpdate {
					case .remove:
						selectedCells.remove(cell)
					case .addition:
						selectedCells.insert(cell)
					case nil:
						break
					}
				}
				.onEnded { _ in
					dragUpdate = nil
				},
			SpatialTapGesture()
				.onEnded { value in
					touchMode = .tap
					if (
						value.location.x < 0 || gridSize < value.location.x ||
						value.location.y < 0 || gridSize < value.location.y
					) {
						return
					}

					let cell = cellForPoint(point: value.location)

					switch selectionMode {
					case .single:
						selectedCells = [cell]
					case .multiple:
						if selectedCells.contains(cell) {
							selectedCells.remove(cell)
						} else {
							selectedCells.insert(cell)
						}
					}
				}
		)
	}

	var cellSpaceToPointSpace: CGAffineTransform {
		CGAffineTransformIdentity
			.scaledBy(x: cellSize, y: cellSize)
	}

	func cellForPoint(point: CGPoint) -> Int {
		let p = point.applying(cellSpaceToPointSpace.inverted())

		let row = Int(p.x)
		let col = Int(p.y)

		return col * 9 + row
	}

	func pointForCell(cell: Int) -> CGPoint {
		let row = cell % 9
		let col = cell / 9

		return CGPoint(x: row, y: col)
			.applying(cellSpaceToPointSpace)
	}

	func pathFor(cells: Set<Int>) -> Path {
		var path = Path()

		cells.forEach { cell in
			let origin = pointForCell(cell: cell)
			Direction.allCases.forEach { direction in
				if !cells.contains(cell + direction.rawValue) {
					switch direction {
					case .left:
						path.move(to: origin)
						path.addLine(to: origin.applying(.init(translationX: 0, y: cellSize)))
					case .up:
						path.move(to: origin)
						path.addLine(to: origin.applying(.init(translationX: cellSize, y: 0)))
					case .down:
						path.move(to: origin.applying(.init(translationX: 0, y: cellSize)))
						path.addLine(to: origin.applying(.init(translationX: cellSize, y: cellSize)))
					case .right:
						path.move(to: origin.applying(.init(translationX: cellSize, y: 0)))
						path.addLine(to: origin.applying(.init(translationX: cellSize, y: cellSize)))
					}
				}
			}
		}

		return path
	}

	enum Direction: Int, CaseIterable {
		case up = -9
		case down = 9
		case left = -1
		case right = 1
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
