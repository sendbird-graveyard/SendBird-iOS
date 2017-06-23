//
//  OutgoingFileMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/7/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class OutgoingFileMessageTableViewCell: UITableViewCell {
    weak var delegate: MessageDelegate?
    
    @IBOutlet weak var dateSeperatorView: UIView!
    @IBOutlet weak var dateSeperatorLabel: UILabel!
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var fileTypeImageView: UIImageView!
    @IBOutlet weak var fileActionImageView: UIImageView!
    @IBOutlet weak var filenameLabel: UILabel!
    @IBOutlet weak var sendStatusLabel: UILabel!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var resendMessageButton: UIButton!
    @IBOutlet weak var deleteMessageButton: UIButton!
    @IBOutlet weak var unreadCountLabel: UILabel!
    
    @IBOutlet weak var dateSeperatorViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorViewBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var messageContainerViewTopPadding: NSLayoutConstraint!
    @IBOutlet weak var messageContainerViewBottomPadding: NSLayoutConstraint!
    @IBOutlet weak var fileContainerViewHeight: NSLayoutConstraint!
    
    private var message: SBDFileMessage!
    private var prevMessage: SBDBaseMessage!

    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }

    @objc private func clickFileMessage() {
        if self.delegate != nil {
            self.delegate?.clickMessage(view: self, message: self.message!)
        }
    }
    
    @objc private func clickResendUserMessage() {
        if self.delegate != nil {
            self.delegate?.clickResend(view: self, message: self.message!)
        }
    }
    
    @objc private func clickDeleteUserMessage() {
        if self.delegate != nil {
            self.delegate?.clickDelete(view: self, message: self.message!)
        }
    }
    
    func setModel(aMessage: SBDFileMessage) {
        self.message = aMessage

        let messageContainerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickFileMessage))
        self.messageContainerView.isUserInteractionEnabled = true
        self.messageContainerView.addGestureRecognizer(messageContainerTapRecognizer)
        
        self.resendMessageButton.addTarget(self, action: #selector(clickResendUserMessage), for: UIControlEvents.touchUpInside)
        self.deleteMessageButton.addTarget(self, action: #selector(clickDeleteUserMessage), for: UIControlEvents.touchUpInside)
        
        if self.message.type.hasPrefix("video") {
            self.fileTypeImageView.image = UIImage(named: "icon_video_chat")
            self.fileActionImageView.image = UIImage(named: "btn_play_chat")
        }
        else if self.message.type.hasPrefix("audio") {
            self.fileTypeImageView.image = UIImage(named: "icon_voice_chat")
            self.fileActionImageView.image = UIImage(named: "btn_play_chat")
        }
        else {
            self.fileTypeImageView.image = UIImage(named: "icon_file_chat")
            self.fileActionImageView.image = UIImage(named: "btn_download_chat")
        }
        
        self.filenameLabel.text = self.message.name
        
        // Unread message count
        if self.message.channelType == CHANNEL_TYPE_GROUP {
            let channelOfMessage = SBDGroupChannel.getChannelFromCache(withChannelUrl: self.message.channelUrl!)
            if channelOfMessage != nil {
                let unreadMessageCount = channelOfMessage?.getReadReceipt(of: self.message)
                if unreadMessageCount == 0 {
                    self.hideUnreadCount()
                    self.unreadCountLabel.text = ""
                }
                else {
                    self.showUnreadCount()
                    self.unreadCountLabel.text = String(format: "%d", unreadMessageCount!)
                }
            }
        }
        else {
            self.hideUnreadCount()
        }
        
        // Message Date
        let messageDateAttribute = [
            NSFontAttributeName: Constants.messageDateFont(),
            NSForegroundColorAttributeName: Constants.messageDateColor()
        ]
        
        let messageTimestamp = Double(self.message.createdAt) / 1000.0
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        let messageCreatedDate = NSDate(timeIntervalSince1970: messageTimestamp)
        let messageDateString = dateFormatter.string(from: messageCreatedDate as Date)
        
        let messageDateAttributedString = NSMutableAttributedString(string: messageDateString, attributes: messageDateAttribute)
        self.messageDateLabel.attributedText = messageDateAttributedString
        
        // Seperator Date
        let seperatorDateFormatter = DateFormatter()
        seperatorDateFormatter.dateStyle = DateFormatter.Style.medium
        self.dateSeperatorLabel.text = seperatorDateFormatter.string(from: messageCreatedDate as Date)
        
        // Relationship between the current message and the previous message
        if self.prevMessage != nil {
            // Day Changed
            let prevMessageDate = NSDate(timeIntervalSince1970: Double(self.prevMessage.createdAt) / 1000.0)
            let currMessageDate = NSDate(timeIntervalSince1970: Double(self.message.createdAt) / 1000.0)
            let prevMessageDateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: prevMessageDate as Date)
            let currMessagedateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: currMessageDate as Date)
            
            if prevMessageDateComponents.year != currMessagedateComponents.year || prevMessageDateComponents.month != currMessagedateComponents.month || prevMessageDateComponents.day != currMessagedateComponents.day {
                // Show date seperator.
                self.dateSeperatorView.isHidden = false
                self.dateSeperatorViewHeight.constant = 24.0
                self.dateSeperatorViewTopMargin.constant = 10.0
                self.dateSeperatorViewBottomMargin.constant = 10.0
            }
            else {
                // Hide date seperator.
                self.dateSeperatorView.isHidden = true
                self.dateSeperatorViewHeight.constant = 0
                self.dateSeperatorViewBottomMargin.constant = 0
                
                // Continuous Message
                if self.prevMessage is SBDAdminMessage {
                    self.dateSeperatorViewTopMargin.constant = 10.0
                }
                else {
                    var prevMessageSender: SBDUser?
                    var currMessageSender: SBDUser?
                    
                    if self.prevMessage is SBDUserMessage {
                        prevMessageSender = (self.prevMessage as! SBDUserMessage).sender
                    }
                    else if self.prevMessage is SBDFileMessage {
                        prevMessageSender = (self.prevMessage as! SBDFileMessage).sender
                    }
                    
                    currMessageSender = self.message.sender
                    
                    if prevMessageSender != nil && currMessageSender != nil {
                        if prevMessageSender?.userId == currMessageSender?.userId {
                            // Reduce margin
                            self.dateSeperatorViewTopMargin.constant = 5.0
                        }
                        else {
                            // Set default margin.
                            self.dateSeperatorViewTopMargin.constant = 10.0
                        }
                    }
                    else {
                        self.dateSeperatorViewTopMargin.constant = 10.0
                    }
                }
            }
        }
        else {
            // Show date seperator.
            self.dateSeperatorView.isHidden = false
            self.dateSeperatorViewHeight.constant = 24.0
            self.dateSeperatorViewTopMargin.constant = 10.0
            self.dateSeperatorViewBottomMargin.constant = 10.0
        }
        
        self.layoutIfNeeded()
    }
    
    func setPreviousMessage(aPrevMessage: SBDBaseMessage?) {
        self.prevMessage = aPrevMessage
    }
    
    func getHeightOfViewCell() -> CGFloat {
        let height = self.dateSeperatorViewTopMargin.constant + self.dateSeperatorViewHeight.constant + self.dateSeperatorViewBottomMargin.constant + self.messageContainerViewTopPadding.constant + self.messageContainerViewBottomPadding.constant + self.fileContainerViewHeight.constant
        
        return height
    }
    
    func hideUnreadCount() {
        self.unreadCountLabel.isHidden = true
    }
    
    func showUnreadCount() {
        if self.message.channelType == CHANNEL_TYPE_GROUP {
            self.unreadCountLabel.isHidden = false
            self.resendMessageButton.isHidden = true
            self.deleteMessageButton.isHidden = true
        }
    }
    
    func hideMessageControlButton() {
        self.resendMessageButton.isHidden = true
        self.deleteMessageButton.isHidden = true
    }
    
    func showMessageControlButton() {
        self.sendStatusLabel.isHidden = true
        self.messageDateLabel.isHidden = true
        self.unreadCountLabel.isHidden = true
        
        self.resendMessageButton.isHidden = false
        self.deleteMessageButton.isHidden = false
    }
    
    func showSendingStatus() {
        self.messageDateLabel.isHidden = true
        self.unreadCountLabel.isHidden = true
        self.resendMessageButton.isHidden = true
        self.deleteMessageButton.isHidden = true
        
        self.sendStatusLabel.isHidden = false
        self.sendStatusLabel.text = "Sending"
    }
    
    func showFailedStatus() {
        self.messageDateLabel.isHidden = true
        self.unreadCountLabel.isHidden = true
        self.resendMessageButton.isHidden = true
        self.deleteMessageButton.isHidden = true
        
        self.sendStatusLabel.isHidden = false
        self.sendStatusLabel.text = "Failed"
    }
    
    func showMessageDate() {
        self.unreadCountLabel.isHidden = true
        self.resendMessageButton.isHidden = true
        self.sendStatusLabel.isHidden = true
        
        self.messageDateLabel.isHidden = false
    }
}
