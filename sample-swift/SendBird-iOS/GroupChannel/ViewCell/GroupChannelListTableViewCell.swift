//
//  GroupChannelListTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/10/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import AlamofireImage

class GroupChannelListTableViewCell: UITableViewCell {
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadMessageCountLabel: UILabel!
    @IBOutlet weak var coverImageContainerForOne: UIView!
    @IBOutlet weak var coverImageView11: UIImageView!
    
    @IBOutlet weak var coverImageContainerForTwo: UIView!
    @IBOutlet weak var coverImageView21: UIImageView!
    @IBOutlet weak var coverImageView22: UIImageView!
    
    @IBOutlet weak var coverImageContainerForThree: UIView!
    @IBOutlet weak var coverImageView31: UIImageView!
    @IBOutlet weak var coverImageView32: UIImageView!
    @IBOutlet weak var coverImageView33: UIImageView!
    
    @IBOutlet weak var coverImageContainerForFour: UIView!
    @IBOutlet weak var coverImageView41: UIImageView!
    @IBOutlet weak var coverImageView42: UIImageView!
    @IBOutlet weak var coverImageView43: UIImageView!
    @IBOutlet weak var coverImageView44: UIImageView!
    
    @IBOutlet weak var unreadMessageCountContainerView: UIView!
    @IBOutlet weak var typingImageView: UIImageView!
    @IBOutlet weak var typingLabel: UILabel!
    
    private var channel: SBDGroupChannel!

    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    
    func startTypingAnimation() {
        if self.channel == nil {
            return
        }
        
        // Typing indicator
        if self.channel.isTyping() == true {
            var typingLabelText = ""
            if self.channel.getTypingMembers()?.count == 1 {
                typingLabelText = String(format: Bundle.sbLocalizedStringForKey(key: "TypingMessageSingular"), (self.channel.getTypingMembers()?[0].nickname)!)
            }
            else {
                typingLabelText = Bundle.sbLocalizedStringForKey(key: "TypingMessagePlural")
            }
            
            self.typingLabel.text = typingLabelText
            
            if self.typingImageView.isAnimating == false {
                var typingImages: [UIImage] = []
                for i in 1...50 {
                    let typingImageFrameName = String(format: "%02d", i)
                    typingImages.append(UIImage(named: typingImageFrameName)!)
                }
                self.typingImageView.animationImages = typingImages
                self.typingImageView.animationDuration = 1.5
                DispatchQueue.main.async {
                    self.typingImageView.startAnimating()
                }
            }
            self.lastMessageLabel.isHidden = true
            self.typingImageView.isHidden = false
            self.typingLabel.isHidden = false
        }
        else {
            if self.typingImageView.isAnimating == true {
                DispatchQueue.main.async {
                    self.typingImageView.stopAnimating()
                }
            }
            self.lastMessageLabel.isHidden = false
            self.typingImageView.isHidden = true
            self.typingLabel.isHidden = true
        }
    }
    
    func setModel(aChannel: SBDGroupChannel) {
        self.channel = aChannel
        
        self.memberCountLabel.text = String(format: "%ld", self.channel.memberCount)
        
        self.typingImageView.isHidden = true
        self.typingLabel.isHidden = true
        
        self.coverImageContainerForOne.isHidden = true
        self.coverImageContainerForTwo.isHidden = true
        self.coverImageContainerForThree.isHidden = true
        self.coverImageContainerForFour.isHidden = true
        
        var memberNames: [String] = []
        if self.channel.memberCount == 1 {
            self.coverImageContainerForOne.isHidden = false
            let member = self.channel.members?[0] as! SBDUser
            self.coverImageView11.af_setImage(withURL: URL(string: member.profileUrl!)!, placeholderImage: UIImage(named: "img_profile"))
        }
        else if self.channel.memberCount == 2 {
            self.coverImageContainerForOne.isHidden = false
            for member in self.channel.members! as NSArray as! [SBDUser] {
                if member.userId == SBDMain.getCurrentUser()?.userId {
                    continue
                }
                self.coverImageView11.af_setImage(withURL: URL(string: member.profileUrl!)!, placeholderImage: UIImage(named: "img_profile"))
                memberNames.append(member.nickname!)
            }
        }
        else if self.channel.memberCount == 3 {
            self.coverImageContainerForTwo.isHidden = false
            
            var coverImages: [UIImageView] = [self.coverImageView21, self.coverImageView22]
            var memberExceptCurrentUser:  [SBDUser] = []
            for member in self.channel.members! as NSArray as! [SBDUser] {
                if member.userId == SBDMain.getCurrentUser()?.userId {
                    continue
                }
                
                memberExceptCurrentUser.append(member)
                memberNames.append(member.nickname!)
            }
            
            for i in 0...memberExceptCurrentUser.count - 1 {
                coverImages[i].af_setImage(withURL: URL(string: memberExceptCurrentUser[i].profileUrl!)!, placeholderImage: UIImage(named: "img_profile"))
            }
        }
        else if self.channel.memberCount == 4 {
            self.coverImageContainerForThree.isHidden = false
            
            var coverImages: [UIImageView] = [self.coverImageView31, self.coverImageView32, self.coverImageView33]
            var memberExceptCurrentUser:  [SBDUser] = []
            for member in self.channel.members! as NSArray as! [SBDUser] {
                if member.userId == SBDMain.getCurrentUser()?.userId {
                    continue
                }
                
                memberExceptCurrentUser.append(member)
                memberNames.append(member.nickname!)
            }
            
            for i in 0...memberExceptCurrentUser.count - 1 {
                coverImages[i].af_setImage(withURL: URL(string: memberExceptCurrentUser[i].profileUrl!)!, placeholderImage: UIImage(named: "img_profile"))
            }
        }
        else if self.channel.memberCount > 4 {
            self.coverImageContainerForFour.isHidden = false
            
            var coverImages: [UIImageView] = [self.coverImageView41, self.coverImageView42, self.coverImageView43, self.coverImageView44]
            var memberExceptCurrentUser:  [SBDUser] = []
            var memberCount = 0
            for member in self.channel.members! as NSArray as! [SBDUser] {
                if member.userId == SBDMain.getCurrentUser()?.userId {
                    continue
                }
                
                memberExceptCurrentUser.append(member)
                memberNames.append(member.nickname!)
                
                memberCount += 1
                if memberCount >= 4 {
                    break;
                }
            }
            
            for i in 0...memberExceptCurrentUser.count - 1 {
                coverImages[i].af_setImage(withURL: URL(string: memberExceptCurrentUser[i].profileUrl!)!, placeholderImage: UIImage(named: "img_profile"))
            }
        }
        
        self.channelNameLabel.text = memberNames.joined(separator: ", ")
        var lastMessageTimestamp: Int64 = 0
        if self.channel.lastMessage is SBDUserMessage {
            let lastMessage = (self.channel.lastMessage as! SBDUserMessage)
            self.lastMessageLabel.text = lastMessage.message
            lastMessageTimestamp = Int64(lastMessage.createdAt)
        }
        else if self.channel.lastMessage is SBDFileMessage {
            let lastMessage = (self.channel.lastMessage as! SBDFileMessage)
            if lastMessage.type.hasPrefix("image") {
                self.lastMessageLabel.text = Bundle.sbLocalizedStringForKey(key: "MessageSummaryImage")
            }
            else if lastMessage.type.hasPrefix("video") {
                self.lastMessageLabel.text = Bundle.sbLocalizedStringForKey(key: "MessageSummaryVideo")
            }
            else if lastMessage.type.hasPrefix("audio") {
                self.lastMessageLabel.text = Bundle.sbLocalizedStringForKey(key: "MessageSummaryAudio")
            }
            else {
                self.lastMessageLabel.text = Bundle.sbLocalizedStringForKey(key: "MessageSummaryFile")
            }
            lastMessageTimestamp = Int64(lastMessage.createdAt)
        }
        else if self.channel.lastMessage is SBDAdminMessage {
            let lastMessage = self.channel.lastMessage as! SBDAdminMessage
            self.lastMessageLabel.text = lastMessage.message
            lastMessageTimestamp = Int64(lastMessage.createdAt)
        }
        else {
            self.lastMessageLabel.text = ""
            lastMessageTimestamp = Int64(self.channel.createdAt)
        }
        
        // Last message date time
        let lastMessageDateFormatter = DateFormatter()
        
        var lastMessageDate: Date?
        if String(format: "%lld", lastMessageTimestamp).characters.count == 10 {
            lastMessageDate = Date.init(timeIntervalSince1970: Double(lastMessageTimestamp))
        }
        else {
            lastMessageDate = Date.init(timeIntervalSince1970: Double(lastMessageTimestamp) / 1000.0)
        }
        let currDate = Date()
        
        let lastMessageDateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: lastMessageDate! as Date)
        let currDateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: currDate as Date)
        
        if lastMessageDateComponents.year != currDateComponents.year || lastMessageDateComponents.month != currDateComponents.month || lastMessageDateComponents.day != currDateComponents.day {
            lastMessageDateFormatter.dateStyle = DateFormatter.Style.short
            lastMessageDateFormatter.timeStyle = DateFormatter.Style.none
            self.dateLabel.text = lastMessageDateFormatter.string(from: lastMessageDate!)
        }
        else {
            lastMessageDateFormatter.dateStyle = DateFormatter.Style.none
            lastMessageDateFormatter.timeStyle = DateFormatter.Style.short
            self.dateLabel.text = lastMessageDateFormatter.string(from: lastMessageDate!)
        }

        self.unreadMessageCountContainerView.isHidden = false
        if self.channel.unreadMessageCount == 0 {
            self.unreadMessageCountContainerView.isHidden = true
        }
        else if self.channel.unreadMessageCount <= 9 {
            self.unreadMessageCountLabel.text = String(format: "%ld", self.channel.unreadMessageCount)
        }
        else {
            self.unreadMessageCountLabel.text = "9+"
        }
    }
}
