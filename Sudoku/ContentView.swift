//
//  ContentView.swift
//  Sudoku
//
//  Created by Oliver Foggin on 12/09/2022.
//

import SwiftUI

struct ContentView: View {
	@State var selectedCells: Set<Int> = [10, 16, 19, 25]

	@State var coloredCells: [Int: Color] = [
		15 : .red,
		13 : .yellow,
		1 : .green,
		72 : .blue,
	]

	let gridSize: CGFloat = 300
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
						let translation = CGAffineTransformMakeTranslation(cellSize * (-0.5), cellSize * -(0.5))

						let cellPath = Path(CGRect(
							origin: pointForCell(cell: cell),
							size: CGSize(width: cellSize, height: cellSize)
						))

						context.fill(cellPath, with: .color(color.opacity(0.7)))
					}

					selectedCells.map(pointForCell(cell:))
						.map {
							let translation = CGAffineTransformMakeTranslation(cellSize * (-0.5), cellSize * -(0.5))

							return Path(CGRect(
								origin: $0.applying(.init(translationX: 3, y: 3)),
								size: CGSize(width: cellSize - 6, height: cellSize - 6)
							))
						}
						.forEach {
							//						context.fill($0, with: .color(.purple.opacity(0.7)))
							context.stroke($0, with: .color(.purple.opacity(0.7)), lineWidth: 6)
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

			HStack {
				ForEach([Color.red, .yellow, .blue, .green], id: \.self) { color in
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

			Button("Clear selection") {
				selectedCells = []
			}
		}
	}

	var tapGesture: some Gesture {
		SpatialTapGesture()
			.onEnded { value in
				if (
					value.location.x < 0 || gridSize < value.location.x ||
					value.location.y < 0 || gridSize < value.location.y
				) {
					return
				}
				let cell = cellForPoint(point: value.location)
				if selectedCells.contains(cell) {
					selectedCells.remove(cell)
				} else {
					selectedCells.insert(cell)
				}
			}
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
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}

extension View {
	public func continuousCornerRadius(_ radius: CGFloat) -> some View {
		self
			.clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
	}
}

