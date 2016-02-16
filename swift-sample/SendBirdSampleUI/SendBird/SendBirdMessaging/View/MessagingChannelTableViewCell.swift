//
//  MessagingChannelTableViewCell.swift
//  SendBirdSampleUI
//
//  Created by Jed Kyung on 2/7/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

import UIKit
import SendBirdSDK

class MessagingChannelTableViewCell: UITableViewCell {
    let kChannelUrlFontSize: CGFloat = 14.0
    let kChannelMembersFontSize: CGFloat = 11.0
    let kChannelCoverRadius: CGFloat = 19.0
    let kChannelLastMessageFontSize: CGFloat = 11.0
    let kChannelLastMessageDateFontSize: CGFloat = 9.0
    let kChannelUnreadCountFontSize: CGFloat = 11.0
    
    var profileImageView: UIImageView?
    var nicknameLabel: UILabel?
    var lastMessageLabel: UILabel?
    var bottomLineView: UIView?
    var unreadCountImageView: UIImageView?
    var unreadCountLabel: UILabel?
    var lastMessageDateLabel: UILabel?
    var checkImageView: UIImageView?
    var memberCountImageView: UIImageView?
    var memberCountLabel: UILabel?
    
    private var memberCountImageViewWidthConstraint: NSLayoutConstraint?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        self.profileImageView = UIImageView()
        self.profileImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.profileImageView?.layer.cornerRadius = kChannelCoverRadius
        self.profileImageView?.clipsToBounds = true
        self.profileImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        self.addSubview(self.profileImageView!)
        
        self.nicknameLabel = UILabel()
        self.nicknameLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.nicknameLabel?.font = UIFont.boldSystemFontOfSize(kChannelUrlFontSize)
        self.nicknameLabel?.textColor = SendBirdUtils.UIColorFromRGB(0x3d3d3d)
        self.addSubview(self.nicknameLabel!)
        
        self.lastMessageLabel = UILabel()
        self.lastMessageLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.lastMessageLabel?.font = UIFont.systemFontOfSize(kChannelLastMessageFontSize)
        self.lastMessageLabel?.textColor = SendBirdUtils.UIColorFromRGB(0x999999)
        self.addSubview(self.lastMessageLabel!)
        
        self.bottomLineView = UIView()
        self.bottomLineView?.translatesAutoresizingMaskIntoConstraints = false
        self.bottomLineView?.backgroundColor = SendBirdUtils.UIColorFromRGB(0xc8c8c8)
        self.addSubview(self.bottomLineView!)
        
        self.lastMessageDateLabel = UILabel()
        self.lastMessageDateLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.lastMessageDateLabel?.font = UIFont.systemFontOfSize(kChannelLastMessageDateFontSize)
        self.lastMessageDateLabel?.textColor = SendBirdUtils.UIColorFromRGB(0x999999)
        self.lastMessageDateLabel?.text = "Apr 16, 2015"
        self.addSubview(self.lastMessageDateLabel!)
        
        self.unreadCountImageView = UIImageView()
        self.unreadCountImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.unreadCountImageView?.image = UIImage.init(named: "_bg_notify")
        self.addSubview(self.unreadCountImageView!)
        
        self.unreadCountLabel = UILabel()
        self.unreadCountLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.unreadCountLabel?.font = UIFont.systemFontOfSize(kChannelUnreadCountFontSize)
        self.unreadCountLabel?.textColor = SendBirdUtils.UIColorFromRGB(0xffffff)
        self.unreadCountLabel?.text = "99"
        self.addSubview(self.unreadCountLabel!)
        
        self.checkImageView = UIImageView()
        self.checkImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.checkImageView?.image = UIImage.init(named: "_btn_check_off")
        self.addSubview(self.checkImageView!)
        
        self.memberCountImageView = UIImageView()
        self.memberCountImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.memberCountImageView?.image = UIImage.init(named: "_icon_group_number")
        self.addSubview(self.memberCountImageView!)
        
        self.memberCountLabel = UILabel()
        self.memberCountLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.memberCountLabel?.text = "5"
        self.memberCountLabel?.textColor = SendBirdUtils.UIColorFromRGB(0xa4acbc)
        self.memberCountLabel?.font = UIFont.systemFontOfSize(10.0)
        self.addSubview(self.memberCountLabel!)
        
        // Profile Image View
        self.addConstraint(NSLayoutConstraint.init(item: self.profileImageView!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.profileImageView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 12))
        self.addConstraint(NSLayoutConstraint.init(item: self.profileImageView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        self.addConstraint(NSLayoutConstraint.init(item: self.profileImageView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        
        // Nickname Label
        self.addConstraint(NSLayoutConstraint.init(item: self.nicknameLabel!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 10))
        self.addConstraint(NSLayoutConstraint.init(item: self.nicknameLabel!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.profileImageView!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 14))
        self.addConstraint(NSLayoutConstraint.init(item: self.nicknameLabel!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.memberCountImageView!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -10))
        
        // Last Message Label
        self.addConstraint(NSLayoutConstraint.init(item: self.lastMessageLabel!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.nicknameLabel!, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 6))
        self.addConstraint(NSLayoutConstraint.init(item: self.lastMessageLabel!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.profileImageView!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 14))
        self.addConstraint(NSLayoutConstraint.init(item: self.lastMessageLabel!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -46))
        
        // Last Message Date
        self.addConstraint(NSLayoutConstraint.init(item: self.lastMessageDateLabel!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 12))
        self.addConstraint(NSLayoutConstraint.init(item: self.lastMessageDateLabel!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -12))
        // Unread Count Background Image View
        self.addConstraint(NSLayoutConstraint.init(item: self.unreadCountImageView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -10))
        self.addConstraint(NSLayoutConstraint.init(item: self.unreadCountImageView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -12))
        self.addConstraint(NSLayoutConstraint.init(item: self.unreadCountImageView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 22))
        self.addConstraint(NSLayoutConstraint.init(item: self.unreadCountImageView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 22))
        
        // Unread Count Label
        self.addConstraint(NSLayoutConstraint.init(item: self.unreadCountLabel!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.unreadCountImageView!, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.unreadCountLabel!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.unreadCountImageView!, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        // Bottom Line View
        self.addConstraint(NSLayoutConstraint.init(item: self.bottomLineView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.bottomLineView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 66))
        self.addConstraint(NSLayoutConstraint.init(item: self.bottomLineView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.bottomLineView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 0.5))
        
        // Check Image View
        self.addConstraint(NSLayoutConstraint.init(item: self.checkImageView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -12))
        self.addConstraint(NSLayoutConstraint.init(item: self.checkImageView!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        // Member Count View
        // Member Count ImageView
        self.addConstraint(NSLayoutConstraint.init(item: self.memberCountImageView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -70))
        self.addConstraint(NSLayoutConstraint.init(item: self.memberCountImageView!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.nicknameLabel!, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.memberCountImageView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 12.5))
        self.memberCountImageViewWidthConstraint = NSLayoutConstraint.init(item: self.memberCountImageView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 22)
        self.addConstraint(self.memberCountImageViewWidthConstraint!)
        
        // Member Count Label
        self.addConstraint(NSLayoutConstraint.init(item: self.memberCountLabel!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.memberCountImageView!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -2))
        self.addConstraint(NSLayoutConstraint.init(item: self.memberCountLabel!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.memberCountImageView!, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.checkImageView!.image = UIImage.init(named: "_btn_check_on")
        }
        else {
            self.checkImageView!.image = UIImage.init(named: "_btn_check_off")
        }
    }
    
    func setModel(model: SendBirdMessagingChannel?, check: Bool) {
        if model == nil {
            return
        }
        
        let channelName: String = String.init(format: "%@", SendBirdUtils.getMessagingChannelNames((model?.members)! as NSArray as! [SendBirdMemberInMessagingChannel]))
        self.nicknameLabel?.text = channelName
        self.lastMessageLabel?.text = model?.lastMessage.message
        
        if check {
            self.unreadCountLabel?.hidden = true
            self.unreadCountImageView?.hidden = true
            self.lastMessageDateLabel?.hidden = true
            self.checkImageView?.hidden = false
        }
        else {
            self.checkImageView?.hidden = true
            if model?.lastMessage == nil {
                self.lastMessageDateLabel?.hidden = true
            }
            else {
                self.lastMessageDateLabel?.hidden = false
                let ts: Int64 = (model?.lastMessage.getMessageTimestamp())! / 1000
                self.lastMessageDateLabel?.text = SendBirdUtils.lastMessageDateTime(NSTimeInterval(ts))
            }
            
            let unreadCount: Int32 = model!.unreadMessageCount
            if unreadCount > 0 {
                self.unreadCountImageView?.hidden = false
                self.unreadCountLabel?.hidden = false
                var unreadCountText: String = ""
                if unreadCount < 99 {
                    unreadCountText = String.init(format: "%d", unreadCount)
                }
                else {
                    unreadCountText = "99"
                }
                self.unreadCountLabel?.text = unreadCountText
            }
            else {
                self.unreadCountImageView?.hidden = true
                self.unreadCountLabel?.hidden = true
            }
        }

        SendBirdUtils.loadImage(SendBirdUtils.getDisplayCoverImageUrl((model?.members)! as NSArray as! [SendBirdMemberInMessagingChannel]), imageView: self.profileImageView!, width: 40, height: 40)
        
        if model?.members.count > 2 {
            self.memberCountLabel?.hidden = false
            self.memberCountImageView?.hidden = false
            let memberCount: String = String.init(format: "%lu", (model?.members.count)!)
            
            self.memberCountLabel?.text = memberCount
            var memberCountRect: CGRect?
            let memberCountAttribute = [NSFontAttributeName: UIFont.systemFontOfSize(10.0)]
            let attributedMemberCount: NSAttributedString = NSAttributedString.init(string: memberCount, attributes: memberCountAttribute)
            memberCountRect = attributedMemberCount.boundingRectWithSize(CGSizeMake(CGFloat.max, 12.5), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
            
            self.memberCountImageViewWidthConstraint?.constant = 16 + memberCountRect!.size.width
            self.updateConstraints()
        }
        else {
            self.memberCountLabel?.hidden = true
            self.memberCountImageView?.hidden = true
        }
    }
}
