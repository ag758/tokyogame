//
//  SaveDataManager.swift
//  tokyogame
//
//  Created by Antigravity on 10/11/26.
//

import Foundation
import CoreGraphics

/// Model representing a saved game state.
struct SaveSlotData: Codable {
    let slotId: Int
    let playerX: Double
    let playerY: Double
    let districtName: String
    let savedDate: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: savedDate)
    }
    
    var playerPosition: CGPoint {
        return CGPoint(x: playerX, y: playerY)
    }
}

/// Manages persistent saving and loading across slots using UserDefaults.
class SaveDataManager {
    
    static let shared = SaveDataManager()
    static let maxSlots = 3
    
    private let userDefaultsKeyPrefix = "tokyogame_save_slot_"
    
    private init() {}
    
    /// Saves player position and district to the specified slot (1-indexed).
    func saveGame(slotId: Int, playerPosition: CGPoint, districtName: String = "Shibuya Crossing") -> Bool {
        guard slotId >= 1 && slotId <= SaveDataManager.maxSlots else { return false }
        
        let slotData = SaveSlotData(
            slotId: slotId,
            playerX: Double(playerPosition.x),
            playerY: Double(playerPosition.y),
            districtName: districtName,
            savedDate: Date()
        )
        
        do {
            let encoded = try JSONEncoder().encode(slotData)
            UserDefaults.standard.set(encoded, forKey: "\(userDefaultsKeyPrefix)\(slotId)")
            UserDefaults.standard.synchronize()
            return true
        } catch {
            print("Failed to encode save data: \(error)")
            return false
        }
    }
    
    /// Loads saved game data for the specified slot.
    func loadGame(slotId: Int) -> SaveSlotData? {
        guard slotId >= 1 && slotId <= SaveDataManager.maxSlots else { return nil }
        guard let data = UserDefaults.standard.data(forKey: "\(userDefaultsKeyPrefix)\(slotId)") else {
            return nil
        }
        
        do {
            let slotData = try JSONDecoder().decode(SaveSlotData.self, from: data)
            return slotData
        } catch {
            print("Failed to decode save data: \(error)")
            return nil
        }
    }
    
    /// Deletes the specified save slot.
    func deleteSave(slotId: Int) {
        UserDefaults.standard.removeObject(forKey: "\(userDefaultsKeyPrefix)\(slotId)")
        UserDefaults.standard.synchronize()
    }
    
    /// Returns all save slots (array of 3 elements, nil if slot is empty).
    func getAllSlots() -> [SaveSlotData?] {
        return (1...SaveDataManager.maxSlots).map { loadGame(slotId: $0) }
    }
    
    /// Returns true if at least one save slot exists.
    var hasAnySave: Bool {
        return getAllSlots().contains { $0 != nil }
    }
}
