//
//  MessageModel.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2019/12/24.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import SendBirdSyncManager

class MessageModel {
    
    let message: SBDBaseMessage
    var params: SBDBaseMessageParams?
    
    var hasPrevMessage = false
    
    var isPrevMessageSameUser = false
    var isPrevMessageSameDay = true
     
    var isNextMessageSameUser = false
    var isNextMessageSameDay = false
    
    var progress: CGFloat? = nil
    
    init(_ message: SBDBaseMessage, params: SBDBaseMessageParams? = nil) {
        self.message = message
        self.params = params
    }
}

extension MessageModel {
    var requestID: String {
        self.message.requestID
    }
    
    var messageID: Int64 {
        self.message.messageId
    }
    
    var createdAt: Int64 {
        self.message.createdAt
    }
    
    var hasParams: Bool {
        return params != nil
    }
    
    var userID: String? {
        return message.getSender()?.userId
    }
}

extension MessageModel: Equatable {
    static func == (lhs: MessageModel, rhs: MessageModel) -> Bool {
        lhs.message == rhs.message
    }
}

extension MessageModel {
    func cellIdentifier(currentUser: SBDUser) -> String? {
        
        guard let sender = self.message.getSender() else { assertionFailure(); return nil }
        
        let isOutgoingMessage = sender.userId == currentUser.userId
        
        switch self.message {
            case is SBDAdminMessage:
            
                return MessageNeutralAdminCell.className
            
            case is SBDUserMessage:
                
                if isOutgoingMessage {
                    return MessageOutgoingUserCell.className
                } else {
                    return MessageIncomingUserCell.className
            }
            
            case  is SBDFileMessage:
                
                guard let fileMessage = self.message as? SBDFileMessage else { assertionFailure(); return nil }
                if isOutgoingMessage {
                    switch fileMessage.fileType {
                    case .image, .video:
                        return MessageOutgoingImageVideoFileCell.className
                    case .audio:
                        return MessageOutgoingAudioFileCell.className
                    case .file:
                        return MessageOutgoingGeneralFileCell.className
                    }
                    
                } else {
                    switch fileMessage.fileType {
                    case .image, .video:
                        return MessageIncomingImageVideoFileCell.className
                    case .audio:
                        return MessageIncomingAudioFileCell.className
                    case .file:
                        return MessageIncomingGeneralFileCell.className
                    }
            }
            
        default:
            assertionFailure()
            return nil
        }
        
    }
}
