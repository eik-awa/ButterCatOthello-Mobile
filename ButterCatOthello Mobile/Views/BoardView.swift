import SwiftUI

struct BoardView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let cellSize = size / 8

            ZStack {
                // ボード背景
                RoundedRectangle(cornerRadius: 6)
                    .fill(AppTheme.boardGreen)

                // グリッドライン
                Path { path in
                    for i in 0...8 {
                        let offset = CGFloat(i) * cellSize
                        path.move(to: CGPoint(x: offset, y: 0))
                        path.addLine(to: CGPoint(x: offset, y: size))
                        path.move(to: CGPoint(x: 0, y: offset))
                        path.addLine(to: CGPoint(x: size, y: offset))
                    }
                }
                .stroke(Color.black.opacity(0.35), lineWidth: 0.7)

                // ガイドドット (2,2)(2,5)(5,2)(5,5)
                ForEach([(2,2),(2,5),(5,2),(5,5)], id: \.0) { (x, y) in
                    Circle()
                        .fill(Color.black.opacity(0.45))
                        .frame(width: 7, height: 7)
                        .position(x: CGFloat(x) * cellSize,
                                  y: CGFloat(y) * cellSize)
                }

                // セル
                ForEach(0..<8, id: \.self) { y in
                    ForEach(0..<8, id: \.self) { x in
                        let pos = Position(x: x, y: y)
                        let disk = viewModel.board.count > y ? viewModel.board[y][x] : nil
                        let isValid = viewModel.validMoves.contains(pos)
                        let isFlipping = viewModel.flippingPositions().contains("\(x),\(y)")

                        CellView(
                            disk: disk,
                            isValidMove: isValid,
                            isFlipping: isFlipping,
                            size: cellSize
                        )
                        .position(x: CGFloat(x) * cellSize + cellSize / 2,
                                  y: CGFloat(y) * cellSize + cellSize / 2)
                        .onTapGesture {
                            viewModel.tapCell(at: pos)
                        }
                    }
                }
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(white: 0.1).opacity(0.7), lineWidth: 2.5)
            )
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
