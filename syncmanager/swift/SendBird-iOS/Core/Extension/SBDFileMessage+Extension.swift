//
//  SBDFileMessage+Extension.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2019/12/16.
//  Copyright © 2019 SendBird. All rights reserved.
//

import SendBirdSDK

extension SBDFileMessage {
    var fileType: FileMessageType {
        return FileMessageType.getType(by: self.type)
    }
}
