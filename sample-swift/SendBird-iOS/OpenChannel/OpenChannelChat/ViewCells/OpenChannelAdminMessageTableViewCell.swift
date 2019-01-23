//
//  OpenChannelAdminMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/18/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class OpenChannelAdminMessageTableViewCell: UITableViewCell {
    weak var delegate: OpenChannelMessageTableViewCellDelegate?
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var messageContainerViewTopMargin: NSLayoutConstraint!
    
    private var msg: SBDAdminMessage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setMessage(_ message: SBDAdminMessage) {
        self.msg = message
        
        let longClickMessageGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longClickMessage(_:)))
        self.messageContainerView.addGestureRecognizer(longClickMessageGesture)
        
        self.messageLabel.text = self.msg!.message
    }
    
    func getMessage() -> SBDAdminMessage? {
        return self.msg
    }
    
    func setPreviousMessage(_ prevMessage: SBDBaseMessage?) {
        if prevMessage != nil {
            self.messageContainerViewTopMargin.constant = 14
        }
        else {
            self.messageContainerViewTopMargin.constant = 0
        }
    }
    
    @objc func longClickMessage(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            if let delegate = self.delegate {
                if delegate.responds(to: #selector(OpenChannelMessageTableViewCellDelegate.didLongClickAdminMessage(_:))) {
                    delegate.didLongClickAdminMessage!(self.msg!)
                }
            }
        }
    }
}
