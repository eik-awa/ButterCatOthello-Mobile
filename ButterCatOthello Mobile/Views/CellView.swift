import SwiftUI

struct CellView: View {
    let disk: Disk?
    let isValidMove: Bool
    let isFlipping: Bool
    let size: CGFloat

    var body: some View {
        ZStack {
            // ホバー色（有効手ヒント）
            if isValidMove && disk == nil {
                Circle()
                    .fill(Color.yellow.opacity(0.65))
                    .frame(width: size * 0.33, height: size * 0.33)
                    .shadow(color: Color.yellow.opacity(0.4), radius: 3)
            }

            if let disk {
                DiscView(disk: disk, size: size * 0.84, isFlipping: isFlipping)
            }
        }
        .frame(width: size, height: size)
        .contentShape(Rectangle())
    }
}
