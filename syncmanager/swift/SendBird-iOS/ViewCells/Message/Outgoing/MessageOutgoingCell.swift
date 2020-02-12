//
//  MessageOutgoingCell.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 11/29/19.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class MessageOutgoingCell: MessageCell {
    
    @IBOutlet weak var dateSeperatorContainerView: UIView!
    @IBOutlet weak var dateSeperatorLabel: UILabel!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var messageStatusContainerView: UIView!
    @IBOutlet weak var resendButtonContainerView: UIView!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var sendingFailureContainerView: UIView!
    @IBOutlet weak var readStatusContainerView: UIView!
    @IBOutlet weak var readStatusLabel: UILabel!
    @IBOutlet weak var sendingFlagImageView: UIImageView!
    @IBOutlet weak var messageContainerView: UIView!
    
    @IBOutlet var sendingFailureContainerViewConstraint: NSLayoutConstraint!

    @IBOutlet weak var dateSeperatorContainerViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var messageStatusContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var messageContainerViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var messageContainerViewBottomMargin: NSLayoutConstraint!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func configure(with model: MessageModel) {
        super.configure(with: model)

        self.resendButton.addTarget(self, action: #selector(MessageOutgoingUserCell.clickResendUserMessage(_:)), for: .touchUpInside)
        
        var hideDateSeperator = false
        var hideMessageStatus = false
        var decreaseTopMargin = false
        var hideReadCount = false
         
        if model.isNextMessageSameUser {
            hideReadCount = true
        }
        
        if model.isPrevMessageSameDay {
            hideDateSeperator = true
            decreaseTopMargin = model.isPrevMessageSameUser ? true : decreaseTopMargin
        } else {
            hideDateSeperator = false
        }
        
        if model.isNextMessageSameUser {
            hideMessageStatus = model.isNextMessageSameDay
        } else {
            hideMessageStatus = false
        }
        
        if hideDateSeperator {
            self.dateSeperatorContainerView.isHidden = true
            self.dateSeperatorContainerViewHeight.constant = 0
            self.dateSeperatorContainerViewTopMargin.constant = 0
        } else {
            self.dateSeperatorContainerView.isHidden = false
            self.dateSeperatorLabel.text = Utils.getDateStringForDateSeperatorFromTimestamp(self.message.createdAt)
            self.dateSeperatorContainerViewHeight.constant = Constants.dateSeperatorContainerViewHeight
            self.dateSeperatorContainerViewTopMargin.constant = Constants.dateSeperatorContainerViewOutgoingTopMargin
        }
        
        if decreaseTopMargin {
            self.messageContainerViewTopMargin.constant = Constants.messageContainerViewTopMarginReduced
        } else {
            self.messageContainerViewTopMargin.constant = Constants.messageContainerViewTopMarginNormal
        }
        
        let failed = model.message.requestState() == .failed
        
        if hideMessageStatus, hideReadCount, !failed {
            self.messageDateLabel.text = ""
            self.messageStatusContainerView.isHidden = true
            self.readStatusContainerView.isHidden = true
            self.resendButtonContainerView.isHidden = true
            self.resendButton.isEnabled = false
            self.sendingFailureContainerView.isHidden = true
            self.sendingFailureContainerViewConstraint.isActive = false

            self.messageContainerViewBottomMargin.constant = 0
        } else {
            self.messageStatusContainerView.isHidden = false
            self.messageContainerViewBottomMargin.constant = Constants.messageContainerViewBottomMarginNormal
            if failed {
                self.messageDateLabel.text = ""
                self.readStatusContainerView.isHidden = true
                self.resendButtonContainerView.isHidden = false
                self.resendButton.isEnabled = true
                self.sendingFailureContainerViewConstraint.isActive = true

                self.sendingFailureContainerView.isHidden = false
                self.sendingFlagImageView.isHidden = true
            } else {
                self.messageDateLabel.text = Utils.getMessageDateStringFromTimestamp(self.message.createdAt)
                self.readStatusContainerView.isHidden = false
                self.showReadStatus(readCount: (self.channel?.getReadMembers(with: self.message, includeAllMembers: false).count)!)
                self.resendButtonContainerView.isHidden = true
                self.resendButton.isEnabled = false
                self.sendingFailureContainerViewConstraint.isActive = false

                self.sendingFailureContainerView.isHidden = true
                self.sendingFlagImageView.isHidden = true
            }
        }
        
    }
   
    func showProgress(_ progress: CGFloat) {
        // Please override this function
    }
     
    func hideProgress() {
        // Please override this function
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

    func hideFailureElement(){
        self.resendButtonContainerView.isHidden = true
        self.resendButton.isEnabled = false
        self.sendingFailureContainerView.isHidden = true
    }
    
    func showFailureElement(){
        self.resendButtonContainerView.isHidden = false
        self.resendButton.isEnabled = true
        self.sendingFailureContainerView.isHidden = false
    }
}
