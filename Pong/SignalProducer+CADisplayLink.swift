//
//  SignalProducer+CADisplayLink.swift
//  Pong
//
//  Created by Nikita Belousov on 27.10.2019.
//  Copyright © 2019 Nikita Belousov. All rights reserved.
//

import ReactiveSwift
import ReactiveCocoa

class DisplayLinkProxy: NSObject {
    
    private let observer: Signal<TimeInterval, Never>.Observer
    
    init(observer: Signal<TimeInterval, Never>.Observer) {
        self.observer = observer
    }
    
    func keepInMemory() {}
    
    @objc func step(displayLink: CADisplayLink) {
        observer.send(value: displayLink.duration)
    }
    
}

extension SignalProducer where Value == TimeInterval, Error == Never {
    
    static func displayLink() -> SignalProducer<TimeInterval, Never> {
        
        return SignalProducer<TimeInterval, Never>() { observer, lifetime in
            
            let proxy = DisplayLinkProxy(observer: observer)
            let displayLink = CADisplayLink(target: proxy, selector: #selector(DisplayLinkProxy.step(displayLink:)))
            displayLink.add(to: .main, forMode: .default)
            
            lifetime += AnyDisposable {
                proxy.keepInMemory()
            }
            
            lifetime.observeEnded {
                displayLink.invalidate()
            }
            
        }
        
    }
    
}
