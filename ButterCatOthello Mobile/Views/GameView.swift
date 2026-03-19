import SwiftUI

struct GameView: View {
    @StateObject var viewModel: GameViewModel
    @ObservedObject private var adManager = AdMobManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showGameSettings = false

    var body: some View {
        ZStack {
            ButterBackground()

            VStack(spacing: 0) {
                // ナビゲーションバー代替
                TopBar(
                    viewModel: viewModel,
                    onDismiss: {
                        adManager.showInterstitial()
                        dismiss()
                    },
                    onSettings: { showGameSettings = true }
                )
                .padding(.top, 4)

                // スコア
                ScoreRow(viewModel: viewModel)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                // 相手手札（コンパクト）
                OpponentHandRow(viewModel: viewModel)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                // ボード
                BoardView(viewModel: viewModel)
                    .padding(.horizontal, 10)
                    .padding(.top, 10)

                Spacer(minLength: 0)

                // プレイヤー手札バー（下部固定）
                BottomDiscBar(viewModel: viewModel)

                // バナー広告
                BannerAdView(adUnitID: AdMobManager.bannerAdUnitID)
                    .frame(height: 50)
                    .background(AppTheme.card)
            }

            // パス通知トースト
            if viewModel.showPassMessage {
                VStack {
                    Spacer()
                    PassToast(message: viewModel.statusMessage)
                        .padding(.bottom, 160)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(), value: viewModel.showPassMessage)
            }

            // ゲームオーバーオーバーレイ
            if viewModel.isGameOver {
                GameOverOverlay(
                    winner: viewModel.winner,
                    blackCount: viewModel.blackDiscCount,
                    whiteCount: viewModel.whiteDiscCount,
                    onRestart: {
                        adManager.showInterstitial()
                        viewModel.restartGame()
                    },
                    onClose: {
                        adManager.showInterstitial()
                        dismiss()
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .animation(.spring(duration: 0.3), value: viewModel.isGameOver)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showGameSettings) {
            GameSettingsSheet(
                onRestart: {
                    showGameSettings = false
                    adManager.showInterstitial()
                    viewModel.restartGame()
                },
                onReturnToMenu: {
                    showGameSettings = false
                    adManager.showInterstitial()
                    dismiss()
                }
            )
        }
    }
}

// MARK: - Top bar
private struct TopBar: View {
    @ObservedObject var viewModel: GameViewModel
    let onDismiss: () -> Void
    let onSettings: () -> Void

    var modeLabel: String {
        switch viewModel.mode {
        case .pvp:     return "PvP"
        case .cpuEasy: return "CPU Easy"
        case .cpuHard: return "CPU Hard"
        }
    }

    var body: some View {
        HStack {
            Button(action: onDismiss) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                    Text("タイトル")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(AppTheme.boardGreenDark)
            }
            Spacer()
            HStack(spacing: 6) {
                Image("buttercat")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text("ButterCat Othello")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.boardGreenDark)
            }
            Spacer()
            HStack(spacing: 8) {
                Text(modeLabel)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.boardGreen)
                    .cornerRadius(8)

                Button(action: onSettings) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.boardGreenDark)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(AppTheme.card)
                                .shadow(color: .black.opacity(0.1), radius: 4, y: 1)
                        )
                        .overlay(
                            Circle()
                                .stroke(AppTheme.cardBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Score row
private struct ScoreRow: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        HStack(spacing: 10) {
            ScoreBadge(
                circleColor: Color(white: 0.1),
                label: "黒",
                count: viewModel.blackDiscCount,
                isActive: viewModel.currentTurn == .black && !viewModel.isGameOver,
                activeColor: AppTheme.boardGreen
            )
            Text("VS")
                .font(.system(size: 12, weight: .black))
                .foregroundColor(AppTheme.textMid)
            ScoreBadge(
                circleColor: .white,
                label: "白",
                count: viewModel.whiteDiscCount,
                isActive: viewModel.currentTurn == .white && !viewModel.isGameOver,
                activeColor: AppTheme.amber
            )
        }
    }
}

private struct ScoreBadge: View {
    let circleColor: Color
    let label: String
    let count: Int
    let isActive: Bool
    let activeColor: Color

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(circleColor)
                .frame(width: 18, height: 18)
                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.textMid)
            Spacer()
            Text("\(count)")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(isActive ? activeColor : AppTheme.textMid)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isActive ? activeColor.opacity(0.5) : AppTheme.cardBorder,
                                lineWidth: isActive ? 2 : 1.5)
                )
                .shadow(color: isActive ? activeColor.opacity(0.15) : .black.opacity(0.04),
                        radius: isActive ? 6 : 3, y: 2)
        )
        .animation(.spring(duration: 0.2), value: isActive)
    }
}

// MARK: - Opponent hand row
private struct OpponentHandRow: View {
    @ObservedObject var viewModel: GameViewModel

    var opponentColor: PlayerColor {
        viewModel.mode == .pvp ? viewModel.currentTurn.opposite : .white
    }
    var hand: Hand {
        opponentColor == .black ? viewModel.blackHand : viewModel.whiteHand
    }

    var body: some View {
        HStack(spacing: 8) {
            Text("相手の手札")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.textMid)
            HStack(spacing: 5) {
                ForEach(hand.discs) { disc in
                    MiniHandDiscView(disc: disc,
                                     isSelected: hand.selectedDiscId == disc.id)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.card.opacity(0.7))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.cardBorder, lineWidth: 1))
        )
    }
}

// MARK: - Pass toast
private struct PassToast: View {
    let message: String
    var body: some View {
        Text(message)
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color(white: 0.1).opacity(0.88))
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 2)
            )
    }
}

// MARK: - Game over overlay
struct GameOverOverlay: View {
    let winner: String?
    let blackCount: Int
    let whiteCount: Int
    let onRestart: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            AppTheme.pageBg.opacity(0.6)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)

            VStack(spacing: 24) {
                // アイコン
                Image(winner == "draw" ? "buttercat" : (winner == "black" ? "cat" : "whitecat"))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)

                VStack(spacing: 6) {
                    Text(resultTitle)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(AppTheme.textDark)
                    Text(resultSubtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textMid)
                }

                // スコア
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Circle().fill(Color(white: 0.1))
                            .frame(width: 28, height: 28)
                            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        Text("\(blackCount)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(AppTheme.textDark)
                    }
                    Text("－")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(AppTheme.textMid)
                    VStack(spacing: 4) {
                        Circle().fill(.white)
                            .frame(width: 28, height: 28)
                            .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 1.5))
                        Text("\(whiteCount)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(AppTheme.textDark)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 32)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppTheme.pageBg)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.cardBorder, lineWidth: 1.5))
                )

                VStack(spacing: 10) {
                    Button(action: onRestart) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 15, weight: .bold))
                            Text("もう一度プレイ")
                                .font(.system(size: 17, weight: .black, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.boardGreen, AppTheme.boardGreenDark],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: AppTheme.boardGreen.opacity(0.3), radius: 8, y: 3)
                    }
                    .buttonStyle(ScaleButtonStyle())

                    Button(action: onClose) {
                        HStack(spacing: 8) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 15, weight: .bold))
                            Text("タイトルへ")
                                .font(.system(size: 17, weight: .black, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.amber, Color(red: 1.0, green: 0.55, blue: 0.0)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: AppTheme.amberShadow, radius: 8, y: 3)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppTheme.card)
                    .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
            )
            .padding(.horizontal, 32)
        }
    }

    var resultTitle: String {
        if winner == "draw"  { return "引き分け 🤝" }
        return (winner == "black" ? "⚫️ 黒" : "⚪️ 白") + "の勝ち！"
    }
    var resultSubtitle: String {
        if winner == "draw" { return "いい勝負でした！" }
        return winner == "black" ? "おめでとう🎉" : "お見事でした！"
    }
}
// MARK: - Game settings sheet
private struct GameSettingsSheet: View {
    @ObservedObject private var audio = AudioManager.shared
    @Environment(\.dismiss) private var dismiss
    let onRestart: () -> Void
    let onReturnToMenu: () -> Void

    @State private var showRestartConfirm = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(red: 0.2, green: 0.6, blue: 1.0))
                                .frame(width: 36, height: 36)
                            Image(systemName: audio.isBGMMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        Toggle("BGM", isOn: Binding(
                            get: { !audio.isBGMMuted },
                            set: { _ in audio.toggleBGM() }
                        ))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    }

                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(AppTheme.amber)
                                .frame(width: 36, height: 36)
                            Image(systemName: audio.isSEMuted ? "bell.slash.fill" : "bell.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        Toggle("SE（効果音）", isOn: Binding(
                            get: { !audio.isSEMuted },
                            set: { _ in audio.toggleSE() }
                        ))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                } header: {
                    Text("サウンド設定")
                }

                Section {
                    Button {
                        showRestartConfirm = true
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppTheme.boardGreen)
                                    .frame(width: 36, height: 36)
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            Text("初めからやり直す")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.textDark)
                        }
                    }

                    Button(action: onReturnToMenu) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppTheme.amber)
                                    .frame(width: 36, height: 36)
                                Image(systemName: "house.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            Text("メインメニューに戻る")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.textDark)
                        }
                    }
                } header: {
                    Text("ゲーム操作")
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.boardGreenDark)
                }
            }
            .alert("確認", isPresented: $showRestartConfirm) {
                Button("キャンセル", role: .cancel) {}
                Button("やり直す", role: .destructive) {
                    onRestart()
                }
            } message: {
                Text("対局を最初からやり直しますか？")
            }
        }
        .presentationDetents([.medium])
    }
}

