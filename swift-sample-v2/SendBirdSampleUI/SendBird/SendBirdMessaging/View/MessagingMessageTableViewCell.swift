//
//  MessagingMessageTableViewCell.swift
//  SendBirdSampleUI
//
//  Created by Jed Kyung on 2/7/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

import UIKit
import SendBirdSDK

class MessagingMessageTableViewCell: UITableViewCell {
    let kMessageCellTopMargin: CGFloat = 14
    let kMessageCellBottomMargin: CGFloat = 0
    let kMessageCellLeftMargin: CGFloat = 12
    let kMessageFontSize: CGFloat = 14.0
    let kMessageBalloonTopPadding: CGFloat = 12
    let kMessageBalloonBottomPadding: CGFloat = 12
    let kMessageBalloonLeftPadding: CGFloat = 60
    let kMessageBalloonRightPadding: CGFloat = 12
    let kMessageMaxWidth: CGFloat = 168
    let kMessageProfileHeight: CGFloat = 36
    let kMessageProfileWidth: CGFloat = 36
    let kMessageDateTimeLeftMarign: CGFloat = 4
    let kMessageDateTimeFontSize: CGFloat = 10.0
    let kMessageNicknameFontSize: CGFloat = 12.0
    
    var message: SendBirdMessage?
    var profileImageView: UIImageView?
    var messageBackgroundImageView: UIImageView?
    var nicknameLabel: UILabel?
    var messageLabel: UILabel?
    var dateTimeLabel: UILabel?
    
    private var topMargin: CGFloat?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.topMargin = kMessageCellTopMargin
        self.initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        self.backgroundColor = UIColor.clearColor()
        
        self.profileImageView = UIImageView()
        self.profileImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.profileImageView?.layer.cornerRadius = kMessageProfileHeight / 2
        self.profileImageView?.clipsToBounds = true
        self.profileImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        self.addSubview(self.profileImageView!)
        
        self.messageBackgroundImageView = UIImageView()
        self.messageBackgroundImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.messageBackgroundImageView?.image = UIImage.init(named: "_bg_chat_bubble_gray")
        self.addSubview(self.messageBackgroundImageView!)
        
        self.nicknameLabel = UILabel()
        self.nicknameLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.nicknameLabel?.font = UIFont.systemFontOfSize(kMessageNicknameFontSize)
        self.nicknameLabel?.numberOfLines = 1
        self.nicknameLabel?.textColor = SendBirdUtils.UIColorFromRGB(0xa792e5)
        self.nicknameLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
        self.addSubview(self.nicknameLabel!)
        
        self.messageLabel = UILabel()
        self.messageLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.messageLabel?.font = UIFont.systemFontOfSize(kMessageFontSize)
        self.messageLabel?.numberOfLines = 0
        self.messageLabel?.textColor = SendBirdUtils.UIColorFromRGB(0x3d3d3d)
        self.messageLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
        self.addSubview(self.messageLabel!)
        
        self.dateTimeLabel = UILabel()
        self.dateTimeLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.dateTimeLabel?.numberOfLines = 1
        self.dateTimeLabel?.textColor = SendBirdUtils.UIColorFromRGB(0xacaab2)
        self.dateTimeLabel?.font = UIFont.systemFontOfSize(kMessageDateTimeFontSize)
        self.dateTimeLabel?.text = "11:24 PM"
        self.addSubview(self.dateTimeLabel!)
        
        // Profile Image View
        self.addConstraint(NSLayoutConstraint.init(item: self.profileImageView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -kMessageCellBottomMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.profileImageView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: kMessageCellLeftMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.profileImageView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kMessageProfileWidth))
        self.addConstraint(NSLayoutConstraint.init(item: self.profileImageView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kMessageProfileHeight))
        
        // Nickname Label
        self.addConstraint(NSLayoutConstraint.init(item: self.nicknameLabel!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.messageLabel!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.nicknameLabel!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: kMessageBalloonLeftPadding))
        self.addConstraint(NSLayoutConstraint.init(item: self.nicknameLabel!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kMessageMaxWidth))
        
        // Message Label
        self.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -kMessageBalloonBottomPadding - kMessageCellBottomMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: kMessageBalloonLeftPadding))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kMessageMaxWidth))
        
        // Message Background Image View
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -kMessageCellBottomMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: kMessageBalloonLeftPadding - 16))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.messageLabel!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: kMessageBalloonRightPadding))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.nicknameLabel!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: kMessageBalloonRightPadding))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.nicknameLabel!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: -kMessageBalloonTopPadding))
        
        // DateTime Label
        self.addConstraint(NSLayoutConstraint.init(item: self.dateTimeLabel!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.dateTimeLabel!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: kMessageDateTimeLeftMarign))
    }
    
    func setContinuousMessage(continuousFlag: Bool) {
        if continuousFlag {
            topMargin = 4.0
        }
        else {
            topMargin = kMessageCellTopMargin
        }
    }
    
    func setModel(message: SendBirdMessage) {
        self.message = message
        self.messageLabel?.attributedText = self.buildMessage()
        let sender: SendBirdSender = (self.message?.sender)!
        let ts: Int64 = (self.message?.getMessageTimestamp())! / 1000
        self.dateTimeLabel?.text = SendBirdUtils.messageDateTime(NSTimeInterval(ts))
        self.nicknameLabel?.text = sender.name
        
        SendBirdUtils.loadImage(sender.imageUrl, imageView: self.profileImageView!, width: kMessageProfileWidth, height: kMessageProfileHeight)
    }
    
    func buildMessage() -> NSAttributedString {
        let messageAttribute: [String: AnyObject] = [NSFontAttributeName: UIFont.systemFontOfSize(kMessageFontSize), NSForegroundColorAttributeName: SendBirdUtils.UIColorFromRGB(0x3d3d3d)]
        let urlAttribute: [String: AnyObject] = [NSFontAttributeName: UIFont.systemFontOfSize(kMessageFontSize), NSForegroundColorAttributeName: SendBirdUtils.UIColorFromRGB(0x2981e1)]
        let blockMark: String = ""
        
        var message: NSString = NSString.init(format: "%@%@", (self.message?.message)!, blockMark).stringByReplacingOccurrencesOfString(" ", withString: "\u{00A0}")
        let url = SendBirdUtils.getUrlFromstring(self.message!.message)
        var urlRange: NSRange?
        if url.characters.count > 0 {
            urlRange = message.rangeOfString(url)
        }
        message = message.stringByReplacingOccurrencesOfString(" ", withString: "\u{00A0}")
        message = message.stringByReplacingOccurrencesOfString("-", withString: "\u{2011}")
        
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
        let nickname: String = (self.message?.sender.name)!
        var messageRect: CGRect?
        var nicknameRect: CGRect?
        let attributedMessage: NSAttributedString = self.buildMessage()
        let nicknameAttribute: [String: AnyObject] = [NSFontAttributeName: UIFont.systemFontOfSize(12.0)]
        let attributedNickname: NSAttributedString = NSAttributedString.init(string: nickname, attributes: nicknameAttribute)
        
        messageRect = attributedMessage.boundingRectWithSize(CGSizeMake(kMessageMaxWidth, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        nicknameRect = attributedNickname.boundingRectWithSize(CGSizeMake(kMessageMaxWidth, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        let height: CGFloat = nicknameRect!.size.height + messageRect!.size.height + kMessageCellTopMargin + kMessageCellBottomMargin + kMessageBalloonBottomPadding + kMessageBalloonTopPadding
        
        return height
    }
}
