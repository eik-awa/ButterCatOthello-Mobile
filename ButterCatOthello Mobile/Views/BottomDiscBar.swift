import SwiftUI

struct BottomDiscBar: View {
    @ObservedObject var viewModel: GameViewModel

    private var playerColor: PlayerColor {
        viewModel.mode == .pvp ? viewModel.currentTurn : .black
    }
    private var playerHand: Hand {
        playerColor == .black ? viewModel.blackHand : viewModel.whiteHand
    }
    private var isCpuTurn: Bool {
        viewModel.mode != .pvp && viewModel.currentTurn == .white
    }

    var body: some View {
        VStack(spacing: 0) {
            // 細い境界線
            Rectangle()
                .fill(AppTheme.cardBorder)
                .frame(height: 1)

            HStack(spacing: 0) {
                // 左：ステータス
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(playerColor == .black ? Color(white: 0.1) : Color.white)
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 0.8))
                        Text(playerColor.displayName)
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundColor(AppTheme.textDark)
                    }
                    Text(statusText)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.textMid)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(minWidth: 80, alignment: .leading)
                .padding(.leading, 14)

                Spacer()

                // 右：手札4枚
                HStack(spacing: 8) {
                    ForEach(playerHand.discs) { disc in
                        HandDiscView(
                            disc: disc,
                            isSelected: playerHand.selectedDiscId == disc.id,
                            size: 56
                        ) {
                            viewModel.selectDisc(disc.id)
                        }
                        .disabled(isCpuTurn || viewModel.isLocked)
                    }
                }
                .padding(.trailing, 14)
            }
            .padding(.vertical, 10)
            .background(
                AppTheme.card
                    .opacity(0.96)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }

    private var statusText: String {
        if isCpuTurn { return "考え中…" }
        if viewModel.isLocked { return "フリップ中" }
        if playerHand.hasSelection { return "盤面に置いてね" }
        return "駒を選んでね"
    }
}
