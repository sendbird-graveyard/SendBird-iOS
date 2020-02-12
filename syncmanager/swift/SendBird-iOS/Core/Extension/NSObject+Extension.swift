//
//  NSObject+Extension.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2019/11/29.
//  Copyright © 2019 SendBird. All rights reserved.
//

import Foundation

extension NSObject {
    static var className: String {
        guard let className = String(describing: self).components(separatedBy: ".").last else {
            print(String(describing: self))
            fatalError("Class name couldn't find.")
        }
        return className
    }
    
    var className: String {
        guard let className = String(describing: self)
            .components(separatedBy: ":").first?
            .components(separatedBy: ".").last else {
                print(String(describing: self))
                fatalError("Class name couldn't find.")
        }
        return className
    }
}
