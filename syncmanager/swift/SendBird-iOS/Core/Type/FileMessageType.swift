//
//  FileMessageType.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2019/12/16.
//  Copyright © 2019 SendBird. All rights reserved.
//

import Foundation

enum FileMessageType {
    case image
    case video
    case audio
    case file
}

extension FileMessageType {
    var string: String {
        switch self {
        case .image: return "Image"
        case .video: return "Video"
        case .audio: return "Audio"
        case .file:  return "File"
            
        }
    }
}

extension FileMessageType {
    static func getType(by text: String) -> FileMessageType {
        if text.hasPrefix("image") {
            return .image
            
        } else if text.hasPrefix("video") {
            return .video
            
        } else if text.hasPrefix("audio") {
            return .audio
            
        } else {
            return .file
        }
    }
}
