//
//  SBDGroupChannel+Extension.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2019/12/16.
//  Copyright © 2019 SendBird. All rights reserved.
//

import SendBirdSDK

extension SBDGroupChannel {
    var typingIndicatorText: String {
        guard let typingMembers = self.getTypingMembers() else { return "" }
        switch typingMembers.count {
            
        case 0: return ""
        case 1: return typingMembers[0].nickname! + " is typing."
        case 2: return typingMembers[0].nickname! + " and " + typingMembers[1].nickname! + " are typing."
        
        default:
            return "Several people are typing."
        }
    }
}
