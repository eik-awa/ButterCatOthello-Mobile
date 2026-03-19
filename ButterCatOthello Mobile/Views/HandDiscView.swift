import SwiftUI

/// 手札バー内の大きいインタラクティブ駒
struct HandDiscView: View {
    let disc: HandDisc
    let isSelected: Bool
    let size: CGFloat
    let onTap: () -> Void

    private var imageName: String? {
        switch disc.type {
        case .normal:    return nil
        case .butter:    return disc.color == .black ? "butter" : "ogura"
        case .cat:       return disc.color == .black ? "cat"    : "whitecat"
        case .butterCat: return "buttercat"
        }
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // ベース円
                Circle()
                    .fill(baseColor)
                    .frame(width: size, height: size)
                    .overlay(
                        Circle().stroke(
                            isSelected ? AppTheme.amber : Color.white.opacity(0.4),
                            lineWidth: isSelected ? 3 : 1.5
                        )
                    )

                if disc.isUsed {
                    // 空きスロット
                    Circle()
                        .strokeBorder(Color.white.opacity(0.25),
                                      style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                        .frame(width: size * 0.65, height: size * 0.65)
                } else if let name = imageName {
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.80, height: size * 0.80)
                        .clipShape(Circle())
                } else {
                    // 通常駒
                    Circle()
                        .fill(
                            disc.color == .black
                            ? RadialGradient(colors: [Color(white: 0.40), Color(white: 0.06)],
                                             center: UnitPoint(x: 0.35, y: 0.30),
                                             startRadius: 0, endRadius: size * 0.4)
                            : RadialGradient(colors: [.white, Color(white: 0.80)],
                                             center: UnitPoint(x: 0.35, y: 0.30),
                                             startRadius: 0, endRadius: size * 0.4)
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
        }
        .disabled(disc.isUsed)
        .opacity(disc.isUsed ? 0.35 : 1.0)
        .frame(width: size, height: size)
    }

    private var baseColor: Color {
        if disc.isUsed { return Color.white.opacity(0.12) }
        switch disc.type {
        case .normal:
            return disc.color == .black ? Color(white: 0.18) : Color(white: 0.92)
        case .butter:
            return Color(red: 1.0, green: 0.92, blue: 0.60)
        case .cat:
            return Color(red: 0.90, green: 0.98, blue: 0.92)
        case .butterCat:
            return Color(red: 1.0, green: 0.88, blue: 0.60)
        }
    }
}

/// 相手手札の小さい読み取り専用駒
struct MiniHandDiscView: View {
    let disc: HandDisc
    let isSelected: Bool

    private var imageName: String? {
        switch disc.type {
        case .normal:    return nil
        case .butter:    return disc.color == .black ? "butter" : "ogura"
        case .cat:       return disc.color == .black ? "cat"    : "whitecat"
        case .butterCat: return "buttercat"
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(baseColor)
                .frame(width: 30, height: 30)
                .overlay(
                    Circle().stroke(
                        isSelected ? AppTheme.amber : Color.gray.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
                )

            if !disc.isUsed {
                if let name = imageName {
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .clipShape(Circle())
                } else {
                    // 通常
                    Circle()
                        .fill(disc.color == .black ? Color(white: 0.15) : Color(white: 0.90))
                        .frame(width: 22, height: 22)
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 0.8))
                }
            }
        }
        .opacity(disc.isUsed ? 0.25 : 1.0)
    }

    private var baseColor: Color {
        if disc.isUsed { return Color.white.opacity(0.1) }
        switch disc.type {
        case .normal:    return disc.color == .black ? Color(white: 0.15) : Color(white: 0.88)
        case .butter:    return Color(red: 1.0, green: 0.92, blue: 0.60)
        case .cat:       return Color(red: 0.88, green: 0.98, blue: 0.90)
        case .butterCat: return Color(red: 1.0, green: 0.87, blue: 0.58)
        }
    }
}
