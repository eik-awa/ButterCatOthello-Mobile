import Foundation

class Game: @unchecked Sendable {
    var board: Board
    var currentTurn: PlayerColor
    var blackHand: Hand
    var whiteHand: Hand
    var isLocked: Bool
    var flippingPositions: Set<String>  // "x,y" keys

    init() {
        board = Board()
        currentTurn = .black
        blackHand = Hand(color: .black)
        whiteHand = Hand(color: .white)
        isLocked = false
        flippingPositions = []
    }

    private init(board: Board, currentTurn: PlayerColor,
                 blackHand: Hand, whiteHand: Hand,
                 isLocked: Bool, flippingPositions: Set<String>) {
        self.board = board
        self.currentTurn = currentTurn
        self.blackHand = blackHand
        self.whiteHand = whiteHand
        self.isLocked = isLocked
        self.flippingPositions = flippingPositions
    }

    func clone() -> Game {
        Game(board: board, currentTurn: currentTurn,
             blackHand: blackHand, whiteHand: whiteHand,
             isLocked: isLocked, flippingPositions: flippingPositions)
    }

    // MARK: - Hand accessors

    var currentHand: Hand {
        get { currentTurn == .black ? blackHand : whiteHand }
        set { if currentTurn == .black { blackHand = newValue } else { whiteHand = newValue } }
    }

    func hand(for color: PlayerColor) -> Hand {
        color == .black ? blackHand : whiteHand
    }

    // MARK: - Selection

    func selectHandDisc(_ id: Int) {
        if blackHand.discs.contains(where: { $0.id == id }) {
            whiteHand = whiteHand.deselected()
            blackHand = blackHand.selecting(id)
        } else if whiteHand.discs.contains(where: { $0.id == id }) {
            blackHand = blackHand.deselected()
            whiteHand = whiteHand.selecting(id)
        }
    }

    func deselectHandDisc() {
        currentHand = currentHand.deselected()
    }

    // MARK: - Move validation

    func canPlaceDisk(at pos: Position, color: PlayerColor) -> Bool {
        guard board.getDisk(at: pos) == nil else { return false }
        for dir in Position.directions {
            var cur = pos.move(dx: dir.dx, dy: dir.dy)
            var foundOpponent = false
            while let c = cur {
                guard let disk = board.getDisk(at: c) else { break }
                if disk.isButterCat { break }
                if disk.color == color.opposite {
                    foundOpponent = true
                } else if disk.color == color && foundOpponent {
                    return true
                } else {
                    break
                }
                cur = c.move(dx: dir.dx, dy: dir.dy)
            }
        }
        return false
    }

    func getValidMoves(for color: PlayerColor) -> [Position] {
        let hand = self.hand(for: color)
        let selId = hand.selectedDiscId
        let discType: DiscType? = selId.flatMap { id in hand.discs.first { $0.id == id }?.type }

        var positions: [Position] = []
        for y in 0..<8 {
            for x in 0..<8 {
                let pos = Position(x: x, y: y)
                if let t = discType, t != .normal, pos.isInCenter16 { continue }
                if canPlaceDisk(at: pos, color: color) {
                    positions.append(pos)
                }
            }
        }
        return positions
    }

    // MARK: - Place disk

    @discardableResult
    func placeDisk(at pos: Position, color: PlayerColor) -> [Position]? {
        guard !isLocked, color == currentTurn else { return nil }
        let hand = currentHand
        guard hand.hasSelection, let selDisc = hand.selectedDisc else { return nil }

        let discType = selDisc.type
        if discType != .normal && pos.isInCenter16 { return nil }
        guard canPlaceDisk(at: pos, color: color) else { return nil }

        // Determine placed color
        let placedColor: PlayerColor = discType == .butter ? color.opposite : color
        board.setDisk(Disk(placedColor, discType), at: pos)

        var flipped: [Position] = []

        if discType != .butterCat {
            let flipBase: PlayerColor = discType == .butter ? color : placedColor
            for dir in Position.directions {
                var toFlip: [Position] = []
                var cur = pos.move(dx: dir.dx, dy: dir.dy)
                while let c = cur {
                    guard let disk = board.getDisk(at: c) else { break }
                    if disk.isButterCat { break }
                    if disk.color == flipBase.opposite {
                        toFlip.append(c)
                    } else if disk.color == flipBase {
                        for flipPos in toFlip {
                            if let fd = board.getDisk(at: flipPos) {
                                if fd.isCat || fd.isButter {
                                    // Stays same color/type (360° visual spin)
                                    board.setDisk(Disk(fd.color, fd.type), at: flipPos)
                                } else {
                                    board.setDisk(Disk(flipBase, fd.type), at: flipPos)
                                }
                                flipped.append(flipPos)
                            }
                        }
                        break
                    } else {
                        break
                    }
                    cur = c.move(dx: dir.dx, dy: dir.dy)
                }
            }
        }

        currentHand = currentHand.afterUsingSelected()
        currentTurn = currentTurn.opposite
        return flipped
    }

    // MARK: - Flipping animation state

    func startFlipping(_ positions: [Position]) {
        isLocked = true
        flippingPositions = Set(positions.map { "\($0.x),\($0.y)" })
    }

    func endFlipping() {
        isLocked = false
        flippingPositions = []
    }

    func isFlipping(at pos: Position) -> Bool {
        flippingPositions.contains("\(pos.x),\(pos.y)")
    }

    // MARK: - Pass

    func pass() {
        deselectHandDisc()
        currentTurn = currentTurn.opposite
    }

    // MARK: - Game state queries

    func hasValidMoves() -> Bool {
        !getValidMoves(for: currentTurn).isEmpty
    }

    func hasValidMovesWithNormalDiscs() -> Bool {
        let hand = currentHand
        let normalDiscs = hand.discs.filter { !$0.isUsed && $0.type == .normal }
        guard !normalDiscs.isEmpty else { return false }
        for disc in normalDiscs {
            let tmp = clone()
            tmp.selectHandDisc(disc.id)
            if !tmp.getValidMoves(for: currentTurn).isEmpty { return true }
        }
        return false
    }

    func isGameOver() -> Bool {
        let curMoves = getValidMoves(for: currentTurn)
        if !curMoves.isEmpty { return false }
        let oppMoves = getValidMoves(for: currentTurn.opposite)
        return oppMoves.isEmpty
    }

    func discCount(for color: PlayerColor) -> Int {
        var count = 0
        for y in 0..<8 {
            for x in 0..<8 {
                if board.getDisk(at: Position(x: x, y: y))?.color == color { count += 1 }
            }
        }
        return count
    }

    func winner() -> String? {
        guard isGameOver() else { return nil }
        let b = discCount(for: .black)
        let w = discCount(for: .white)
        if b > w { return "black" }
        if w > b { return "white" }
        return "draw"
    }
}
