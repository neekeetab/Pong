//
//  Player.swift
//  Pong
//
//  Created by Nikita Belousov on 27.10.2019.
//  Copyright © 2019 Nikita Belousov. All rights reserved.
//

import ReactiveSwift

class Player {
    
    // from 0 to 1
    static let defaultYPosition: CGFloat = 0.5
    
    // form 0 to 1
    static let length: CGFloat = 0.3
    
    // from 0 to 1
    let y = MutableProperty<CGFloat>(Player.defaultYPosition);
    
    func moveRacket(dy: CGFloat) {
        y.value = max(min(y.value + dy, 1), 0)
    }
    
}
