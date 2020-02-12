//
//  MessageIncomingUserCell.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 11/29/19.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class MessageIncomingUserCell: MessageIncomingCell {
 
    @IBOutlet weak var textMessageLabel: UILabel!
 
    override func awakeFromNib() {
        self.messageCellType = .user

        super.awakeFromNib()
        
        let longClickMessageContainerGesture = UILongPressGestureRecognizer(target: self, action: #selector(MessageIncomingUserCell.longClickUserMessage(_:)))
        self.messageContainerView.addGestureRecognizer(longClickMessageContainerGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func configure(with model: MessageModel) {
        super.configure(with: model)
        guard let message = model.message as? SBDUserMessage else { return }
        self.textMessageLabel.text = message.message
    }
 
    @objc func longClickUserMessage(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            guard let message = self.message as? SBDUserMessage else { return }
            self.delegate?.didLongClickUserMessage?(message)
        }
    }
}
