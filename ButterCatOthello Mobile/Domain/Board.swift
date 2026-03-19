import Foundation

struct Board {
    // grid[y][x]
    private var grid: [[Disk?]]

    init() {
        grid = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        // Standard Othello starting position
        grid[3][3] = Disk(.white)
        grid[3][4] = Disk(.black)
        grid[4][3] = Disk(.black)
        grid[4][4] = Disk(.white)
    }

    func getDisk(at pos: Position) -> Disk? {
        grid[pos.y][pos.x]
    }

    mutating func setDisk(_ disk: Disk, at pos: Position) {
        grid[pos.y][pos.x] = disk
    }

    func toArray() -> [[Disk?]] {
        grid
    }
}
