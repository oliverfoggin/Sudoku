struct SudokuEngine {
	private static let groups: [Set<Int>] = [
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

	static func visibleCells(from cell: Int) -> Set<Int> {
		var cells: Set<Int> = []

		let mod = cell % 9
		stride(from: 0, to: 9*9, by: 9)
			.map { $0 + mod }
			.forEach { cells.insert($0) }

		let div = cell / 9
		let start = 9 * div
		let end = start + 8
		(start...end).forEach { cells.insert($0) }

		groups.filter { $0.contains(cell) }
			.flatMap { $0 }
			.forEach { cells.insert($0) }

		cells.remove(cell)
		return cells
	}
}
