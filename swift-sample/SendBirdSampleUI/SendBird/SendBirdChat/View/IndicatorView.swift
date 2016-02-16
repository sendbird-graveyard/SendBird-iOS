//
//  IndicatorView.swift
//  SendBirdSampleUI
//
//  Created by Jed Kyung on 2/3/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

import UIKit
import SendBirdSDK

class IndicatorView: UIView {
    
    var progressView: UIActivityIndicatorView?
    
    convenience init() {
        self.init(frame:CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        
        self.progressView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        self.progressView?.translatesAutoresizingMaskIntoConstraints = false
        self.progressView?.startAnimating()
        self.progressView?.color = UIColor.whiteColor()
        addSubview(self.progressView!)
        
        self.applyConstraints()
    }
    
    private func applyConstraints() {
        self.addConstraint(NSLayoutConstraint.init(item: self.progressView!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.progressView!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.progressView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 100))
        self.addConstraint(NSLayoutConstraint.init(item: self.progressView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 100))
    }
}
