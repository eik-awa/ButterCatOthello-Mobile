import Foundation

struct HardCpuStrategy: CpuStrategy {
    private let maxDepth = 3

    private let weights: [[Int]] = [
        [100, -20, 10,  5,  5, 10, -20, 100],
        [-20, -50, -2, -2, -2, -2, -50, -20],
        [ 10,  -2,  5,  1,  1,  5,  -2,  10],
        [  5,  -2,  1,  0,  0,  1,  -2,   5],
        [  5,  -2,  1,  0,  0,  1,  -2,   5],
        [ 10,  -2,  5,  1,  1,  5,  -2,  10],
        [-20, -50, -2, -2, -2, -2, -50, -20],
        [100, -20, 10,  5,  5, 10, -20, 100],
    ]

    func decideMove(game: Game) -> CpuMove? {
        let cpuColor = game.currentTurn
        let allMoves = getAllValidMoves(game: game)
        guard !allMoves.isEmpty else { return nil }

        var bestMove: CpuMove? = nil
        var bestScore = Int.min

        for move in allMoves {
            let clone = game.clone()
            clone.selectHandDisc(move.discId)
            guard clone.placeDisk(at: move.position, color: clone.currentTurn) != nil else { continue }

            var score = minimax(game: clone, depth: maxDepth - 1,
                                alpha: Int.min, beta: Int.max,
                                isMaximizing: false, cpuColor: cpuColor)

            // Disc-type adjustments
            if let disc = game.hand(for: cpuColor).discs.first(where: { $0.id == move.discId }) {
                let posVal = weights[move.position.y][move.position.x]
                switch disc.type {
                case .butter:
                    if posVal < -10       { score += 30 }
                    else if posVal > 50   { score -= 100 }
                    else                  { score -= 15 }
                case .cat:
                    if move.position.isCorner { score -= 1000 }
                    else if posVal > 0        { score += 30 }
                    else                      { score += 15 }
                case .butterCat:
                    score += 15
                case .normal:
                    break
                }
                let total = game.discCount(for: .black) + game.discCount(for: .white)
                if total < 20 && disc.type != .normal { score -= 10 }
            }

            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }
        return bestMove
    }

    private func minimax(game: Game, depth: Int, alpha: Int, beta: Int,
                         isMaximizing: Bool, cpuColor: PlayerColor) -> Int {
        if depth == 0 || game.isGameOver() {
            return evaluate(game: game, cpuColor: cpuColor)
        }
        let moves = getAllValidMoves(game: game)
        if moves.isEmpty {
            let clone = game.clone()
            clone.pass()
            return minimax(game: clone, depth: depth - 1,
                           alpha: alpha, beta: beta,
                           isMaximizing: !isMaximizing, cpuColor: cpuColor)
        }

        var alpha = alpha
        var beta = beta

        if isMaximizing {
            var maxEval = Int.min
            for move in moves {
                let clone = game.clone()
                clone.selectHandDisc(move.discId)
                clone.placeDisk(at: move.position, color: clone.currentTurn)
                let ev = minimax(game: clone, depth: depth - 1,
                                 alpha: alpha, beta: beta,
                                 isMaximizing: false, cpuColor: cpuColor)
                maxEval = max(maxEval, ev)
                alpha = max(alpha, ev)
                if beta <= alpha { break }
            }
            return maxEval
        } else {
            var minEval = Int.max
            for move in moves {
                let clone = game.clone()
                clone.selectHandDisc(move.discId)
                clone.placeDisk(at: move.position, color: clone.currentTurn)
                let ev = minimax(game: clone, depth: depth - 1,
                                 alpha: alpha, beta: beta,
                                 isMaximizing: true, cpuColor: cpuColor)
                minEval = min(minEval, ev)
                beta = min(beta, ev)
                if beta <= alpha { break }
            }
            return minEval
        }
    }

    private func evaluate(game: Game, cpuColor: PlayerColor) -> Int {
        let opp = cpuColor.opposite
        if game.isGameOver() {
            let w = game.winner()
            if w == cpuColor.rawValue { return 100_000 }
            if w == opp.rawValue      { return -100_000 }
            return 0
        }

        var score = 0
        let cpuDiscs  = game.discCount(for: cpuColor)
        let oppDiscs  = game.discCount(for: opp)
        let total = cpuDiscs + oppDiscs

        // 1. Position weights
        score += (posScore(game: game, color: cpuColor) - posScore(game: game, color: opp)) * 2

        // 2. Mobility
        let cpuMob = game.getValidMoves(for: cpuColor).count
        let oppMob = game.getValidMoves(for: opp).count
        score += (cpuMob - oppMob) * 10

        // 3. Stable discs (corners)
        score += (stableDiscs(game: game, color: cpuColor) - stableDiscs(game: game, color: opp)) * 25

        // 4. Disc count
        if total < 40 { score += (cpuDiscs - oppDiscs) * 2 }
        else          { score += (cpuDiscs - oppDiscs) * 15 }

        // 5. Dangerous positions
        score -= dangerousPositions(game: game, color: cpuColor) * 30
        score += dangerousPositions(game: game, color: opp) * 30

        // 6. Edge control
        score += (edgeControl(game: game, color: cpuColor) - edgeControl(game: game, color: opp)) * 5

        return score
    }

    private func posScore(game: Game, color: PlayerColor) -> Int {
        var s = 0
        for y in 0..<8 { for x in 0..<8 {
            if game.board.getDisk(at: Position(x: x, y: y))?.color == color {
                s += weights[y][x]
            }
        }}
        return s
    }

    private func stableDiscs(game: Game, color: PlayerColor) -> Int {
        let corners = [(0,0),(7,0),(0,7),(7,7)]
        var count = 0
        for (cx, cy) in corners {
            let pos = Position(x: cx, y: cy)
            if game.board.getDisk(at: pos)?.color == color {
                count += 1
                let dirs: [(Int,Int)] = [(cx == 0 ? 1 : -1, 0), (0, cy == 0 ? 1 : -1)]
                for (dx, dy) in dirs {
                    var nx = cx + dx; var ny = cy + dy
                    while nx >= 0 && nx < 8 && ny >= 0 && ny < 8 {
                        if game.board.getDisk(at: Position(x: nx, y: ny))?.color == color { count += 1 }
                        else { break }
                        nx += dx; ny += dy
                    }
                }
            }
        }
        return count
    }

    private func dangerousPositions(game: Game, color: PlayerColor) -> Int {
        let dangerous = [(1,0),(0,1),(1,1),(6,0),(7,1),(6,1),(0,6),(1,7),(1,6),(6,6),(7,6),(6,7)]
        let cornerFor: (Int,Int) -> (Int,Int) = { x, y in
            if x <= 1 && y <= 1 { return (0,0) }
            if x >= 6 && y <= 1 { return (7,0) }
            if x <= 1 && y >= 6 { return (0,7) }
            return (7,7)
        }
        var count = 0
        for (dx, dy) in dangerous {
            if game.board.getDisk(at: Position(x: dx, y: dy))?.color == color {
                let (cx, cy) = cornerFor(dx, dy)
                if game.board.getDisk(at: Position(x: cx, y: cy)) == nil { count += 1 }
            }
        }
        return count
    }

    private func edgeControl(game: Game, color: PlayerColor) -> Int {
        var count = 0
        for x in 0..<8 {
            if game.board.getDisk(at: Position(x: x, y: 0))?.color == color { count += 1 }
            if game.board.getDisk(at: Position(x: x, y: 7))?.color == color { count += 1 }
        }
        for y in 1..<7 {
            if game.board.getDisk(at: Position(x: 0, y: y))?.color == color { count += 1 }
            if game.board.getDisk(at: Position(x: 7, y: y))?.color == color { count += 1 }
        }
        return count
    }
}
