//
//  ContentView.swift
//  WarpTracker
//
//  Created by Cameron Lee on 5/3/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplash: Bool = true

    var body: some View {
        ZStack {
            TabView {
                SaveSelectView()
                    .tabItem {
                        Label("Saves", systemImage: "square.stack.fill")
                    }

                ResourcesView()
                    .tabItem {
                        Label("Resources", systemImage: "book.fill")
                    }
            }

            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}

struct SplashView: View {
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0
    @State private var dotCount: Int = 0
    @State private var timer: Timer? = nil

    var loadingText: String {
        "Loading" + String(repeating: ".", count: dotCount)
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // App icon / logo area
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 120, height: 120)

                    Image("splash_screen")
                        .font(.system(size: 52))
                        .foregroundColor(.blue)
                }
                .scaleEffect(scale)
                .opacity(opacity)

                VStack(spacing: 8) {
                    Text("Warp Tracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .opacity(opacity)

                    Text("Pokémon Platinum")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .opacity(opacity)
                }

                Text(loadingText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 80, alignment: .leading)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                dotCount = (dotCount + 1) % 4
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}

#Preview {
    ContentView()
}
