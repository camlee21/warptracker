// SaveView.swift

import SwiftUI

struct SaveView: View {
    @State var PlatinumWarpGraph: WarpGraph
    @State var MainSaveFile: Save
    @State var showFlags: Bool = false
    @State var showHMs: Bool = false
    @State var showTrainers: Bool = false
    @State var showMapMenu: Bool = false
    @State var selectedLocation: String? = "Sandgem"
    @State var linkState: LinkState = .idle
    @State var showUnlinkConfirmation: Bool = false
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

    var uniqueLocations: [String] {
        let locations = MainSaveFile.graph.warps.values.map { $0.location }
        return Array(Set(locations)).sorted()
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

            // Background map image
            if let location = selectedLocation {
                MapView(
                    locationID: location,
                    linkState: $linkState,
                    save: $MainSaveFile,
                    selectedLocation: $selectedLocation,
                    imageSize: imageSizes[location] ?? CGSize(width: 800, height: 600)
                )
                .ignoresSafeArea()
            }

            // Top right area
            VStack {
                HStack {
                    Spacer()

                    if case .firstSelected(let id) = linkState {
                        // Unlink button (only if warp has a linked warp)
                        if let warp = MainSaveFile.graph.warps[id], warp.linked != nil {
                            Button {
                                showUnlinkConfirmation = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "link.badge.minus")
                                    Text("Unlink")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                            }
                            .padding(.top, 8)
                            .padding(.trailing, 4)
                            .confirmationDialog(
                                "Unlink \(id)?",
                                isPresented: $showUnlinkConfirmation,
                                titleVisibility: .visible
                            ) {
                                Button("Unlink", role: .destructive) {
                                    if let linkedID = MainSaveFile.graph.warps[id]?.linked {
                                        MainSaveFile.graph.unlinkWarps(warp1ID: id, warp2ID: linkedID)
                                        MainSaveFile.reloadFlags()
                                    }
                                    linkState = .idle
                                }
                                Button("Cancel", role: .cancel) {}
                            } message: {
                                Text("This will remove the link between these two warps.")
                            }
                        }

                        // Linking label
                        Text("Linking: \(id)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(20)
                            .padding(.top, 8)
                            .padding(.trailing, 4)

                        // Cancel button
                        Button {
                            linkState = .idle
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.title3)
                        }
                        .padding(.top, 8)
                        .padding(.trailing, 16)

                    } else {
                        Text("\(MainSaveFile.available.count) / \(MainSaveFile.graph.warps.count)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .padding(.top, 8)
                            .padding(.trailing, 16)
                    }
                }
                Spacer()
            }

            // Bottom bar
            VStack {
                Spacer()

                HStack(alignment: .bottom) {

                    // Left panels
                    VStack(alignment: .leading, spacing: 8) {
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
                    }
                    .padding(.leading, 16)

                    Spacer()

                    // Right panel
                    VStack(alignment: .trailing, spacing: 8) {
                        if showMapMenu {
                            ScrollView {
                                VStack(spacing: 6) {
                                    ForEach(uniqueLocations, id: \.self) { location in
                                        Button(location) {
                                            selectedLocation = selectedLocation == location ? nil : location
                                            showMapMenu = false
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(8)
                                        .background(selectedLocation == location ? Color.blue : Color(.systemGray5))
                                        .foregroundColor(selectedLocation == location ? .white : .primary)
                                        .cornerRadius(8)
                                        .font(.caption)
                                    }
                                }
                                .padding(12)
                            }
                            .frame(width: 200, height: 400)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 8)
                        }
                    }
                    .padding(.trailing, 16)
                }

                // Bottom button bar
                HStack {
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
                    .padding(.leading, 16)

                    Spacer()

                    sideButton(icon: showMapMenu ? "map.fill" : "map", isActive: showMapMenu) {
                        showMapMenu.toggle()
                    }
                    .padding(.trailing, 16)
                }
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
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
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())
        }
    }
}

#Preview {
    NavigationStack {
        SaveView(save: Save(name: "Preview Save", date: Date(), graph: WarpGraph()))
    }
}
