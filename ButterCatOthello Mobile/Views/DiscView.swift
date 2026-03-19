import SwiftUI

/// ボード上の駒。
/// 通常駒: カードフリップ（旧色→新色）
/// 猫/バター駒: 360°スピン（色・タイプは維持）
/// バター猫駒: 常時回転 + 挟まれないので独立
struct DiscView: View {
    let disk: Disk
    let size: CGFloat
    let isFlipping: Bool

    /// Y軸回転角度。前半(0→90)は旧色、後半(-90→0)は新色
    @State private var angle: Double = 0
    /// false = 旧色(反転前)を表示、true = 新色(現在)を表示
    @State private var showNewFace: Bool = true
    /// バター猫の常時回転
    @State private var butterCatAngle: Double = 0

    // MARK: - 画像マッピング（元Webと同一）
    private func imageName(for color: PlayerColor, type: DiscType) -> String? {
        switch type {
        case .normal:    return nil
        case .butter:    return color == .black ? "ogura"   : "butter"
        case .cat:       return color == .black ? "cat"     : "whitecat"
        case .butterCat: return "buttercat"
        }
    }

    var body: some View {
        ZStack {
            discFace
        }
        // ★ frame を rotation3DEffect より先に確定させることで軸ズレを防ぐ
        .frame(width: size, height: size)
        .rotation3DEffect(
            .degrees(angle),
            axis: (x: 0, y: 1, z: 0),
            anchor: .center,
            anchorZ: 0,
            perspective: 0.4      // わずかな遠近感でリアルに
        )
        .onChange(of: isFlipping) { _, flipping in
            guard flipping else { return }
            performFlip()
        }
    }

    // MARK: - どちらの面を描くか
    @ViewBuilder
    private var discFace: some View {
        switch disk.type {
        case .normal:
            // showNewFace=false のとき旧色(opposite)を描く
            let displayColor = showNewFace ? disk.color : disk.color.opposite
            NormalDiscFace(color: displayColor, size: size)

        case .butter, .cat:
            // 色はそのまま維持（360°スピンのみ）
            SpecialDiscFace(
                imageName: imageName(for: disk.color, type: disk.type),
                size: size
            )

        case .butterCat:
            // 常時回転 + 独立アニメーション
            SpecialDiscFace(imageName: "buttercat", size: size)
                .rotationEffect(.degrees(butterCatAngle))
                .onAppear {
                    withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                        butterCatAngle = 360
                    }
                }
        }
    }

    // MARK: - フリップアニメーション
    private func performFlip() {
        switch disk.type {

        // 通常駒: カードフリップ（旧色 → 新色）
        case .normal:
            showNewFace = false   // まず旧色を見せる
            angle = 0

            // 前半: 0° → 90° （旧色が奥へ倒れる）
            withAnimation(.easeIn(duration: 0.18)) {
                angle = 90
            }
            // ちょうど90°（真横）で色を切り替え、反対側から起こす
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                showNewFace = true
                angle = -90   // 同じ"真横"の鏡映位置から

                // 後半: -90° → 0° （新色が手前へ起き上がる）
                withAnimation(.easeOut(duration: 0.18)) {
                    angle = 0
                }
            }

        // 猫/バター駒: 360°スピン（元に戻る）
        case .butter, .cat:
            angle = 0
            withAnimation(.easeInOut(duration: 0.45)) {
                angle = 360
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                angle = 0
            }

        // バター猫: 挟まれないのでフリップなし
        case .butterCat:
            break
        }
    }
}

// MARK: - 通常駒の描画（色を引数で受ける）
private struct NormalDiscFace: View {
    let color: PlayerColor
    let size: CGFloat

    var body: some View {
        let isBlack = color == .black
        Circle()
            .fill(
                isBlack
                ? RadialGradient(
                    colors: [Color(white: 0.42), Color(white: 0.06)],
                    center: UnitPoint(x: 0.38, y: 0.32),
                    startRadius: 0,
                    endRadius: size * 0.54
                )
                : RadialGradient(
                    colors: [.white, Color(white: 0.78)],
                    center: UnitPoint(x: 0.38, y: 0.32),
                    startRadius: 0,
                    endRadius: size * 0.54
                )
            )
            .frame(width: size, height: size)
            .overlay(
                Circle().stroke(
                    isBlack ? Color(white: 0.28) : Color(white: 0.54),
                    lineWidth: 1.2
                )
            )
            .shadow(color: .black.opacity(0.45), radius: 3, x: 0, y: 2)
    }
}

// MARK: - 特殊駒の描画
private struct SpecialDiscFace: View {
    let imageName: String?
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: size, height: size)
            if let name = imageName {
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.90, height: size * 0.90)
                    .clipShape(Circle())
            }
        }
        .shadow(color: .black.opacity(0.28), radius: 3, x: 0, y: 2)
    }
}
