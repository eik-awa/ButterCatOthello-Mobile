import SwiftUI

// MARK: - Data model

private enum TutorialBeat {
    case message(String)
    case selectDisc
    case boardAction
    case boardAction2
    case opponentMove
    case boardDisplay
}

private struct TutorialStepData {
    let title: String
    let beats: [TutorialBeat]
    let board: BoardSetup
    let handDiscs: [DiscType]
    let correctDiscIndex: [Int]
}

private struct BoardSetup {
    let initialDiscs: [TDisc]
    let targetCol: Int
    let targetRow: Int
    let placeDisc: TDisc
    let flips: [TDisc]
    let targetCol2: Int?
    let targetRow2: Int?
    let placeDisc2: TDisc?
    let flips2: [TDisc]
    let opponentDisc: TDisc?
    let opponentFlips: [TDisc]
    let resistCol: Int?
    let resistRow: Int?
    let butterResistCol: Int?
    let butterResistRow: Int?
    let hasFirstMove: Bool
}

private struct TDisc: Equatable, Hashable {
    let col: Int
    let row: Int
    let isBlack: Bool
    let type: DiscType
}

// MARK: - Step definitions

private let steps: [TutorialStepData] = [

    // ── Step 1: 基本 ─────────────────────────────────
    TutorialStepData(
        title: "駒を選択して置こう",
        beats: [
            .message("やっほー！\nオセロのルールを教えるにゃ"),
            .message("まずは手札から駒を選んで\n盤面に置くにゃ！"),
            .message("下の手札から駒を選ぶにゃ！"),
            .selectDisc,
            .message("いい選択にゃ！\n次は光ってるマスをタップするにゃ！"),
            .boardAction,
            .message("やったにゃ！\n相手の駒を挟んで裏返せたにゃ！"),
            .message("これがオセロの基本にゃ！"),
        ],
        board: BoardSetup(
            initialDiscs: [
                TDisc(col: 1, row: 1, isBlack: false, type: .normal),
                TDisc(col: 2, row: 1, isBlack: true,  type: .normal),
                TDisc(col: 1, row: 2, isBlack: true,  type: .normal),
                TDisc(col: 2, row: 2, isBlack: false, type: .normal),
            ],
            targetCol: 3, targetRow: 2,
            placeDisc: TDisc(col: 3, row: 2, isBlack: true, type: .normal),
            flips: [TDisc(col: 2, row: 2, isBlack: true, type: .normal)],
            targetCol2: nil, targetRow2: nil, placeDisc2: nil, flips2: [],
            opponentDisc: nil, opponentFlips: [],
            resistCol: nil, resistRow: nil,
            butterResistCol: nil, butterResistRow: nil,
            hasFirstMove: true
        ),
        handDiscs: [.normal, .butter, .cat, .butterCat],
        correctDiscIndex: [0]
    ),

    // ── Step 2: 猫駒 ─────────────────────────────────
    TutorialStepData(
        title: "猫駒は裏返されないにゃ",
        beats: [
            .message("次は猫駒について教えるにゃ！"),
            .message("猫駒は自分の色になる\n特別な駒にゃ"),
            .message("手札から猫駒を選ぶにゃ！"),
            .selectDisc,
            .message("猫駒を選んだにゃ！\n光ってるマスに置いてみるにゃ！"),
            .boardAction,
            .message("次は相手のターンにゃ！\n見ててにゃ..."),
            .opponentMove,
            .message("ほらにゃ！猫駒は挟まれても\nくるんと回って裏返されないにゃ！"),
            .message("これが猫駒の特別な力にゃ！"),
        ],
        board: BoardSetup(
            initialDiscs: [
                TDisc(col: 1, row: 1, isBlack: false, type: .normal),
                TDisc(col: 2, row: 1, isBlack: true,  type: .normal),
                TDisc(col: 0, row: 2, isBlack: false, type: .normal),
                TDisc(col: 1, row: 2, isBlack: true,  type: .normal),
            ],
            targetCol: 0, targetRow: 1,
            placeDisc: TDisc(col: 0, row: 1, isBlack: true, type: .cat),
            flips: [TDisc(col: 1, row: 1, isBlack: true, type: .normal)],
            targetCol2: nil, targetRow2: nil, placeDisc2: nil, flips2: [],
            opponentDisc: TDisc(col: 0, row: 0, isBlack: false, type: .normal),
            opponentFlips: [],
            resistCol: 0, resistRow: 1,
            butterResistCol: nil, butterResistRow: nil,
            hasFirstMove: true
        ),
        handDiscs: [.normal, .cat, .butter, .butterCat],
        correctDiscIndex: [1]
    ),

    // ── Step 3: バター駒 ─────────────────────────────────
    TutorialStepData(
        title: "バター駒で角を取るにゃ",
        beats: [
            .message("バター駒は布石に使うにゃ！"),
            .message("まずはバター駒を選ぶにゃ！"),
            .selectDisc,
            .message("光ってるマスに置くにゃ！"),
            .boardAction,
            .message("次は相手のターンにゃ"),
            .opponentMove,
            .message("今度は通常駒で角を取るにゃ！"),
            .selectDisc,
            .message("角に置いてみるにゃ！"),
            .boardAction2,
            .message("これがバター駒の使い方にゃ！"),
        ],
        board: BoardSetup(
            initialDiscs: [
                TDisc(col: 2, row: 1, isBlack: false, type: .normal),
                TDisc(col: 3, row: 1, isBlack: true,  type: .normal),
                TDisc(col: 2, row: 2, isBlack: true,  type: .normal),
                TDisc(col: 3, row: 2, isBlack: false, type: .normal),
            ],
            targetCol: 1, targetRow: 1,
            placeDisc: TDisc(col: 1, row: 1, isBlack: false, type: .butter),
            flips: [TDisc(col: 2, row: 1, isBlack: true, type: .normal)],   // 白→黒に裏返す
            targetCol2: 0, targetRow2: 0,
            placeDisc2: TDisc(col: 0, row: 0, isBlack: true, type: .normal),
            flips2: [],   // バター駒は裏返さない（反転アニメのみ）
            opponentDisc: TDisc(col: 3, row: 0, isBlack: false, type: .normal),
            opponentFlips: [TDisc(col: 3, row: 1, isBlack: false, type: .normal)],  // 黒→白に裏返す
            resistCol: nil, resistRow: nil,
            butterResistCol: 1, butterResistRow: 1,
            hasFirstMove: true
        ),
        handDiscs: [.normal, .butter, .cat, .butterCat],
        correctDiscIndex: [1, 0]
    ),

    // ── Step 4: バター猫駒 ────────────────────────────
    TutorialStepData(
        title: "バター猫で拡大を防ぐにゃ",
        beats: [
            .message("次はバター猫駒にゃ！"),
            .message("まずは相手のターンを見るにゃ"),
            .boardDisplay,
            .opponentMove,
            .message("角に白が置かれたにゃ！"),
            .message("このままだとどんどん広がるにゃ"),
            .message("ここでバター猫の出番にゃ！"),
            .message("手札からバター猫駒を選ぶにゃ！"),
            .selectDisc,
            .message("光ってるマスに置いて防ぐにゃ！"),
            .boardAction,
            .message("これで拡大を止められたにゃ！"),
            .message("バター猫は壁として使うにゃ！"),
        ],
        board: BoardSetup(
            initialDiscs: [
                    TDisc(col: 1, row: 1, isBlack: true,  type: .normal), // 黒
                    TDisc(col: 1, row: 2, isBlack: true,  type: .normal), // 黒
                    TDisc(col: 2, row: 2, isBlack: false, type: .normal), // 白
                    TDisc(col: 0, row: 1, isBlack: false, type: .normal), // 白（相手が(0,2)から挟む用）
                ],
                targetCol: 1, targetRow: 0,
                placeDisc: TDisc(col: 1, row: 0, isBlack: true, type: .butterCat),
                flips: [TDisc(col: 1, row: 1, isBlack: true, type: .normal)],
                targetCol2: nil, targetRow2: nil, placeDisc2: nil, flips2: [],
                opponentDisc: TDisc(col: 0, row: 0, isBlack: false, type: .normal),
                opponentFlips: [TDisc(col: 1, row: 1, isBlack: false, type: .normal)], // 黒→白に裏返す
                resistCol: nil, resistRow: nil,
                butterResistCol: nil, butterResistRow: nil,
                hasFirstMove: false
        ),
        handDiscs: [.normal, .butterCat, .butter, .cat],
        correctDiscIndex: [1]
    ),
]

// MARK: - Board phase

private enum BoardPhase {
    case initial
    case firstPlaced
    case opponentAnimating
    case opponentMoved
    case secondPlaced
}

// MARK: - TutorialView

struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var stepIndex = 0
    @State private var visibleBeatCount = 1
    @State private var hasSelected = false
    @State private var hasPlaced = false
    @State private var hasPlaced2 = false
    @State private var hasOpponentMoved = false
    @State private var isOpponentAnimating = false
    @State private var isAdvancing = false
    @State private var wrongPick = false

    private var currentStep: TutorialStepData { steps[stepIndex] }

    private var currentBeat: TutorialBeat? {
        guard visibleBeatCount > 0, visibleBeatCount <= currentStep.beats.count else { return nil }
        return currentStep.beats[visibleBeatCount - 1]
    }

    private var waitingForSelection: Bool {
        guard let beat = currentBeat else { return false }
        if case .selectDisc = beat { return !hasSelected }
        return false
    }

    private var waitingForBoard: Bool {
        guard let beat = currentBeat else { return false }
        if case .boardAction = beat { return !hasPlaced }
        return false
    }

    private var waitingForBoard2: Bool {
        guard let beat = currentBeat else { return false }
        if case .boardAction2 = beat {
            return hasOpponentMoved && !hasPlaced2
        }
        return false
    }

    private var waitingForOpponent: Bool {
        guard let beat = currentBeat else { return false }
        if case .opponentMove = beat { return !hasOpponentMoved }
        return false
    }

    private var isStepComplete: Bool {
        visibleBeatCount >= currentStep.beats.count
    }

    private var canAdvance: Bool {
        !waitingForBoard && !waitingForBoard2 && !waitingForSelection
            && !waitingForOpponent && !isStepComplete && !isAdvancing
    }

    // ビート番号から盤面フェーズを再計算（戻るボタン対応の核心）
    private func recomputeState(for beatCount: Int, in step: TutorialStepData) -> (placed: Bool, placed2: Bool, opponent: Bool, selected: Bool) {
        let visibleBeats = step.beats.prefix(beatCount)
        let placed    = visibleBeats.contains { if case .boardAction  = $0 { return true }; return false }
        let placed2   = visibleBeats.contains { if case .boardAction2 = $0 { return true }; return false }
        let opponent  = visibleBeats.contains { if case .opponentMove = $0 { return true }; return false }
        // selectDiscが偶数回完了しているか（2手目以降の選択済み判定）は
        // 現在のbeat末尾がselectDiscかどうかで判断する
        let lastBeat  = beatCount > 0 ? step.beats[beatCount - 1] : nil
        let selected: Bool
        if let last = lastBeat, case .selectDisc = last {
            selected = false   // selectDiscが最後 → まだ未選択状態
        } else {
            // 直前にselectDiscがあれば選択済み
            selected = visibleBeats.contains { if case .selectDisc = $0 { return true }; return false }
        }
        return (placed, placed2, opponent, selected)
    }

    private var boardPhase: BoardPhase {
        if hasPlaced2 { return .secondPlaced }
        if hasOpponentMoved { return .opponentMoved }
        if isOpponentAnimating { return .opponentAnimating}
        if hasPlaced { return .firstPlaced }
        return .initial
    }

    var body: some View {
        ZStack {
            ButterBackground()

            VStack(spacing: 0) {
                tutorialTopBar

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            Text(currentStep.title)
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(AppTheme.boardGreenDark)
                                .padding(.top, 12)
                                .id("title")

                            ForEach(0..<visibleBeatCount, id: \.self) { i in
                                beatView(currentStep.beats[i], index: i)
                                    .id("beat-\(i)")
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .bottom).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }

                            Color.clear.frame(height: 16).id("scrollBottom")
                        }
                        .padding(.horizontal, 20)
                    }
                    .onChange(of: visibleBeatCount) { _, newCount in
                        guard newCount > 0 else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo("scrollBottom", anchor: .bottom)
                            }
                        }
                        if newCount <= currentStep.beats.count {
                            if case .opponentMove = currentStep.beats[newCount - 1],
                               !hasOpponentMoved {
                                triggerOpponentMove()
                            }
                        }
                    }
                    .onChange(of: stepIndex) { _, _ in
                        proxy.scrollTo("title", anchor: .top)
                    }
                }

                tutorialBottomBar
            }
        }
    }

    // MARK: - Beat rendering

    @ViewBuilder
    private func beatView(_ beat: TutorialBeat, index: Int) -> some View {
        switch beat {
        case .message(let text):
            CatBubble(text: text)

        case .selectDisc:
            let selectOccurrence = currentStep.beats.prefix(index)
                .filter { if case .selectDisc = $0 { return true }; return false }.count
            TutorialHandBar(
                discTypes: currentStep.handDiscs,
                correctIndex: currentStep.correctDiscIndex[selectOccurrence],
                hasSelected: hasSelected,
                wrongPick: wrongPick
            ) { tappedIndex in
                handleDiscSelection(tappedIndex, occurrence: selectOccurrence)
            }

        case .boardAction:
            TutorialMiniBoard(
                config: currentStep.board,
                phase: boardPhase,
                isInteractive: waitingForBoard,
                onPlace: { placeDisc() },
                onPlace2: {}
            )
            .frame(maxWidth: .infinity)

        case .boardAction2:
            TutorialMiniBoard(
                config: currentStep.board,
                phase: boardPhase,
                isInteractive: waitingForBoard2,
                onPlace: {},
                onPlace2: { placeDisc2() }
            )
            .frame(maxWidth: .infinity)

        case .boardDisplay:
            TutorialMiniBoard(
                config: currentStep.board,
                phase: boardPhase,
                isInteractive: false,
                onPlace: {},
                onPlace2: {}
            )
            .frame(maxWidth: .infinity)

        case .opponentMove:
            HStack {
                Spacer()
                Text("相手のターン")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.gray.opacity(0.6)))
            }
        }
    }

    // MARK: - Actions

    private func advance() {
        guard canAdvance else { return }
        // selectDiscの次ビートへ進むとき、hasSelectedをリセット
        if let beat = currentBeat, case .selectDisc = beat {
            // 選択済みのままなので次のselectDiscに備えてリセット不要
            // （次のselectDiscが来たときに再度falseにする）
        }
        isAdvancing = true
        withAnimation(.spring(duration: 0.35)) {
            visibleBeatCount += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            isAdvancing = false
        }
    }

    private func handleDiscSelection(_ tappedIndex: Int, occurrence: Int) {
        guard waitingForSelection else { return }
        let correctIndex = currentStep.correctDiscIndex[occurrence]
        if tappedIndex == correctIndex {
            hasSelected = true
            isAdvancing = true
            withAnimation(.spring(duration: 0.35)) {
                visibleBeatCount += 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                // 次のビートもselectDiscなら未選択に戻す
                if visibleBeatCount <= currentStep.beats.count,
                   case .selectDisc = currentStep.beats[visibleBeatCount - 1] {
                    hasSelected = false
                }
                isAdvancing = false
            }
        } else {
            wrongPick = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                wrongPick = false
            }
        }
    }

    private func placeDisc() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
            hasPlaced = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            isAdvancing = false
            withAnimation(.spring(duration: 0.35)) {
                visibleBeatCount += 1
            }
        }
    }

    private func placeDisc2() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
            hasPlaced2 = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            isAdvancing = false
            withAnimation(.spring(duration: 0.35)) {
                visibleBeatCount += 1
            }
        }
    }

    private func triggerOpponentMove() {
        isOpponentAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                hasOpponentMoved = true
            }
            isOpponentAnimating = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(duration: 0.35)) {
                    visibleBeatCount += 1
                }
            }
        }
    }

    private func goToNextStep() {
        stepIndex += 1
        resetToStart()
    }

    /// 戻る：1ビート戻してフラグを再計算
    private func goBack() {
        let targetBeat = visibleBeatCount - 1
        if targetBeat >= 1 {
            applyState(beatCount: targetBeat, step: currentStep)
            withAnimation(.spring(duration: 0.35)) {
                visibleBeatCount = targetBeat
            }
        } else if stepIndex > 0 {
            // 前のステップの末尾へ
            stepIndex -= 1
            let prev = steps[stepIndex]
            let lastBeat = prev.beats.count
            applyState(beatCount: lastBeat, step: prev)
            withAnimation(.spring(duration: 0.35)) {
                visibleBeatCount = lastBeat
            }
        }
    }

    /// beatCount個表示した状態にフラグを合わせる
    private func applyState(beatCount: Int, step: TutorialStepData) {
        let (placed, placed2, opponent, selected) = recomputeState(for: beatCount, in: step)
        hasPlaced        = placed
        hasPlaced2       = placed2
        hasOpponentMoved = opponent
        hasSelected      = selected
        isAdvancing      = false
        wrongPick        = false
    }

    private func resetToStart() {
        visibleBeatCount = 0
        hasPlaced        = false
        hasPlaced2       = false
        hasSelected      = false
        hasOpponentMoved = false
        isAdvancing      = false
        wrongPick        = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(duration: 0.35)) {
                visibleBeatCount = 1
            }
        }
    }

    // MARK: - Top bar

    private var tutorialTopBar: some View {
        HStack {
            HStack(spacing: 8) {
                ForEach(0..<steps.count, id: \.self) { i in
                    Capsule()
                        .fill(i == stepIndex ? AppTheme.boardGreen : AppTheme.cardBorder)
                        .frame(width: i == stepIndex ? 20 : 8, height: 8)
                        .animation(.spring(duration: 0.3), value: stepIndex)
                }
            }
            Spacer()
            Text("\(stepIndex + 1) / \(steps.count)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textMid)
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.textMid)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle().fill(AppTheme.card)
                            .shadow(color: .black.opacity(0.08), radius: 4, y: 1)
                    )
                    .overlay(Circle().stroke(AppTheme.cardBorder, lineWidth: 1.5))
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Bottom bar

    private var tutorialBottomBar: some View {
        HStack(spacing: 12) {
            if stepIndex > 0 || visibleBeatCount > 1 {
                Button { goBack() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .bold))
                        Text("前へ")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(AppTheme.boardGreenDark)
                    .frame(height: 44)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppTheme.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppTheme.cardBorder, lineWidth: 1.5)
                            )
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }

            Spacer()

            if waitingForSelection {
                Text("手札から駒を選ぶにゃ！")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.amber)
            } else if waitingForBoard || waitingForBoard2 {
                Text("光ってるマスをタップするにゃ！")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.amber)
            } else if waitingForOpponent {
                Text("相手のターンにゃ...見ててにゃ！")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textMid)
            } else if isStepComplete {
                if stepIndex < steps.count - 1 {
                    Button { goToNextStep() } label: {
                        HStack(spacing: 6) {
                            Text("次のステップへ")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(height: 44)
                        .padding(.horizontal, 20)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.boardGreen, AppTheme.boardGreenDark],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: AppTheme.boardGreen.opacity(0.3), radius: 6, y: 3)
                    }
                    .buttonStyle(ScaleButtonStyle())
                } else {
                    Button { dismiss() } label: {
                        Text("さっそく遊ぶにゃ！")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .frame(height: 48)
                            .padding(.horizontal, 24)
                            .background(
                                LinearGradient(
                                    colors: [AppTheme.amber, Color(red: 1.0, green: 0.55, blue: 0.0)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(color: AppTheme.amberShadow, radius: 8, y: 3)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            } else {
                Button { advance() } label: {
                    HStack(spacing: 6) {
                        Text("次へ")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(height: 44)
                    .padding(.horizontal, 20)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.boardGreen, AppTheme.boardGreenDark],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: AppTheme.boardGreen.opacity(0.3), radius: 6, y: 3)
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(!canAdvance)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            AppTheme.card.opacity(0.95)
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(alignment: .top) {
            Rectangle().fill(AppTheme.cardBorder).frame(height: 1)
        }
    }
}

// MARK: - Cat speech bubble

private struct CatBubble: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image("buttercat")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .shadow(color: AppTheme.amberShadow, radius: 4, y: 2)

            Text(text)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.textDark)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppTheme.card)
                        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppTheme.cardBorder, lineWidth: 1.5)
                )

            Spacer(minLength: 24)
        }
    }
}

// MARK: - Hand disc selection bar

private struct TutorialHandBar: View {
    let discTypes: [DiscType]
    let correctIndex: Int
    let hasSelected: Bool
    let wrongPick: Bool
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 14) {
                ForEach(discTypes.indices, id: \.self) { i in
                    TutorialHandDisc(
                        type: discTypes[i],
                        isSelected: hasSelected && i == correctIndex,
                        isActive: !hasSelected,
                        onTap: { onSelect(i) }
                    )
                }
            }

            if wrongPick {
                Text("そっちじゃないにゃ〜 もう一回選ぶにゃ！")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.2))
                    .transition(.opacity)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.card)
                .shadow(color: .black.opacity(0.07), radius: 6, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.cardBorder, lineWidth: 1.5)
        )
    }
}

private struct TutorialHandDisc: View {
    let type: DiscType
    let isSelected: Bool
    let isActive: Bool
    let onTap: () -> Void

    private let size: CGFloat = 56

    private var imageName: String? {
        switch type {
        case .normal:    return nil
        case .butter:    return "butter"
        case .cat:       return "cat"
        case .butterCat: return "buttercat"
        }
    }

    private var baseColor: Color {
        switch type {
        case .normal:    return Color(white: 0.18)
        case .butter:    return Color(red: 1.0, green: 0.92, blue: 0.60)
        case .cat:       return Color(red: 0.90, green: 0.98, blue: 0.92)
        case .butterCat: return Color(red: 1.0, green: 0.88, blue: 0.60)
        }
    }

    private var label: String {
        switch type {
        case .normal:    return "通常"
        case .butter:    return "バター"
        case .cat:       return "猫"
        case .butterCat: return "バター猫"
        }
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(baseColor)
                        .frame(width: size, height: size)
                        .overlay(
                            Circle().stroke(
                                isSelected ? AppTheme.amber : Color.white.opacity(0.4),
                                lineWidth: isSelected ? 3 : 1.5
                            )
                        )

                    if let name = imageName {
                        Image(name)
                            .resizable()
                            .scaledToFit()
                            .frame(width: size * 0.80, height: size * 0.80)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color(white: 0.40), Color(white: 0.06)],
                                    center: UnitPoint(x: 0.35, y: 0.30),
                                    startRadius: 0, endRadius: size * 0.4
                                )
                            )
                            .frame(width: size * 0.76, height: size * 0.76)
                    }
                }
                .scaleEffect(isSelected ? 1.14 : 1.0)
                .shadow(
                    color: isSelected ? AppTheme.amber.opacity(0.5) : .black.opacity(0.15),
                    radius: isSelected ? 8 : 3
                )
                .animation(.spring(response: 0.25, dampingFraction: 0.65), value: isSelected)

                Text(label)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textMid)
            }
        }
        .disabled(!isActive)
        .opacity(isActive || isSelected ? 1.0 : 0.4)
    }
}

// MARK: - Interactive mini board
private struct TutorialMiniBoard: View {
    let config: BoardSetup
    let phase: BoardPhase
    let isInteractive: Bool
    let onPlace: () -> Void
    let onPlace2: () -> Void

    @State private var hintPulse = false
    @State private var resistSpin: Double = 0
    @State private var butterResistSpin: Double = 0

    private let gridSize = 4
    private let cellSize: CGFloat = 52

    private var currentDiscs: [TDisc] {
        var result = config.initialDiscs

        // 1手目（以降ずっと有効）
        if (config.hasFirstMove &&
            (phase == .firstPlaced ||
             phase == .opponentAnimating ||
             phase == .opponentMoved ||
             phase == .secondPlaced))
            ||
           (!config.hasFirstMove &&
            (phase == .firstPlaced ||
             phase == .secondPlaced)) {

            result.append(config.placeDisc)

            for flip in config.flips {
                result.removeAll { $0.col == flip.col && $0.row == flip.row }
                result.append(flip)
            }
        }

        // 相手ターン（2手目以降も保持）
        if phase == .opponentAnimating ||
           phase == .opponentMoved ||
           phase == .secondPlaced,
           let opp = config.opponentDisc {

            result.append(opp)

            // ひっくり返しは確定後のみ
            if phase == .opponentMoved || phase == .secondPlaced {
                for flip in config.opponentFlips {
                    result.removeAll { $0.col == flip.col && $0.row == flip.row }
                    result.append(flip)
                }
            }
        }

        // 自分の2手目
        if phase == .secondPlaced,
           let pd2 = config.placeDisc2 {

            result.append(pd2)

            for flip in config.flips2 {
                result.removeAll { $0.col == flip.col && $0.row == flip.row }
                result.append(flip)
            }
        }

        return result
    }
    
    private func discAt(col: Int, row: Int) -> TDisc? {
        currentDiscs.first { $0.col == col && $0.row == row }
    }

    private func isResistDisc(col: Int, row: Int) -> Bool {
        config.resistCol == col && config.resistRow == row
    }

    private func isButterResistDisc(col: Int, row: Int) -> Bool {
        config.butterResistCol == col && config.butterResistRow == row
    }

    private var activeTargetCol: Int? {
        guard isInteractive else { return nil }
        if config.targetCol2 != nil && phase == .opponentMoved {
            return config.targetCol2
        }
        return config.targetCol
    }

    private var activeTargetRow: Int? {
        guard isInteractive else { return nil }
        if config.targetRow2 != nil && phase == .opponentMoved {
            return config.targetRow2
        }
        return config.targetRow
    }

    var body: some View {
        let boardSize = cellSize * CGFloat(gridSize)

        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(AppTheme.boardGreen)
                .frame(width: boardSize, height: boardSize)

            Path { path in
                for i in 0...gridSize {
                    let offset = CGFloat(i) * cellSize
                    path.move(to: CGPoint(x: offset, y: 0))
                    path.addLine(to: CGPoint(x: offset, y: boardSize))
                    path.move(to: CGPoint(x: 0, y: offset))
                    path.addLine(to: CGPoint(x: boardSize, y: offset))
                }
            }
            .stroke(Color.black.opacity(0.3), lineWidth: 0.6)
            .frame(width: boardSize, height: boardSize)

            ForEach(0..<gridSize, id: \.self) { row in
                ForEach(0..<gridSize, id: \.self) { col in
                    let cx = CGFloat(col) * cellSize + cellSize / 2
                    let cy = CGFloat(row) * cellSize + cellSize / 2
                    let isTarget = activeTargetCol == col && activeTargetRow == row

                    ZStack {
                        if isTarget {
                            Circle()
                                .fill(Color.yellow.opacity(0.65))
                                .frame(width: cellSize * 0.33, height: cellSize * 0.33)
                                .scaleEffect(hintPulse ? 1.4 : 1.0)
                                .opacity(hintPulse ? 0.4 : 0.8)
                        }

                        if let disc = discAt(col: col, row: row) {
                            miniDiscView(disc)
                                .rotation3DEffect(
                                    .degrees(isResistDisc(col: col, row: row) ? resistSpin : 0),
                                    axis: (x: 0, y: 1, z: 0)
                                )
                                .rotation3DEffect(
                                    .degrees(isButterResistDisc(col: col, row: row) ? butterResistSpin : 0),
                                    axis: (x: 0, y: 1, z: 0)
                                )
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .frame(width: cellSize, height: cellSize)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard isInteractive && isTarget else { return }
                        if config.targetCol2 != nil && phase == .opponentMoved {
                            onPlace2()
                        } else {
                            onPlace()
                        }
                    }
                    .position(x: cx, y: cy)
                }
            }
        }
        .frame(width: boardSize, height: boardSize)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(white: 0.1).opacity(0.6), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                hintPulse = true
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.6), value: phase)
        .onChange(of: phase) { _, newPhase in
            // 猫駒：相手ターン後にスピン
            if newPhase == .opponentMoved && config.resistCol != nil {
                withAnimation(.easeInOut(duration: 0.5)) {
                    resistSpin = 360
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    resistSpin = 0
                }
            }
            // バター駒：2手目配置後にスピン
            if newPhase == .secondPlaced && config.butterResistCol != nil {
                withAnimation(.easeInOut(duration: 0.5)) {
                    butterResistSpin = 360
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    butterResistSpin = 0
                }
            }
        }
    }

    // MARK: - Disc rendering

    @ViewBuilder
    private func miniDiscView(_ disc: TDisc) -> some View {
        let s = cellSize * 0.78

        switch disc.type {
        case .normal:
            if disc.isBlack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(white: 0.42), Color(white: 0.06)],
                            center: UnitPoint(x: 0.38, y: 0.32),
                            startRadius: 0, endRadius: s * 0.54
                        )
                    )
                    .frame(width: s, height: s)
                    .overlay(Circle().stroke(Color(white: 0.28), lineWidth: 1.2))
                    .shadow(color: .black.opacity(0.45), radius: 3, y: 2)
            } else {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white, Color(white: 0.78)],
                            center: UnitPoint(x: 0.38, y: 0.32),
                            startRadius: 0, endRadius: s * 0.54
                        )
                    )
                    .frame(width: s, height: s)
                    .overlay(Circle().stroke(Color(white: 0.54), lineWidth: 1.2))
                    .shadow(color: .black.opacity(0.45), radius: 3, y: 2)
            }

        case .cat:
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: s, height: s)
                Image(disc.isBlack ? "cat" : "whitecat")
                    .resizable().scaledToFit()
                    .frame(width: s * 0.90, height: s * 0.90)
                    .clipShape(Circle())
            }
            .shadow(color: .black.opacity(0.28), radius: 3, y: 2)

        case .butter:
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: s, height: s)
                Image(disc.isBlack ? "ogura" : "butter")
                    .resizable().scaledToFit()
                    .frame(width: s * 0.90, height: s * 0.90)
                    .clipShape(Circle())
            }
            .shadow(color: .black.opacity(0.28), radius: 3, y: 2)

        case .butterCat:
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: s, height: s)
                Image("buttercat")
                    .resizable().scaledToFit()
                    .frame(width: s * 0.90, height: s * 0.90)
                    .clipShape(Circle())
            }
            .shadow(color: .black.opacity(0.28), radius: 3, y: 2)
        }
    }
}

// MARK: - Preview

#Preview {
    TutorialView()
}
