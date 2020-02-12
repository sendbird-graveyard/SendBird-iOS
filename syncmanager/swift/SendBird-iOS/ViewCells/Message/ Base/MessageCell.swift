//
//  MessageCell.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 11/29/19.
//  Copyright © 2019 SendBird. All rights reserved.
//
import UIKit
import SendBirdSDK

enum MessageCellType {
    case file
    case audio
    case imageVideo
    case user
}

class MessageCell: UITableViewCell {
    
    enum Constants {
        
        static let dateSeperatorContainerViewOutgoingTopMargin: CGFloat = 0.0
        static let dateSeperatorContainerViewIncomingTopMargin: CGFloat = 3.0
        static let dateSeperatorContainerViewHeight: CGFloat = 65.0
        
        static let nicknameContainerViewTopMargin: CGFloat = 3.0
        static let messageContainerViewTopMarginNormal: CGFloat = 6.0
        static let messageContainerViewTopMarginNoNickname: CGFloat = 3.0
        static let messageContainerViewBottomMarginNormal: CGFloat = 14.0
        static let messageContainerViewTopMarginReduced: CGFloat = 3.0
    }
    
    weak var delegate: MessageCellDelegate?

    var model: MessageModel = .init(.init())
    var channel: SBDGroupChannel?
    var messageCellType: MessageCellType = .file
    
    var message: SBDBaseMessage {
        return model.message
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
 
    func configure(with model: MessageModel) {
        self.model = model
    }
    
    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}
