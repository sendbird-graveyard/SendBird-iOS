//
//  CustomButton.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/3/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 0.0
    
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = self.cornerRadius
        self.layer.masksToBounds = true
    }
}
