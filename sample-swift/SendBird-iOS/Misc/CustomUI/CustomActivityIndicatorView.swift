//
//  CustomActivityIndicatorView.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/12/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import QuartzCore

class CustomActivityIndicatorView: UIActivityIndicatorView {
    var image: UIImage?
    var imageView: UIImageView?
    
    var backgroundImage: UIImage?
    var backgroundImageView: UIImageView?
    
    var animation: CABasicAnimation?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self._init()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self._init()
    }
    
    override init(style: UIActivityIndicatorView.Style) {
        super.init(style: .whiteLarge)
        self._init()
    }
    
    func _init() {
        self.animation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        
        self.animation?.fromValue = NSNumber(value: 0.0)
        self.animation?.toValue = NSNumber(value: 2 * Double.pi)
        self.animation?.duration = 1.0
        self.animation?.repeatCount = HUGE
        
        if self.frame.size.width == 0 {
            return
        }
        
        self.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
        
        self.imageView?.removeFromSuperview()
        self.imageView = nil
        
        self.backgroundImageView?.removeFromSuperview()
        self.backgroundImageView = nil
        
        if self.subviews.count > 0 {
            self.subviews[0].isHidden = true
        }
        
        self.image = UIImage.init(named: "img_loading_indicator")
        self.imageView = UIImageView.init(image: self.image)
        
        self.backgroundImage = UIImage.init(named: "img_loading_indicator_background")
        self.backgroundImageView = UIImageView.init(image: self.backgroundImage)
        
        if self.hidesWhenStopped && !self.isAnimating {
            self.imageView?.isHidden = true
            self.backgroundImageView?.isHidden = true
        }
        
        self.addSubview(self.backgroundImageView!)
        self.addSubview(self.imageView!)
        
        if self.imageView?.layer.animation(forKey: "animation") != nil {
            self.imageView?.layer.add(self.animation!, forKey: "animation")
        }
        
        let height = UIScreen.main.bounds.size.height
        let width = UIScreen.main.bounds.size.width
        self.imageView?.frame = CGRect(origin: CGPoint(x: (width - (self.imageView?.frame.size.width)!) / 2, y: (height - (self.imageView?.frame.size.height)!) / 2), size: (self.imageView?.frame.size)!)
        self.backgroundImageView?.frame = CGRect(origin: CGPoint(x: (width - (self.backgroundImageView?.frame.size.width)!) / 2, y: (height - (self.backgroundImageView?.frame.size.height)!) / 2), size: (self.backgroundImageView?.frame.size)!)
    }
    
    override var hidesWhenStopped: Bool {
        get {
            return super.hidesWhenStopped
        }
        set {
            super.hidesWhenStopped = newValue
            
            if self.hidesWhenStopped && self.isAnimating == false {
                self.imageView?.isHidden = true
                self.backgroundImageView?.isHidden = true
            }
            else {
                self.imageView?.isHidden = false
                self.backgroundImageView?.isHidden = false
            }
        }
    }
    
    override func startAnimating() {
        super.startAnimating()
        
        self.imageView?.isHidden = false
        self.backgroundImageView?.isHidden = false
        
        self.imageView?.layer.add(self.animation!, forKey: "animation")
    }
    
    override func stopAnimating() {
        super.stopAnimating()
        
        if self.hidesWhenStopped == true {
            self.imageView?.isHidden = true
            self.backgroundImageView?.isHidden = true
        }
        
        self.imageView?.layer.removeAllAnimations()
    }
}
