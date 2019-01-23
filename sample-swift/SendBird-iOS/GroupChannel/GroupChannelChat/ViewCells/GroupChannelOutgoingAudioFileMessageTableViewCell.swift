//
//  GroupChannelOutgoingAudioFileMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/6/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK


class GroupChannelOutgoingAudioFileMessageTableViewCell: UITableViewCell {
    weak var delegate: GroupChannelMessageTableViewCellDelegate?
    var channel: SBDGroupChannel?
    
    private var msg: SBDFileMessage?
    private var hideMessageStatus: Bool = false
    private var hideReadCount: Bool = false
    
    @IBOutlet weak var dateSeperatorContainerView: UIView!
    @IBOutlet weak var dateSeperatorLabel: UILabel!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var messageStatusContainerView: UIView!
    @IBOutlet weak var resendButtonContainerView: UIView!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var fileTransferProgressViewContainerView: UIView!
    @IBOutlet weak var fileTransferProgressCircleView: CustomProgressCircle!
    @IBOutlet weak var fileTransferProgressLabel: UILabel!
    @IBOutlet weak var readStatusContainerView: UIView!
    @IBOutlet weak var sendingFailureContainerView: UIView!
    @IBOutlet weak var sendingFlagImageView: UIImageView!
    @IBOutlet weak var readStatusLabel: UILabel!
    
    @IBOutlet weak var dateSeperatorContainerViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var messageStatusContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var messageContainerViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var messageContainerViewBottomMargin: NSLayoutConstraint!
    
    static public let kDateSeperatorContainerViewTopMargin: CGFloat = 3.0
    static public let kDateSeperatorContainerViewHeight: CGFloat = 65.0
    static public let kMessageContainerViewTopMarginNormal: CGFloat = 6.0
    static public let kMessageContainerViewTopMarginReduced: CGFloat = 3.0
    static public let kMessageContainerViewBottomMarginNormal: CGFloat = 14.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setMessage(currMessage: SBDFileMessage, prevMessage: SBDBaseMessage?, nextMessage: SBDBaseMessage?, failed: Bool) {
        var hideDateSeperator = false
        self.hideMessageStatus = false
        var decreaseTopMargin = false
        self.hideReadCount = false
        
        self.msg = currMessage
        
        let longClickMessageContainerGesture = UILongPressGestureRecognizer(target: self, action: #selector(GroupChannelOutgoingAudioFileMessageTableViewCell.longClickAudioFileMessage(_:)))
        self.messageContainerView.addGestureRecognizer(longClickMessageContainerGesture)
        
        let clickMessageContainteGesture = UITapGestureRecognizer(target: self, action: #selector(GroupChannelOutgoingAudioFileMessageTableViewCell.clickAudioFileMessage(_:)))
        self.messageContainerView.addGestureRecognizer(clickMessageContainteGesture)
        
        self.resendButton.addTarget(self, action: #selector(GroupChannelOutgoingAudioFileMessageTableViewCell.clickResendAudioMessage(_:)), for: .touchUpInside)
        
        let filename = NSAttributedString(string: self.msg!.name, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.white as Any,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0, weight: .regular),
            ])
        self.fileNameLabel.attributedText = filename
        
        var prevMessageSender: SBDUser?
        var nextMessageSender: SBDUser?
        
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
                    self.hideReadCount = true
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
                self.hideMessageStatus = false
            }
            else {
                self.hideMessageStatus = true
            }
        }
        else {
            self.hideMessageStatus = false
        }
        
        if hideDateSeperator {
            self.dateSeperatorContainerView.isHidden = true
            self.dateSeperatorContainerViewHeight.constant = 0
            self.dateSeperatorContainerViewTopMargin.constant = 0
        }
        else {
            self.dateSeperatorContainerView.isHidden = false
            self.dateSeperatorLabel.text = Utils.getDateStringForDateSeperatorFromTimestamp((self.msg?.createdAt)!)
            self.dateSeperatorContainerViewHeight.constant = GroupChannelOutgoingAudioFileMessageTableViewCell.kDateSeperatorContainerViewHeight
            self.dateSeperatorContainerViewTopMargin.constant = GroupChannelOutgoingAudioFileMessageTableViewCell.kDateSeperatorContainerViewTopMargin
        }
        
        if decreaseTopMargin {
            self.messageContainerViewTopMargin.constant = GroupChannelOutgoingAudioFileMessageTableViewCell.kMessageContainerViewTopMarginReduced
        }
        else {
            self.messageContainerViewTopMargin.constant = GroupChannelOutgoingAudioFileMessageTableViewCell.kMessageContainerViewTopMarginNormal
        }
        
        if self.hideMessageStatus && self.hideReadCount && !failed {
            self.messageDateLabel.text = ""
            self.messageStatusContainerView.isHidden = true
            self.messageContainerViewBottomMargin.constant = 0
            self.readStatusContainerView.isHidden = true
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
    
    func getMessage() -> SBDFileMessage? {
        return self.msg
    }
    
    func showProgress(_ progress: CGFloat) {
        if progress < 1.0 {
            self.messageDateLabel.isHidden = true
            self.fileTransferProgressViewContainerView.isHidden = false
            self.sendingFailureContainerView.isHidden = true
            self.readStatusContainerView.isHidden = true
            
            self.fileTransferProgressCircleView.drawCircle(progress: progress)
            self.fileTransferProgressLabel.text = String(format: "%.2lf%%", progress * 100.0)
            self.messageContainerViewBottomMargin.constant = GroupChannelOutgoingAudioFileMessageTableViewCell.kMessageContainerViewBottomMarginNormal
        }
        else {
            self.messageDateLabel.isHidden = false
            self.fileTransferProgressViewContainerView.isHidden = true
            self.sendingFailureContainerView.isHidden = true
            self.readStatusContainerView.isHidden = false

            if self.hideMessageStatus && self.hideReadCount {
                self.messageContainerViewBottomMargin.constant = 0
            }
            else {
                self.messageContainerViewBottomMargin.constant = GroupChannelOutgoingAudioFileMessageTableViewCell.kMessageContainerViewBottomMarginNormal
            }
        }
    }
    
    func hideElementsForFailure() {
        self.fileTransferProgressViewContainerView.isHidden = true
        self.resendButtonContainerView.isHidden = true
        self.resendButton.isEnabled = false
        self.sendingFailureContainerView.isHidden = true
        self.messageContainerViewBottomMargin.constant = 0
    }
    
    func showElementsForFailure() {
        self.fileTransferProgressViewContainerView.isHidden = true
        self.resendButtonContainerView.isHidden = false
        self.resendButton.isEnabled = true
        self.sendingFailureContainerView.isHidden = false
        self.messageContainerViewBottomMargin.constant = GroupChannelOutgoingAudioFileMessageTableViewCell.kMessageContainerViewBottomMarginNormal
    }
    
    func showReadStatus(readCount: Int) {
        self.sendingFlagImageView.isHidden = true
        self.readStatusContainerView.isHidden = false
        self.readStatusLabel.text = String(format: "Read %lu ∙", readCount)
    }
    
    func hideReadStatus() {
        self.sendingFlagImageView.isHidden = true
        self.readStatusContainerView.isHidden = true
    }
    
    func hideProgress() {
        self.fileTransferProgressViewContainerView.isHidden = true
        self.sendingFailureContainerView.isHidden = true
    }
    
    func showBottomMargin() {
        self.messageContainerViewBottomMargin.constant = GroupChannelOutgoingAudioFileMessageTableViewCell.kMessageContainerViewBottomMarginNormal
    }
    
    @objc func longClickAudioFileMessage(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            if let delegate = self.delegate {
                if delegate.responds(to: #selector(GroupChannelMessageTableViewCellDelegate.didLongClickGeneralFileMessage(_:))) {
                    delegate.didLongClickGeneralFileMessage!(self.msg!)
                }
            }
        }
    }
    
    @objc func clickResendImageFileMessage(_ sender: AnyObject) {
        // TODO:
    }
    
    @objc func clickAudioFileMessage(_ recognizer: UITapGestureRecognizer) {
        if self.msg!.type.hasPrefix("audio") {
            if let delegate = self.delegate {
                if delegate.responds(to: #selector(GroupChannelMessageTableViewCellDelegate.didClickAudioFileMessage(_:))) {
                    delegate.didClickAudioFileMessage!(self.msg!)
                }
            }
        }
    }
    
    @objc func clickResendAudioMessage(_ sender: AnyObject) {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(GroupChannelMessageTableViewCellDelegate.didClickResendAudioGeneralFileMessage(_:))) {
                delegate.didClickResendAudioGeneralFileMessage!(self.msg!)
            }
        }
    }
}
