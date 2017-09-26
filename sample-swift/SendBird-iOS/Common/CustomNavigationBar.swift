//
//  CustomNavigationBar.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 9/25/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

import UIKit

class CustomNavigationBar: UINavigationBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if #available(iOS 11.0, *) {
            for subview in self.subviews {
                let stringFromClass = NSStringFromClass(subview.classForCoder)
                if stringFromClass.contains("BarBackground") {
                    subview.frame = self.bounds
                }
                else if stringFromClass.contains("BarContentView") {
                    subview.frame = CGRect(x: subview.frame.origin.x, y: 24, width: subview.frame.size.width, height: self.bounds.size.height - 24)
                }
            }
        }
    }
}
