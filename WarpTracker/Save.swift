//
//  Save.swift
//  WarpTracker
//
//  Created by Cameron Lee on 5/3/2026.
//

import Foundation

var starting_flags: [String: Bool] = [
    // Flags
    "GOT_WORKS_KEY": false,
    "GOT_GALACTIC_KEY": false,
    "GOT_BIKE": false,
    "GOT_SECRET_POTION": false,
    "SEEN_ROARK": false,
    "SEEN_FANTINA": false,
    "SEEN_VOLKNER": false,
    "DEFEATED_MARS_WINDWORKS": false,

    // Obtained HMs
    "GOT_ROCK_SMASH": false,
    "GOT_CUT": false,
    "GOT_FLY": false,
    "GOT_DEFOG": false,
    "GOT_SURF": false,
    "GOT_STRENGTH": false,
    "GOT_ROCK_CLIMB": false,
    "GOT_WATERFALL": false,
    "GOT_TELEPORT": false,

    // Beaten Gyms
    "DEFEATED_GYM_1": false,  // Rock Smash
    "DEFEATED_GYM_2": false,  // Cut
    "DEFEATED_GYM_3": false,  // Defog
    "DEFEATED_GYM_4": false,  // Fly
    "DEFEATED_GYM_5": false,  // Surf
    "DEFEATED_GYM_6": false,  // Strength
    "DEFEATED_GYM_7": false,  // Rock Climb
    "DEFEATED_GYM_8": false,  // Waterfall

    // Beaten E4 + Champion for Tracker
    "DEFEATED_AARON": false,
    "DEFEATED_BERTHA": false,
    "DEFEATED_FLINT": false,
    "DEFEATED_LUCIAN": false,
    "DEFEATED_CYNTHIA": false
]

var starting_traversal_flags: [String: Bool] = [
    "CAN_ROCK_SMASH": false,
    "CAN_CUT": false,
    "CAN_DEFOG": false,
    "CAN_FLY": false,
    "CAN_SURF": false,
    "CAN_STRENGTH": false,
    "CAN_ROCK_CLIMB": false,
    "CAN_WATERFALL": false
]

struct Save: Codable, Hashable {
    var name: String
    var date: Date
    var graph: WarpGraph
    var flags: [String: Bool]
    var traversalFlags: [String: Bool]
    var available: [String]
    
    init(name: String, date: Date, graph: WarpGraph) {
        self.name = name
        self.date = date
        self.graph = graph
        self.flags = starting_flags
        self.traversalFlags = starting_traversal_flags
        self.available = [
            "Verity_Lake_Entrance"
        ]
    }
    
    mutating func changeFlag(flagID: String) {
        self.flags[flagID]?.toggle()
    }
    
    mutating func expandAvailable() {
        var changed = true
        while changed {
            changed = false
            for warpID in available {
                if let neighbours = graph.warps[warpID]?.neighbours {
                    for neighbour in neighbours {
                        if !available.contains(neighbour) {
                            available.append(neighbour)
                            changed = true
                        }
                    }
                }
            }
        }
    }
    
    mutating func saveToDisk() {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        do {
            let data = try encoder.encode(self)
            let url = Save.saveURL(name: name)
            try data.write(to: url)
            print("Saved to \(url)")
        } catch {
            print("Failed to save: \(error)")
        }
    }

    static func loadFromDisk(name: String) -> Save? {
        let url = Save.saveURL(name: name)
        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            return try decoder.decode(Save.self, from: data)
        } catch {
            print("Failed to load: \(error)")
            return nil
        }
    }

    static func saveURL(name: String) -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("\(name).plist")
    }
    
    mutating func reloadFlags() {
        // update flags
        if self.flags["GOT_ROCK_SMASH"] == true && self.flags["DEFEATED_GYM_1"] == true {
            self.traversalFlags["CAN_ROCK_SMASH"] = true
        } else {
            self.traversalFlags["CAN_ROCK_SMASH"] = false
        }
        if self.flags["GOT_CUT"] == true && self.flags["DEFEATED_GYM_2"] == true {
            self.traversalFlags["CAN_CUT"] = true
        } else {
            self.traversalFlags["CAN_CUT"] = false
        }
        if self.flags["GOT_DEFOG"] == true && self.flags["DEFEATED_GYM_3"] == true {
            self.traversalFlags["CAN_DEFOG"] = true
        } else {
            self.traversalFlags["CAN_DEFOG"] = false
        }
        if self.flags["GOT_FLY"] == true && self.flags["DEFEATED_GYM_4"] == true {
            self.traversalFlags["CAN_FLY"] = true
        } else {
            self.traversalFlags["CAN_FLY"] = false
        }
        if self.flags["GOT_SURF"] == true && self.flags["DEFEATED_GYM_5"] == true {
            self.traversalFlags["CAN_SURF"] = true
        } else {
            self.traversalFlags["CAN_SURF"] = false
        }
        if self.flags["GOT_STRENGTH"] == true && self.flags["DEFEATED_GYM_6"] == true {
            self.traversalFlags["CAN_STRENGTH"] = true
        } else {
            self.traversalFlags["CAN_STRENGTH"] = false
        }
        if self.flags["GOT_ROCK_CLIMB"] == true && self.flags["DEFEATED_GYM_7"] == true {
            self.traversalFlags["CAN_ROCK_CLIMB"] = true
        } else {
            self.traversalFlags["CAN_ROCK_CLIMB"] = false
        }
        if self.flags["GOT_WATERFALL"] == true && self.flags["DEFEATED_GYM_8"] == true {
            self.traversalFlags["CAN_WATERFALL"] = true
        } else {
            self.traversalFlags["CAN_WATERFALL"] = false
        }
        
        // update available warps
        expandAvailable()
    }
}
