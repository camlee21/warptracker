//
//  Warp.swift
//  WarpTracker
//
//  Created by Cameron Lee on 5/3/2026.
//

import Foundation

struct Warp: Codable, Hashable {
    var id: String
    var location: String
    var neighbours: [String]  // Store IDs, not Warp objects

    init(id: String, location: String = "") {
        self.id = id
        self.location = location
        self.neighbours = []
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
