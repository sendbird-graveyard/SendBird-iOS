//
//  TypingNowView.swift
//  SendBirdSampleUI
//
//  Created by Jed Kyung on 2/7/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

import UIKit
import SendBirdSDK

class TypingNowView: UIView {
    var typingImageView: UIImageView?
    var typingLabel: UILabel?

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
        self.backgroundColor = UIColor.whiteColor()
        
        self.typingImageView = UIImageView()
        self.typingImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.typingImageView?.animationImages = [UIImage.init(named: "_icon_loading_typing0")!,
            UIImage.init(named: "_icon_loading_typing1")!,
            UIImage.init(named: "_icon_loading_typing2")!,
            UIImage.init(named: "_icon_loading_typing3")!,
            UIImage.init(named: "_icon_loading_typing4")!,
            UIImage.init(named: "_icon_loading_typing5")!,
            UIImage.init(named: "_icon_loading_typing6")!,
        ]
        self.typingImageView?.animationDuration = 1.0
        self.typingImageView?.animationRepeatCount = 0
        self.typingImageView?.startAnimating()
        self.addSubview(self.typingImageView!)
        
        self.typingLabel = UILabel()
        self.typingLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.typingLabel?.font = UIFont.italicSystemFontOfSize(12.0)
        self.typingLabel?.numberOfLines = 0
        self.typingLabel?.textColor = SendBirdUtils.UIColorFromRGB(0x9d9ba5)
        self.typingLabel?.text = "Typing something cool..."
        self.typingLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
        self.addSubview(self.typingLabel!)
        
        // Typing Image View
        self.addConstraint(NSLayoutConstraint.init(item: self.typingImageView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 10))
        self.addConstraint(NSLayoutConstraint.init(item: self.typingImageView!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.typingLabel!, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.typingImageView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.typingLabel!, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: -10))
        self.addConstraint(NSLayoutConstraint.init(item: self.typingImageView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 18.5))
        self.addConstraint(NSLayoutConstraint.init(item: self.typingImageView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 5))
        
        // Typing Label
        self.addConstraint(NSLayoutConstraint.init(item: self.typingLabel!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -8))
        self.addConstraint(NSLayoutConstraint.init(item: self.typingLabel!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 10))
    }
    
    func setModel(typeStatus: NSDictionary) {
        let count: Int = typeStatus.count
        self.typingLabel?.text = String.init(format: "%d Typing something cool...", count)
    }
}
