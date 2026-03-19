import Foundation

struct Disk {
    let color: PlayerColor
    let type: DiscType

    init(_ color: PlayerColor, _ type: DiscType = .normal) {
        self.color = color
        self.type = type
    }

    var isNormal:    Bool { type == .normal }
    var isButter:    Bool { type == .butter }
    var isCat:       Bool { type == .cat }
    var isButterCat: Bool { type == .butterCat }
}
