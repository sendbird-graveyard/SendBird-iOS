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
    
    @IBOutlet fileprivate weak var coverImageView: UIImageView!
    @IBOutlet fileprivate weak var channelTitleLabel: UILabel!
    @IBOutlet fileprivate weak var lastMessageLabel: UILabel!
    @IBOutlet fileprivate weak var lastMessageDateLabel: UILabel!
    @IBOutlet fileprivate weak var unreadMessageCountLabel: UILabel!
    @IBOutlet fileprivate weak var memberCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
        return UINib.init(nibName: NSStringFromClass(self).components(separatedBy: ".").last!, bundle: Bundle(for: self));
    }
    
    static func cellReuseIdentifier() -> String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    func setModel(_ aChannel: SBDGroupChannel) {
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
            self.coverImageView.af_setImage(withURL: URL.init(string: (representativeUser?.profileUrl)!)!)
        }
        else {
            self.coverImageView.af_setImage(withURL: URL.init(string: (self.channel?.coverUrl)!)!)
        }
        
        channelTitle = channelTitleNameArray.joined(separator: ",")
        
        self.channelTitleLabel.text = channelTitle
        let date: Date?
        if self.channel?.lastMessage?.isKind(of: SBDUserMessage.self) == true {
            self.lastMessageLabel.text = (self.channel?.lastMessage as! SBDUserMessage).message
            date = Date(timeIntervalSince1970: Double((self.channel?.lastMessage!.createdAt)!) / 1000)
        }
        else if self.channel?.lastMessage?.isKind(of: SBDUserMessage.self) == true {
            self.lastMessageLabel.text = "(File)"
            date = Date(timeIntervalSince1970: Double((self.channel?.lastMessage!.createdAt)!) / 1000)
        }
        else {
            self.lastMessageLabel.text = ""
            date = Date(timeIntervalSince1970: Double((self.channel?.createdAt)!) / 1000)
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeStyle = DateFormatter.Style.short
        formatter.dateStyle = DateFormatter.Style.short
        formatter.timeZone = TimeZone.autoupdatingCurrent
        
        self.lastMessageDateLabel.text = formatter.string(from: date!)
        
        if self.channel?.unreadMessageCount == 0 {
            self.unreadMessageCountLabel.isHidden = true
        }
        else {
            self.unreadMessageCountLabel.isHidden = false
            self.unreadMessageCountLabel.text = String(format: "%lu", (self.channel?.unreadMessageCount)!)
        }
        
        self.memberCountLabel.text = String(format: "%lu", self.channel!.memberCount)
    }
    
    override func draw(_ rect: CGRect) {
        self.coverImageView.layer.cornerRadius = 18
        self.coverImageView.clipsToBounds = true
    }
}
