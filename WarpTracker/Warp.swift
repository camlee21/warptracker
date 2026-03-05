// Warp.swift

import Foundation

struct Warp: Codable, Hashable {
    var id: String
    var location: String
    var neighbours: [String]
    var linked: String?  // ID of the warp this has been manually linked to

    init(id: String, location: String = "") {
        self.id = id
        self.location = location
        self.neighbours = []
        self.linked = nil
    }

    mutating func addLink(_ warpID: String) {
        if !neighbours.contains(warpID) {
            neighbours.append(warpID)
        }
    }

    mutating func removeLink(_ warpID: String) {
        neighbours.removeAll { $0 == warpID }
    }
}
