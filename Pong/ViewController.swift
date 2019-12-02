//
//  ViewController.swift
//  Pong
//
//  Created by Nikita Belousov on 23.10.2019.
//  Copyright © 2019 Nikita Belousov. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class ViewController: UIViewController {

    @IBOutlet weak var ballView: UIView!
    @IBOutlet weak var fieldView: UIView!
    @IBOutlet weak var leftRacketView: UIView!
    @IBOutlet weak var leftRacketViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftRacketViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightRacketView: UIView!
    @IBOutlet weak var rightRacketViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightRacketViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet var leftPanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var rightPanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var leftBotSwitch: UISwitch!
    @IBOutlet weak var rightBotSwitch: UISwitch!
    @IBOutlet weak var leftCounterLabel: UILabel!
    @IBOutlet weak var rightCounterLabel: UILabel!
    
    private let player1 = BotPlayer()
    private let player2 = BotPlayer()
    private let leftCounter = MutableProperty(0)
    private let rightCounter = MutableProperty(0)
    private let ball = MutableProperty<Ball>(.initialRandomized())
    
    private var isFirstLayout = true

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard isFirstLayout else {
            return
        }
        isFirstLayout = false
        setupUI()
    }
    
    private func setupUI() {
        player1.isBotEnabled <~ leftBotSwitch.reactive.isOnValues
        player2.isBotEnabled <~ rightBotSwitch.reactive.isOnValues
        leftPanGestureRecognizer.reactive.isEnabled <~ player1.isBotEnabled.negate()
        rightPanGestureRecognizer.reactive.isEnabled <~ player2.isBotEnabled.negate()
        leftCounterLabel.reactive.text <~ leftCounter.map { String($0) }
        rightCounterLabel.reactive.text <~ rightCounter.map { String($0) }
        let racketViewHeight = fieldView.bounds.height * Player.length
        leftRacketViewHeightConstraint.constant = racketViewHeight
        rightRacketViewHeightConstraint.constant = racketViewHeight
        let fieldViewHeight = fieldView.bounds.size.height
        let fieldViewWidth = fieldView.bounds.size.width
        ballView.reactive.center <~ ball
            .map { CGPoint(x: $0.normalizedLocation.x * fieldViewWidth, y: $0.normalizedLocation.y * fieldViewHeight) }
        leftRacketViewCenterYConstraint.reactive.constant <~ player1.y
            .map { -fieldViewHeight / 2 + $0 * fieldViewHeight }
        rightRacketViewCenterYConstraint.reactive.constant <~ player2.y
            .map { -fieldViewHeight / 2 + $0 * fieldViewHeight }
    }

    private var gameController: GameController!
    
    @IBAction func fieldViewHandleTap(_ sender: Any) {
        
        // initialize new game controller
        gameController = GameController(player1: player1, player2: player2)
        
        ball <~ gameController.ball
        
        // a bot needs to know where the ball is
        player1.ball <~ gameController.ball
        player2.ball <~ gameController.ball
        
        // update counters when the game ends
        let leftCounterValue = leftCounter.value
        leftCounter <~ gameController.state.producer
            .map { [unowned self] in
                switch $0 {
                case .ended(winner: let winner):
                    return winner === self.player1 ? leftCounterValue + 1 : leftCounterValue
                case _:
                    return leftCounterValue
                }
            }
        let rightCounterValue = rightCounter.value
        rightCounter <~ gameController.state.producer
            .map { [unowned self] in
                switch $0 {
                case .ended(winner: let winner):
                    return winner === self.player2 ? rightCounterValue + 1 : rightCounterValue
                case _:
                    return rightCounterValue
                }
        }

        gameController.startGame()
        
    }
    
    @IBAction func panGestureRecognizerEvent(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let dy = panGestureRecognizer.translation(in: view).y / fieldView.bounds.size.height
        (panGestureRecognizer == leftPanGestureRecognizer ? player1 : player2).moveRacket(dy: dy)
        panGestureRecognizer.setTranslation(.zero, in: view)
    }
    
}

fileprivate extension Reactive where Base: UIView {
    
    /// Sets the `center` value of the view.
    var center: BindingTarget<CGPoint> {
        return makeBindingTarget { $0.center = $1 }
    }
    
}

fileprivate extension Reactive where Base: UIPanGestureRecognizer {
    
    /// Sets `isEnabled` property of the pan gesture recognizer
    var isEnabled: BindingTarget<Bool> {
        return makeBindingTarget { $0.isEnabled = $1 }
    }
    
}
