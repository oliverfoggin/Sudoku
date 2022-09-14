enum FillColor: CaseIterable {
	case red
	case yellow
	case blue
	case green
}

enum EntryMode: String, CaseIterable {
	case big = "Big"
	case center = "Center"
}

enum SelectionMode: String, CaseIterable {
	case single = "Single"
	case multiple = "Multiple"
}

enum DragUpdate: String {
	case addition = "Add"
	case remove = "Remove"
}

enum TouchMode: String {
	case tap = "Tap"
	case drag = "Drag"
}

enum Direction: Int, CaseIterable {
	case up = -9
	case down = 9
	case left = -1
	case right = 1
}
