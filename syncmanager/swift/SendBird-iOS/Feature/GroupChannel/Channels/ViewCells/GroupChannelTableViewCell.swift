//
//  GroupChannelTableViewswift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/12/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import FLAnimatedImage

class GroupChannelTableViewCell: UITableViewCell {
    
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var memberCountContainerView: UIView!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var lastUpdatedDateLabel: UILabel!
    @IBOutlet weak var notiOffIconImageView: UIImageView!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var unreadMessageCountContainerView: UIView!
    @IBOutlet weak var unreadMessageCountLabel: UILabel!
    @IBOutlet weak var typingIndicatorContainerView: UIView!
    @IBOutlet weak var typingIndicatorImageView: FLAnimatedImageView!
    @IBOutlet weak var typingIndicatorLabel: UILabel!
    @IBOutlet weak var profileImagView: ProfileImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        do {
            let path = Bundle.main.path(forResource: "loading_typing", ofType: "gif")!
            let gifData = try NSData(contentsOfFile: path) as Data
            let image = FLAnimatedImage(animatedGIFData: gifData)
            self.typingIndicatorImageView.animatedImage = image
            self.typingIndicatorContainerView.isHidden = true
            self.lastMessageLabel.isHidden = false
        } catch {
            print(error.localizedDescription)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension GroupChannelTableViewCell {
    func set(by channel: SBDGroupChannel, timer: Timer? = nil) {
        self.fetchProfileImage(by: channel)
        self.channelNameLabel.text = Utils.createGroupChannelName(channel: channel)
        self.setLastMessage(channel: channel, timer: timer)
        
        self.unreadMessageCountContainerView.isHidden = false
        switch channel.unreadMessageCount {
        case 1...99: self.unreadMessageCountLabel.text = String(channel.unreadMessageCount)
        case 100...: self.unreadMessageCountLabel.text = "+99"
            
        default: self.unreadMessageCountContainerView.isHidden = true
        }
        
        if channel.memberCount <= 2 {
            self.memberCountContainerView.isHidden = true
            
        } else {
            self.memberCountContainerView.isHidden = false
            self.memberCountLabel.text = String(channel.memberCount)
        }
        
        let pushOption = channel.myPushTriggerOption
        switch pushOption {
        case .all, .default, .mentionOnly:
            self.notiOffIconImageView.isHidden = true
        case .off:
            self.notiOffIconImageView.isHidden = false
        @unknown default:
            assertionFailure()
        }
    }
    
    func fetchProfileImage(by channel: SBDGroupChannel) {
        
        DispatchQueue.main.async {
            guard
                let members = channel.members as? [SBDMember],
                let currentUser = SBDMain.getCurrentUser(),
                let coverUrl = channel.coverUrl else { return }
            
            let filterMembers = members.filter { $0.userId != currentUser.userId }.prefix(4)
            
            if coverUrl.count > 0 && !coverUrl.hasPrefix("https://sendbird.com/main/img/cover/") {
                self.profileImagView.setImage(withCoverUrl: coverUrl)
            } else {
                self.profileImagView.users = Array(filterMembers)
                self.profileImagView.makeCircularWithSpacing(spacing: 1)
            }
        }
    }
}

private extension GroupChannelTableViewCell {
    func setLastMessage(channel: SBDGroupChannel, timer: Timer? = nil) {
        
        let lastMessageDateFormatter = DateFormatter()
        var lastUpdatedAt: Date?
        
        /// Marking Date on the Group Channel List
        if let lastMessage = channel.lastMessage {
            lastUpdatedAt = Date(timeIntervalSince1970: Double(lastMessage.createdAt / 1000))
        } else {
            lastUpdatedAt = Date(timeIntervalSince1970: Double(channel.createdAt))
        }
        
        let currDate = Date()
        let lastMessageDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: lastUpdatedAt!)
        let currDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: currDate)
        
        if lastMessageDateComponents.year != currDateComponents.year || lastMessageDateComponents.month != currDateComponents.month || lastMessageDateComponents.day != currDateComponents.day {
            lastMessageDateFormatter.dateStyle = .short
            lastMessageDateFormatter.timeStyle = .none
            self.lastUpdatedDateLabel.text = lastMessageDateFormatter.string(from: lastUpdatedAt!)
        } else {
            lastMessageDateFormatter.dateStyle = .none
            lastMessageDateFormatter.timeStyle = .short
            self.lastUpdatedDateLabel.text = lastMessageDateFormatter.string(from: lastUpdatedAt!)
        }
        
        let typingIndicatorText = channel.typingIndicatorText
        let showTypingIndicator = timer == nil || typingIndicatorText.isEmpty
        guard showTypingIndicator else {
            self.lastMessageLabel.isHidden = true
            self.typingIndicatorContainerView.isHidden = false
            self.typingIndicatorLabel.text = typingIndicatorText
            return
        }
        
        self.lastMessageLabel.isHidden = false
        self.typingIndicatorContainerView.isHidden = true
        
        guard let lastMessage = channel.lastMessage else {
            self.lastMessageLabel.text = ""
            return
        }
        if let userMessage = lastMessage as? SBDUserMessage {
            self.lastMessageLabel.text = userMessage.message
        } else if let fileMessage = lastMessage as? SBDFileMessage {
            self.lastMessageLabel.text = "(" + fileMessage.fileType.string + ")"
        } else {
            self.lastMessageLabel.text = ""
        }
    }
    
}
