import ComposableArchitecture
import SwiftUI

struct GameBoard: View {
	let store: StoreOf<GameCore>
	let viewStore: ViewStoreOf<GameCore>

	let gridSize: CGFloat = UIScreen.main.bounds.width - 20
	var cellSize: CGFloat { gridSize / 9 }
	var gridRect: CGRect {
		CGRect(
			origin: .zero,
			size: CGSize(width: gridSize, height: gridSize)
		)
	}

	init(store: StoreOf<GameCore>) {
		self.store = store
		viewStore = ViewStore(store)
	}

	var body: some View {
		Canvas(opaque: true, rendersAsynchronously: true) { context, size in
				let gridSize = size.width
				let boxSize = size.width / 3
				let cellSize = size.width / 9
				let rect = CGRect(origin: .zero, size: size)

				context.fill(Path(roundedRect: rect, cornerSize: .zero), with: .color(.white))

				viewStore.coloredCells.forEach { cell, color in
					let cellPath = Path(CGRect(
						origin: pointForCell(cell: cell),
						size: CGSize(width: cellSize, height: cellSize)
					))

					context.fill(cellPath, with: .color(color.color))
				}

				context.stroke(
					pathFor(cells: viewStore.selectedCells),
					with: .color(.purple.opacity(0.5)),
					lineWidth: 6
				)

				viewStore.errorCells.forEach { cell in
					let cellPath = Path(CGRect(
						origin: pointForCell(cell: cell),
						size: CGSize(width: cellSize, height: cellSize)
					))

					context.fill(cellPath, with: .color(.red.opacity(0.5)))
				}

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

				viewStore.fixedNumbers.forEach { cell, value in
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

				viewStore.bigNumbers
					.filter { cell, _ in
						!viewStore.fixedNumbers.keys.contains(cell)
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

				viewStore.centerNumbers
					.filter { cell, _ in
						!viewStore.bigNumbers.keys.contains(cell) &&
						!viewStore.fixedNumbers.keys.contains(cell)
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
	}

	var gestures: some Gesture {
		ExclusiveGesture(
			DragGesture(minimumDistance: 3)
				.onChanged { value in
					guard gridRect.contains(value.location) else {
						return
					}
					let cell = cellForPoint(point: value.location)
					viewStore.send(.cellDragged(cell))
				}
				.onEnded { _ in
					viewStore.send(.dragEnded)
				},
			SpatialTapGesture()
				.onEnded { value in
					guard gridRect.contains(value.location) else {
						return
					}
					let cell = cellForPoint(point: value.location)
					viewStore.send(.cellTapped(cell))
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
}
