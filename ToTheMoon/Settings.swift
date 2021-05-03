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
    static let strapOfDollarsCategory: UInt32 = 0x1 << 2
}

enum ZPositions {
    static let background: CGFloat = -1
    static let platform: CGFloat = 0
    static let ball: CGFloat = 1
    static let dollar: CGFloat = 2
    static let scoreLabel: CGFloat = 2
    static let logo: CGFloat = 2
    static let playButton: CGFloat = 2
}
