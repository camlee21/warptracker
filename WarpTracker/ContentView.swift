//
//  ContentView.swift
//  WarpTracker
//
//  Created by Cameron Lee on 5/3/2026.
//

import SwiftUI

struct ContentView: View {
    @State var PlatinumWarpGraph: WarpGraph
    @State var MainSaveFile: Save

    init() {
        var graph = WarpGraph()
        graph.loadFromFiles()
        let save = Save(name: "Save 1", date: Date(), graph: graph)
        _PlatinumWarpGraph = State(initialValue: graph)
        _MainSaveFile = State(initialValue: save)
    }
    
    func formatFlagID(_ flagID: String) -> String {
        let parts = flagID.components(separatedBy: "_")
        switch parts.first {
        case "GOT":
            return parts.dropFirst().map { $0.capitalized }.joined(separator: " ") + " Got"
        case "SEEN":
            return parts.dropFirst().map { $0.capitalized }.joined(separator: " ") + " Seen"
        case "DEFEATED":
            if parts[1] == "GYM" {
                return "Gym \(parts[2]) Defeated"
            }
            return parts.dropFirst().map { $0.capitalized }.joined(separator: " ") + " Defeated"
        default:
            return parts.map { $0.capitalized }.joined(separator: " ")
        }
    }
    
    var body: some View {
        VStack {
            Text("Available warps: \(MainSaveFile.graph.warps.count)")
            Button("Reload Save") {
                MainSaveFile.reloadFlags()
            }
            Text("\(MainSaveFile.available.count)")
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(Array(MainSaveFile.flags.keys.sorted()), id: \.self) { flagID in
                        Button(formatFlagID(flagID)) {
                            MainSaveFile.changeFlag(flagID: flagID)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(MainSaveFile.flags[flagID] == true ? Color.green : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .font(.caption)
                    }
                }
                .padding()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
