//
//  SaveSelect.swift
//  WarpTracker
//
//  Created by Cameron Lee on 5/3/2026.
//

import SwiftUI

let availableGames: [String] = [
    "Pokémon Platinum"
]

let gameBackgrounds: [String: String] = [
    "Pokémon Platinum": "platinum_background",
    "Pokémon Emerald": "emerald_background",
    "Pokémon Black 2": "blackwhite_background",
    "Pokémon White 2": "blackwhite_background",
    "Pokémon HeartGold": "heartgold_background",
    "Pokémon SoulSilver": "soulsilver_background",
]

struct SaveSelectView: View {
    @State var saves: [Save] = []
    @State var showNewSaveSheet: Bool = false
    @State var newSaveName: String = ""
    @State var newSaveGame: String = "Pokémon Platinum"
    @State var saveToDelete: Save? = nil
    @State var showDeleteConfirmation: Bool = false
    @State var newSave: Save? = nil

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var sortedSaves: [Save] {
        saves.sorted { $0.name < $1.name }
    }

    var body: some View {
        ZStack {
            GeometryReader { geo in
                Image("splash_screen")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
            .ignoresSafeArea()

            NavigationStack {
                ZStack {
                    Color.clear
                        .ignoresSafeArea()

                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(sortedSaves, id: \.name) { save in
                                NavigationLink {
                                    SaveView(save: save, onDisappear: loadAllSaves)
                                } label: {
                                    saveCard(save)
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        saveToDelete = save
                                        showDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }

                            Button {
                                showNewSaveSheet = true
                            } label: {
                                addCard()
                            }
                        }
                        .padding(16)
                    }
                    .scrollContentBackground(.hidden)
                }
                .navigationTitle("Warp Tracker")
                .navigationBarTitleDisplayMode(.large)
                .toolbarBackground(.hidden, for: .navigationBar)
                .navigationDestination(item: $newSave) { save in
                    SaveView(save: save, onDisappear: loadAllSaves)
                }
                .sheet(isPresented: $showNewSaveSheet) {
                    newSaveSheet()
                }
                .confirmationDialog(
                    "Delete \(saveToDelete?.name ?? "this save")?",
                    isPresented: $showDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        if let save = saveToDelete {
                            deleteSave(save)
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        saveToDelete = nil
                    }
                } message: {
                    Text("This cannot be undone.")
                }
            }
            .background(Color.clear)
            .onAppear {
                loadAllSaves()
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
                UITableView.appearance().backgroundColor = .clear
                UICollectionView.appearance().backgroundColor = .clear
            }
        }
    }

    @ViewBuilder
    func saveCard(_ save: Save) -> some View {
        let cynthiaDefeated = save.flags["DEFEATED_CYNTHIA"] == .done
        let linked = save.graph.warps.values.filter { $0.linked != nil }.count
        let total = save.graph.warps.count
        let gameName = save.game ?? "Pokémon Platinum"
        let backgroundImage = gameBackgrounds[gameName] ?? "platinum_background"
        let gold = Color(red: 0.9882352941, green: 0.7607843137, blue: 0)

        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                // Game background image
                Image(backgroundImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.width / 1.5)
                    .clipped()
                    .opacity(0.7) // CHANGE OPACITY HERE :)

                // Text overlay
                VStack(alignment: .leading, spacing: 4) {
                    Text(save.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(cynthiaDefeated ? gold : .white)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)

                    Text(gameName)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.85))
                        .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)

                    Text("\(linked) / \(total) linked")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.75))
                        .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [Color.black.opacity(0.6), Color.clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
            .frame(width: geo.size.width, height: geo.size.width / 1.5)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .aspectRatio(1.5, contentMode: .fit)
    }

    @ViewBuilder
    func addCard() -> some View {
        GeometryReader { geo in
            VStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
                Text("New Save")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            .frame(width: geo.size.width, height: geo.size.width / 1.5)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [6]))
            )
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .aspectRatio(1.5, contentMode: .fit)
    }

    @ViewBuilder
    func newSaveSheet() -> some View {
        VStack(spacing: 24) {
            VStack(spacing: 6) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                Text("New Save")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.top, 8)

            TextField("Save name", text: $newSaveName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                Text("Game")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(availableGames, id: \.self) { game in
                            Button {
                                newSaveGame = game
                            } label: {
                                Text(game)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(newSaveGame == game ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(newSaveGame == game ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }

            HStack(spacing: 12) {
                Button("Cancel") {
                    newSaveName = ""
                    newSaveGame = "Pokémon Platinum"
                    showNewSaveSheet = false
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(10)

                Button("Create") {
                    let save = createNewSave(name: newSaveName, game: newSaveGame)
                    newSaveName = ""
                    newSaveGame = "Pokémon Platinum"
                    showNewSaveSheet = false
                    newSave = save
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(newSaveName.trimmingCharacters(in: .whitespaces).isEmpty ? Color.blue.opacity(0.4) : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(newSaveName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 32)
        .presentationDetents([.height(320)])
    }

    func loadAllSaves() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documents, includingPropertiesForKeys: nil)
            saves = files.filter { $0.pathExtension == "plist" }.compactMap { url in
                let name = url.deletingPathExtension().lastPathComponent
                guard var loaded = Save.loadFromDisk(name: name) else { return nil }

                var graph = WarpGraph()
                graph.loadFromFiles()
                for (id, savedWarp) in loaded.graph.warps {
                    if let linkedID = savedWarp.linked {
                        graph.warps[id]?.linked = linkedID
                    }
                }
                loaded.graph = graph
                return loaded
            }
        } catch {
            print("Failed to list saves: \(error)")
        }
    }

    @discardableResult
    func createNewSave(name: String, game: String) -> Save {
        var graph = WarpGraph()
        graph.loadFromFiles()
        var save = Save(name: name, date: Date(), graph: graph)
        save.game = game
        save.saveToDisk()
        saves.append(save)
        return save
    }

    func deleteSave(_ save: Save) {
        let url = Save.saveURL(name: save.name)
        do {
            try FileManager.default.removeItem(at: url)
            saves.removeAll { $0.name == save.name }
        } catch {
            print("Failed to delete save: \(error)")
        }
        saveToDelete = nil
    }
}

#Preview {
    SaveSelectView()
}
