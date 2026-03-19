import Foundation

struct HandDisc: Identifiable, Equatable {
    let id: Int          // 黒: 0-3, 白: 4-7
    let color: PlayerColor
    let type: DiscType
    let isUsed: Bool

    init(id: Int, color: PlayerColor, type: DiscType = .normal, isUsed: Bool = false) {
        self.id = id
        self.color = color
        self.type = type
        self.isUsed = isUsed
    }

    var isNormal: Bool  { type == .normal }
    var isSpecial: Bool { type != .normal }
}
