//
//  MessageIncomingAudioFileCell.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 11/29/19.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK 
import FLAnimatedImage

class MessageIncomingAudioFileCell: MessageIncomingCell {

    @IBOutlet weak var fileNameLabel: UILabel!
    
    override func awakeFromNib() {
        self.messageCellType = .audio
        
        let clickMessageContainteGesture = UITapGestureRecognizer(target: self, action: #selector(MessageIncomingAudioFileCell.clickAudioFileMessage(_:)))
        self.messageContainerView.addGestureRecognizer(clickMessageContainteGesture)
        
        let longClickMessageContainerGesture = UILongPressGestureRecognizer(target: self, action: #selector(MessageIncomingAudioFileCell.longClickAudioFileMessage(_:)))
        self.messageContainerView.addGestureRecognizer(longClickMessageContainerGesture)
        
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func configure(with model: MessageModel) {
        super.configure(with: model)
          
        self.fileNameLabel.text = (model.message as? SBDFileMessage)?.name
        
    }
  
    @objc func clickAudioFileMessage(_ recognizer: UITapGestureRecognizer) {
        if let message = self.message as? SBDFileMessage {
            self.delegate?.didClickAudioFileMessage?(message)
        }
    }
    
    @objc func longClickAudioFileMessage(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            if let message = self.message as? SBDFileMessage {
                self.delegate?.didLongClickGeneralFileMessage?(message)
                
            }
        }
    }
}
