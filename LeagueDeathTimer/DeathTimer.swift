//
// DeathTimer.swift
// LeagueDeathTimer
//
// Created by Tohr01 on 03.11.24
// Copyright © 2024 Tohr01. All rights reserved.
//

import SwiftUI

struct DeathTimer: View {
    @Environment(\.scenePhase) var scenePhase

    @State var bgUrl: URL?
    @State var riotID: String = "RiotID"
    @State var respawnTimer: Int? = nil
    @State var championName: String = "Champion Name"
    @State var numberOfDeaths: Int? = nil
    var body: some View {
        ZStack {
            GeometryReader(content: { _ in
                AsyncImage(url: bgUrl, content: { image in
                    image
                        .resizable()
                        .frame(alignment: .top)
                        .aspectRatio(contentMode: .fill)
                        .grayscale(respawnTimer == nil ? 0 : 1)
                }, placeholder: {
                    ProgressView()
                })
            })

            Rectangle()
                .fill(
                    LinearGradient(colors: [respawnTimer == nil ? .black : Color("deathRed"), .clear], startPoint: UnitPoint(x: 0, y: 0.5), endPoint: UnitPoint(x: 1, y: 0.5))
                )

            HStack {
                Group {
                    if respawnTimer == nil {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.white)
                    } else {
                        Text(respawnTimer!.description)
                            .font(.custom("BeaufortforLOL-Bold", size: 35))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 40)
                .padding(.horizontal, 20)
                VStack(alignment: .leading, content: {
                    Text(riotID)
                        .font(.custom("BeaufortforLOL-Bold", size: 21))
                        .foregroundStyle(.white)
                    Text(championName)
                        .font(.custom("BeaufortforLOL-Bold", size: 30))
                        .foregroundStyle(.white)
                    if numberOfDeaths ?? 0 > 0 {
                        Text("Diggah du bist jetzt schon das \(numberOfDeaths ?? 0). mal verreckt lol")
                            .font(.custom("BeaufortforLOL-Bold", size: 14))
                            .foregroundColor(Color.white)
                    }
                })
                Spacer()
            }
            .padding(15)
        }
        .frame(width: 517, height: 138)
        .task {
            if let playerRiotID = await getActivePlayerRiotID() {
                riotID = playerRiotID
            }
            if let champName = await getActivePlayerChampionName(riotID: riotID) {
                championName = champName
            }

            bgUrl = await getChampionSplashURL(championName: championName)
            while gameClientRunning() {
                if let timer = await getRespawnTimer(riotID: riotID) {
                    respawnTimer = Int(timer.rounded(.down))
                } else {
                    respawnTimer = nil
                }
                numberOfDeaths = await getNumberOfDeaths(riotID: riotID)

                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }
}

#Preview {
    DeathTimer()
}
