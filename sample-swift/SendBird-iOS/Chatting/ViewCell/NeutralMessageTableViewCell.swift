//
//  NeutralMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/7/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class NeutralMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var dateContainerViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var messageContainerViewTopPadding: NSLayoutConstraint!
    @IBOutlet weak var iconImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var iconImageViewBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var messageContainerViewBottomPadding: NSLayoutConstraint!
    @IBOutlet weak var dateContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var dateContainerViewBottomMargin: NSLayoutConstraint!
    
    @IBOutlet weak var messageContainerViewLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var messageContainerViewRightMargin: NSLayoutConstraint!
    @IBOutlet weak var messageContainerViewLeftPadding: NSLayoutConstraint!
    @IBOutlet weak var messageContainerViewRightPadding: NSLayoutConstraint!

    @IBOutlet weak var dateSeperatorContainerView: UIView!
    @IBOutlet weak var dateSeperatorLabel: UILabel!
    
    private var message: SBDAdminMessage!
    private var prevMessage: SBDBaseMessage!

    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    
    func setModel(aMessage: SBDAdminMessage) {
        self.message = aMessage
        
        let fullMessage = self.buildMessage()
        self.messageLabel.attributedText = fullMessage
        
        // Seperator Date
        let messageTimestamp = Double(self.message.createdAt) / 1000.0
        let messageCreatedDate = NSDate(timeIntervalSince1970: messageTimestamp)

        let seperatorDateFormatter = DateFormatter()
        seperatorDateFormatter.dateStyle = DateFormatter.Style.medium
        self.dateSeperatorLabel.text = seperatorDateFormatter.string(from: messageCreatedDate as Date)
        
        // Relationship between the current message and the previous message
        self.dateSeperatorContainerView.isHidden = false
        self.dateContainerHeight.constant = 24.0
        self.dateContainerViewTopMargin.constant = 10.0
        self.dateContainerViewBottomMargin.constant = 10.0
        if self.prevMessage != nil {
            // Day Changed
            let prevMessageDate = NSDate(timeIntervalSince1970: Double(self.prevMessage.createdAt) / 1000.0)
            let currMessageDate = NSDate(timeIntervalSince1970: Double(self.message.createdAt) / 1000.0)
            let prevMessageDateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: prevMessageDate as Date)
            let currMessagedateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: currMessageDate as Date)
            
            if prevMessageDateComponents.year != currMessagedateComponents.year || prevMessageDateComponents.month != currMessagedateComponents.month || prevMessageDateComponents.day != currMessagedateComponents.day {
                // Show date seperator.
                self.dateSeperatorContainerView.isHidden = false
                self.dateContainerHeight.constant = 24.0
                self.dateContainerViewTopMargin.constant = 10.0
                self.dateContainerViewBottomMargin.constant = 10.0
            }
            else {
                // Hide date seperator.
                self.dateSeperatorContainerView.isHidden = true
                self.dateContainerHeight.constant = 0
                self.dateContainerViewBottomMargin.constant = 0
                
                // Continuous Message
                if self.prevMessage is SBDAdminMessage {
                    self.dateContainerViewTopMargin.constant = 5.0
                }
                else {
                    self.dateContainerViewTopMargin.constant = 10.0
                }
            }
        }
        
        self.layoutIfNeeded()
    }
    
    func setPreviousMessage(aPrevMessage: SBDBaseMessage?) {
        self.prevMessage = aPrevMessage
    }
    
    func buildMessage() -> NSAttributedString {
        let messageAttribute = [
            NSFontAttributeName: Constants.messageFont()
        ]
        
        let message = self.message.message
        
        let fullMessage = NSMutableAttributedString.init(string: message! as String)
        
        fullMessage.addAttributes(messageAttribute, range: NSMakeRange(0, (message?.characters.count)!))
        
        return fullMessage
    }
    
    
    func getHeightOfViewCell() -> CGFloat {
        let fullMessage = self.buildMessage()
        
        var fullMessageRect: CGRect
        
        let messageLabelMaxWidth = self.frame.size.width - (self.messageContainerViewLeftMargin.constant + self.messageContainerViewRightMargin.constant + self.messageContainerViewLeftPadding.constant + self.messageContainerViewRightPadding.constant)
        fullMessageRect = fullMessage.boundingRect(with: CGSize.init(width: messageLabelMaxWidth, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        
        
        let cellHeight = self.dateContainerViewTopMargin.constant + self.dateContainerHeight.constant + self.dateContainerViewBottomMargin.constant + self.messageContainerViewTopPadding.constant + self.iconImageViewHeight.constant + self.iconImageViewBottomMargin.constant + fullMessageRect.size.height + self.messageContainerViewBottomPadding.constant
        
        return cellHeight
    }
}
