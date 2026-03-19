import Foundation

enum DiscType: String, CaseIterable, Codable {
    case normal    = "normal"
    case butter    = "butter"
    case cat       = "cat"
    case butterCat = "buttercat"

    var isSpecial: Bool { self != .normal }

    static func random(allNormal: Bool = false) -> DiscType {
        if allNormal {
            let specials: [DiscType] = [.butter, .cat, .butterCat]
            return specials.randomElement()!
        }
        let r = Double.random(in: 0..<1)
        if r < 0.7 { return .normal }
        if r < 0.8 { return .butter }
        if r < 0.9 { return .cat }
        return .butterCat
    }

    var displayName: String {
        switch self {
        case .normal:    return "通常"
        case .butter:    return "バター"
        case .cat:       return "猫"
        case .butterCat: return "バター猫"
        }
    }

    var description: String {
        switch self {
        case .normal:    return "普通の駒"
        case .butter:    return "相手の色で置かれ、裏返されない"
        case .cat:       return "自分の色で置かれ、裏返されない"
        case .butterCat: return "挟めず、裏返されもしない"
        }
    }
}
