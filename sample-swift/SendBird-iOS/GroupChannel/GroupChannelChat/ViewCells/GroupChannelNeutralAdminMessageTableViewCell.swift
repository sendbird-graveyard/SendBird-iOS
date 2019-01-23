//
//  GroupChannelNeutralAdminMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/6/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class GroupChannelNeutralAdminMessageTableViewCell: UITableViewCell {
    weak var delegate: GroupChannelMessageTableViewCellDelegate?
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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setMessage(currMessage: SBDAdminMessage, prevMessage: SBDBaseMessage?) {
        var showDateSeperator = false
        var hasPrevMessage = false
        self.msg = currMessage
        
        let longClickMessageContainerGesture = UILongPressGestureRecognizer(target: self, action: #selector(GroupChannelNeutralAdminMessageTableViewCell.longClickAdminMessage(_:)))
        
        self.dateSeperatorLabel.text = Utils.getDateStringForDateSeperatorFromTimestamp((self.msg?.createdAt)!)
        self.textMessageLabel.text = self.msg?.message
        
        // Adjust constraints regarding the prevMessage
        if prevMessage == nil {
            showDateSeperator = true
            hasPrevMessage = false
        }
        else {
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
            self.dateSeperatorContainerViewTopMargin.constant = GroupChannelNeutralAdminMessageTableViewCell.kDateSeperatorConatinerViewTopMargin
            self.dateSeperatorContainerViewHeight.constant = GroupChannelNeutralAdminMessageTableViewCell.kDateSeperatorContainerViewHeight
            self.messageContainerViewTopMargin.constant = GroupChannelNeutralAdminMessageTableViewCell.kMessageConatinerViewTopMarginNormal
        }
        else {
            self.dateSeperatorContainerView.isHidden = true
            self.dateSeperatorContainerViewTopMargin.constant = 0
            self.dateSeperatorContainerViewHeight.constant = 0
            if hasPrevMessage {
                self.messageContainerViewTopMargin.constant = GroupChannelNeutralAdminMessageTableViewCell.kMessageConatinerViewTopMarginNoDateSeperator
            }
            else {
                self.messageContainerViewTopMargin.constant = 0
            }
        }
    }
    
    func getMessage() -> SBDAdminMessage? {
        return self.msg
    }
    
    @objc func longClickAdminMessage(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            if let delegate = self.delegate {
                if delegate.responds(to: #selector(GroupChannelMessageTableViewCellDelegate.didLongClickAdminMessage(_:))) {
                    delegate.didLongClickAdminMessage!(self.msg!)
                }
            }
        }
    }
}
