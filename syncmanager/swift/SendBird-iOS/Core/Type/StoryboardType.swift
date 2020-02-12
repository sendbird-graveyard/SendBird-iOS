//
//  StoryboardType.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2019/12/26.
//  Copyright © 2019 SendBird. All rights reserved.
//

import Foundation

enum StoryboardType { 
    case groupChannel
    case settings
    case main
    
    var fileName: String {
        switch self {
            
        case .groupChannel:
            return "GroupChannel"
            
        case .settings:
            return "Settings"
            
        case .main:
            return "Main"
        }
    }
    
}
