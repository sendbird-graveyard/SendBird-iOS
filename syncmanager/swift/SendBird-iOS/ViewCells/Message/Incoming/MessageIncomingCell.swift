//
//  MessageIncomingCell.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 11/29/19.
//  Copyright © 2019 SendBird. All rights reserved.
//
 
import UIKit
import SendBirdSDK 
import FLAnimatedImage
 
class MessageIncomingCell: MessageCell {

    @IBOutlet weak var dateSeperatorContainerView: UIView!
    @IBOutlet weak var dateSeperatorLabel: UILabel!
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var messageStatusContainerView: UIView!
    @IBOutlet weak var messageContainerView: UIView!
    
    @IBOutlet weak var dateSeperatorContainerViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var nicknameContainerViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var messageStatusContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var messageContainerViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var messageContainerViewBottomMargin: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let longClickProfileGesture = UILongPressGestureRecognizer(target: self, action: #selector(MessageIncomingCell.longClickProfile(_:)))
        self.profileContainerView.addGestureRecognizer(longClickProfileGesture)

        let clickProfileGesture = UITapGestureRecognizer(target: self, action: #selector(MessageIncomingCell.clickProfile(_:)))
        self.profileContainerView.addGestureRecognizer(clickProfileGesture)
        // Initialization code
    }
    
    override func configure(with model: MessageModel) {
        super.configure(with: model)
        
        var hideDateSeperator = false
        var hideProfileImage = false
        
        guard let sender = model.message.getSender() else { return }
        self.profileImageView.setProfileImageView(for: sender)
    
        if model.isPrevMessageSameDay {
            
            self.dateSeperatorContainerView.isHidden = true
            self.dateSeperatorLabel.text = ""
            self.dateSeperatorContainerViewHeight.constant = 0
            self.dateSeperatorContainerViewTopMargin.constant = 0
            self.nicknameContainerViewTopMargin.constant = 0
            hideDateSeperator = true
            
        } else {
            
            self.dateSeperatorContainerView.isHidden = false
            self.dateSeperatorLabel.text = Utils.getDateStringForDateSeperatorFromTimestamp(self.message.createdAt)
            self.dateSeperatorContainerViewHeight.constant = Constants.dateSeperatorContainerViewHeight
            self.dateSeperatorContainerViewTopMargin.constant = Constants.dateSeperatorContainerViewIncomingTopMargin
            self.nicknameContainerViewTopMargin.constant = Constants.nicknameContainerViewTopMargin
            hideDateSeperator = false
            
        }
        
        if model.isPrevMessageSameUser, hideDateSeperator {
            self.nicknameLabel.text = ""
            self.nicknameContainerViewTopMargin.constant = 0
            self.messageContainerViewTopMargin.constant = Constants.messageContainerViewTopMarginNoNickname
        } else {
            let nickname = sender.nickname ?? ""
            self.nicknameLabel.text = nickname.isEmpty ? " " : sender.nickname
            self.nicknameContainerViewTopMargin.constant = Constants.nicknameContainerViewTopMargin
            self.messageContainerViewTopMargin.constant = Constants.messageContainerViewTopMarginNormal
        }
        
        if model.isNextMessageSameUser {
            hideProfileImage = model.isNextMessageSameDay
        } else {
            hideProfileImage = false
        }
        
        if hideProfileImage {
            self.messageDateLabel.text = ""
            self.profileContainerView.isHidden = true
            self.messageStatusContainerView.isHidden = true
            self.messageContainerViewBottomMargin.constant = 0
        }
        else {
            self.messageDateLabel.text = Utils.getMessageDateStringFromTimestamp(self.message.createdAt)
            self.profileContainerView.isHidden = false
            self.messageStatusContainerView.isHidden = false
            self.messageContainerViewBottomMargin.constant = Constants.messageContainerViewBottomMarginNormal
        }

        
    }
    
    @objc func longClickProfile(_ recognizer: UILongPressGestureRecognizer) {
        guard let sender = self.message.getSender() else { return }
        if recognizer.state == .began {
            self.delegate?.didLongClickUserProfile?(sender)
        }
    }
    
    @objc func clickProfile(_ recognizer: UILongPressGestureRecognizer) {
        guard let sender = self.message.getSender() else { return }
        self.delegate?.didClickUserProfile?(sender)
    }
    
    
}
