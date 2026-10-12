//
//  PhysicsCategory.swift
//  tokyogame
//
//  Created by Antigravity on 10/11/26.
//

import Foundation

/// Physics bitmasks for 2.5D collisions and triggers in Tokyo.
struct PhysicsCategory {
    static let none: UInt32          = 0
    static let player: UInt32        = 1 << 0  // 1
    static let building: UInt32      = 1 << 1  // 2
    static let obstacle: UInt32      = 1 << 2  // 4
    static let worldBoundary: UInt32  = 1 << 3  // 8
    static let triggerZone: UInt32   = 1 << 4  // 16
    static let npc: UInt32           = 1 << 5  // 32
    static let collectible: UInt32   = 1 << 6  // 64
    static let vehicle: UInt32       = 1 << 7  // 128
}
