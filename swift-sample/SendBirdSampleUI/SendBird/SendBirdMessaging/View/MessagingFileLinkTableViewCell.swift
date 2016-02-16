//
//  MessagingFileLinkTableViewCell.swift
//  SendBirdSampleUI
//
//  Created by Jed Kyung on 2/7/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

import UIKit
import SendBirdSDK

class MessagingFileLinkTableViewCell: UITableViewCell {
    let kFileLinkCellTopMargin: CGFloat = 14
    let kFileLinkCellBottomMargin: CGFloat = 0
    let kFileLinkCellLeftMargin: CGFloat = 12
    let kFileLinkFontSize: CGFloat = 14.0
    let kFileLinkBalloonTopPadding: CGFloat = 12
    let kFileLinkBalloonBottomPadding: CGFloat = 12
    let kFileLinkBalloonLeftPadding: CGFloat = 60
    let kFileLinkBalloonRightPadding: CGFloat = 12
    let kFileLinkWidth: CGFloat = 150
    let kFileLinkHeight: CGFloat = 150
    let kFileLinkProfileHeight: CGFloat = 36
    let kFileLinkProfileWidth: CGFloat = 36
    let kFileLinkDateTimeLeftMarign: CGFloat = 4
    let kFileLinkDateTimeFontSize: CGFloat = 10.0
    let kFileLinkNicknameFontSize: CGFloat = 12.0

    var fileLink: SendBirdFileLink?
    var profileImageView: UIImageView?
    var fileImageView: UIImageView?
    var messageBackgroundImageView: UIImageView?
    var nicknameLabel: UILabel?
    var dateTimeLabel: UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        self.backgroundColor = UIColor.clearColor()
        
        self.profileImageView = UIImageView()
        self.profileImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.profileImageView?.layer.cornerRadius = kFileLinkProfileHeight / 2
        self.profileImageView?.clipsToBounds = true
        self.profileImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        self.addSubview(self.profileImageView!)
        
        self.messageBackgroundImageView = UIImageView()
        self.messageBackgroundImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.messageBackgroundImageView?.image = UIImage.init(named: "_bg_chat_bubble_gray")
        self.addSubview(self.messageBackgroundImageView!)
        
        self.nicknameLabel = UILabel()
        self.nicknameLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.nicknameLabel?.font = UIFont.systemFontOfSize(kFileLinkNicknameFontSize)
        self.nicknameLabel?.numberOfLines = 1
        self.nicknameLabel?.textColor = SendBirdUtils.UIColorFromRGB(0xa792e5)
        self.nicknameLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
        self.addSubview(self.nicknameLabel!)
        
        self.dateTimeLabel = UILabel()
        self.dateTimeLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.dateTimeLabel?.numberOfLines = 1
        self.dateTimeLabel?.textColor = SendBirdUtils.UIColorFromRGB(0xacaab2)
        self.dateTimeLabel?.font = UIFont.systemFontOfSize(kFileLinkDateTimeFontSize)
        self.dateTimeLabel?.text = "11:24 PM"
        self.addSubview(self.dateTimeLabel!)
        
        self.fileImageView = UIImageView.init(image: UIImage.init(named: "_icon_file"))
        self.fileImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.fileImageView?.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(self.fileImageView!)
        
        // Profile Image View
        self.addConstraint(NSLayoutConstraint.init(item: self.profileImageView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -kFileLinkCellBottomMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.profileImageView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: kFileLinkCellLeftMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.profileImageView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kFileLinkProfileWidth))
        self.addConstraint(NSLayoutConstraint.init(item: self.profileImageView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kFileLinkProfileHeight))
        
        // Nickname Label
        self.addConstraint(NSLayoutConstraint.init(item: self.nicknameLabel!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.fileImageView!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.nicknameLabel!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: kFileLinkBalloonLeftPadding))
        self.addConstraint(NSLayoutConstraint.init(item: self.nicknameLabel!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kFileLinkWidth))
        
        // File Image View
        self.addConstraint(NSLayoutConstraint.init(item: self.fileImageView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -kFileLinkBalloonBottomPadding))
        self.addConstraint(NSLayoutConstraint.init(item: self.fileImageView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: kFileLinkBalloonLeftPadding))
        self.addConstraint(NSLayoutConstraint.init(item: self.fileImageView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kFileLinkWidth))
        self.addConstraint(NSLayoutConstraint.init(item: self.fileImageView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kFileLinkHeight))
        
        // Message Background Image View
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: kFileLinkCellBottomMargin))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: kFileLinkBalloonLeftPadding - 16))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.fileImageView!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: kFileLinkBalloonRightPadding))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.nicknameLabel!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: -kFileLinkBalloonTopPadding))
        
        // DateTime Label
        self.addConstraint(NSLayoutConstraint.init(item: self.dateTimeLabel!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.dateTimeLabel!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.messageBackgroundImageView!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: kFileLinkDateTimeLeftMarign))
    }
    
    func setModel(model: SendBirdFileLink) {
        self.fileLink = model
        let sender: SendBirdSender = (self.fileLink?.sender)!
        let ts: Int64 = (self.fileLink?.getMessageTimestamp())! / 1000
        self.dateTimeLabel?.text = SendBirdUtils.messageDateTime(NSTimeInterval(ts))
        self.nicknameLabel?.text = sender.name
        
        SendBirdUtils.loadImage(sender.imageUrl, imageView: self.profileImageView!, width: kFileLinkProfileWidth, height: kFileLinkProfileWidth)
        
        if self.fileLink?.fileInfo.type.hasPrefix("image") == true {
            SendBirdUtils.loadImage(model.fileInfo.url, imageView: self.fileImageView!, width: kFileLinkWidth, height: kFileLinkHeight)
        }
    }
    
    func getHeightOfViewCell(totalWidth: CGFloat) -> CGFloat {
        let nickname: String = self.fileLink!.sender.name
        var nicknameRect: CGRect?
        let nicknameAttribute = [NSFontAttributeName: UIFont.systemFontOfSize(12.0)]
        let attributedNickname: NSAttributedString = NSAttributedString.init(string: nickname, attributes: nicknameAttribute)
        
        nicknameRect = attributedNickname.boundingRectWithSize(CGSizeMake(kFileLinkWidth, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        return nicknameRect!.size.height + kFileLinkCellBottomMargin + kFileLinkBalloonBottomPadding + kFileLinkHeight + kFileLinkBalloonTopPadding + kFileLinkCellTopMargin;
    }
}
