//
//  OpenChannelUserMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/18/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class OpenChannelUserMessageTableViewCell: UITableViewCell {
    weak var delegate: OpenChannelMessageTableViewCellDelegate?
    var msg: SBDUserMessage?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileImageContainerView: UIView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var resendButtonContainerView: UIView!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var sendingFailureContainerView: UIView!
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var messageContainerViewBottomMargin: NSLayoutConstraint!
    
    static let kMessageContainerViewBottomMarginNormal: CGFloat = 14.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setMessage(_ message: SBDUserMessage) {
        self.msg = message
        
        self.resendButton.addTarget(self, action: #selector(OpenChannelUserMessageTableViewCell.clickResendUserMessageButton(_:)), for: .touchUpInside)
        
        let longClickMessageContainerGesture = UILongPressGestureRecognizer(target: self, action: #selector(OpenChannelUserMessageTableViewCell.longClickUserMessage(_:)))
        self.messageContainerView.addGestureRecognizer(longClickMessageContainerGesture)
        
        let longClickProfileGesture = UILongPressGestureRecognizer(target: self, action: #selector(OpenChannelUserMessageTableViewCell.longClickProfile(_:)))
        self.profileImageContainerView.addGestureRecognizer(longClickProfileGesture)
        
        let clickProfileGesture = UITapGestureRecognizer(target: self, action: #selector(OpenChannelUserMessageTableViewCell.clickProfile(_:)))
        self.profileImageContainerView.addGestureRecognizer(clickProfileGesture)
        
        self.messageLabel.text = self.msg?.message
        if self.msg!.sender?.nickname!.count == 0 {
            self.nicknameLabel.text = " "
        }
        else {
            self.nicknameLabel.text = self.msg!.sender?.nickname
        }
    }
    
    func getMessage() -> SBDUserMessage? {
        return self.msg
    }
    
    func hideElementsForFailure() {
        self.resendButtonContainerView.isHidden = true
        self.resendButton.isEnabled = false
        self.sendingFailureContainerView.isHidden = true
        self.messageContainerViewBottomMargin.constant = 0
    }
    
    func showElementsForFailure() {
        self.resendButtonContainerView.isHidden = false
        self.resendButton.isEnabled = true
        self.sendingFailureContainerView.isHidden = false
        self.messageContainerViewBottomMargin.constant = OpenChannelUserMessageTableViewCell.kMessageContainerViewBottomMarginNormal
    }
    
    @objc func clickResendUserMessageButton(_ sender: AnyObject) {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(OpenChannelMessageTableViewCellDelegate.didClickResendUserMessageButton(_:))) {
                delegate.didClickResendUserMessageButton!(self.msg!)
            }
        }
    }
    
    @objc func longClickProfile(_ recognizer: UILongPressGestureRecognizer) {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(OpenChannelMessageTableViewCellDelegate.didLongClickUserProfile(_:))) {
                delegate.didLongClickUserProfile!(self.msg!.sender!)
            }
        }
    }
    
    @objc func longClickUserMessage(_ recognizer: UILongPressGestureRecognizer) {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(OpenChannelMessageTableViewCellDelegate.didLongClickUserMessage(_:))) {
                delegate.didLongClickUserMessage!(self.msg!)
            }
        }
    }
    
    @objc func clickProfile(_ recognizer: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(OpenChannelMessageTableViewCellDelegate.didClickUserProfile(_:))) {
                delegate.didClickUserProfile!(self.msg!.sender!)
            }
        }
    }
}
