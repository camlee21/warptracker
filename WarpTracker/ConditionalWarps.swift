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
    "GOT_SECRET_POTION": [["Route_210_Milk", "Celestic_Centre_Entrance"]],
    "GOT_WORKS_KEY": [["Valley_Windworks_Entrance", "Floaroma_Centre_Entrance"]],
    "GOT_GALACTIC_KEY": [["GHQ_Lobby_Stairs", "GHQ_Lobby_Exit_Left"],
                        ["GHQ_Basement_Stairs_Top", "GHQ_Basement_Stairs_Right"],
                        ["GHQ_Cyrus_Warp_Room", "GHQ_Cyrus_Stairs"]],
    "GOT_BIKE": [["Orebugh_Mart_Entrance", "Bicycle_Road_Entrance"],
                ["Route_227_House", "Stark_Mountain_Entrance"],
                ["Route_228_House_Bottom", "Route_228_House_Top"],
                ["Route_228_Cave", "Route_228_House_Top"]],
    "SEEN_ROARK": [["Oreburgh_Gym_Entrance", "Oreburgh_Centre_Entrance"]],
    "SEEN_FANTINA": [["Hearthome_Gym_Entrance", "Hearthome_Centre_Entrance"]],
    "SEEN_VOLKNER": [["Sunyshore_Gym_Entrance", "Sunyshore_Centre_Entrance"]],
    "DEFEATED_MARS_WINDWORKS": [["Floaroma_Centre_Entrance", "Route_205_House"]],
    "DEFEATED_GYM_1": [["Jubilife_Centre_Entrance", "Jubilife_GTS_Entrance"]],
    "DEFEATED_GYM_2": [["Jubilife_Centre_Entrance", "Jubilife_GTS_Entrance"]],
    "DEFEATED_GYM_3": [["Hearthome_Gate_East", "Hearthome_Gate_West"],
                       ["Jubilife_Centre_Entrance", "Jubilife_GTS_Entrance"]],
    "DEFEATED_GYM_4": [["Jubilife_Centre_Entrance", "Jubilife_GTS_Entrance"]],
    "DEFEATED_GYM_5": [["Jubilife_Centre_Entrance", "Jubilife_GTS_Entrance"]],
    "DEFEATED_GYM_6": [["Jubilife_Centre_Entrance", "Jubilife_GTS_Entrance"]],
    "DEFEATED_GYM_7": [["Jubilife_Centre_Entrance", "Jubilife_GTS_Entrance"]],
    "DEFEATED_GYM_8": [["Jubilife_Centre_Entrance", "Jubilife_GTS_Entrance"]],
    "CAN_ROCK_SMASH": [["Oreburgh_Gate_Stairs", "Oreburgh_Gate_Exit_Left"],
                      []],
    "CAN_CUT": [["Route_205_House", "Eterna_Centre_Entrance"],
               ["Eterna_TG_Building", "Eterna_Centre_Entrance"],
                ["Route_206_Cave_Entrance", "Bicycle_Road_Entrance"],
               ["Eterna_Forest_Exit_North", "Eterna_Forest_Mansion"]],
    "CAN_SURF": [["Fight_Area_Centre_Entrance", "Resort_Area_Centre_Entrance"],
                ["Victory_Road_Water_Stairs_Middle", "Victory_Road_Water_Stairs_Bottom"],
                ["Floaroma_Centre_Entrance", "Fuego_Ironworks_Entrance"],
                ["Route_205_House", "Fuego_Ironworks_Meadow_Entrance"],
                ["Fuego_Ironworks_Meadow_Entrance", "Fuego_Ironworks_Entrance"],
                ["Route_221_House", "Sandgem_Centre_Entrance"],
                ["Acuity_Lake_Exit", "Acuity_Lake_Cave"],
                 ["Verity_Lake_Exit", "Verity_Lake_Cave"],
                 ["Valor_Lake_Exit", "Valor_Lake_Cave"],
                ["Route_226_House", "Route_226_Gate"]],
    "CAN_ROCK_CLIMB": [["Acuity_Lake_Entrance", "Snowpoint_Centre_Entrance"],
                      ["Survival_Area_Rock_House", "Survival_Area_Centre_Entrance"],
                      ["Coronet_Peak_Top_Upper_Cave", "Coronet_Peak_Top_Lower_Cave"],
                      ["Coronet_Peak_Bottom_Lower_Cave", "Coronet_Peak_Bottom_Right_Cave"],
                      ["Sunyshore_Rock_House", "Sunyshore_Centre_Entrance"],
                      ["Valor_House_Rock_Climb", "Valor_Cafe_Entrance"],
                       ["Coronet_Waterall_Room_Entrance_Left", "Coronet_Waterall_Room_Exit"],
                      ["Coronet_Cyrus_Exit_North", "Coronet_Cyrus_Exit_Right"],
                      ["Route_210_House", "Celestic_Centre_Entrance"],
                      ["Victory_Road_Main_Stairs_Left_Bottom", "Victory_Road_Main_Stairs_Right_Middle"],
                      ["Victory_Road_Exit_South", "Victory_Road_Main_Stairs_Left_Middle"],
                      ["Victory_Road_Main_Cave", "Victory_Road_Exit_North"],
                       ["Victory_Road_Main_Cave", "Victory_Road_Main_Stairs_Right_Top"]],
    "CAN_STRENGTH": [["Coronet_Looker_Room_Exit_South", "Coronet_Looker_Room_Exit_North"],
                    ["Coronet_Big_Room_East", "Coronet_Big_Room_West"],
                    ["Coronet_Big_Room_South", "Coronet_Big_Room_East"],
                     ["Coronet_Big_Room_East", "Coronet_Big_Room_North"]],
    "CAN_WATERFALL": [["Canalave_Centre_Entrance", "League_Centre_Small_Entrance"],
                      ["Pokemon_League_E4_Exit", "Pokemon_League_Entrance"],
                     ["Coronet_Waterfall_Room_Waterfall", "Coronet_Waterall_Room_Entrance_Bottom"]],
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
