//
//  OpenChannelImageVideoFileMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/18/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import FLAnimatedImage
import AlamofireImage

class OpenChannelImageVideoFileMessageTableViewCell: UITableViewCell {
    var imageHash: Int?
    
    weak var delegate: OpenChannelMessageTableViewCellDelegate?
    
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var resendButtonContainerView: UIView!
    @IBOutlet weak var resendButton: UIButton!
    
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var fileImageView: FLAnimatedImageView!
    @IBOutlet weak var imageMessagePlaceholderImageView: UIImageView!
    
    @IBOutlet weak var fileTransferProgressViewContainerView: UIView!
    @IBOutlet weak var fileTransferProgressCircleView: CustomProgressCircle!
    @IBOutlet weak var fileTransferProgressLabel: UILabel!
    @IBOutlet weak var sendingFailureContainerView: UIView!
    
    @IBOutlet weak var messageContainerViewBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var fileImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var videoPlayIconImageView: UIImageView!
    @IBOutlet weak var videoMessagePlaceholderImageView: UIImageView!
    
    var channel: SBDOpenChannel?
    
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
        self.resendButton.addTarget(self, action: #selector(self.clickResendImageFileMessage(_:)), for: .touchUpInside)
        
        let longClickMessageGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longClickMessage(_:)))
        self.messageContainerView.addGestureRecognizer(longClickMessageGesture)
        
        let clickMessageContainerGesture = UITapGestureRecognizer(target: self, action: #selector(self.clickImageVideoFileMessage(_:)))
        self.messageContainerView.addGestureRecognizer(clickMessageContainerGesture)
        
        let longClickProfileGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longClickProfile(_:)))
        self.profileContainerView.addGestureRecognizer(longClickProfileGesture)
        
        let clickProfileGesture = UITapGestureRecognizer(target: self, action: #selector(self.clickProfile(_:)))
        self.profileContainerView.addGestureRecognizer(clickProfileGesture)
        
        if self.msg!.sender?.nickname!.count == 0 {
            self.nicknameLabel.text = ""
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
        self.fileTransferProgressLabel.text = String(format: "%.2lf%%", (progress * 100.0))
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
        self.messageContainerViewBottomMargin.constant = OpenChannelImageVideoFileMessageTableViewCell.kMessageContainerViewBottomMarginNormal
    }
    
    func hideBottomMargin() {
        self.messageContainerViewBottomMargin.constant = 0
    }
    
    func hideAllPlaceholders() {
        self.videoPlayIconImageView.isHidden = true
        self.imageMessagePlaceholderImageView.isHidden = true
        self.videoMessagePlaceholderImageView.isHidden = true
    }
    
    @objc func clickResendImageFileMessage(_ sender: AnyObject) {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(OpenChannelMessageTableViewCellDelegate.didClickResendImageFileMessageButton(_:))) {
                delegate.didClickResendImageFileMessageButton!(self.msg!)
            }
        }
    }
    
    @objc func clickImageVideoFileMessage(_ recognizer: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(OpenChannelMessageTableViewCellDelegate.didClickImageVideoFileMessage(_:))) {
                delegate.didClickImageVideoFileMessage!(self.msg!)
            }
        }
    }
    
    @objc func longClickMessage(_ recognizer: UILongPressGestureRecognizer) {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(OpenChannelMessageTableViewCellDelegate.didLongClickImageVideoFileMessage(_:))) {
                delegate.didLongClickImageVideoFileMessage!(self.msg!)
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
    
    @objc func clickProfile(_ recognizer: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(OpenChannelMessageTableViewCellDelegate.didClickUserProfile(_:))) {
                delegate.didClickUserProfile!(self.msg!.sender!)
            }
        }
    }
    
    func setAnimated(image: FLAnimatedImage?, hash: Int) {
        if image == nil || hash == 0 {
            self.imageHash = 0
            self.fileImageView.animatedImage = nil
            self.fileImageView.image = nil
        }
        else {
            if self.imageHash == 0 || self.imageHash != hash {
                self.fileImageView.image = nil
                self.fileImageView.animatedImage = image
                self.imageHash = hash
            }
        }
    }
    
    func setImage(_ image: UIImage?) {
        if image == nil {
            self.imageHash = 0
            self.fileImageView.animatedImage = nil
            self.fileImageView.image = nil
        }
        else {
            let newImageHash = image!.jpegData(compressionQuality: 0.5).hashValue
            if self.imageHash == 0 || self.imageHash != newImageHash {
                self.fileImageView.animatedImage = nil
                self.fileImageView.image = image
                self.imageHash = newImageHash
            }
        }
    }
}
