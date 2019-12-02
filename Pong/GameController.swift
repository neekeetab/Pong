//
//  GameController.swift
//  Pong
//
//  Created by Nikita Belousov on 27.10.2019.
//  Copyright © 2019 Nikita Belousov. All rights reserved.
//

import UIKit
import ReactiveSwift

class GameController {
    
    enum State {
        case ready
        case inProgress
        case ended(winner: Player)
    }
    
    // read-only
    let state = MutableProperty<State>(.ready)
    // read-only
    let ball = MutableProperty<Ball>(.initialRandomized())
    
    // fraction of a dimension per second
    static let vX: CGFloat = 0.75
    static let vY: CGFloat = 1
    
    func startGame() {
        
        guard case .ready = state.value else {
            return
        }
        
        ball.value = .initialRandomized()
        state.value = .inProgress
        
        let displayLinkUntilGameOverProducer =
            SignalProducer.displayLink()
                .take(until:
                    self.state.signal
                        .filter {
                            switch $0 {
                            case .ended(winner: _):
                                return true
                            case _:
                                return false
                            }
                        }
                        .map { _ in () })
        
        let ys = SignalProducer.combineLatest(player1.y.producer, player2.y.producer)
        
        ball <~ ys.sample(with: displayLinkUntilGameOverProducer)
            .map { tuple, timeInterval in (tuple.0, tuple.1, timeInterval) }
            .map { [unowned ball] y1, y2, timeInterval -> Ball in
                
                // compute new ball position based on the current ball position, direction, y1, y2
                let ball = ball.value
                let delta = GameController.delta(for: ball.direction, timeInterval: timeInterval)
                var newBallLocation = ball.normalizedLocation + delta
                var newBallDirection = ball.direction
                
                // process bounces of the top and bottom walls
                if (newBallLocation.y < 0 || newBallLocation.y > 1) {
                    newBallDirection = ball.direction.mirroredAgainstX
                    newBallLocation = CGPoint(x: newBallLocation.x, y: round(newBallLocation.y))
                }
                
                // process bounces of rackets
                if (newBallLocation.x < 0) {
                    // if there's a collision with the left player, mirror the direction and update ball location
                    if ball.normalizedLocation.y > y1 - Player.length / 2 && ball.normalizedLocation.y < y1 + Player.length / 2 {
                        newBallDirection = ball.direction.mirroredAgainstY
                        newBallLocation = CGPoint(x: round(newBallLocation.x), y: newBallLocation.y)
                    }
                }
                if (newBallLocation.x > 1) {
                    // if there's a collision with the right player, mirror the direction and update ball location
                    if ball.normalizedLocation.y > y2 - Player.length / 2 && ball.normalizedLocation.y < y2 + Player.length / 2 {
                        newBallDirection = ball.direction.mirroredAgainstY
                        newBallLocation = CGPoint(x: round(newBallLocation.x), y: newBallLocation.y)
                    }
                }
                
                return Ball(direction: newBallDirection, normalizedLocation: newBallLocation)
                
            }
            .on(value: { [unowned self] in
                // end the game if the ball is off-screen
                if $0.normalizedLocation.x < 0 {
                    self.state.value = .ended(winner: self.player2)
                } else if $0.normalizedLocation.x > 1 {
                    self.state.value = .ended(winner: self.player1)
                }
            })
        
    }
    
    static private func delta(for direction: Direction, timeInterval: TimeInterval) -> CGPoint {
        
        let timeInterval = CGFloat(timeInterval)
        
        switch direction {
        case .bottomLeft:
            return .init(x: -vX * timeInterval, y: vY * timeInterval)
        case .bottomRight:
            return .init(x: vX * timeInterval, y: vY * timeInterval)
        case .topLeft:
            return .init(x: -vX * timeInterval, y: -vY * timeInterval)
        case .topRight:
            return .init(x: vX * timeInterval, y: -vY * timeInterval)
        }
        
    }
    
    private let player1: Player
    private let player2: Player
    
    init(player1: Player, player2: Player) {
        self.player1 = player1
        self.player2 = player2
    }
    
}

fileprivate func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
