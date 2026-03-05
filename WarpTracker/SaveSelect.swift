//
//  SaveSelect.swift
//  WarpTracker
//
//  Created by Cameron Lee on 5/3/2026.
//

// SaveSelectView.swift

import SwiftUI

struct SaveSelectView: View {
    @State var saves: [Save] = []
    @State var showNewSaveSheet: Bool = false
    @State var newSaveName: String = ""
    @State var saveToDelete: Save? = nil
    @State var showDeleteConfirmation: Bool = false
    @State var newSave: Save? = nil

    var body: some View {
        NavigationStack {
            List(saves.sorted(by: { $0.name < $1.name }), id: \.name) { save in
                NavigationLink(save.name) {
                    SaveView(save: save, onDisappear: loadAllSaves)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        saveToDelete = save
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Saves")
            .toolbar {
                Button {
                    showNewSaveSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .navigationDestination(item: $newSave) { save in
                SaveView(save: save, onDisappear: loadAllSaves)
            }
            .sheet(isPresented: $showNewSaveSheet) {
                VStack(spacing: 20) {
                    Text("New Save")
                        .font(.headline)
                    TextField("Save name", text: $newSaveName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    HStack {
                        Button("Cancel") {
                            newSaveName = ""
                            showNewSaveSheet = false
                        }
                        .foregroundColor(.red)
                        Spacer()
                        Button("Create") {
                            let save = createNewSave(name: newSaveName)
                            newSaveName = ""
                            showNewSaveSheet = false
                            newSave = save
                        }
                        .disabled(newSaveName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                .padding(.top, 32)
                .presentationDetents([.height(200)])
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
        .onAppear {
            loadAllSaves()
        }
    }

    func loadAllSaves() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documents, includingPropertiesForKeys: nil)
            saves = files.filter { $0.pathExtension == "plist" }.compactMap { url in
                let name = url.deletingPathExtension().lastPathComponent
                return Save.loadFromDisk(name: name)
            }
        } catch {
            print("Failed to list saves: \(error)")
        }
    }

    @discardableResult
    func createNewSave(name: String) -> Save {
        var graph = WarpGraph()
        graph.loadFromFiles()
        var save = Save(name: name, date: Date(), graph: graph)
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
