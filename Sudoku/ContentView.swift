//
//  ContentView.swift
//  Sudoku
//
//  Created by Oliver Foggin on 12/09/2022.
//

import SwiftUI

struct ContentView: View {
	@State var selectedCells: Set<Int> = [10, 16, 19, 25]

	let gridSize: CGFloat = 300
	var cellSize: CGFloat { gridSize / 9 }

	var body: some View {
		Canvas(
			opaque: true,
			rendersAsynchronously: true) { context, size in
				let gridSize = size.width
				let boxSize = size.width / 3
				let cellSize = size.width / 9
				let rect = CGRect(origin: .zero, size: size)

				context.fill(Path(roundedRect: rect, cornerSize: .zero), with: .color(.white))

				let transform = CGAffineTransformIdentity
					.scaledBy(x: cellSize, y: cellSize)

				selectedCells.map(pathForCell(cell:))
					.map { $0.applying(transform) }
					.forEach {
						context.fill($0, with: .color(.purple.opacity(0.7)))
//						context.stroke($0, with: .color(.purple.opacity(0.7)), lineWidth: 6)
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
			}
			.gesture(tapGesture)
			.frame(width: gridSize, height: gridSize, alignment: .center)
			.background(Color.white)
	}

	var tapGesture: some Gesture {
		SpatialTapGesture()
			.onEnded { value in
				let cell = cellForPoint(point: value.location)
				if selectedCells.contains(cell) {
					selectedCells.remove(cell)
				} else {
					selectedCells.insert(cell)
				}
			}
	}

	func cellForPoint(point: CGPoint) -> Int {
		let transform = CGAffineTransformIdentity
			.scaledBy(x: 1 / cellSize, y: 1 / cellSize)

		let p = point.applying(transform)

		let row = Int(p.x)
		let col = Int(p.y)

		return col * 9 + row
	}

	func pathForCell(cell: Int) -> Path {
		let row = cell % 9
		let col = cell / 9

		var path = Path()
		path.addLines([
			CGPoint(x: row, y: col),
			CGPoint(x: row + 1, y: col),
			CGPoint(x: row + 1, y: col + 1),
			CGPoint(x: row, y: col + 1),
			CGPoint(x: row, y: col),
		])
		path.closeSubpath()

		return path
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
