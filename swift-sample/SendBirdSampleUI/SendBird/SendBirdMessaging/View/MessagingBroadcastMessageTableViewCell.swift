//
//  MessagingBroadcastMessageTableViewCell.swift
//  SendBirdSampleUI
//
//  Created by Jed Kyung on 2/7/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

import UIKit
import SendBirdSDK

class MessagingBroadcastMessageTableViewCell: UITableViewCell {
    let kBroadcastMessageCellTopMargin: CGFloat = 6
    let kBroadcastMessageCellBottomMargin: CGFloat = 6
    let kBroadcastMessageCellLeftMargin: CGFloat = 15
    let kBroadcastMessageCellRightMargin: CGFloat = 15
    let kBroadcastMessageCellTopPadding: CGFloat = 8
    let kBroadcastMessageCellBottomPadding: CGFloat = 8
    let kBroadcastMessageCellLeftPadding: CGFloat = 8
    let kBroadcastMessageCellRightPadding: CGFloat = 8
    let kBroadcastMessageFontSize: CGFloat = 14.0
    
    var message: SendBirdBroadcastMessage?
    var messageLabel: UILabel?
    var innerView: UIView?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.backgroundColor = UIColor.clearColor()
        self.backgroundColor = UIColor.clearColor()
        
        self.innerView = UIView()
        self.innerView?.translatesAutoresizingMaskIntoConstraints = false
        self.innerView?.backgroundColor = SendBirdUtils.UIColorFromRGB(0xe3e3e3)
        
        self.messageLabel = UILabel()
        self.messageLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.messageLabel?.font = UIFont.systemFontOfSize(kBroadcastMessageFontSize)
        self.messageLabel?.numberOfLines = 0
        self.messageLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
        
        self.contentView.addSubview(self.innerView!)
        self.contentView.addSubview(self.messageLabel!)
        
        self.addConstraint(NSLayoutConstraint.init(item: self.contentView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.contentView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        
        // Inner View
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.innerView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: kBroadcastMessageCellTopMargin))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.innerView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: kBroadcastMessageCellLeftMargin))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.innerView!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: kBroadcastMessageCellRightMargin))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.innerView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -kBroadcastMessageCellBottomMargin))
        
        // Message Label
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.innerView!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: kBroadcastMessageCellTopPadding))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.innerView!, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: kBroadcastMessageCellLeftPadding))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.innerView!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -kBroadcastMessageCellRightPadding))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.innerView!, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -kBroadcastMessageCellBottomPadding))
    }
    
    func setModel(message: SendBirdBroadcastMessage) {
        self.message = message
        self.messageLabel?.attributedText = self.buildMessage()
    }
    
    private func buildMessage() -> NSAttributedString {
        let messageAttribute = [NSFontAttributeName: UIFont.boldSystemFontOfSize(kBroadcastMessageFontSize), NSForegroundColorAttributeName: SendBirdUtils.UIColorFromRGB(0x747284)]
        
        var message: String = (self.message?.message)!
        message = message.stringByReplacingOccurrencesOfString(" ", withString: "\u{00A0}")
        message = message.stringByReplacingOccurrencesOfString("-", withString: "\u{2011}")
        
        let attributedMessage: NSMutableAttributedString = NSMutableAttributedString.init(string: message)
        let messageRange: NSRange = NSMakeRange(0, self.message!.message.characters.count)
        
        attributedMessage.beginEditing()
        attributedMessage.setAttributes(messageAttribute, range: messageRange)
        attributedMessage.endEditing()
        
        return attributedMessage
    }
    
    func getHeightOfViewCell(totalWidth: CGFloat) -> CGFloat {
        var messageWidth: CGFloat
        var messageRect: CGRect
        let attributedMessage: NSAttributedString = self.buildMessage()
        
        messageWidth = totalWidth - (kBroadcastMessageCellLeftMargin + kBroadcastMessageCellRightMargin + kBroadcastMessageCellLeftPadding + kBroadcastMessageCellRightPadding)
        messageRect = attributedMessage.boundingRectWithSize(CGSizeMake(messageWidth, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        return messageRect.size.height + kBroadcastMessageCellTopMargin + kBroadcastMessageCellBottomMargin + kBroadcastMessageCellTopPadding + kBroadcastMessageCellBottomPadding
    }
}
