import Foundation

struct EasyCpuStrategy: CpuStrategy {
    func decideMove(game: Game) -> CpuMove? {
        let color = game.currentTurn
        let hand = game.hand(for: color)
        let available = hand.discs.filter { !$0.isUsed }
        guard !available.isEmpty else { return nil }

        // Prefer non-cat discs
        let selected = available.first { $0.type != .cat } ?? available[0]
        let tmp = game.clone()
        tmp.selectHandDisc(selected.id)
        let validMoves = tmp.getValidMoves(for: color)
        guard !validMoves.isEmpty else { return nil }

        // Cat disc: avoid corners if possible
        if selected.type == .cat {
            let nonCorner = validMoves.filter { !$0.isCorner }
            let pos = (nonCorner.isEmpty ? validMoves : nonCorner).randomElement()!
            return CpuMove(discId: selected.id, position: pos)
        }

        return CpuMove(discId: selected.id, position: validMoves.randomElement()!)
    }
}
