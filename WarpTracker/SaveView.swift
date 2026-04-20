// SaveView.swift

import SwiftUI
import UniformTypeIdentifiers

let topBarIcons = ["dead_end", "event", "trainer", "bike", "HM", "level", "legendary"]
let trainerIcons = ["Roark", "Gardenia", "Fantina", "Maylene", "Crasher Wake", "Byron", "Candice", "Volkner", "Aaron", "Bertha", "Flint", "Lucian", "Cynthia"]

// →

let adjacencies: [String: [(direction: String, location: String)]] = [
    "Sandgem": [("←", "Verity Lakefront"), ("↑", "Jubilife"), ("↓", "Route 221")],
    "Jubilife": [("↓", "Sandgem"), ("↑", "Route 204"), ("→", "Route 203")],
    "Verity Lakefront": [("→", "Sandgem")],
    "Route 204": [("↓", "Jubilife"), ("↑", "Floaroma")],
    "Route 203": [("←", "Jubilife")],
    "Oreburgh": [("↑", "Route 207")],
    "Floaroma": [("↓", "Route 204"), ("→", "Route 205")],
    "Eterna": [("←", "Route 205"), ("→", "Route 211")],
    "Solaceon": [("↓", "Route 209"), ("↑", "Route 210")],
    "Pastoria": [("←", "Route 212")],
    "Celestic": [("←", "Route 211"), ("→", "Route 210")],
    "Canalave": [("→", "Iron Island")],
    "Iron Island": [("←", "Canalave")],
    "Snowpoint": [("←", "Route 217")],
    "Sunyshore": [("↑", "Pokemon League")],
    "Valor Lakefront": [("↑", "Route 214")],
    "Route 209": [("↑", "Solaceon")],
    "Route 210": [("←", "Celestic"), ("↓", "Solaceon"), ("→", "Route 215")],
    "Route 211": [("←", "Eterna"), ("→", "Celestic")],
    "Route 212": [("→", "Pastoria")],
    "Route 214": [("↓", "Valor Lakefront")],
    "Route 215": [("←", "Route 210")],
    "Route 216": [("↑", "Route 217")],
    "Route 217": [("↓", "Route 216"), ("↑", "Acuity Lakefront"), ("→", "Snowpoint")],
    "Route 221": [("←", "Sandgem")],
    "Route 222": [("←", "Valor Lakefront")],
    "Route 205": [("←", "Floaroma"), ("↑", "Fuego Ironworks"), ("→", "Valley Windworks"), ("→", "Eterna")],
    "Route 206": [("↓", "Route 207")],
    "Route 207": [("↓", "Oreburgh"), ("↑", "Route 206")],
    "Route 225": [("↑", "Survival Area")],
    "Route 226": [("←", "Survival Area"), ("↑", "Route 227")],
    "Route 227": [("↓", "Route 226"), ("↑", "Stark Mountain")],
    "Stark Mountain": [("↓", "Route 227")],
    "Route 228": [("↓", "Resort Area")],
    "Acuity Lakefront": [("↓", "Route 217")],
    "Pokemon League": [("↓", "Sunyshore")],
    "Fight Area": [("→", "Resort Area")],
    "Fuego Ironworks": [("↓", "Route 205")],
    "Survival Area": [("←", "Route 225"), ("→", "Route 226")],
    "Resort Area": [("←", "Fight Area"), ("↑", "Route 228")],
    "Valley Windworks": [("←", "Route 205")],
]

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
    @State var iconMenuExpanded: Bool = false
    @State var iconCycleIndex: [String: Int] = [:]
    @State var showNotes: Bool = false
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
        "DEFEATED_GYM_3": "Fantina",
        "DEFEATED_GYM_4": "Maylene",
        "DEFEATED_GYM_5": "Crasher Wake",
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
        "DEFEATED_GYM_3": "RelicBadge",
        "DEFEATED_GYM_4": "CobbleBadge",
        "DEFEATED_GYM_5": "FenBadge",
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
            iconMenuExpanded = false
        }
    }

    func handleIconLongPress(_ iconName: String) {
        let linkedWarps = MainSaveFile.graph.warps.values
            .filter { $0.linked == iconName }
            .sorted { $0.id < $1.id }

        guard !linkedWarps.isEmpty else { return }

        let currentIndex = iconCycleIndex[iconName] ?? 0
        let clampedIndex = currentIndex % linkedWarps.count
        let targetWarp = linkedWarps[clampedIndex]

        selectedLocation = targetWarp.location
        iconCycleIndex[iconName] = (clampedIndex + 1) % linkedWarps.count
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

    func iconRows(from icons: [String]) -> [[String]] {
        stride(from: 0, to: icons.count, by: 5).map {
            Array(icons[$0..<min($0 + 5, icons.count)])
        }
    }
    
    @ViewBuilder
    func adjacencyBar() -> some View {
        if let location = selectedLocation,
           let neighbors = adjacencies[location],
           !neighbors.isEmpty {
            HStack(spacing: 10) {
                ForEach(neighbors, id: \.location) { neighbor in
                    Button {
                        selectedLocation = neighbor.location
                    } label: {
                        HStack(spacing: 4) {
                            Text(neighbor.direction)
                                .font(.caption)
                                .fontWeight(.bold)
                            Text(neighbor.location)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }

    @ViewBuilder
    func iconButton(_ iconName: String, duringLinking: Bool) -> some View {
        let imageName = iconImageNames[iconName] ?? iconName
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .padding(4)
                .background(
                    duringLinking
                        ? Color.black.opacity(0.5)
                        : (selectedIcon == iconName ? Color.yellow : Color.black.opacity(0.5))
                )
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            duringLinking
                                ? Color.white.opacity(0.3)
                                : (selectedIcon == iconName ? Color.yellow : Color.white.opacity(0.3)),
                            lineWidth: 1
                        )
                )
        }
        .onTapGesture {
            handleIconTap(iconName)
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            guard !duringLinking else { return }
            handleIconLongPress(iconName)
        }
    }

    @ViewBuilder
    func iconPanel(duringLinking: Bool) -> some View {
        let allIcons = topBarIcons + trainerIcons
        let rows = iconRows(from: allIcons)

        VStack(alignment: .leading, spacing: 6) {
            ForEach(rows.indices, id: \.self) { rowIndex in
                HStack(spacing: 8) {
                    ForEach(rows[rowIndex], id: \.self) { iconName in
                        iconButton(iconName, duringLinking: duringLinking)
                    }
                }
            }
        }
        .padding(8)
        .background(Color.black.opacity(0.4))
        .cornerRadius(10)
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
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {

                    // Left: icon menu toggle + expanded panel
                    VStack(alignment: .leading, spacing: 6) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                iconMenuExpanded.toggle()
                            }
                        } label: {
                            Image(systemName: iconMenuExpanded ? "chevron.left.circle.fill" : "chevron.right.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }

                        if iconMenuExpanded {
                            if case .firstSelected(_) = linkState {
                                iconPanel(duringLinking: true)
                            } else {
                                iconPanel(duringLinking: false)
                            }
                        }
                    }
                    .padding(.leading, 16)
                    .padding(.top, 8)

                    Spacer()

                    // Right: linking controls or counter + notes button
                    VStack(alignment: .trailing, spacing: 4) {
                        if case .firstSelected(let id) = linkState {
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
                            // Counter
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
                            .padding(.top, 8)
                            .padding(.trailing, 16)

                            // Notes button just below counter
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showNotes.toggle()
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: showNotes ? "note.text.badge.plus" : "note.text")
                                    Text("Notes")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(showNotes ? Color.orange : Color.black.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                            }
                            .padding(.trailing, 16)

                            // Tooltip shown below the Notes button
                            if showCounterTooltip {
                                Text("Unlinked / Available / Total Warps")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.black.opacity(0.75))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(.trailing, 16)
                                    .transition(.opacity)
                                    .animation(.easeInOut(duration: 0.2), value: showCounterTooltip)
                            }
                        }
                    }
                }

                // Linking label row
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
                    .padding(.top, 4)
                }

                Spacer()
            }

            // Notes overlay
            if showNotes {
                GeometryReader { geometry in
                    ZStack {
                        // Dim background — tap outside to close
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showNotes = false
                                }
                            }

                        VStack(spacing: 0) {
                            // Title bar
                            HStack {
                                Text("Notes — \(MainSaveFile.name)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        showNotes = false
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.secondarySystemBackground))

                            Divider()

                            // Text editor
                            TextEditor(text: Binding(
                                get: { MainSaveFile.notes ?? "" },
                                set: { newValue in
                                    MainSaveFile.notes = newValue
                                    MainSaveFile.saveToDisk()
                                }
                            ))
                            .font(.body)
                            .padding(12)
                            .background(Color(.systemBackground))
                        }
                        .frame(
                            width: geometry.size.width * 0.9,
                            height: geometry.size.height * 0.75
                        )
                        .cornerRadius(16)
                        .shadow(radius: 20)
                        .position(
                            x: geometry.size.width / 2,
                            y: geometry.size.height / 2
                        )
                    }
                }
                .ignoresSafeArea()
                .transition(.opacity)
                .zIndex(10)
            }

            // Bottom bar
            VStack {
                Spacer()

                // Current location label
                if let location = selectedLocation {
                    Text(location)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Color.black.opacity(0.55))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                
                Spacer()
                    .frame(height: 5)

                adjacencyBar()
                
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
        .toolbar(.hidden, for: .tabBar)
        .onDisappear {
            onDisappear()
        }
        .sheet(isPresented: $showExportSheet) {
            ShareSheet(url: Save.saveURL(name: MainSaveFile.name)) { completed in
                if completed {
                    alertMessage = "Warp layout \"\(MainSaveFile.name)\" exported successfully."
                    showSuccessAlert = true
                }
            }
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
    var onComplete: (Bool) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        controller.completionWithItemsHandler = { _, completed, _, error in
            if error != nil {
                context.coordinator.onComplete(false)
            } else if completed {
                context.coordinator.onComplete(true)
            } else {
                context.coordinator.onComplete(false)
            }
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}

    class Coordinator {
        var onComplete: (Bool) -> Void
        init(onComplete: @escaping (Bool) -> Void) {
            self.onComplete = onComplete
        }
    }
}

#Preview {
    NavigationStack {
        SaveView(save: Save(name: "Preview Save", date: Date(), graph: WarpGraph()))
    }
}
