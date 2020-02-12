//
//  SBDBaseMessage+Extension.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2019/12/16.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import SendBirdSyncManager

extension SBDBaseMessage {
    func getSender() -> SBDSender? {
        switch self {
        case let message as SBDFileMessage:
            return message.sender
        case let message as SBDUserMessage:
            return message.sender
        default:
            return nil
        }
        
    }
}

extension SBDBaseMessage {
    var requestID: String {
        if let requestId = requestId() {
            return requestId
        } else {
            assertionFailure("Request ID must exist.")
            return ""
        }
           
    }
    
//    @available(*, deprecated, renamed: "requestID")
//    func requestId() -> String? {
//        nil
//    }
    
}

// For ignore deprecated warning
//private protocol GetRequestId {
//    func requestId() -> String?
//}
