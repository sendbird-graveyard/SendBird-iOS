//
//  MessagingMyMessageTableViewCell.swift
//  SendBirdSampleUI
//
//  Created by Jed Kyung on 2/7/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

import UIKit
import SendBirdSDK

class MessagingMyMessageTableViewCell: UITableViewCell {
    let kMyMessageCellTopMargin: CGFloat = 14
    let kMyMessageCellBottomMargin: CGFloat = 0
    let kMyMessageCellLeftMargin: CGFloat = 12
    let kMyMessageBalloonRightMargin: CGFloat = 12
    let kMyMessageCellRightMargin: CGFloat = 32
    let kMyMessageFontSize: CGFloat = 14.0
    let kMyMessageBalloonTopPadding: CGFloat = 12
    let kMyMessageBalloonBottomPadding: CGFloat = 12
    let kMyMessageBalloonLeftPadding: CGFloat = 12
    let kMyMessageBalloonRightPadding: CGFloat = 12
    let kMyMessageMaxWidth: CGFloat = 168
    let kMyMessageDateTimeRightMarign: CGFloat = 4
    let kMyMessageDateTimeFontSize: CGFloat = 10.0
    let kMyMessageUnreadFontSize: CGFloat = 10.0
    
    var message: SendBirdMessage?
    var messageBackgroundImageView: UIImageView?
    var messageLabel: UILabel?
    var dateTimeLabel: UILabel?
    var unreadLabel: UILabel?
    var readStatus: NSMutableDictionary?
    
    private var topMargin: CGFloat?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.topMargin = kMyMessageCellTopMargin
        self.initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        self.backgroundColor = UIColor.clearColor()
        
        self.messageBackgroundImageView = UIImageView()
        self.messageBackgroundImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.messageBackgroundImageView?.image = UIImage.init(named: "_bg_chat_bubble_purple")
        self.addSubview(self.messageBackgroundImageView!)
        
        self.messageLabel = UILabel()
        self.messageLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.messageLabel?.font = UIFont.systemFontOfSize(14.0)
        self.messageLabel?.numberOfLines = 0
        self.messageLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
        self.addSubview(self.messageLabel!)
        
        self.dateTimeLabel = UILabel()
        self.dateTimeLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.dateTimeLabel?.numberOfLines = 1
        self.dateTimeLabel?.textColor = SendBirdUtils.UIColorFromRGB(0xacaab2)
        self.dateTimeLabel?.font = UIFont.systemFontOfSize(kMyMessageDateTimeFontSize)
        self.dateTimeLabel?.text = "11:24 PM"
        self.addSubview(self.dateTimeLabel!)
        
        self.unreadLabel = UILabel()
        self.unreadLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.unreadLabel?.numberOfLines = 1
        self.unreadLabel?.textColor = SendBirdUtils.UIColorFromRGB(0xac90ff)
        self.unreadLabel?.font = UIFont.systemFontOfSize(kMyMessageUnreadFontSize)
        self.unreadLabel?.text = "Unread"
        self.unreadLabel?.hidden = true
        self.addSubview(self.unreadLabel!)
        
        // Message Label
        self.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -kMyMessageBalloonBottomPadding))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -kMyMessageCellRightMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kMyMessageMaxWidth))
        
        // Message Background Image View
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -kMyMessageCellBottomMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.messageLabel!, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: -kMyMessageBalloonLeftPadding))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -kMyMessageBalloonRightMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.messageLabel!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: -kMyMessageBalloonTopPadding))
        
        // DateTime Label
        self.addConstraint(NSLayoutConstraint.init(item: self.dateTimeLabel!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.dateTimeLabel!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: -kMyMessageDateTimeRightMarign))
        
        // Unread Label
        self.addConstraint(NSLayoutConstraint.init(item: self.unreadLabel!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.dateTimeLabel!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.unreadLabel!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: -kMyMessageDateTimeRightMarign))
    }

    func setContinuousMessage(continuousFlag: Bool) {
        if continuousFlag {
            self.topMargin = 4.0
        }
        else {
            self.topMargin = kMyMessageCellTopMargin
        }
    }
    
    func setModel(message: SendBirdMessage) {
        self.message = message
        self.messageLabel?.attributedText = self.buildMessage()
        let ts: Int64 = (self.message?.getMessageTimestamp())! / 1000
        self.dateTimeLabel?.text = SendBirdUtils.messageDateTime(NSTimeInterval(ts))
        self.unreadLabel?.hidden = true
        
        var unreadCount: Int = 0
        if self.readStatus != nil {
            for item in self.readStatus! {
                if item.key as? String != SendBird.getUserId() {
                    let readTime: Int64 = (item.value as! NSNumber).longLongValue 
                    if ts <= readTime {
                        
                    }
                    else {
                        unreadCount = unreadCount + 1
                    }
                }
            }
        }
        
        if unreadCount == 0 {
            self.unreadLabel?.hidden = true
        }
        else {
            self.unreadLabel?.hidden = false
            self.unreadLabel?.text = String.init(format: "Unread %d", unreadCount)
        }
    }
    
    func buildMessage() -> NSAttributedString {
        let messageAttribute = [NSFontAttributeName: UIFont.systemFontOfSize(kMyMessageFontSize), NSForegroundColorAttributeName: SendBirdUtils.UIColorFromRGB(0x3d3d3d)]
        let urlAttribute = [NSFontAttributeName: UIFont.systemFontOfSize(kMyMessageFontSize), NSForegroundColorAttributeName: SendBirdUtils.UIColorFromRGB(0x2981e1)]
        
        var message: NSString = NSString.init(format: "%@", (self.message?.message)!)
        let url: String = SendBirdUtils.getUrlFromstring((self.message?.message)!)
        var urlRange: NSRange?
        if url.characters.count > 0 {
            urlRange = message.rangeOfString(url)
        }
        message = message.stringByReplacingOccurrencesOfString(" ", withString: "\u{00A0}")
        message = message.stringByReplacingOccurrencesOfString(" ", withString: "\u{2011}")
        
        let attributedMessage: NSMutableAttributedString = NSMutableAttributedString.init(string: message as String)
        let messageRange: NSRange = NSMakeRange(0, self.message!.message.characters.count)
        
        attributedMessage.beginEditing()
        attributedMessage.setAttributes(messageAttribute, range: messageRange)
        if url.characters.count > 0 {
            attributedMessage.setAttributes(urlAttribute, range: urlRange!)
        }
        attributedMessage.endEditing()
        
        return attributedMessage
    }
    
    func getHeightOfViewCell(totalWidth: CGFloat) -> CGFloat {
        var messageRect: CGRect
        let attributedMessage: NSAttributedString = self.buildMessage()
        
        messageRect = attributedMessage.boundingRectWithSize(CGSizeMake(kMyMessageMaxWidth, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        return messageRect.size.height + self.topMargin! + kMyMessageCellBottomMargin + kMyMessageBalloonTopPadding + kMyMessageBalloonBottomPadding
    }
}
