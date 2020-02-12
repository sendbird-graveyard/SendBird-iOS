//
//  MessageOutgoingUserCell.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 11/29/19.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class MessageOutgoingUserCell: MessageOutgoingCell {
    
   
    @IBOutlet weak var textMessageLabel: UILabel!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.messageCellType = .user
        
        let longClickMessageContainerGesture = UILongPressGestureRecognizer(target: self, action: #selector(MessageOutgoingUserCell.longClickUserMessage(_:)))
        self.messageContainerView.addGestureRecognizer(longClickMessageContainerGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func configure(with model: MessageModel) {
        super.configure(with: model)
        
        guard let userMessage = model.message as? SBDUserMessage else {
            assertionFailure("Message type must UserMessage")
            return
        }
        
        self.resendButton.addTarget(self, action: #selector(MessageOutgoingUserCell.clickResendUserMessage(_:)), for: .touchUpInside)
        
        self.textMessageLabel.text = userMessage.message
        
    }
  
    @objc func clickResendUserMessage(_ sender: AnyObject) {
        guard let message = self.message as? SBDUserMessage else { return }
        delegate?.didClickResendUserMessage?(message)
    }
    
    @objc func longClickUserMessage(_ recognizer: UILongPressGestureRecognizer) {
        guard let message = self.message as? SBDUserMessage, recognizer.state == .began else { return }
        delegate?.didLongClickUserMessage?(message)
    }
}

