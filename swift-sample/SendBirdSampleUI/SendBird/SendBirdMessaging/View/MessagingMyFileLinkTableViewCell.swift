//
//  MessagingMyFileLinkTableViewCell.swift
//  SendBirdSampleUI
//
//  Created by Jed Kyung on 2/7/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

import UIKit
import SendBirdSDK

class MessagingMyFileLinkTableViewCell: UITableViewCell {
    let kMyFileLinkCellTopMargin: CGFloat = 14.0
    let kMyFileLinkCellBottomMargin: CGFloat = 0
    let kMyFileLinkCellLeftMargin: CGFloat = 12
    let kMyFileLinkBalloonRightMargin: CGFloat = 12
    let kMyFileLinkCellRightMargin: CGFloat = 32
    let kMyFileLinkFontSize: CGFloat = 14.0
    let kMyFileLinkBalloonTopPadding: CGFloat = 12
    let kMyFileLinkBalloonBottomPadding: CGFloat = 12
    let kMyFileLinkBalloonLeftPadding: CGFloat = 12
    let kMyFileLinkBalloonRightPadding: CGFloat = 12
    let kMyFileLinkWidth: CGFloat = 160
    let kMyFileLinkHeight: CGFloat = 160
    let kMyFileLinkDateTimeRightMarign: CGFloat = 4
    let kMyFileLinkDateTimeFontSize: CGFloat = 10.0
    let kMyFileLinkUnreadFontSize: CGFloat = 10.0
    
    var fileLink: SendBirdFileLink?
    var currentChannel: SendBirdMessagingChannel?
    var messageBackgroundImageView: UIImageView?
    var dateTimeLabel: UILabel?
    var unreadLabel: UILabel?
    var fileImageView: UIImageView?
    var readStatus: NSMutableDictionary?
    
    private var topMargin: CGFloat?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.topMargin = kMyFileLinkCellTopMargin
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
        
        self.dateTimeLabel = UILabel()
        self.dateTimeLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.dateTimeLabel?.numberOfLines = 1
        self.dateTimeLabel?.textColor = SendBirdUtils.UIColorFromRGB(0xacaab2)
        self.dateTimeLabel?.font = UIFont.systemFontOfSize(kMyFileLinkDateTimeFontSize)
        self.dateTimeLabel?.text = "11:24 PM"
        self.addSubview(self.dateTimeLabel!)
        
        self.unreadLabel = UILabel()
        self.unreadLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.unreadLabel?.numberOfLines = 1
        self.unreadLabel?.textColor = SendBirdUtils.UIColorFromRGB(0xac90ff)
        self.unreadLabel?.font = UIFont.systemFontOfSize(kMyFileLinkUnreadFontSize)
        self.unreadLabel?.text = "Unread"
        self.addSubview(self.unreadLabel!)
        
        self.fileImageView = UIImageView.init(image: UIImage.init(named: "_icon_file"))
        self.fileImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.fileImageView?.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(self.fileImageView!)
        
        // File Image View
        self.addConstraint(NSLayoutConstraint.init(item: self.fileImageView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -kMyFileLinkBalloonBottomPadding))
        self.addConstraint(NSLayoutConstraint.init(item: self.fileImageView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -kMyFileLinkCellRightMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.fileImageView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kMyFileLinkWidth))
        self.addConstraint(NSLayoutConstraint.init(item: self.fileImageView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kMyFileLinkHeight))
        
        // Message Background Image View
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -kMyFileLinkCellBottomMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.fileImageView!, attribute: NSLayoutAttribute.Leading
            , multiplier: 1, constant: -kMyFileLinkBalloonLeftPadding))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -kMyFileLinkBalloonRightMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.fileImageView!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: -kMyFileLinkBalloonTopPadding))
        
        // DateTime Label
        self.addConstraint(NSLayoutConstraint.init(item: self.dateTimeLabel!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.dateTimeLabel!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: -kMyFileLinkDateTimeRightMarign))
        
        // Unread Label
        self.addConstraint(NSLayoutConstraint.init(item: self.unreadLabel!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.dateTimeLabel!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.unreadLabel!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: -kMyFileLinkDateTimeRightMarign))
    }
    
    func setContinuousMessage(continuousFlag: Bool) {
        if continuousFlag {
            self.topMargin = 4.0
        }
        else {
            self.topMargin = kMyFileLinkCellTopMargin;
        }
    }
    
    func setModel(model: SendBirdFileLink) {
        self.fileLink = model
        let ts: Int64 = (self.fileLink?.getMessageTimestamp())! / 1000
        self.dateTimeLabel?.text = SendBirdUtils.messageDateTime(NSTimeInterval(ts))
        self.unreadLabel?.hidden = true

        var unreadCount: Int = 0
        if self.readStatus != nil {
            for item in self.readStatus! {
                if item.key as! String == SendBird.getUserId() {
                    let readTime: Int64 = item.value as! Int64
                    if ts < readTime {
                        
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
        
        if self.fileLink?.fileInfo.type.hasPrefix("image") == true {
            SendBirdUtils.loadImage((self.fileLink?.fileInfo.url)!, imageView: self.fileImageView!, width: kMyFileLinkWidth, height: kMyFileLinkHeight)
        }
    }
    
    func getHeightOfViewCell(totalWidth: CGFloat) -> CGFloat {
        return kMyFileLinkHeight + self.topMargin! + kMyFileLinkCellBottomMargin + kMyFileLinkBalloonTopPadding + kMyFileLinkBalloonBottomPadding;
    }
}
