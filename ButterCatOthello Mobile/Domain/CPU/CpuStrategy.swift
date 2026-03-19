import Foundation

struct CpuMove {
    let discId: Int
    let position: Position
}

protocol CpuStrategy: Sendable {
    func decideMove(game: Game) -> CpuMove?
}

extension CpuStrategy {
    func getAllValidMoves(game: Game) -> [CpuMove] {
        var moves: [CpuMove] = []
        let color = game.currentTurn
        let hand = game.hand(for: color)
        let available = hand.discs.filter { !$0.isUsed }
        for disc in available {
            let tmp = game.clone()
            tmp.selectHandDisc(disc.id)
            let positions = tmp.getValidMoves(for: color)
            for pos in positions {
                moves.append(CpuMove(discId: disc.id, position: pos))
            }
        }
        return moves
    }
}
