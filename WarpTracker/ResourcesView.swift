//
//  ResourcesView.swift
//  WarpTracker
//
//  Created by Cameron Lee on 5/3/2026.
//

import SwiftUI
import SafariServices

// MARK: - Resource Types

struct LinkResource: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let url: String
    let icon: String
}

struct ViewResource: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let destination: AnyView

    init(title: String, description: String, icon: String, destination: some View) {
        self.title = title
        self.description = description
        self.icon = icon
        self.destination = AnyView(destination)
    }
}

enum Resource: Identifiable {
    case link(LinkResource)
    case view(ViewResource)

    var id: UUID {
        switch self {
        case .link(let r): return r.id
        case .view(let r): return r.id
        }
    }

    var title: String {
        switch self {
        case .link(let r): return r.title
        case .view(let r): return r.title
        }
    }

    var description: String {
        switch self {
        case .link(let r): return r.description
        case .view(let r): return r.description
        }
    }

    var icon: String {
        switch self {
        case .link(let r): return r.icon
        case .view(let r): return r.icon
        }
    }
}

// MARK: - Resource Data

let resourcesByGame: [String: [Resource]] = [
    "All": [
        .link(LinkResource(
            title: "Warp Randomizer Info",
            description: "The main page for the Pokemon Warp Randomizer by Pointcrow",
            url: "https://warprandomizer.com/",
            icon: "shuffle"
        )),
        .link(LinkResource(
            title: "Rare Candies",
            description: "The location of all Rare Candies in different Pokemon games",
            url: "https://bulbapedia.bulbagarden.net/wiki/Rare_Candy#Acquisition",
            icon: "book.fill"
        )),
        .view(ViewResource(
            title: "Credits",
            description: "Acknowledgements and credits for this Warp Tracker application",
            icon: "heart.fill",
            destination: CreditsView()
        )),
    ],
    "Pokémon Platinum": [
        .link(LinkResource(
            title: "HM Locations",
            description: "The location and acquisition methods of all Hidden Machines in Pokemon Platinum",
            url: "https://pokemondb.net/diamond-pearl/hms",
            icon: "globe"
        )),
        .link(LinkResource(
            title: "Gym and E4 Battles",
            description: "Information on each Gym Leader and E4 + Champion battle in Pokemon Platinum",
            url: "https://pokemondb.net/platinum/gymleaders-elitefour",
            icon: "globe"
        )),
    ]
]

// MARK: - ResourcesView

struct ResourcesView: View {
    @State var selectedGame: String = "All"
    @State var safariURL: URL? = nil
    @State var showSafari: Bool = false
    @State var activeViewResource: ViewResource? = nil

    let games = ["All", "Pokémon Platinum"]

    var resources: [Resource] {
        resourcesByGame[selectedGame] ?? []
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Game selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(games, id: \.self) { game in
                            Button {
                                selectedGame = game
                            } label: {
                                Text(game)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(selectedGame == game ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(selectedGame == game ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(Color(.systemGroupedBackground))

                Divider()

                // Resource list
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(resources) { resource in
                            resourceRow(resource)
                        }
                    }
                    .padding(16)
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Resources")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $activeViewResource) { viewResource in
                viewResource.destination
            }
        }
        .sheet(isPresented: $showSafari) {
            if let url = safariURL {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }

    @ViewBuilder
    func resourceRow(_ resource: Resource) -> some View {
        Button {
            switch resource {
            case .link(let r):
                if let url = URL(string: r.url) {
                    safariURL = url
                    showSafari = true
                }
            case .view(let r):
                activeViewResource = r
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: resource.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 4) {
                    Text(resource.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)

                    Text(resource.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
    }
}

extension ViewResource: Hashable {
    static func == (lhs: ViewResource, rhs: ViewResource) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - SafariView

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

#Preview {
    ResourcesView()
}
