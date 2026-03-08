//
//  ConditionalWarps.swift
//  WarpTracker
//
//  Created by Cameron Lee on 6/3/2026.
//

import Foundation

//"GOT_WORKS_KEY": false,
//"GOT_GALACTIC_KEY": false,
//"GOT_BIKE": false,
//"GOT_SECRET_POTION": false,
//"SEEN_ROARK": false,
//"SEEN_FANTINA": false,
//"SEEN_VOLKNER": false,
//"DEFEATED_MARS_WINDWORKS": false,

//"DEFEATED_GYM_1": false,  // Rock Smash
//"DEFEATED_GYM_2": false,  // Cut
//"DEFEATED_GYM_3": false,  // Defog
//"DEFEATED_GYM_4": false,  // Fly
//"DEFEATED_GYM_5": false,  // Surf
//"DEFEATED_GYM_6": false,  // Strength
//"DEFEATED_GYM_7": false,  // Rock Climb
//"DEFEATED_GYM_8": false,  // Waterfall

//"GOT_ROCK_SMASH": false,
//"GOT_CUT": false,
//"GOT_FLY": false,
//"GOT_DEFOG": false,
//"GOT_SURF": false,
//"GOT_STRENGTH": false,
//"GOT_ROCK_CLIMB": false,
//"GOT_WATERFALL": false,
//"GOT_TELEPORT": false,

//"CAN_ROCK_SMASH": false,
//"CAN_CUT": false,
//"CAN_DEFOG": false,
//"CAN_FLY": false,
//"CAN_SURF": false,
//"CAN_STRENGTH": false,
//"CAN_ROCK_CLIMB": false,
//"CAN_WATERFALL": false

// [CONDITION_ID : [[GROUPED WARPS] [GROUPED WARPS]]]
var conditionalWarps: [String:[[String]]] = [
    "GOT_WORKS_KEY": [["Valley_Windworks_Entrance", "Floaroma_Centre_Entrance"]],
    "GOT_GALACTIC_KEY": [["GHQ_Lobby_Stairs", "GHQ_Lobby_Exit_Left"],
                        ["GHQ_Basement_Stairs_Top", "GHQ_Basement_Stairs_Bottom"]],
    "SEEN_ROARK": [["Oreburgh_Gym_Entrance", "Oreburgh_Centre_Entrance"]],
    "SEEN_FANTINA": [["Hearthome_Gym_Entrance", "Hearthome_Centre_Entrance"]],
    "SEEN_VOLKNER": [["Sunyshore_Gym_Entrance", "Sunyshore_Centre_Entrance"]],
    "DEFEATED_MARS_WINDWORKS": [["Floaroma_Centre_Entrance", "Route_205_House"]],
    "DEFEATED_GYM_3": [["Hearthome_Gate_East", "Hearthome_Gate_West"]],
    "CAN_ROCK_SMASH": [["Oreburgh_Gate_Stairs", "Oreburgh_Gate_Exit_Left"],
                      []],
    "CAN_CUT": [["Route_205_House", "Eterna_Centre_Entrance"],
               ["Eterna_TG_Building", "Eterna_Centre_Entrance"],
               ["Route_206_Cave_Entrance", "Bicycle_Road_Entrance"]],
    "CAN_SURF": [["Fight_Area_Centre_Entrance", "Resort_Area_Centre_Entrance"],
                ["Victory_Road_Water_Stairs_Middle", "Victory_Road_Water_Stairs_Bottom"]],
    "CAN_ROCK_CLIMB": [["Acuity_Lake_Entrance", "Snowpoint_Centre_Entrance"],
                      ["Survival_Area_Rock_House", "Survival_Area_Centre_Entrance"],
                      ["Coronet_Peak_Top_Upper_Cave", "Coronet_Peak_Top_Lower_Cave"],
                      ["Coronet_Peak_Bottom_Lower_Cave", "Coronet_Peak_Bottom_Right_Cave"],
                      ["Sunyshore_Rock_House", "Sunyshore_Centre_Entrance"],
                      ["Valor_House_Rock_Climb", "Valor_Cafe_Entrance"]],
    "CAN_TELEPORT": [["Sandgem_Centre_Exit", "Sandgem_Centre_Entrance"],
                    ["Jubilife_Centre_Exit", "Jubilife_Centre_Entrance"],
                    ["Oreburgh_Centre_Exit", "Oreburgh_Centre_Entrance"],
                    ["Floaroma_Centre_Exit", "Floaroma_Centre_Entrance"],
                    ["Eterna_Centre_Exit", "Eterna_Centre_Entrance"],
                    ["Hearthome_Centre_Exit", "Hearthome_Centre_Entrance"],
                    ["Solaceon_Centre_Exit", "Solaceon_Centre_Entrance"],
                    ["Veilstone_Centre_Exit", "Veilstone_Centre_Entrance"],
                    ["Pastoria_Centre_Exit", "Pastoria_Centre_Entrance"],
                    ["Celestic_Centre_Exit", "Celestic_Centre_Entrance"],
                    ["Canalave_Centre_Exit", "Canalave_Centre_Entrance"],
                    ["Snowpoint_Centre_Exit", "Snowpoint_Centre_Entrance"],
                    ["Sunyshore_Centre_Exit", "Sunyshore_Centre_Entrance"],
                    ["Fight_Area_Centre_Exit", "Fight_Area_Centre_Entrance"],
                    ["Survival_Area_Centre_Exit", "Survival_Area_Centre_Entrance"],
                    ["Resort_Area_Centre_Exit", "Resort_Area_Centre_Entrance"],
                    ["League_Centre_Small_Exit", "League_Centre_Small_Entrance"],
                    ["League_Centre_Big_Exit", "Pokemon_League_Entrance"]],
]
