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
    var traversalFlags: [String: Bool] = [:]
    var available: [String]
    
    init(name: String, date: Date, graph: WarpGraph) {
        self.name = name
        self.date = date
        self.graph = graph
        self.flags = starting_flags
        self.available = [
//            "Verity_Lake_Entrance",
//            "Sandgem_Centre_Entrance",
//            "Sandgem_Mart_Entrance",
//            "Sandgem_House_Left",
//            "Sandgem_House_Right",
//            "Jubilife_House_Bottom",
//            "Jubilife_Centre_Entrance",
//            "Jubilife_Mart_Entrance",
//            "Jubilife_Condo",
//            "Jubilife_TV_Entrance",
//            "Jubilife_Poketch_Left",
//            "Jubilife_Poketch_Right",
//            "Jublife_Gate_West",
//            "Route_204_Cave_South",
            "Route_203_Cave"
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
    
    mutating func reloadFlags() {
        // update flags
        if self.flags["GOT_ROCK_SMASH"] == true && self.flags["DEFEATED_GYM_1"] == true {
            self.traversalFlags["CAN_ROCK_SMASH"] = true
        }
        if self.flags["GOT_CUT"] == true && self.flags["DEFEATED_GYM_2"] == true {
            self.traversalFlags["CAN_CUT"] = true
        }
        if self.flags["GOT_DEFOG"] == true && self.flags["DEFEATED_GYM_3"] == true {
            self.traversalFlags["CAN_DEFOG"] = true
        }
        if self.flags["GOT_FLY"] == true && self.flags["DEFEATED_GYM_4"] == true {
            self.traversalFlags["CAN_FLY"] = true
        }
        if self.flags["GOT_SURF"] == true && self.flags["DEFEATED_GYM_5"] == true {
            self.traversalFlags["CAN_SURF"] = true
        }
        if self.flags["GOT_STRENGTH"] == true && self.flags["DEFEATED_GYM_6"] == true {
            self.traversalFlags["CAN_STRENGTH"] = true
        }
        if self.flags["GOT_ROCK_CLIMB"] == true && self.flags["DEFEATED_GYM_7"] == true {
            self.traversalFlags["CAN_ROCK_CLIMB"] = true
        }
        if self.flags["GOT_WATERFALL"] == true && self.flags["DEFEATED_GYM_8"] == true {
            self.traversalFlags["CAN_WATERFALL"] = true
        }
        
        // update available warps
        expandAvailable()
    }
}
