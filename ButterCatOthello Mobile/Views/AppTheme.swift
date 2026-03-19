import SwiftUI

// MARK: - App Color Theme (元Webの #fef9ee バター色ベース)
enum AppTheme {
    /// ページ背景 #fef9ee
    static let pageBg      = Color(red: 0.996, green: 0.976, blue: 0.933)
    /// エメラルドボード色
    static let boardGreen  = Color(red: 0.067, green: 0.533, blue: 0.267)
    static let boardGreenDark = Color(red: 0.047, green: 0.420, blue: 0.200)
    /// Amber アクセント
    static let amber       = Color(red: 1.0,   green: 0.702, blue: 0.0)
    static let amberLight  = Color(red: 1.0,   green: 0.910, blue: 0.580)
    static let amberShadow = Color(red: 1.0,   green: 0.800, blue: 0.200).opacity(0.4)
    /// テキスト
    static let textDark    = Color(red: 0.13,  green: 0.13,  blue: 0.15)
    static let textMid     = Color(red: 0.35,  green: 0.35,  blue: 0.38)
    /// カード白
    static let card        = Color.white
    static let cardBorder  = Color(red: 0.93,  green: 0.88,  blue: 0.80)
}

// MARK: - Hex init helper
extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: .init(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        self.init(
            red:   Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >>  8) & 0xFF) / 255,
            blue:  Double( rgb        & 0xFF) / 255
        )
    }
}

// MARK: - Tiled butter background
struct ButterBackground: View {
    var body: some View {
        ZStack {
            AppTheme.pageBg.ignoresSafeArea()
            // Tiled butter.png pattern – rotated -15°, low opacity
            GeometryReader { geo in
                let tileSize: CGFloat = 90
                // 回転後も全面をカバーするため、対角線の長さ分に拡大
                let diagonal = hypot(geo.size.width, geo.size.height)
                let expandedSize = diagonal + tileSize * 2
                let cols = Int(expandedSize / tileSize) + 1
                let rows = Int(expandedSize / tileSize) + 1
                Canvas { context, _ in
                    guard let resolved = context.resolveSymbol(id: 0) else { return }
                    for row in 0..<rows {
                        for col in 0..<cols {
                            let x = CGFloat(col) * tileSize
                            let y = CGFloat(row) * tileSize
                            context.draw(resolved, at: CGPoint(x: x, y: y), anchor: .topLeading)
                        }
                    }
                } symbols: {
                    Image("butter")
                        .resizable()
                        .frame(width: tileSize, height: tileSize)
                        .tag(0)
                }
                .frame(width: expandedSize, height: expandedSize)
                .rotationEffect(.degrees(-15))
                .frame(width: geo.size.width, height: geo.size.height)
                .opacity(0.10)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}
