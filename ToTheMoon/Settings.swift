//
//  Settings.swift
//  ToTheMoon
//
//  Created by Robert Pelka on 28/04/2021.
//

import SpriteKit

enum PhysicsCategories {
    static let none: UInt32 = 0
    static let ballCategory: UInt32 = 0x1
    static let platformCategory: UInt32 = 0x1 << 1
}
