//
//  MessageIncomingGeneralFileCell.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 11/29/19.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK 
import FLAnimatedImage
import Hero

class MessageIncomingGeneralFileCell: MessageIncomingCell {
    
    @IBOutlet weak var fileNameLabel: UILabel!
    
    override func awakeFromNib() {
        self.messageCellType = .file
        
        let clickMessageContainteGesture = UITapGestureRecognizer(target: self, action: #selector(MessageIncomingGeneralFileCell.clickGeneralFileMessage(_:)))
        self.messageContainerView.addGestureRecognizer(clickMessageContainteGesture)
        
        let longClickMessageContainteGesture = UILongPressGestureRecognizer(target: self, action: #selector(MessageIncomingGeneralFileCell.longClickGeneralFileMessage(_:)))
        self.messageContainerView.addGestureRecognizer(longClickMessageContainteGesture)
        super.awakeFromNib()
    }
    
    override func configure(with model: MessageModel) {
        super.configure(with: model)
        self.fileNameLabel.text = (model.message as? SBDFileMessage)?.name
        
    }
  
    @objc func longClickGeneralFileMessage(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            if let message = self.message as? SBDFileMessage {
                self.delegate?.didLongClickGeneralFileMessage?(message)
            }
        }
    }
    
    @objc func clickGeneralFileMessage(_ recognizer: UITapGestureRecognizer) {
        guard let message = self.message as? SBDFileMessage else { return }
        self.hero.isEnabled = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hero.isEnabled = false
        }
        
        switch message.fileType {
            
        case .video:
            self.delegate?.didClickVideoFileMessage?(message)
            
        default:
            self.delegate?.didClickGeneralFileMessage?(message)
        }
    }
}
