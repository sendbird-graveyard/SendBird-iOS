//
//  CustomProgressCircle.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/18/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit

class CustomProgressCircle: UIView {
    private var circleLayer: CAShapeLayer?
    private var progress: CGFloat?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.progress = 0.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.progress = 0.5
    }

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.backgroundColor = UIColor.clear
        let circlePath = UIBezierPath()
        let startAngle = -(CGFloat.pi / 2)
        let endAngle = 2 * CGFloat.pi * self.progress! + startAngle
        circlePath.addArc(withCenter: CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0), radius: (self.frame.size.width - 4) / 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        // Set the render colors.
        UIColor.clear.setFill()
        UIColor(named: "color_general_file_message_transfer_progress_text", in: nil, compatibleWith: nil)?.setStroke()
        
        if let aRef = UIGraphicsGetCurrentContext() {
            // If you have content to draw after the shape,
            // save the current state before changing the transform.
            //CGContextSaveGState(aRef);
            
            // Adjust the view's origin temporarily. The oval is
            // now drawn relative to the new origin point.
            aRef.saveGState()
            aRef.translateBy(x: 0, y: 0)
            
            // Adjust the drawing options as needed.
            circlePath.lineWidth = 2
            
            // Fill the path before stroking it so that the fill
            // color does not obscure the stroked line.
            circlePath.fill()
            circlePath.stroke()
            
            // Restore the graphics state before drawing any other content.
            //CGContextRestoreGState(aRef);
        }
    }

    func drawCircle(progress: CGFloat) {
        self.progress = progress
        self.setNeedsDisplay()
    }
}
