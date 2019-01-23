//
//  GroupChannelOutgoingUserMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/6/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class GroupChannelOutgoingUserMessageTableViewCell: UITableViewCell {
    weak var delegate: GroupChannelMessageTableViewCellDelegate?
    var channel: SBDGroupChannel?
    
    @IBOutlet weak var dateSeperatorContainerView: UIView!
    @IBOutlet weak var dateSeperatorLabel: UILabel!
    @IBOutlet weak var textMessageLabel: UILabel!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var messageStatusContainerView: UIView!
    @IBOutlet weak var resendButtonContainerView: UIView!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var sendingFailureContainerView: UIView!
    @IBOutlet weak var readStatusContainerView: UIView!
    @IBOutlet weak var readStatusLabel: UILabel!
    @IBOutlet weak var sendingFlagImageView: UIImageView!
    @IBOutlet weak var messageContainerView: UIView!
    
    @IBOutlet weak var dateSeperatorContainerViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var messageStatusContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var messageContainerViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var messageContainerViewBottomMargin: NSLayoutConstraint!
    
    private var msg: SBDUserMessage?
    
    static let kDateSeperatorContainerViewTopMargin: CGFloat = 0.0
    static let kDateSeperatorContainerViewHeight: CGFloat = 65.0
    static let kMessageContainerViewTopMarginNormal: CGFloat = 6.0
    static let kMessageContainerViewTopMarginReduced: CGFloat = 3.0
    static let kMessageContainerViewBottomMarginNormal: CGFloat = 14.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setMessage(currMessage: SBDUserMessage, prevMessage: SBDBaseMessage?, nextMessage: SBDBaseMessage?, failed: Bool) {
        var hideDateSeperator = false
        var hideMessageStatus = false
        var decreaseTopMargin = false
        var hideReadCount = false
        
        let longClickMessageContainerGesture = UILongPressGestureRecognizer(target: self, action: #selector(GroupChannelOutgoingUserMessageTableViewCell.longClickUserMessage(_:)))
        self.messageContainerView.addGestureRecognizer(longClickMessageContainerGesture)
        
        self.resendButton.addTarget(self, action: #selector(GroupChannelOutgoingUserMessageTableViewCell.clickResendUserMessage(_:)), for: .touchUpInside)
        
        self.msg = currMessage
        
        var prevMessageSender: SBDUser?
        var nextMessageSender: SBDUser?
        
        self.textMessageLabel.text = self.msg?.message
        
        if prevMessage != nil {
            if prevMessage is SBDUserMessage {
                prevMessageSender = (prevMessage as! SBDUserMessage).sender
            }
            else if prevMessage is SBDFileMessage {
                prevMessageSender = (prevMessage as! SBDFileMessage).sender
            }
        }
        
        if nextMessage != nil {
            if nextMessage is SBDUserMessage {
                nextMessageSender = (nextMessage as! SBDUserMessage).sender
            }
            else if nextMessage is SBDFileMessage {
                nextMessageSender = (nextMessage as! SBDFileMessage).sender
            }
            
            if nextMessageSender != nil && nextMessageSender?.userId == self.msg!.sender?.userId {
                let nextReadCount = self.channel?.getReadMembers(with: nextMessage!, includeAllMembers: false).count
                let currReadCount = self.channel?.getReadMembers(with: self.msg!, includeAllMembers: false).count

                if nextReadCount == currReadCount {
                    hideReadCount = true
                }
            }
        }
        
        if prevMessage != nil && Utils.checkDayChangeDayBetweenOldTimestamp(oldTimestamp: (prevMessage?.createdAt)!, newTimestamp: (self.msg?.createdAt)!) {
            hideDateSeperator = false
        }
        else {
            hideDateSeperator = true
        }
        
        if prevMessageSender != nil && prevMessageSender?.userId == self.msg!.sender?.userId {
            if hideDateSeperator {
                decreaseTopMargin = true
            }
            else {
                decreaseTopMargin = false
            }
        }
        else {
            decreaseTopMargin = false
        }
        
        if nextMessageSender != nil && nextMessageSender?.userId == self.msg!.sender?.userId {
            if Utils.checkDayChangeDayBetweenOldTimestamp(oldTimestamp: (self.msg?.createdAt)!, newTimestamp: (nextMessage?.createdAt)!) {
                hideMessageStatus = false
            }
            else {
                hideMessageStatus = true
            }
        }
        else {
            hideMessageStatus = false
        }
        
        if hideDateSeperator {
            self.dateSeperatorContainerView.isHidden = true
            self.dateSeperatorContainerViewHeight.constant = 0
            self.dateSeperatorContainerViewTopMargin.constant = 0
        }
        else {
            self.dateSeperatorContainerView.isHidden = false
            self.dateSeperatorLabel.text = Utils.getDateStringForDateSeperatorFromTimestamp((self.msg?.createdAt)!)
            self.dateSeperatorContainerViewHeight.constant = GroupChannelOutgoingUserMessageTableViewCell.kDateSeperatorContainerViewHeight
            self.dateSeperatorContainerViewTopMargin.constant = GroupChannelOutgoingUserMessageTableViewCell.kDateSeperatorContainerViewTopMargin
        }
        
        if decreaseTopMargin {
            self.messageContainerViewTopMargin.constant = GroupChannelOutgoingUserMessageTableViewCell.kMessageContainerViewTopMarginReduced
        }
        else {
            self.messageContainerViewTopMargin.constant = GroupChannelOutgoingUserMessageTableViewCell.kMessageContainerViewTopMarginNormal
        }
        
        if hideMessageStatus && hideReadCount && !failed {
            self.messageDateLabel.text = ""
            self.messageStatusContainerView.isHidden = true
            self.readStatusContainerView.isHidden = true
            self.resendButtonContainerView.isHidden = true
            self.resendButton.isEnabled = false
            self.sendingFailureContainerView.isHidden = true
            self.messageContainerViewBottomMargin.constant = 0;
        }
        else {
            self.messageStatusContainerView.isHidden = false
            
            if (failed) {
                self.messageDateLabel.text = ""
                self.readStatusContainerView.isHidden = true
                self.resendButtonContainerView.isHidden = false
                self.resendButton.isEnabled = true
                self.sendingFailureContainerView.isHidden = false
                self.sendingFlagImageView.isHidden = true
            }
            else {
                self.messageDateLabel.text = Utils.getMessageDateStringFromTimestamp((self.msg?.createdAt)!)
                self.readStatusContainerView.isHidden = false
                self.showReadStatus(readCount: (self.channel?.getReadMembers(with: self.msg!, includeAllMembers: false).count)!)
                self.resendButtonContainerView.isHidden = true;
                self.resendButton.isEnabled = false
                self.sendingFailureContainerView.isHidden = true
                self.sendingFlagImageView.isHidden = true
            }
            
            self.messageContainerViewBottomMargin.constant = GroupChannelOutgoingUserMessageTableViewCell.kMessageContainerViewBottomMarginNormal
        }
    }
    
    func getMessage() -> SBDUserMessage? {
        return self.msg
    }
    
    func showReadStatus(readCount: Int) {
        self.sendingFlagImageView.isHidden = true
        self.readStatusContainerView.isHidden = false
        self.readStatusLabel.text = String(format: "Read %lu ∙", readCount)
    }
    
    @objc func clickResendUserMessage(_ sender: AnyObject) {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(GroupChannelMessageTableViewCellDelegate.didClickResendUserMessage(_:))) {
                delegate.didClickResendUserMessage!(self.msg!)
            }
        }
    }
    
    @objc func longClickUserMessage(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            if let delegate = self.delegate {
                if delegate.responds(to: #selector(GroupChannelMessageTableViewCellDelegate.didLongClickUserMessage(_:))) {
                    delegate.didLongClickUserMessage!(self.msg!)
                }
            }
        }
    }
}

