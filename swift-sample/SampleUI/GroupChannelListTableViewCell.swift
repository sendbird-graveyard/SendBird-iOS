//
//  GroupChannelListTableViewCell.swift
//  SampleUI
//
//  Created by Jed Kyung on 8/24/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class GroupChannelListTableViewCell: UITableViewCell {
    var channel: SBDGroupChannel?
    
    @IBOutlet private weak var coverImageView: UIImageView!
    @IBOutlet private weak var channelTitleLabel: UILabel!
    @IBOutlet private weak var lastMessageLabel: UILabel!
    @IBOutlet private weak var lastMessageDateLabel: UILabel!
    @IBOutlet private weak var unreadMessageCountLabel: UILabel!
    @IBOutlet private weak var memberCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
        return UINib.init(nibName: NSStringFromClass(self).componentsSeparatedByString(".").last!, bundle: NSBundle(forClass: self));
    }
    
    static func cellReuseIdentifier() -> String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    func setModel(aChannel: SBDGroupChannel) {
        self.channel = aChannel
        
        var representativeUser: SBDUser?
        
        var channelTitle: String?
        var channelTitleNameArray: [String] = []
        for item in self.channel!.members! {
            let user = item as! SBDUser
            if user.userId == SBDMain.getCurrentUser()!.userId {
                continue
            }
            else {
                channelTitleNameArray.append(user.nickname!)
                representativeUser = user
            }
        }
        
        if representativeUser != nil {
            self.coverImageView.af_setImageWithURL(NSURL.init(string: (representativeUser?.profileUrl)!)!)
        }
        else {
            self.coverImageView.af_setImageWithURL(NSURL.init(string: (self.channel?.coverUrl)!)!)
        }
        
        channelTitle = channelTitleNameArray.joinWithSeparator(",")
        
        self.channelTitleLabel.text = channelTitle
        let date: NSDate?
        if self.channel?.lastMessage?.isKindOfClass(SBDUserMessage) == true {
            self.lastMessageLabel.text = (self.channel?.lastMessage as! SBDUserMessage).message
            date = NSDate(timeIntervalSince1970: Double((self.channel?.lastMessage!.createdAt)!) / 1000)
        }
        else if self.channel?.lastMessage?.isKindOfClass(SBDUserMessage) == true {
            self.lastMessageLabel.text = "(File)"
            date = NSDate(timeIntervalSince1970: Double((self.channel?.lastMessage!.createdAt)!) / 1000)
        }
        else {
            self.lastMessageLabel.text = ""
            date = NSDate(timeIntervalSince1970: Double((self.channel?.createdAt)!) / 1000)
        }
        
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale.currentLocale()
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeZone = NSTimeZone.localTimeZone()
        
        self.lastMessageDateLabel.text = formatter.stringFromDate(date!)
        
        if self.channel?.unreadMessageCount == 0 {
            self.unreadMessageCountLabel.hidden = true
        }
        else {
            self.unreadMessageCountLabel.hidden = false
            self.unreadMessageCountLabel.text = String(format: "%lu", (self.channel?.unreadMessageCount)!)
        }
        
        self.memberCountLabel.text = String(format: "%lu", self.channel!.memberCount)
    }
    
    override func drawRect(rect: CGRect) {
        self.coverImageView.layer.cornerRadius = 18
        self.coverImageView.clipsToBounds = true
    }
}
