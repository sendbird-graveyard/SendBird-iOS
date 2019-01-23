//
//  CustomTextField.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/3/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    @IBInspectable var bottomBorderColor: UIColor = UIColor.darkText
    @IBInspectable var bottomBorderWidth: CGFloat = 0.0
    
    private var shapeLayer: CAShapeLayer? = nil
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.borderStyle = UITextField.BorderStyle.none
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: self.frame.size.height - (self.bottomBorderWidth / 2)))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height - (self.bottomBorderWidth / 2)))
        
        if self.shapeLayer != nil {
            self.shapeLayer!.removeFromSuperlayer()
            self.shapeLayer = nil
        }
        
        self.shapeLayer = CAShapeLayer()
        self.shapeLayer!.path = path.cgPath
        self.shapeLayer!.lineWidth = self.bottomBorderWidth
        self.shapeLayer!.strokeColor = self.bottomBorderColor.cgColor
        self.shapeLayer!.fillColor = self.bottomBorderColor.cgColor
        
        self.layer.addSublayer(self.shapeLayer!)
    }
}
