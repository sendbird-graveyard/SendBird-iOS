//
//  Throttler.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2020/01/07.
//  Copyright © 2020 SendBird. All rights reserved.
//
 
import UIKit 
 
// Romove Throttler
public class Throttler {
    
    private let queue: DispatchQueue = DispatchQueue.global(qos: .background)
    
    private var job: DispatchWorkItem = DispatchWorkItem(block: {})
    private var previousRun: Date = Date.distantPast
    private var maxInterval: Int
    
    init(seconds: Int) {
        self.maxInterval = seconds
    }
    
    
    func throttle(block: @escaping () -> ()) {
        job.cancel()
        job = DispatchWorkItem(){ [weak self] in
            self?.previousRun = Date()
            block()
        }
        let delay = Date.second(from: previousRun) > maxInterval ? 0 : maxInterval
        queue.asyncAfter(deadline: .now() + Double(delay), execute: job)
    }
}
 
private extension Date {
    static func second(from referenceDate: Date) -> Int {
        return Int(Date().timeIntervalSince(referenceDate).rounded())
    }
}
