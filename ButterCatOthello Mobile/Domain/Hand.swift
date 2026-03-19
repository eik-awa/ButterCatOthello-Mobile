import Foundation

struct Hand {
    private(set) var discs: [HandDisc]
    private(set) var selectedDiscId: Int?

    init(color: PlayerColor) {
        let base = color == .black ? 0 : 4
        discs = (0..<4).map { HandDisc(id: base + $0, color: color) }
        selectedDiscId = nil
        ensureAtLeastOneSpecial()
    }

    // Private memberwise init for cloning
    private init(discs: [HandDisc], selectedDiscId: Int?) {
        self.discs = discs
        self.selectedDiscId = selectedDiscId
    }

    var selectedDisc: HandDisc? {
        guard let id = selectedDiscId else { return nil }
        return discs.first { $0.id == id }
    }

    var hasSelection: Bool { selectedDiscId != nil }

    // Returns new Hand with the disc selected
    func selecting(_ id: Int) -> Hand {
        guard let disc = discs.first(where: { $0.id == id }), !disc.isUsed else {
            return self
        }
        return Hand(discs: discs, selectedDiscId: id)
    }

    func deselected() -> Hand {
        Hand(discs: discs, selectedDiscId: nil)
    }

    // Replenishes the used disc with a new random type
    func afterUsingSelected() -> Hand {
        guard let selId = selectedDiscId else { return self }
        let allNormal = discs.filter { !$0.isUsed && $0.id != selId }.allSatisfy { $0.type == .normal }
        let newDiscs = discs.map { disc -> HandDisc in
            guard disc.id == selId else { return disc }
            let newType = DiscType.random(allNormal: allNormal)
            return HandDisc(id: disc.id, color: disc.color, type: newType, isUsed: false)
        }
        return Hand(discs: newDiscs, selectedDiscId: nil)
    }

    private mutating func ensureAtLeastOneSpecial() {
        let hasSpecial = discs.contains { $0.type != .normal }
        if !hasSpecial, let idx = discs.indices.randomElement() {
            let d = discs[idx]
            discs[idx] = HandDisc(id: d.id, color: d.color,
                                  type: DiscType.random(allNormal: true), isUsed: false)
        }
    }
}
