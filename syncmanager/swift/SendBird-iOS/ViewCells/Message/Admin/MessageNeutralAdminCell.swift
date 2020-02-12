//
//  MessageNeutralAdminCell.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 11/29/19.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class MessageNeutralAdminCell: MessageCell {
    var msg: SBDAdminMessage?
    
    @IBOutlet weak var dateSeperatorContainerView: UIView!
    @IBOutlet weak var dateSeperatorLabel: UILabel!
    @IBOutlet weak var textMessageLabel: UILabel!
    @IBOutlet weak var messageContainerView: UIView!
    
    @IBOutlet weak var dateSeperatorContainerViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var messageContainerViewTopMargin: NSLayoutConstraint!
    
    static public let kDateSeperatorConatinerViewTopMargin: CGFloat = 3.0
    static public let kDateSeperatorContainerViewHeight: CGFloat = 65.0
    static public let kMessageConatinerViewTopMarginNormal: CGFloat = 3.0
    static public let kMessageConatinerViewTopMarginNoDateSeperator: CGFloat = 6.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
 
    override func configure(with model: MessageModel) {
        super.configure(with: model)
        var showDateSeperator = false

        
        let longClickMessageContainerGesture = UILongPressGestureRecognizer(target: self, action: #selector(MessageNeutralAdminCell.longClickAdminMessage(_:)))
        self.messageContainerView.addGestureRecognizer(longClickMessageContainerGesture)
        
        self.dateSeperatorLabel.text = Utils.getDateStringForDateSeperatorFromTimestamp((self.msg?.createdAt)!)
        self.textMessageLabel.text = self.msg?.message
        
        if model.hasPrevMessage {
            
        } else {
            
        }
        // Adjust constraints regarding the prevMessage
        if model.hasPrevMessage {
            
            showDateSeperator = !model.isPrevMessageSameDay
            
        } else {
            
            showDateSeperator = true
        }
        
        if showDateSeperator {
            self.dateSeperatorContainerView.isHidden = false
            self.dateSeperatorContainerViewTopMargin.constant = MessageNeutralAdminCell.kDateSeperatorConatinerViewTopMargin
            self.dateSeperatorContainerViewHeight.constant = MessageNeutralAdminCell.kDateSeperatorContainerViewHeight
            self.messageContainerViewTopMargin.constant = MessageNeutralAdminCell.kMessageConatinerViewTopMarginNormal
        } else {
            self.dateSeperatorContainerView.isHidden = true
            self.dateSeperatorContainerViewTopMargin.constant = 0
            self.dateSeperatorContainerViewHeight.constant = 0
            self.messageContainerViewTopMargin.constant = model.hasPrevMessage ? MessageNeutralAdminCell.kMessageConatinerViewTopMarginNoDateSeperator : 0
            
        }
    }
    
    func setMessage(currMessage: SBDAdminMessage, prevMessage: SBDBaseMessage?) {
        var showDateSeperator = false
        var hasPrevMessage = false
        self.msg = currMessage
        
        let longClickMessageContainerGesture = UILongPressGestureRecognizer(target: self, action: #selector(MessageNeutralAdminCell.longClickAdminMessage(_:)))
        self.messageContainerView.addGestureRecognizer(longClickMessageContainerGesture)
        
        self.dateSeperatorLabel.text = Utils.getDateStringForDateSeperatorFromTimestamp((self.msg?.createdAt)!)
        self.textMessageLabel.text = self.msg?.message
        
        // Adjust constraints regarding the prevMessage
        if prevMessage == nil {
            showDateSeperator = true
            hasPrevMessage = false
        } else {
            if Utils.checkDayChangeDayBetweenOldTimestamp(oldTimestamp: (self.msg?.createdAt)!, newTimestamp: (prevMessage?.createdAt)!) {
                showDateSeperator = true
            }
            else {
                showDateSeperator = false
            }
            
            hasPrevMessage = true
        }
        
        if showDateSeperator {
            self.dateSeperatorContainerView.isHidden = false
            self.dateSeperatorContainerViewTopMargin.constant = MessageNeutralAdminCell.kDateSeperatorConatinerViewTopMargin
            self.dateSeperatorContainerViewHeight.constant = MessageNeutralAdminCell.kDateSeperatorContainerViewHeight
            self.messageContainerViewTopMargin.constant = MessageNeutralAdminCell.kMessageConatinerViewTopMarginNormal
        } else {
            self.dateSeperatorContainerView.isHidden = true
            self.dateSeperatorContainerViewTopMargin.constant = 0
            self.dateSeperatorContainerViewHeight.constant = 0
            self.messageContainerViewTopMargin.constant = hasPrevMessage ? MessageNeutralAdminCell.kMessageConatinerViewTopMarginNoDateSeperator : 0
            
        }
    }
    
    func getMessage() -> SBDAdminMessage? {
        return self.msg
    }
    
    @objc func longClickAdminMessage(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            if let delegate = self.delegate {
                if delegate.responds(to: #selector(MessageCellDelegate.didLongClickAdminMessage(_:))) {
                    delegate.didLongClickAdminMessage!(self.msg!)
                }
            }
        }
    }
}
