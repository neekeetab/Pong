//
//  Direction.swift
//  Pong
//
//  Created by Nikita Belousov on 27.10.2019.
//  Copyright © 2019 Nikita Belousov. All rights reserved.
//

import Foundation

enum Direction: UInt32 {
    
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    
    var mirroredAgainstX: Direction {
        switch self {
        case .bottomLeft:
            return .topLeft
        case .bottomRight:
            return .topRight
        case .topLeft:
            return .bottomLeft
        case .topRight:
            return .bottomRight
        }
    }
    
    var mirroredAgainstY: Direction {
        switch self {
        case .bottomLeft:
            return .bottomRight
        case .bottomRight:
            return .bottomLeft
        case .topLeft:
            return .topRight
        case .topRight:
            return .topLeft
        }
    }
    
}
