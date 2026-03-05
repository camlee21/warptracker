//
//  MapView.swift
//  WarpTracker
//
//  Created by Cameron Lee on 5/3/2026.
//

import SwiftUI

struct MapView: View {
    var locationID: String
    
    func getImgFromID(_ id: String) -> String {
        switch id {
        case "Lake Verity": return "verity_lakefront"
        case "Sandgem": return "sandgem"
        case "Jubilife": return "jubilife"
        case "Route 204": return "route_204"
        case "Route 203": return "route_203"
        case "Oreburgh": return "oreburgh"
        case "Oreburgh Gate": return "oreburgh_gate"
        case "Floaroma": return "floaroma"
        case "Floaroma Meadow": return "floaroma_meadow"
        case "Eterna": return "eterna"
        case "Eterna Forest": return "eterna_forest"
        case "Hearthome": return "hearthome"
        case "Solaceon": return "solaceon"
        case "Solaceon Ruins": return "solaceon_ruins"
        case "Veilstone": return "veilstone"
        case "Dept Store": return "dept"
        case "Pastoria": return "pastoria"
        case "Celestic": return "celestic"
        case "Canalave": return "canalave"
        case "Iron Island": return "iron_island"
        case "Snowpoint": return "snowpoint"
        case "Sunyshore": return "sunyshore"
        case "Valor Lake": return "valor_lakefront"
        case "Route 209": return "route_209"
        case "Route 210": return "route_210"
        case "Route 211": return "route_211"
        case "Route 212": return "route_212"
        case "Route 213": return "route_213"
        case "Route 214": return "route_214"
        case "Route 215": return "route_215"
        case "Route 216": return "route_216"
        case "Route 217": return "route_217"
        case "Route 221": return "route_221"
        case "Route 222": return "route_222"
        case "Route 205": return "route_205"
        case "Route 206": return "route_206"
        case "Route 207": return "route_207"
        case "Route 208": return "route_208"
        case "Route 223": return "route_223"
        case "Route 226": return "route_226"
        case "Route 227": return "route_227"
        case "Route 228": return "route_228"
        case "Backlot Mansion": return "mansion"
        case "Jubilife TV": return "jubilife_tv"
        case "Jubilife GTS": return "" // ????
        case "Poketch": return "poketch"
        case "TG Eterna": return "eterna_galactic"
        case "Old Chateau": return "old_chateau"
        case "Galactic HQ": return "galactic_hq"
        case "Acuity Lake": return "acuity_lakefront"
        case "Verity Lake": return "verity_lakefront"
        case "Mt Coronet": return "coronet"
        case "Coronet Peak": return "coronet_peak"
        case "Pokemon League": return "league"
        case "Victory Road": return "victory_road"
        case "Fight Area": return "fight_area"
        case "Survival Area": return "survival_area"
        case "Resort Area": return "resort_area"
        case "Fuego Ironworks": return "fuego_ironworks"
        default: return "sandgem"
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                Image(getImgFromID(locationID))
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: geometry.size.height)
            }
        }
    }
}

#Preview {
    MapView(locationID: "Solaceon Ruins")
}
