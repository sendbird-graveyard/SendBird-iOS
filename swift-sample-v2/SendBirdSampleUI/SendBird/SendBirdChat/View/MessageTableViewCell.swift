//
//  MessageTableViewCell.swift
//  SendBirdSampleUI
//
//  Created by Jed Kyung on 2/4/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

import UIKit
import SendBirdSDK

class MessageTableViewCell: UITableViewCell {
    let kMessageCellTopMargin: CGFloat = 4
    let kMessageCellBottomMargin: CGFloat = 4
    let kMessageCellLeftMargin: CGFloat = 15
    let kMessageCellRightMargin: CGFloat = 15
    let kMessageFontSize: CGFloat = 14.0

    var message: SendBirdMessage?
    var messageLabel: UILabel?

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

        self.messageLabel = UILabel()
        self.messageLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.messageLabel?.font = UIFont.systemFontOfSize(kMessageFontSize)
        self.messageLabel?.numberOfLines = 0
        self.messageLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
        
        self.contentView.addSubview(self.messageLabel!)

        
        // Message Label
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: kMessageCellTopMargin))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: kMessageCellLeftMargin))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -kMessageCellRightMargin))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: kMessageCellBottomMargin))
        
        // Content View
        self.addConstraint(NSLayoutConstraint.init(item: self.contentView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
    }
    
    func setModel(model: SendBirdMessage) {
        self.message = model;
        self.messageLabel?.attributedText = self.buildMessage()
    }
    
    func buildMessage() -> NSAttributedString {
        let nameAttribute = [NSFontAttributeName: UIFont.boldSystemFontOfSize(kMessageFontSize), NSForegroundColorAttributeName: SendBirdUtils.UIColorFromRGB(0x824096)]
        let messageAttribute = [NSFontAttributeName: UIFont.systemFontOfSize(kMessageFontSize), NSForegroundColorAttributeName: SendBirdUtils.UIColorFromRGB(0x595959)]
        let urlAttribute = [NSFontAttributeName: UIFont.systemFontOfSize(kMessageFontSize), NSForegroundColorAttributeName: SendBirdUtils.UIColorFromRGB(0x01579b)]
        var msg = String.init(format: "%@: %@", (self.message?.sender.name)!, (self.message?.message.stringByReplacingOccurrencesOfString(" ", withString: "\u{00A0}"))!)
        let url: String = SendBirdUtils.getUrlFromstring((self.message?.message)!)
        var urlRange: NSRange?
        if url.characters.count > 0 {
            urlRange = (msg as NSString).rangeOfString(url)
        }
        msg = msg.stringByReplacingOccurrencesOfString(" ", withString: "\u{00A0}")
        msg = msg.stringByReplacingOccurrencesOfString("-", withString: "\u{2011}")
        
        var badge: Int = 0
        if self.message?.isOpMessage == true {
            msg = String.init(format: "\u{00A0}\u{00A0}%@", msg)
            badge = 2
        }
        
        let attributedMessage: NSMutableAttributedString = NSMutableAttributedString.init(string: msg)
        let nameRange: NSRange = NSMakeRange(badge, (self.message?.sender.name.characters.count)!)
        let messageRange: NSRange = NSMakeRange(self.message!.sender.name.characters.count + badge, self.message!.message.characters.count + 2)
        
        if self.message?.isOpMessage == true {
            let textAttachment: NSTextAttachment = NSTextAttachment()
            textAttachment.image = UIImage.init(named: "_icon_admin")
            let attrStringWithImage: NSAttributedString = NSAttributedString.init(attachment: textAttachment)
            attributedMessage.replaceCharactersInRange(NSMakeRange(0, 1), withAttributedString: attrStringWithImage)
        }
        
        attributedMessage.beginEditing()
        attributedMessage.setAttributes(nameAttribute, range: nameRange)
        attributedMessage.setAttributes(messageAttribute, range: messageRange)
        if url.characters.count > 0 {
            attributedMessage.setAttributes(urlAttribute, range: urlRange!)
        }
        attributedMessage.endEditing()
        
        return attributedMessage
    }
    
    func getHeightOfViewCell(totalWidth: CGFloat) -> CGFloat {
        var messageWidth: CGFloat
        var messageRect: CGRect
        let attributedMessage: NSAttributedString = self.buildMessage()
        
        messageWidth = totalWidth - (kMessageCellLeftMargin + kMessageCellRightMargin)
        messageRect = attributedMessage.boundingRectWithSize(CGSizeMake(messageWidth, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        return messageRect.size.height + kMessageCellTopMargin + kMessageCellBottomMargin
    }
}
