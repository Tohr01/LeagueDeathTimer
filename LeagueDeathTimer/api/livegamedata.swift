//
// livegamedata.swift
// LeagueDeathTimer
//
// Created by Tohr01 on 03.11.24
// Copyright © 2024 Tohr01. All rights reserved.
//

import Foundation

func getActivePlayerChampionName(riotID: String) async -> String? {
    guard let playerDict = await getCurrentPlayerInformationDict(riotID: riotID) else {
        return nil
    }
    return playerDict["championName"] as? String
}

func getActivePlayerRiotID() async -> String? {
    guard let dict = await makeLiveGameDataRequest(urlStr: "https://127.0.0.1:2999/liveclientdata/activeplayer") as? [String: Any],
          let riotID = dict["riotId"] as? String
    else {
        return nil
    }
    return riotID
}

func getRespawnTimer(riotID: String) async -> Float? {
    guard let playerDict = await getCurrentPlayerInformationDict(riotID: riotID) else {
        return nil
    }
    if !(playerDict["isDead"] as! Bool) { return nil }

    return playerDict["respawnTimer"] as? Float
}

func getNumberOfDeaths(riotID: String) async -> Int? {
    guard let playerDict = await getCurrentPlayerInformationDict(riotID: riotID) else {
        return nil
    }
    guard let scores = playerDict["scores"] as? [String: Any],
          let deaths = scores["deaths"] as? Int
    else { return nil }
    return deaths
}

private func getCurrentPlayerInformationDict(riotID: String) async -> [String: Any]? {
    guard let dict = await makeLiveGameDataRequest(urlStr: "https://127.0.0.1:2999/liveclientdata/playerlist") as? [[String: Any]] else {
        return nil
    }

    let player = dict.filter { $0["riotId"] as! String == riotID }[0]
    return player
}

private func makeLiveGameDataRequest(urlStr: String) async -> Any? {
    let url = URL(string: urlStr)!
    let urlRequest = URLRequest(url: url)
    guard let (data, _) = try? await URLSession(configuration: .default, delegate: CertIgnoreURLSessionDelegate(), delegateQueue: .main).data(for: urlRequest),
          let e = try? JSONSerialization.jsonObject(with: data)
    else {
        return nil
    }
    return e
}
