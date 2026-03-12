// SaveView.swift

import SwiftUI
import UniformTypeIdentifiers

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
    @State var selectedIcon: String? = nil
    @State var showExportSheet: Bool = false
    @State var showImportPicker: Bool = false
    @State var showSuccessAlert: Bool = false
    @State var showFailureAlert: Bool = false
    @State var alertMessage: String = ""
    @State var showCounterTooltip: Bool = false
    let onDisappear: () -> Void

    init(save: Save, onDisappear: @escaping () -> Void = {}) {
        var graph = WarpGraph()
        graph.loadFromFiles()
        var loaded = Save.loadFromDisk(name: save.name) ?? save

        for (id, savedWarp) in loaded.graph.warps {
            if let linkedID = savedWarp.linked {
                graph.warps[id]?.linked = linkedID
                _ = graph.addDoubleLink(between: id, and: linkedID)
            }
        }

        loaded.graph = graph
        _PlatinumWarpGraph = State(initialValue: graph)
        _MainSaveFile = State(initialValue: loaded)
        self.onDisappear = onDisappear
    }

    var uniqueLocations: [String] {
        let locations = MainSaveFile.graph.warps.values.map { $0.location }
        return Array(Set(locations)).sorted()
    }

    var unlinkedAvailableCount: Int {
        let terminalIcons = ["dead_end", "event"]
        return MainSaveFile.available.filter { warpID in
            guard let warp = MainSaveFile.graph.warps[warpID] else { return true }
            guard let linkedID = warp.linked else { return true }
            if terminalIcons.contains(linkedID) { return false }
            if MainSaveFile.graph.warps[linkedID] != nil { return false }
            return true
        }.count
    }

    func locationStatus(_ location: String) -> Color {
        let locationWarps = MainSaveFile.graph.warps.values.filter { $0.location == location }
        guard !locationWarps.isEmpty else { return Color(.systemGray5) }

        let terminalIcons = ["dead_end", "event"]
        let availableWarps = locationWarps.filter { MainSaveFile.available.contains($0.id) }

        if availableWarps.isEmpty { return Color(.systemGray5) }

        let allWarpsFullyLinked = locationWarps.allSatisfy { warp in
            guard let linkedID = warp.linked else { return false }
            if terminalIcons.contains(linkedID) { return true }
            return MainSaveFile.graph.warps[linkedID] != nil
        }
        if allWarpsFullyLinked { return Color.green }

        let allAvailableLinked = availableWarps.allSatisfy { warp in warp.linked != nil }
        if allAvailableLinked {
            let hasNonTerminalIconLink = availableWarps.contains { warp in
                guard let linkedID = warp.linked else { return false }
                return iconNames.contains(linkedID) && !terminalIcons.contains(linkedID)
            }
            return hasNonTerminalIconLink ? Color.green.opacity(0.5) : Color.green.opacity(0.7)
        }

        return Color.red.opacity(0.7)
    }

    let flagDisplayNames: [String: String] = [
        "GOT_WORKS_KEY": "Works Key",
        "GOT_GALACTIC_KEY": "Galactic Key",
        "GOT_BIKE": "Bike",
        "GOT_SECRET_POTION": "Secret Potion",
        "SEEN_ROARK": "Roark Seen",
        "SEEN_FANTINA": "Fantina Seen",
        "SEEN_VOLKNER": "Volkner Seen",
        "DEFEATED_MARS_WINDWORKS": "Mars",
        "GOT_ROCK_SMASH": "Rock Smash",
        "GOT_CUT": "Cut",
        "GOT_FLY": "Fly",
        "GOT_DEFOG": "Defog",
        "GOT_SURF": "Surf",
        "GOT_STRENGTH": "Strength",
        "GOT_ROCK_CLIMB": "Rock Climb",
        "GOT_WATERFALL": "Waterfall",
        "GOT_TELEPORT": "Teleport",
        "DEFEATED_GYM_1": "Roark",
        "DEFEATED_GYM_2": "Gardenia",
        "DEFEATED_GYM_3": "Maylene",
        "DEFEATED_GYM_4": "Crasher Wake",
        "DEFEATED_GYM_5": "Fantina",
        "DEFEATED_GYM_6": "Byron",
        "DEFEATED_GYM_7": "Candice",
        "DEFEATED_GYM_8": "Volkner",
        "DEFEATED_AARON": "Aaron",
        "DEFEATED_BERTHA": "Bertha",
        "DEFEATED_FLINT": "Flint",
        "DEFEATED_LUCIAN": "Lucian",
        "DEFEATED_CYNTHIA": "Cynthia",
    ]

    let flagImageNames: [String: String] = [
        "GOT_WORKS_KEY": "WorksKey",
        "GOT_GALACTIC_KEY": "GalacticKey",
        "GOT_BIKE": "Bike 2",
        "GOT_SECRET_POTION": "SecretPotion",
        "SEEN_ROARK": "Roark",
        "SEEN_FANTINA": "Fantina",
        "SEEN_VOLKNER": "Volkner",
        "DEFEATED_MARS_WINDWORKS": "DefeatedWindworks",
        "GOT_ROCK_SMASH": "RockSmash",
        "GOT_CUT": "Cut",
        "GOT_FLY": "Fly",
        "GOT_DEFOG": "Defog",
        "GOT_SURF": "Surf",
        "GOT_STRENGTH": "Strength",
        "GOT_ROCK_CLIMB": "RockClimb",
        "GOT_WATERFALL": "Waterfall",
        "GOT_TELEPORT": "Teleport",
        "DEFEATED_GYM_1": "CoalBadge",
        "DEFEATED_GYM_2": "ForestBadge",
        "DEFEATED_GYM_3": "CobbleBadge",
        "DEFEATED_GYM_4": "FenBadge",
        "DEFEATED_GYM_5": "RelicBadge",
        "DEFEATED_GYM_6": "MineBadge",
        "DEFEATED_GYM_7": "IcicleBadge",
        "DEFEATED_GYM_8": "BeaconBadge",
        "DEFEATED_AARON": "Aaron",
        "DEFEATED_BERTHA": "Bertha",
        "DEFEATED_FLINT": "Flint",
        "DEFEATED_LUCIAN": "Lucian",
        "DEFEATED_CYNTHIA": "Cynthia",
    ]

    func formatFlagID(_ flagID: String) -> String {
        return flagDisplayNames[flagID] ?? flagID
    }

    func handleIconTap(_ iconName: String) {
        switch linkState {
        case .idle:
            if selectedIcon == iconName {
                selectedIcon = nil
            } else {
                selectedIcon = iconName
            }
        case .firstSelected(let warpID):
            MainSaveFile.graph.warps[warpID]?.linked = iconName
            MainSaveFile.reloadFlags()
            linkState = .idle
            selectedIcon = nil
        }
    }

    func unlinkIcon(_ iconName: String) {
        for id in MainSaveFile.graph.warps.keys {
            if MainSaveFile.graph.warps[id]?.linked == iconName {
                MainSaveFile.graph.warps[id]?.linked = nil
            }
        }
        MainSaveFile.reloadFlags()
        selectedIcon = nil
    }

    func exportSave() {
        let url = Save.saveURL(name: MainSaveFile.name)
        guard FileManager.default.fileExists(atPath: url.path) else {
            alertMessage = "Warp layout \"\(MainSaveFile.name)\" export failed."
            showFailureAlert = true
            return
        }
        showExportSheet = true
    }

    func importSave(from url: URL) {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }

        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            var imported = try decoder.decode(Save.self, from: data)

            var graph = WarpGraph()
            graph.loadFromFiles()
            for (id, savedWarp) in imported.graph.warps {
                if let linkedID = savedWarp.linked {
                    graph.warps[id]?.linked = linkedID
                    _ = graph.addDoubleLink(between: id, and: linkedID)
                }
            }

            imported.name = MainSaveFile.name
            imported.graph = graph
            MainSaveFile = imported
            MainSaveFile.reloadFlags()

            alertMessage = "Warp layout \"\(MainSaveFile.name)\" imported successfully."
            showSuccessAlert = true

        } catch {
            alertMessage = "Warp layout \"\(MainSaveFile.name)\" import failed."
            showFailureAlert = true
        }
    }

    var body: some View {
        ZStack {

            Image("save_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

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

            // Top area
            VStack {
                HStack(alignment: .center) {

                    if case .firstSelected(let id) = linkState {
                        HStack(spacing: 8) {
                            ForEach(iconNames, id: \.self) { iconName in
                                Button {
                                    handleIconTap(iconName)
                                } label: {
                                    Image(iconName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 28, height: 28)
                                        .padding(4)
                                        .background(Color.black.opacity(0.5))
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.leading, 16)
                        .padding(.top, 8)

                        Spacer()

                        HStack(spacing: 4) {
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
                                .confirmationDialog(
                                    "Unlink \(id)?",
                                    isPresented: $showUnlinkConfirmation,
                                    titleVisibility: .visible
                                ) {
                                    Button("Unlink", role: .destructive) {
                                        if let linkedID = MainSaveFile.graph.warps[id]?.linked {
                                            if iconNames.contains(linkedID) {
                                                MainSaveFile.graph.warps[id]?.linked = nil
                                                MainSaveFile.reloadFlags()
                                            } else {
                                                MainSaveFile.graph.unlinkWarps(warp1ID: id, warp2ID: linkedID)
                                                MainSaveFile.reloadFlags()
                                            }
                                        }
                                        linkState = .idle
                                    }
                                    Button("Cancel", role: .cancel) {}
                                } message: {
                                    Text("This will remove the link between these two warps.")
                                }
                            }

                            Button {
                                linkState = .idle
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.title3)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.trailing, 16)

                    } else {
                        HStack(spacing: 8) {
                            ForEach(iconNames, id: \.self) { iconName in
                                Button {
                                    handleIconTap(iconName)
                                } label: {
                                    Image(iconName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 28, height: 28)
                                        .padding(4)
                                        .background(selectedIcon == iconName ? Color.yellow : Color.black.opacity(0.5))
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedIcon == iconName ? Color.yellow : Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        unlinkIcon(iconName)
                                    } label: {
                                        Label("Unlink all \(iconName)", systemImage: "link.badge.minus")
                                    }
                                }
                            }
                        }
                        .padding(.leading, 16)
                        .padding(.top, 8)

                        Spacer()

                        ZStack(alignment: .bottom) {
                            Text("\(unlinkedAvailableCount) / \(MainSaveFile.available.count) / \(MainSaveFile.graph.warps.count)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .onLongPressGesture(minimumDuration: 0.4) {
                                    showCounterTooltip = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        showCounterTooltip = false
                                    }
                                }

                            if showCounterTooltip {
                                Text("Unlinked / Available / Total Warps")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.black.opacity(0.75))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .offset(y: 30)
                                    .transition(.opacity)
                                    .animation(.easeInOut(duration: 0.2), value: showCounterTooltip)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.trailing, 16)
                    }
                }

                if case .firstSelected(let id) = linkState {
                    HStack {
                        Spacer()
                        Text("Linking: \(id)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(20)
                        Spacer()
                    }
                }

                Spacer()
            }

            // Bottom bar
            VStack {
                Spacer()

                HStack(alignment: .bottom) {
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
                                        .background(locationStatus(location))
                                        .foregroundColor(.primary)
                                        .colorScheme(.light)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedLocation == location ? Color.blue : Color.clear, lineWidth: 2)
                                        )
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

                    HStack(spacing: 8) {
                        sideButton(icon: "square.and.arrow.up", isActive: false) {
                            exportSave()
                        }
                        sideButton(icon: "square.and.arrow.down", isActive: false) {
                            showImportPicker = true
                        }
                    }

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
        .sheet(isPresented: $showExportSheet, onDismiss: {
            alertMessage = "Warp layout \"\(MainSaveFile.name)\" exported successfully."
            showSuccessAlert = true
        }) {
            ShareSheet(url: Save.saveURL(name: MainSaveFile.name))
        }
        .fileImporter(
            isPresented: $showImportPicker,
            allowedContentTypes: [UTType.propertyList],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    importSave(from: url)
                }
            case .failure:
                alertMessage = "Warp layout \"\(MainSaveFile.name)\" import failed."
                showFailureAlert = true
            }
        }
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("Okay", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .alert("Failed", isPresented: $showFailureAlert) {
            Button("Okay", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    @ViewBuilder
    func flagPanel(keys: [String]) -> some View {
        let rowCount = ceil(Double(keys.count) / 2.0)
        let rowHeight: CGFloat = 44
        let padding: CGFloat = 16
        let totalHeight = rowCount * rowHeight + padding * 2
        let lastKeyIsOdd = keys.count % 2 != 0
        let pairedKeys = stride(from: 0, to: lastKeyIsOdd ? keys.count - 1 : keys.count, by: 2).map {
            (keys[$0], keys[$0 + 1])
        }

        ScrollView {
            VStack(spacing: 8) {
                ForEach(Array(pairedKeys.enumerated()), id: \.offset) { _, pair in
                    HStack(spacing: 8) {
                        flagButton(pair.0)
                        flagButton(pair.1)
                    }
                }
                if lastKeyIsOdd, let lastKey = keys.last {
                    flagButton(lastKey)
                        .frame(maxWidth: .infinity)
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
    func flagButton(_ flagID: String) -> some View {
        HStack(spacing: 6) {
            if let imageName = flagImageNames[flagID] {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
            Text(formatFlagID(flagID))
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(flagColor(for: flagID))
        .foregroundColor(.white)
        .cornerRadius(8)
        .onTapGesture {
            MainSaveFile.changeFlag(flagID: flagID)
            MainSaveFile.reloadFlags()
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            MainSaveFile.discoverFlag(flagID: flagID)
            MainSaveFile.reloadFlags()
        }
    }

    func flagColor(for flagID: String) -> Color {
        switch MainSaveFile.flags[flagID] {
        case .done: return .green
        case .discovered: return .yellow
        default: return .red
        }
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

struct ShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        SaveView(save: Save(name: "Preview Save", date: Date(), graph: WarpGraph()))
    }
}
