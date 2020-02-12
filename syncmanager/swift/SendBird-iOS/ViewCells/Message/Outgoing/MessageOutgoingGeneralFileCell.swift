//
//  MessageOutgoingGeneralFileCell.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 11/29/19.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class MessageOutgoingGeneralFileCell: MessageOutgoingCell {
    
    var hideMessageStatus: Bool = false
    var hideReadCount: Bool = false
    
  
    @IBOutlet weak var fileNameLabel: UILabel!
  
    @IBOutlet weak var fileTransferProgressViewContainerView: UIView!
    @IBOutlet weak var fileTransferProgressCircleView: CustomProgressCircle!
    @IBOutlet weak var fileTransferProgressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.messageCellType = .file
        
        let longClickMessageContainerGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(MessageOutgoingGeneralFileCell.longClickGeneralFileMessage(_:)))

        let clickMessageContainteGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(MessageOutgoingGeneralFileCell.clickGeneralFileMessage(_:))
        )
        
        self.messageContainerView.addGestureRecognizer(longClickMessageContainerGesture)
        self.messageContainerView.addGestureRecognizer(clickMessageContainteGesture)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func configure(with model: MessageModel) {
        super.configure(with: model)
        
        guard let fileMessage = model.message as? SBDFileMessage else {
            assertionFailure("Message must be SBDFileMessage")
            return
        }
        
        self.hideMessageStatus = false
        self.hideReadCount = false
         
        self.resendButton.addTarget(self, action: #selector(MessageOutgoingGeneralFileCell.clickGeneralFileMessage(_:)), for: .touchUpInside)
        
        let filename = NSAttributedString(string: fileMessage.name, attributes: [
            .foregroundColor: UIColor(named: "color_group_channel_message_text") as Any,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: UIFont.systemFont(ofSize: 14.0, weight: .medium),
        ])
        self.fileNameLabel.attributedText = filename

        switch self.message.requestState() {
        case .pending:
            
            // Outgoing general file message
            self.hideReadStatus()
            self.hideFailureElement()
            self.showBottomMargin()
            self.delegate = nil
            
            DispatchQueue.main.async {
                guard let progress = self.model.progress else { return }
                self.showProgress(progress)
                
            }
             
            
        case .failed:
            assertionFailure("Need Logic")
            
        case .succeeded:
            self.showProgress(1.0)
              
        case .none:
            assertionFailure()
            
        @unknown default:
            assertionFailure()

        }
        
        
    }
     
    override func showProgress(_ progress: CGFloat) {
        if progress < 1.0 {
            self.fileTransferProgressViewContainerView.isHidden = false
            self.sendingFailureContainerView.isHidden = true
            self.readStatusContainerView.isHidden = true
            
            self.fileTransferProgressCircleView.drawCircle(progress: progress)
            self.fileTransferProgressLabel.text = String(format: "%.2lf%%", progress * 100.0)
            self.messageContainerViewBottomMargin.constant = Constants.messageContainerViewBottomMarginNormal
            
        } else {
            self.fileTransferProgressViewContainerView.isHidden = true
            self.sendingFailureContainerView.isHidden = true
            self.readStatusContainerView.isHidden = false
            
            if self.hideMessageStatus && self.hideReadCount {
                self.messageContainerViewBottomMargin.constant = 0
            }
            else {
                self.messageContainerViewBottomMargin.constant = Constants.messageContainerViewBottomMarginNormal
            }
        }
    }
    
    override func hideFailureElement() {
        self.fileTransferProgressViewContainerView.isHidden = true
        self.messageContainerViewBottomMargin.constant = 0
        super.hideFailureElement()
    }
    
    override func showFailureElement() {
        self.fileTransferProgressViewContainerView.isHidden = true
        self.messageContainerViewBottomMargin.constant = Constants.messageContainerViewBottomMarginNormal
        super.showFailureElement()
    }
    
    func showBottomMargin() {
        self.messageContainerViewBottomMargin.constant = Constants.messageContainerViewBottomMarginNormal
    }
    
    @objc func longClickGeneralFileMessage(_ recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .began, let message = self.message as? SBDFileMessage else { return }
        delegate?.didLongClickGeneralFileMessage?(message)
    }
    
    @objc func clickResendGeneralMessage(_ sender: AnyObject) {
        guard let message = self.message as? SBDFileMessage else { return }
        delegate?.didClickResendAudioGeneralFileMessage?(message)
    }
    
    @objc func clickGeneralFileMessage(_ recognizer: UITapGestureRecognizer) {
        guard let message = self.message as? SBDFileMessage else { return }
        self.hero.isEnabled = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hero.isEnabled = false
        }
        
        if message.type.hasPrefix("video") {
            delegate?.didClickVideoFileMessage?(message)
        } else {
            delegate?.didClickGeneralFileMessage?(message)
        }
    }
}
 
