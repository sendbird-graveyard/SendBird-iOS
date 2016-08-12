//
//  MessagingSystemMessageTableViewCell.swift
//  SendBirdSampleUI
//
//  Created by Jed Kyung on 2/7/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

import UIKit
import SendBirdSDK

class MessagingSystemMessageTableViewCell: UITableViewCell {
    let kSystemMessageCellLeftMargin: CGFloat = 16
    let kSystemMessageCellRightMargin: CGFloat = 16
    let kSystemMessageCellGapMargin: CGFloat = 10
    
    var leftLineView: UIView?
    var rightLineView: UIView?
    var messageLabel: UILabel?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        self.backgroundColor = UIColor.clearColor()
        
        self.leftLineView = UIView()
        self.leftLineView?.translatesAutoresizingMaskIntoConstraints = false
        self.leftLineView?.backgroundColor = SendBirdUtils.UIColorFromRGB(0xa6b0ba)
        
        self.rightLineView = UIView()
        self.rightLineView?.translatesAutoresizingMaskIntoConstraints = false
        self.rightLineView?.backgroundColor = SendBirdUtils.UIColorFromRGB(0xa6b0ba)
        
        self.messageLabel = UILabel()
        self.messageLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.messageLabel?.textColor = SendBirdUtils.UIColorFromRGB(0xa6b0ba)
        self.messageLabel?.font = UIFont.systemFontOfSize(11.0)
        self.messageLabel?.sizeToFit()
        
        self.addSubview(self.leftLineView!)
        self.addSubview(self.rightLineView!)
        self.addSubview(self.messageLabel!)
        
        self.applyConstraints()
    }

    private func applyConstraints() {
        self.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.leftLineView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: kSystemMessageCellLeftMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.leftLineView!, attribute: NSLayoutAttribute.Trailing, relatedBy: .Equal, toItem: self.messageLabel!, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: -kSystemMessageCellGapMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.leftLineView!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.leftLineView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 0.5))
        
        self.addConstraint(NSLayoutConstraint.init(item: self.rightLineView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -kSystemMessageCellRightMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.rightLineView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.messageLabel!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: kSystemMessageCellGapMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.rightLineView!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.rightLineView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 0.5))
    }
    
    func setModel(model: SendBirdSystemMessage) {
        var s: NSString = NSString.init(string: model.message)
        
        while s.rangeOfString("<[^>]+>", options: NSStringCompareOptions.RegularExpressionSearch).location != NSNotFound {
            let r: NSRange = s.rangeOfString("<[^>]+>", options: NSStringCompareOptions.RegularExpressionSearch)
            s = s.stringByReplacingCharactersInRange(r, withString: "")
        }
        
        self.messageLabel?.text = s as String
    }
}
