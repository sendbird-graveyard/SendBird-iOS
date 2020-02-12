//
//  MessageOutgoingAudioFileCell.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 11/29/19.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class MessageOutgoingAudioFileCell: MessageOutgoingCell {
 
    private var hideMessageStatus: Bool = false
    private var hideReadCount: Bool = false
    
    @IBOutlet weak var fileNameLabel: UILabel!

    @IBOutlet weak var fileTransferProgressViewContainerView: UIView!
    @IBOutlet weak var fileTransferProgressCircleView: CustomProgressCircle!
    @IBOutlet weak var fileTransferProgressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.messageCellType = .audio
        
        let longClickMessageContainerGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(MessageOutgoingAudioFileCell.longClickAudioFileMessage(_:))
        )
        
        let clickMessageContainteGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(MessageOutgoingAudioFileCell.clickAudioFileMessage(_:))
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
        self.resendButton.addTarget(self, action: #selector(MessageOutgoingAudioFileCell.clickResendAudioMessage(_:)), for: .touchUpInside)
        
        let filename = NSAttributedString(
            string: fileMessage.name,
            attributes: [ .foregroundColor: UIColor.white as Any,
                          .underlineStyle: NSUnderlineStyle.single.rawValue,
                          .font: UIFont.systemFont(ofSize: 12.0, weight: .regular)
        ])
        
        self.fileNameLabel.attributedText = filename
        
        switch message.requestState() {
        case .pending:
            // Outgoing audio file message
            self.hideReadStatus()
            self.hideFailureElement()
            self.showBottomMargin()
            
            DispatchQueue.main.async {
                if let progress = self.model.progress {
                    self.showProgress(progress)
                }
            }
              
        case .failed:
            // Failed outgoing audio file message
            self.hideReadStatus()
            self.hideProgress()
            self.showFailureElement()
            self.showBottomMargin()
              
        case .succeeded:
            // Outgoing audio file message
            self.showProgress(1.0)
             
        case .none:
            assertionFailure()
            
        @unknown default:
            assertionFailure()
        }
        
    }
     
    override func showProgress(_ progress: CGFloat) {
        if progress < 1.0 {
            self.messageDateLabel.isHidden = true
            self.fileTransferProgressViewContainerView.isHidden = false
            self.sendingFailureContainerView.isHidden = true
            self.readStatusContainerView.isHidden = true
            
            self.fileTransferProgressCircleView.drawCircle(progress: progress)
            self.fileTransferProgressLabel.text = String(format: "%.2lf%%", progress * 100.0)
            self.messageContainerViewBottomMargin.constant = Constants.messageContainerViewBottomMarginNormal
            
        } else {
            self.messageDateLabel.isHidden = false
            self.fileTransferProgressViewContainerView.isHidden = true
            self.sendingFailureContainerView.isHidden = true
            self.readStatusContainerView.isHidden = false
            
            if self.hideMessageStatus && self.hideReadCount {
                self.messageContainerViewBottomMargin.constant = 0
                
            } else {
                self.messageContainerViewBottomMargin.constant = Constants.messageContainerViewBottomMarginNormal
            }
        }
    }
    
    override func hideProgress() {
        self.fileTransferProgressViewContainerView.isHidden = true
        self.sendingFailureContainerView.isHidden = true
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
    
    @objc func longClickAudioFileMessage(_ recognizer: UILongPressGestureRecognizer) {
        guard let message = self.message as? SBDFileMessage, recognizer.state == .began else { return }
        delegate?.didLongClickGeneralFileMessage?(message)
    }
    
    @objc func clickResendImageFileMessage(_ sender: AnyObject) {

    }
    
    @objc func clickAudioFileMessage(_ recognizer: UITapGestureRecognizer) {
        guard let message = self.message as? SBDFileMessage, message.type.hasPrefix("audio") else { return }
        delegate?.didClickAudioFileMessage?(message)
    }
    
    @objc func clickResendAudioMessage(_ sender: AnyObject) {
        guard let message = self.message as? SBDFileMessage else { return }
        delegate?.didClickResendAudioGeneralFileMessage?(message)
    }
}
 
extension MessageOutgoingAudioFileCell {
    
}
