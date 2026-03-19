import Foundation

struct Position: Equatable, Hashable {
    let x: Int
    let y: Int

    static let directions: [(dx: Int, dy: Int)] = {
        var dirs: [(Int, Int)] = []
        for dx in -1...1 {
            for dy in -1...1 {
                if dx == 0 && dy == 0 { continue }
                dirs.append((dx, dy))
            }
        }
        return dirs
    }()

    func move(dx: Int, dy: Int) -> Position? {
        let nx = x + dx
        let ny = y + dy
        guard nx >= 0, nx < 8, ny >= 0, ny < 8 else { return nil }
        return Position(x: nx, y: ny)
    }

    var isInCenter16: Bool {
        x >= 2 && x <= 5 && y >= 2 && y <= 5
    }

    var isCorner: Bool {
        (x == 0 || x == 7) && (y == 0 || y == 7)
    }
}
