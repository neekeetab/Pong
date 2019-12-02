//
//  Ball.swift
//  Pong
//
//  Created by Nikita Belousov on 27.10.2019.
//  Copyright © 2019 Nikita Belousov. All rights reserved.
//

import UIKit

struct Ball {
    
    let direction: Direction
    
    // axis range from 0 to 1 top to bottom, left to right
    let normalizedLocation: CGPoint
    
    static func initialRandomized() -> Ball {
        return Ball(direction: Direction(rawValue: arc4random() % 4) ?? .topLeft, normalizedLocation: CGPoint(x: 0.5, y: 0.5))
    }
    
}
