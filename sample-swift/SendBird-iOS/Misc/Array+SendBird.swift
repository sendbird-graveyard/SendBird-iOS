//
//  Array+SendBird.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/24/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import Foundation

extension Array where Element : Equatable  {
    public mutating func removeObject(_ item: Element) {
        if let index = self.firstIndex(of: item) {
            self.remove(at: index)
        }
    }
}
