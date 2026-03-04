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
        _PlatinumWarpGraph = State(initialValue: graph)
        _MainSaveFile = State(initialValue: Save(name: "Save 1", date: Date(), graph: graph))
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Text("\(MainSaveFile.graph.warps.count)")
            Text("\(MainSaveFile.available.count)")
        }
        .padding()
        .task {
            // Nothing here yet lol
        }
    }
}

#Preview {
    ContentView()
}
