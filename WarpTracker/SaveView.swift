//
//  SaveView.swift
//  WarpTracker
//
//  Created by Cameron Lee on 5/3/2026.
//

// SaveView.swift

import SwiftUI

struct SaveView: View {
    @State var PlatinumWarpGraph: WarpGraph
    @State var MainSaveFile: Save
    @State var showFlags: Bool = false
    @State var showHMs: Bool = false
    @State var showTrainers: Bool = false
    let onDisappear: () -> Void

    init(save: Save, onDisappear: @escaping () -> Void = {}) {
        var graph = WarpGraph()
        graph.loadFromFiles()
        var loaded = Save.loadFromDisk(name: save.name) ?? save
        loaded.graph = graph
        _PlatinumWarpGraph = State(initialValue: graph)
        _MainSaveFile = State(initialValue: loaded)
        self.onDisappear = onDisappear
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
        case "CAN":
            return "Can " + parts.dropFirst().map { $0.capitalized }.joined(separator: " ")
        default:
            return parts.map { $0.capitalized }.joined(separator: " ")
        }
    }
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                VStack(spacing: 12) {
                    Spacer()
                    
                    if showFlags {
                        flagPanel(keys: ["GOT_WORKS_KEY", "GOT_GALACTIC_KEY", "GOT_BIKE", "GOT_SECRET_POTION",
                                         "SEEN_ROARK", "SEEN_FANTINA", "SEEN_VOLKNER", "DEFEATED_MARS_WINDWORKS"])
                    }
                    if showHMs {
                        flagPanel(keys: ["GOT_ROCK_SMASH", "GOT_CUT", "GOT_FLY", "GOT_DEFOG",
                                         "GOT_SURF", "GOT_STRENGTH", "GOT_ROCK_CLIMB", "GOT_WATERFALL", "GOT_TELEPORT"])
                    }
                    if showTrainers {
                        flagPanel(keys: ["DEFEATED_GYM_1", "DEFEATED_GYM_2", "DEFEATED_GYM_3", "DEFEATED_GYM_4",
                                         "DEFEATED_GYM_5", "DEFEATED_GYM_6", "DEFEATED_GYM_7", "DEFEATED_GYM_8",
                                         "DEFEATED_AARON", "DEFEATED_BERTHA", "DEFEATED_FLINT", "DEFEATED_LUCIAN", "DEFEATED_CYNTHIA"])
                    }
                    
                    let anyOpen = showFlags || showHMs || showTrainers
                    
                    if anyOpen {
                        HStack(spacing: 8) {
                            sideButton(icon: showFlags ? "flag.fill" : "flag", isActive: showFlags) {
                                showFlags.toggle()
                                showHMs = false
                                showTrainers = false
                            }
                            sideButton(icon: showHMs ? "opticaldisc.fill" : "opticaldisc", isActive: showHMs) {
                                showHMs.toggle()
                                showFlags = false
                                showTrainers = false
                            }
                            sideButton(icon: showTrainers ? "person.fill" : "person", isActive: showTrainers) {
                                showTrainers.toggle()
                                showFlags = false
                                showHMs = false
                            }
                        }
                    } else {
                        VStack(spacing: 8) {
                            sideButton(icon: "flag", isActive: false) {
                                showFlags = true
                            }
                            sideButton(icon: "opticaldisc", isActive: false) {
                                showHMs = true
                            }
                            sideButton(icon: "person", isActive: false) {
                                showTrainers = true
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.leading, 16)
                
                Spacer()
            }
        }
        .navigationTitle(MainSaveFile.name)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            onDisappear()
        }
    }

    @ViewBuilder
    func flagPanel(keys: [String]) -> some View {
        let rowCount = ceil(Double(keys.count) / 2.0)
        let rowHeight: CGFloat = 44
        let padding: CGFloat = 16
        let totalHeight = rowCount * rowHeight + padding * 2

        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(keys, id: \.self) { flagID in
                    Button(formatFlagID(flagID)) {
                        MainSaveFile.changeFlag(flagID: flagID)
                        MainSaveFile.reloadFlags()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(MainSaveFile.flags[flagID] == true ? Color.green : Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .font(.caption)
                }
            }
            .padding(padding)
        }
        .frame(width: 280, height: totalHeight)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 8)
    }

    @ViewBuilder
    func sideButton(icon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .padding(10)
                .background(isActive ? Color.blue : Color.clear)
                .foregroundColor(isActive ? .white : .blue)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
        }
    }
}

#Preview {
    NavigationStack {
        SaveView(save: Save(name: "Preview Save", date: Date(), graph: WarpGraph()))
    }
}
