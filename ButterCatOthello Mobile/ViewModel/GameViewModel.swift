import Foundation
import Combine

enum GameMode {
    case pvp
    case cpuEasy
    case cpuHard
}

@MainActor
class GameViewModel: ObservableObject {
    @Published var board: [[Disk?]] = []
    @Published var currentTurn: PlayerColor = .black
    @Published var blackHand: Hand = Hand(color: .black)
    @Published var whiteHand: Hand = Hand(color: .white)
    @Published var blackDiscCount: Int = 2
    @Published var whiteDiscCount: Int = 2
    @Published var validMoves: [Position] = []
    @Published var isGameOver: Bool = false
    @Published var winner: String? = nil
    @Published var isLocked: Bool = false
    @Published var statusMessage: String = ""
    @Published var showPassMessage: Bool = false

    let mode: GameMode
    private var game: Game
    private var cpuStrategy: (any CpuStrategy)?
    private let cpuColor: PlayerColor = .white

    init(mode: GameMode) {
        self.mode = mode
        self.game = Game()
        switch mode {
        case .cpuEasy: cpuStrategy = EasyCpuStrategy()
        case .cpuHard: cpuStrategy = HardCpuStrategy()
        case .pvp:     cpuStrategy = nil
        }
        syncState()
    }

    /// ゲームを最初からやり直す
    func restartGame() {
        game = Game()
        isGameOver = false
        winner = nil
        isLocked = false
        showPassMessage = false
        statusMessage = ""
        syncState()
    }

    // MARK: - Public actions

    func selectDisc(_ id: Int) {
        guard !isLocked, !isGameOver else { return }
        if mode != .pvp && game.currentTurn == cpuColor { return }
        game.selectHandDisc(id)
        syncState()
    }

    func tapCell(at pos: Position) {
        guard !isLocked, !isGameOver else { return }
        if mode != .pvp && game.currentTurn == cpuColor { return }
        guard game.currentHand.hasSelection else {
            statusMessage = "駒を選んでください！"
            return
        }
        guard let flipped = game.placeDisk(at: pos, color: game.currentTurn) else { return }
        AudioManager.shared.playMeow()

        if flipped.isEmpty {
            syncState()
            checkTurnAfterPlace()
        } else {
            game.startFlipping(flipped)
            isLocked = true
            syncState()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                self?.game.endFlipping()
                self?.syncState()
                self?.checkTurnAfterPlace()
            }
        }
    }

    // MARK: - Private helpers

    private func checkTurnAfterPlace() {
        if game.isGameOver() {
            isGameOver = true
            winner = game.winner()
            syncState()
            return
        }

        if !game.hasValidMoves() {
            // Current player must pass
            showPassMessage = true
            statusMessage = "\(game.currentTurn.displayName)はパスします"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.game.pass()
                self?.showPassMessage = false
                self?.syncState()
                self?.triggerCpuIfNeeded()
            }
        } else {
            syncState()
            triggerCpuIfNeeded()
        }
    }

    private func triggerCpuIfNeeded() {
        guard mode != .pvp, game.currentTurn == cpuColor,
              !isGameOver, let strategy = cpuStrategy else { return }

        isLocked = true
        statusMessage = "考え中..."

        let gameClone = game.clone()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let move = strategy.decideMove(game: gameClone)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                guard let move else {
                    self.game.pass()
                    self.isLocked = false
                    self.syncState()
                    self.checkTurnAfterPlace()
                    return
                }
                self.game.selectHandDisc(move.discId)
                self.syncState()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    guard let flipped = self.game.placeDisk(at: move.position,
                                                            color: self.game.currentTurn) else {
                        self.isLocked = false
                        self.syncState()
                        return
                    }
                    AudioManager.shared.playMeow()
                    if flipped.isEmpty {
                        self.isLocked = false
                        self.syncState()
                        self.checkTurnAfterPlace()
                    } else {
                        self.game.startFlipping(flipped)
                        self.syncState()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.game.endFlipping()
                            self.isLocked = false
                            self.syncState()
                            self.checkTurnAfterPlace()
                        }
                    }
                }
            }
        }
    }

    private func syncState() {
        board = game.board.toArray()
        currentTurn = game.currentTurn
        blackHand = game.blackHand
        whiteHand = game.whiteHand
        blackDiscCount = game.discCount(for: .black)
        whiteDiscCount = game.discCount(for: .white)
        isLocked = game.isLocked
        validMoves = game.getValidMoves(for: game.currentTurn)

        if !showPassMessage {
            if isLocked {
                statusMessage = game.currentTurn == cpuColor && mode != .pvp ? "考え中..." : ""
            } else if game.currentHand.hasSelection {
                statusMessage = "盤面に置いてください！"
            } else {
                statusMessage = "駒を選んでください！"
            }
        }
    }

    func flippingPositions() -> Set<String> {
        game.flippingPositions
    }
}
