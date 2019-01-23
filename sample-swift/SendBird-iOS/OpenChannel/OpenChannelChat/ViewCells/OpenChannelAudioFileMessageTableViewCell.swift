//
//  OpenChannelAudioFileMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/18/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class OpenChannelAudioFileMessageTableViewCell: UITableViewCell {
    weak var delegate: OpenChannelMessageTableViewCellDelegate?
    
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nicknameContainerView: UIView!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var filenameLabel: UILabel!
    
    @IBOutlet weak var resendButtonContainerView: UIView!
    @IBOutlet weak var resendButton: UIButton!
    
    @IBOutlet weak var fileTransferProgressViewContainerView: UIView!
    @IBOutlet weak var fileTransferProgressCircleView: CustomProgressCircle!
    @IBOutlet weak var fileTransferProgressLabel: UILabel!
    @IBOutlet weak var sendingFailureContainerView: UIView!
    
    @IBOutlet weak var messageContainerViewBottomMargin: NSLayoutConstraint!
    
    private var msg: SBDFileMessage?
    
    private static let kMessageContainerViewBottomMarginNormal: CGFloat = 14.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setMessage(_ message: SBDFileMessage) {
        self.msg = message
        
        let clickMessageGesture = UITapGestureRecognizer(target: self, action: #selector(self.clickMessage))
        self.messageContainerView.addGestureRecognizer(clickMessageGesture)
        
        let longClickMessageGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longClickMessage(_:)))
        self.messageContainerView.addGestureRecognizer(longClickMessageGesture)
        
        let longClickProfileGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longClickProfile(_:)))
        self.profileContainerView.addGestureRecognizer(longClickProfileGesture)
        
        let clickProfileGesture = UITapGestureRecognizer(target: self, action: #selector(self.clickProfile))
        self.profileContainerView.addGestureRecognizer(clickProfileGesture)
        
        self.filenameLabel.text = self.msg!.name
        
        if self.msg!.sender!.nickname!.count == 0 {
            self.nicknameLabel.text = " "
        }
        else {
            self.nicknameLabel.text = self.msg!.sender?.nickname
        }
    }
    
    func getMessage() -> SBDFileMessage? {
        return self.msg
    }
    
    func showProgress(_ progress: CGFloat) {
        self.fileTransferProgressViewContainerView.isHidden = false
        self.sendingFailureContainerView.isHidden = true
        self.fileTransferProgressCircleView.drawCircle(progress: progress)
        self.fileTransferProgressLabel.text = String(format: "%.2lf%%", progress * 100.0)
    }
    
    func hideProgress() {
        self.fileTransferProgressViewContainerView.isHidden = true
        self.sendingFailureContainerView.isHidden = true
    }
    
    func hideElementsForFailure() {
        self.fileTransferProgressViewContainerView.isHidden = true
        self.resendButtonContainerView.isHidden = true
        self.resendButton.isEnabled = false
        self.sendingFailureContainerView.isHidden = true
    }
    
    func showElementsForFailure() {
        self.fileTransferProgressViewContainerView.isHidden = true
        self.resendButtonContainerView.isHidden = false
        self.resendButton.isEnabled = true
        self.sendingFailureContainerView.isHidden = false
    }
    
    func showBottomMargin() {
        self.messageContainerViewBottomMargin.constant = OpenChannelAudioFileMessageTableViewCell.kMessageContainerViewBottomMarginNormal
    }
    
    func hideBottomMargin() {
        self.messageContainerViewBottomMargin.constant = 0
    }
    
    @objc func clickMessage() {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(OpenChannelMessageTableViewCellDelegate.didClickGeneralFileMessage(_:))) {
                delegate.didClickGeneralFileMessage!(self.msg!)
            }
        }
    }
    
    @objc func longClickMessage(_ recognizer: UILongPressGestureRecognizer) {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(OpenChannelMessageTableViewCellDelegate.didLongClickGeneralFileMessage(_:))) {
                delegate.didLongClickGeneralFileMessage!(self.msg!)
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
    
    @objc func clickProfile() {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(OpenChannelMessageTableViewCellDelegate.didClickUserProfile(_:))) {
                delegate.didClickUserProfile!(self.msg!.sender!)
            }
        }
    }
}
