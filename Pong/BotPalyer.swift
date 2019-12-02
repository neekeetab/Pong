//
//  BotPalyer.swift
//  Pong
//
//  Created by Nikita Belousov on 27.10.2019.
//  Copyright © 2019 Nikita Belousov. All rights reserved.
//

import ReactiveSwift

class BotPlayer: Player {
    
    // property to bind to
    let ball = MutableProperty<Ball?>(nil)
    
    // property to bind to
    let isBotEnabled = MutableProperty(false)
    
    override init() {
        super.init()
        y <~ ball
            .producer
            .skipNil()
            .combineLatest(with: isBotEnabled.producer)
            .filterMap { $0.1 ? $0.0 : nil }
            .map { max(min($0.normalizedLocation.y, 1), 0) }
    }
    
}
