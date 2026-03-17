//
//  Save.swift
//  WarpTracker
//
//  Created by Cameron Lee on 5/3/2026.
//

import Foundation

enum FlagState: String, Codable {
    case off
    case discovered
    case done
}

var starting_flags: [String: FlagState] = [
    "GOT_WORKS_KEY": .off,
    "GOT_GALACTIC_KEY": .off,
    "GOT_BIKE": .off,
    "GOT_SECRET_POTION": .off,
    "SEEN_ROARK": .off,
    "SEEN_FANTINA": .off,
    "SEEN_VOLKNER": .off,
    "DEFEATED_MARS_WINDWORKS": .off,
    "GOT_ROCK_SMASH": .off,
    "GOT_CUT": .off,
    "GOT_FLY": .off,
    "GOT_DEFOG": .off,
    "GOT_SURF": .off,
    "GOT_STRENGTH": .off,
    "GOT_ROCK_CLIMB": .off,
    "GOT_WATERFALL": .off,
    "GOT_TELEPORT": .off,
    "DEFEATED_GYM_1": .off,
    "DEFEATED_GYM_2": .off,
    "DEFEATED_GYM_3": .off,
    "DEFEATED_GYM_4": .off,
    "DEFEATED_GYM_5": .off,
    "DEFEATED_GYM_6": .off,
    "DEFEATED_GYM_7": .off,
    "DEFEATED_GYM_8": .off,
    "DEFEATED_AARON": .off,
    "DEFEATED_BERTHA": .off,
    "DEFEATED_FLINT": .off,
    "DEFEATED_LUCIAN": .off,
    "DEFEATED_CYNTHIA": .off
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
    var flags: [String: FlagState]
    var traversalFlags: [String: Bool]
    var available: [String]
    var notes: String?
    var game: String?

    init(name: String, date: Date, graph: WarpGraph) {
        self.name = name
        self.date = date
        self.graph = graph
        self.flags = starting_flags
        self.traversalFlags = starting_traversal_flags
        self.available = [
            "Verity_Lake_Entrance",
            "Sandgem_Centre_Entrance",
            "Sandgem_Mart_Entrance",
            "Sandgem_House_Left",
            "Sandgem_House_Right",
            "Jubilife_House_Bottom",
            "Jubilife_Centre_Entrance",
            "Jubilife_Mart_Entrance",
            "Jubilife_Condo",
            "Jubilife_TV_Entrance",
            "Jubilife_Poketch_Left",
            "Jubilife_Poketch_Right",
            "Jublife_Gate_West",
            "Route_204_Cave_South",
            "Route_203_Cave"
        ]
        self.notes = ""
    }

    mutating func changeFlag(flagID: String) {
        switch self.flags[flagID] {
        case .off: self.flags[flagID] = .done
        case .done: self.flags[flagID] = .off
        default: break  // discovered state only changed by long press
        }
    }

    mutating func discoverFlag(flagID: String) {
        if self.flags[flagID] == .off {
            self.flags[flagID] = .discovered
        } else if self.flags[flagID] == .discovered {
            self.flags[flagID] = .off
        }
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
            print("💾 Saving \(name), flags done: \(flags.filter { $0.value == .done }.keys.sorted())")
        } catch {
            print("❌ Failed to save: \(error)")
        }
    }

    static func loadFromDisk(name: String) -> Save? {
        let url = Save.saveURL(name: name)
        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            let save = try decoder.decode(Save.self, from: data)
            print("✅ Loaded \(name), flags done: \(save.flags.filter { $0.value == .done }.keys.sorted())")
            return save
        } catch {
            print("❌ Failed to load \(name): \(error)")
            return nil
        }
    }

    static func saveURL(name: String) -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("\(name).plist")
    }

    mutating func reloadFlags() {
        // update traversal flags
        if self.flags["GOT_ROCK_SMASH"] == .done && self.flags["DEFEATED_GYM_1"] == .done {
            self.traversalFlags["CAN_ROCK_SMASH"] = true
        } else {
            self.traversalFlags["CAN_ROCK_SMASH"] = false
        }
        if self.flags["GOT_CUT"] == .done && self.flags["DEFEATED_GYM_2"] == .done {
            self.traversalFlags["CAN_CUT"] = true
        } else {
            self.traversalFlags["CAN_CUT"] = false
        }
        if self.flags["GOT_DEFOG"] == .done && self.flags["DEFEATED_GYM_3"] == .done {
            self.traversalFlags["CAN_DEFOG"] = true
        } else {
            self.traversalFlags["CAN_DEFOG"] = false
        }
        if self.flags["GOT_FLY"] == .done && self.flags["DEFEATED_GYM_4"] == .done {
            self.traversalFlags["CAN_FLY"] = true
        } else {
            self.traversalFlags["CAN_FLY"] = false
        }
        if self.flags["GOT_SURF"] == .done && self.flags["DEFEATED_GYM_5"] == .done {
            self.traversalFlags["CAN_SURF"] = true
        } else {
            self.traversalFlags["CAN_SURF"] = false
        }
        if self.flags["GOT_STRENGTH"] == .done && self.flags["DEFEATED_GYM_6"] == .done {
            self.traversalFlags["CAN_STRENGTH"] = true
        } else {
            self.traversalFlags["CAN_STRENGTH"] = false
        }
        if self.flags["GOT_ROCK_CLIMB"] == .done && self.flags["DEFEATED_GYM_7"] == .done {
            self.traversalFlags["CAN_ROCK_CLIMB"] = true
        } else {
            self.traversalFlags["CAN_ROCK_CLIMB"] = false
        }
        if self.flags["GOT_WATERFALL"] == .done && self.flags["DEFEATED_GYM_8"] == .done {
            self.traversalFlags["CAN_WATERFALL"] = true
        } else {
            self.traversalFlags["CAN_WATERFALL"] = false
        }
        
        // apply conditional warp links based on flags and traversal flags
        for (flagID, warpPairs) in conditionalWarps {
            let isActive: Bool
            if let flagState = self.flags[flagID] {
                isActive = flagState == .done
            } else if let traversalFlag = self.traversalFlags[flagID] {
                isActive = traversalFlag
            } else {
                isActive = false
            }

            for pair in warpPairs {
                guard pair.count == 2 else { continue }
                let warp1ID = pair[0]
                let warp2ID = pair[1]

                if isActive {
                    _ = graph.addDoubleLink(between: warp1ID, and: warp2ID)
                } else {
                    graph.removeDoubleLink(between: warp1ID, and: warp2ID)
                }
            }
        }

        // reset available to starting warps before re-expanding
        self.available = ["Verity_Lake_Entrance",
                          "Sandgem_Centre_Entrance",
                          "Sandgem_Mart_Entrance",
                          "Sandgem_House_Left",
                          "Sandgem_House_Right",
                          "Jubilife_House_Bottom",
                          "Jubilife_Centre_Entrance",
                          "Jubilife_Mart_Entrance",
                          "Jubilife_Condo",
                          "Jubilife_TV_Entrance",
                          "Jubilife_Poketch_Left",
                          "Jubilife_Poketch_Right",
                          "Jublife_Gate_West",
                          "Route_204_Cave_South",
                          "Route_203_Cave"]

        // update available warps
        expandAvailable()

        // save changes
        saveToDisk()
    }
}
