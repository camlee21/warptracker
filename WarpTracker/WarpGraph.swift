//
//  WarpGraph.swift
//  WarpTracker
//
//  Created by Cameron Lee on 5/3/2026.
//

import Foundation

func dblLinkGroup(_ warpGraph: inout WarpGraph, _ array: [String]) {
    for i in 0..<array.count {
        for j in 0..<array.count {
            if i != j {
                warpGraph.addDoubleLink(between: array[i], and: array[j])
            }
        }
    }
}

struct WarpGraph: Codable, Hashable {
    var warps: [String: Warp] = [:]
    
    mutating func addWarp(_ warp: Warp) -> Bool {
        guard warps[warp.id] == nil else { return false }
        warps[warp.id] = warp
        return true
    }
    
    // MARK: - Link Management
    
    /// warp1 -> warp2
    mutating func addSingleLink(from warp1ID: String, to warp2ID: String) -> Bool {
        guard warps[warp1ID] != nil,
              warps[warp2ID] != nil,
              !checkLink(from: warp1ID, to: warp2ID) else { return false }
        warps[warp1ID]?.addLink(warp2ID)
        return true
    }
    
    mutating func removeSingleLink(from warp1ID: String, to warp2ID: String) {
        guard warps[warp1ID] != nil,
              warps[warp2ID] != nil,
              checkLink(from: warp1ID, to: warp2ID) else { return }
        warps[warp1ID]?.removeLink(warp2ID)
    }
    
    mutating func addDoubleLink(between warp1ID: String, and warp2ID: String) -> Bool {
        guard warps[warp1ID] != nil,
              warps[warp2ID] != nil,
              !checkLink(from: warp1ID, to: warp2ID),
              !checkLink(from: warp2ID, to: warp1ID) else { return false }
        warps[warp1ID]?.addLink(warp2ID)
        warps[warp2ID]?.addLink(warp1ID)
        return true
    }
    
    mutating func removeDoubleLink(between warp1ID: String, and warp2ID: String) {
        guard warps[warp1ID] != nil,
              warps[warp2ID] != nil,
              checkLink(from: warp1ID, to: warp2ID),
              checkLink(from: warp2ID, to: warp1ID) else { return }
        warps[warp1ID]?.removeLink(warp2ID)
        warps[warp2ID]?.removeLink(warp1ID)
    }
    
    // MARK: - Link Checking
    
    /// Checks if warp1 -> warp2 (single direction only)
    func checkLink(from warp1ID: String, to warp2ID: String) -> Bool {
        guard let warp1 = warps[warp1ID], warps[warp2ID] != nil else { return false }
        return warp1.neighbours.contains(warp2ID)
    }
    
    // MARK: - Pathfinding
    
    func findShortestPath(from startID: String, to endID: String) -> [String]? {
        guard warps[startID] != nil, warps[endID] != nil else { return nil }
        
        var queue: [(current: String, path: [String])] = [(startID, [startID])]
        var visited: Set<String> = []
        
        while !queue.isEmpty {
            let (current, path) = queue.removeFirst()
            
            if current == endID { return path }
            
            if !visited.contains(current) {
                visited.insert(current)
                if let neighbours = warps[current]?.neighbours {
                    for neighbour in neighbours where !visited.contains(neighbour) {
                        queue.append((neighbour, path + [neighbour]))
                    }
                }
            }
        }
        
        return nil
    }
    
    func getWarpIDs() -> Dictionary<String, Warp>.Keys {
        warps.keys
    }
    
    func printAllLinks() {
        print("\n-- PRINTING ALL WARPS AND LINKS --")
        for (id, warp) in warps {
            print("\(id): \(warp.neighbours)")
        }
    }
}

extension WarpGraph: Sequence {
    func makeIterator() -> Dictionary<String, Warp>.Values.Iterator {
        warps.values.makeIterator()
    }
}

extension WarpGraph {
    mutating func linkConditionals(_ dict: [String: [(String, Int)]]) {
        for (key, warpTuples) in dict {
            for (warpID, linkType) in warpTuples {
                if linkType == 1 {
                    addSingleLink(from: key, to: warpID)
                } else {
                    addDoubleLink(between: key, and: warpID)
                }
            }
        }
    }
}

extension WarpGraph {
    mutating func loadFromFiles() {
        
        // Reading in and adding all warps
        if let warpsURL = Bundle.main.url(forResource: "all_warps", withExtension: "txt"),
           let warpsContent = try? String(contentsOf: warpsURL) {
            let lines = warpsContent.components(separatedBy: .newlines).filter { !$0.isEmpty }
            for line in lines {
                let parts = line.components(separatedBy: ", ")
                if parts.count >= 2 {
                    addWarp(Warp(id: parts[0], location: parts[1]))
                }
            }
        }
        
        // Linking all grouped warps
        if let groupsURL = Bundle.main.url(forResource: "groups", withExtension: "txt"),
           let groupsContent = try? String(contentsOf: groupsURL) {
            let lines = groupsContent.components(separatedBy: .newlines)
            var items: [String] = []
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("--") {
                    if !items.isEmpty {
                        dblLinkGroup(&self, items)
                        items = []
                    }
                } else if !trimmed.isEmpty {
                    items.append(trimmed)
                }
            }
            if !items.isEmpty {
                dblLinkGroup(&self, items)
            }
        }
        
        // Reading in and linking all double links
        if let doubleLinksURL = Bundle.main.url(forResource: "all_double_links", withExtension: "txt"),
           let doubleLinksContent = try? String(contentsOf: doubleLinksURL) {
            let lines = doubleLinksContent.components(separatedBy: .newlines).filter { !$0.isEmpty }
            for line in lines {
                let parts = line.components(separatedBy: ", ")
                if parts.count >= 2 {
                    addDoubleLink(between: parts[0], and: parts[1])
                }
            }
        }
        
        // Reading in and linking all single links
        if let singleLinksURL = Bundle.main.url(forResource: "all_single_links", withExtension: "txt"),
           let singleLinksContent = try? String(contentsOf: singleLinksURL) {
            let lines = singleLinksContent.components(separatedBy: .newlines).filter { !$0.isEmpty }
            for line in lines {
                let parts = line.components(separatedBy: ", ")
                if parts.count >= 2 {
                    addSingleLink(from: parts[0], to: parts[1])
                }
            }
        }
    }
}

