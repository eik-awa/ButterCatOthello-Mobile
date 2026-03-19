import Foundation

enum PlayerColor: String, CaseIterable, Codable {
    case black = "black"
    case white = "white"

    var opposite: PlayerColor {
        self == .black ? .white : .black
    }

    var displayName: String {
        self == .black ? "黒" : "白"
    }
}
