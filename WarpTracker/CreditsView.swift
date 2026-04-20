//
//  CreditsView.swift
//  WarpTracker
//
//  Created by Cameron Lee on 20/4/2026.
//

import SwiftUI

struct CreditsView: View {
    var body: some View {
        VStack {
            ScrollView {
                Text("Firstly, I would like to thank Pointcrow and his development team for the creation of the warp randomizer format!")
                Spacer()
                    .frame(height: 20)
                Text("Secondly, I would like to credit Leah for the inspiration for this app, having created a Pokemon Platinum warp tracker of their own for PC. They were also lovely enough to supply me with some resources that they created, which I would love to utilise in future updates!")
            }
        }
        .padding()
        .navigationTitle("Credits")
    }
}

#Preview {
    CreditsView()
}
