import Foundation

struct GridPosition: Hashable {
    let x: Int
    let y: Int

    static func area(from start: GridPosition, to end: GridPosition) -> [GridPosition] {
        let minX = min(start.x, end.x)
        let maxX = max(start.x, end.x)
        let minY = min(start.y, end.y)
        let maxY = max(start.y, end.y)

        var positions: [GridPosition] = []
        for x in minX...maxX {
            for y in minY...maxY {
                positions.append(GridPosition(x: x, y: y))
            }
        }
        return positions
    }

    static func corners(from start: GridPosition, to end: GridPosition) -> [GridPosition] {
        let minX = min(start.x, end.x)
        let maxX = max(start.x, end.x)
        let minY = min(start.y, end.y)
        let maxY = max(start.y, end.y)

        return [
            GridPosition(x: minX, y: minY),
            GridPosition(x: maxX, y: minY),
            GridPosition(x: minX, y: maxY),
            GridPosition(x: maxX, y: maxY)
        ]
    }
}
