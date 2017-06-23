//
//  OutgoingGeneralUrlPreviewMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 6/13/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import TTTAttributedLabel
import Alamofire
import AlamofireImage
import FLAnimatedImage

class OutgoingGeneralUrlPreviewMessageTableViewCell: UITableViewCell, TTTAttributedLabelDelegate {
    weak var delegate: MessageDelegate!
    
    @IBOutlet weak var dateSeperatorView: UIView!
    @IBOutlet weak var dateSeperatorLabel: UILabel!
    @IBOutlet weak var messageLabel: TTTAttributedLabel!
    @IBOutlet weak var previewSiteNameLabel: UILabel!
    @IBOutlet weak var previewTitleLabel: UILabel!
    @IBOutlet weak var previewDescriptionLabel: UILabel!
    @IBOutlet weak var previewThumbnailImageView: FLAnimatedImageView!
    @IBOutlet weak var previewThumbnailLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var resendMessageButton: UIButton!
    @IBOutlet weak var deleteMessageButton: UIButton!
    @IBOutlet weak var unreadCountLabel: UILabel!
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var sendStatusLabel: UILabel!
    
    @IBOutlet weak var dateSeperatorViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorViewBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var messageLabelTopMargin: NSLayoutConstraint!
    @IBOutlet weak var messageLabelBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var dividerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dividerViewBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var previewSiteNameLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var previewSiteNameLabelBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var previewTitleLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var previewTitleLabelBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var previewDescriptionLabelBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var previewThumbnailImageViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var previewThumbnailImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var messageLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var previewSiteNameLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var previewTitleLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var previewDescriptionLabelWidth: NSLayoutConstraint!

    private var message: SBDUserMessage!
    private var prevMessage: SBDBaseMessage?
    private var previewData: Dictionary<String, Any>!
    
    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }

    @objc private func clickUserMessage() {
        if self.delegate != nil {
            self.delegate?.clickMessage(view: self, message: self.message!)
        }
    }
    
    @objc private func clickResendUserMessage() {
        if self.delegate != nil {
            self.delegate?.clickResend(view: self, message: self.message!)
        }
    }
    
    @objc private func clickDeleteUserMessage() {
        if self.delegate != nil {
            self.delegate?.clickDelete(view: self, message: self.message!)
        }
    }
    
    @objc private func clickPreview() {
        let url: String = self.previewData["url"] as! String
        if url.characters.count > 0 {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    func setModel(aMessage: SBDUserMessage) {
        self.message = aMessage
        
        let data = self.message.data?.data(using: String.Encoding.utf8)
        do {
            self.previewData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? Dictionary
        }
        catch let error as NSError {
            print("Details of JSON parsing error:\n \(error)")
        }
        let imageUrl = self.previewData?["image"] as! String
        let ext = (imageUrl as NSString).pathExtension
        let siteName = self.previewData?["site_name"] as! String
        let title = self.previewData?["title"] as? String
        let description = self.previewData?["description"] as! String
        
        let previewThumbnailImageViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickPreview))
        self.previewThumbnailImageView.isUserInteractionEnabled = true
        self.previewThumbnailImageView.addGestureRecognizer(previewThumbnailImageViewTapRecognizer)
        
        let previewSiteNameLabelTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickPreview))
        self.previewSiteNameLabel.isUserInteractionEnabled = true
        self.previewSiteNameLabel.addGestureRecognizer(previewSiteNameLabelTapRecognizer)
        
        let previewTitleLabelTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickPreview))
        self.previewTitleLabel.isUserInteractionEnabled = true
        self.previewTitleLabel.addGestureRecognizer(previewTitleLabelTapRecognizer)
        
        let previewDescriptionLabelTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickPreview))
        self.previewDescriptionLabel.isUserInteractionEnabled = true
        self.previewDescriptionLabel.addGestureRecognizer(previewDescriptionLabelTapRecognizer)
        
        self.previewThumbnailImageView.image = nil
        self.previewThumbnailImageView.animatedImage = nil
        self.previewThumbnailLoadingIndicator.isHidden = false
        self.previewThumbnailLoadingIndicator.startAnimating()
        
        if imageUrl.characters.count > 0 {
            if ext.lowercased().hasPrefix("gif") {
                self.previewThumbnailImageView.setAnimatedImageWithURL(url: URL(string: imageUrl)! , success: { (image) in
                    DispatchQueue.main.async {
                        self.previewThumbnailImageView.animatedImage = image
                        self.previewThumbnailLoadingIndicator.isHidden = true
                        self.previewThumbnailLoadingIndicator.stopAnimating()
                    }
                }, failure: { (error) in
                    DispatchQueue.main.async {
                        self.previewThumbnailLoadingIndicator.isHidden = true
                        self.previewThumbnailLoadingIndicator.stopAnimating()
                    }
                })
            }
            else {
                Alamofire.request(imageUrl, method: .get).responseImage { response in
                    guard let image = response.result.value else {
                        DispatchQueue.main.async {
                            self.previewThumbnailLoadingIndicator.isHidden = true
                            self.previewThumbnailLoadingIndicator.stopAnimating()
                        }
                        
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.previewThumbnailImageView.image = image
                        self.previewThumbnailLoadingIndicator.isHidden = true
                        self.previewThumbnailLoadingIndicator.stopAnimating()
                    }
                }
            }
        }
        else {
            self.previewThumbnailImageView.isHidden = true
            self.previewThumbnailLoadingIndicator.isHidden = true
            self.previewThumbnailImageViewHeight.constant = 0
            self.previewDescriptionLabelBottomMargin.constant = 10
        }

        self.resendMessageButton.isHidden = true
        self.deleteMessageButton.isHidden = true
        
        self.resendMessageButton.addTarget(self, action: #selector(clickResendUserMessage), for: UIControlEvents.touchUpInside)
        self.deleteMessageButton.addTarget(self, action: #selector(clickDeleteUserMessage), for: UIControlEvents.touchUpInside)
        
        // Unread message count
        if self.message.channelType == CHANNEL_TYPE_GROUP {
            let channelOfMessage = SBDGroupChannel.getChannelFromCache(withChannelUrl: self.message.channelUrl!)
            if channelOfMessage != nil {
                let unreadMessageCount = channelOfMessage?.getReadReceipt(of: self.message)
                if unreadMessageCount == 0 {
                    self.hideUnreadCount()
                    self.unreadCountLabel.text = ""
                }
                else {
                    self.showUnreadCount()
                    self.unreadCountLabel.text = String(format: "%d", unreadMessageCount!)
                }
            }
        }
        else {
            self.hideUnreadCount()
        }
        
        // Message Date
        let messageDateAttribute = [
            NSFontAttributeName: Constants.messageDateFont(),
            NSForegroundColorAttributeName: Constants.messageDateColor()
        ]
        let messageTimestamp: TimeInterval = Double(self.message.createdAt) / 1000.0
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        let messageCreateDate: Date = NSDate.init(timeIntervalSince1970: messageTimestamp) as Date
        let messageDateString = dateFormatter.string(from: messageCreateDate)
        let messageDateAttributedString: NSMutableAttributedString = NSMutableAttributedString(string: messageDateString, attributes: messageDateAttribute)
        self.messageDateLabel.attributedText = messageDateAttributedString
        
        // Seperator Date
        let seperatorDateFormatter: DateFormatter = DateFormatter()
        seperatorDateFormatter.dateStyle = DateFormatter.Style.medium
        self.dateSeperatorLabel.text = seperatorDateFormatter.string(from: messageCreateDate)
        
        // Relationship between the current message and the previous message
        self.dateSeperatorView.isHidden = false
        self.dateSeperatorViewHeight.constant = 24.0
        self.dateSeperatorViewTopMargin.constant = 10.0
        self.dateSeperatorViewBottomMargin.constant = 10.0
        if self.prevMessage != nil {
            // Day Changed
            let prevMessageDate: Date = Date(timeIntervalSince1970: Double(self.prevMessage!.createdAt) / 1000.0)
            let currMessageDate: Date = Date(timeIntervalSince1970: Double(self.message.createdAt) / 1000.0)
            let prevMessageDateComponents: DateComponents = Calendar.current.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: prevMessageDate)
            let currMessageDateComponents: DateComponents = Calendar.current.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: currMessageDate)
            
            if prevMessageDateComponents.year != currMessageDateComponents.year || prevMessageDateComponents.month != currMessageDateComponents.month || prevMessageDateComponents.day != currMessageDateComponents.day {
                // Show date seperator.
                self.dateSeperatorView.isHidden = false
                self.dateSeperatorViewHeight.constant = 24.0
                self.dateSeperatorViewTopMargin.constant = 10.0
                self.dateSeperatorViewBottomMargin.constant = 10.0
            }
            else {
                // Hide date seperator.
                self.dateSeperatorView.isHidden = true
                self.dateSeperatorViewHeight.constant = 0
                self.dateSeperatorViewBottomMargin.constant = 0
                
                // Continuous Message
                if (self.prevMessage?.isKind(of: SBDAdminMessage.self))! {
                    self.dateSeperatorViewTopMargin.constant = 10.0
                }
                else {
                    var prevMessageSender: SBDUser?
                    var currMessageSender: SBDUser?
                    
                    if (self.prevMessage?.isKind(of: SBDUserMessage.self))! {
                        prevMessageSender = (self.prevMessage as! SBDUserMessage).sender
                    }
                    else if (self.prevMessage?.isKind(of: SBDFileMessage.self))! {
                        prevMessageSender = (self.prevMessage as! SBDFileMessage).sender
                    }
                    
                    currMessageSender = self.message.sender
                    
                    if prevMessageSender != nil {
                        if prevMessageSender?.userId == currMessageSender?.userId {
                            // Reduce margin
                            self.dateSeperatorViewTopMargin.constant = 5.0
                        }
                        else {
                            // Set default margin.
                            self.dateSeperatorViewTopMargin.constant = 10.0
                        }
                    }
                    else {
                        self.dateSeperatorViewTopMargin.constant = 10.0
                    }
                }
            }
        }
        else {
            // Show date seperator.
            self.dateSeperatorView.isHidden = false
            self.dateSeperatorViewHeight.constant = 24.0
            self.dateSeperatorViewTopMargin.constant = 10.0
            self.dateSeperatorViewBottomMargin.constant = 10.0
        }
        
        self.previewSiteNameLabel.text = siteName
        self.previewTitleLabel.text = title
        self.previewDescriptionLabel.text = description
        
        let fullMessage = self.buildMessage()
        self.messageLabel.attributedText = fullMessage
        self.messageLabel.isUserInteractionEnabled = true
        self.messageLabel.linkAttributes = [
            NSFontAttributeName: Constants.messageFont(),
            NSForegroundColorAttributeName: Constants.outgoingMessageColor(),
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue
        ]
        
        let detector: NSDataDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: self.message.message!, options: [], range: NSMakeRange(0, (self.message.message?.characters.count)!))
        if matches.count > 0 {
            self.messageLabel.delegate = self
            self.messageLabel.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
            for item in matches {
                let match = item
                let range = match.range
                self.messageLabel.addLink(to: match.url, with: range)
            }
        }
        
        self.layoutIfNeeded()
    }
    
    func setPreviousMessage(aPrevMessage: SBDBaseMessage?) {
        self.prevMessage = aPrevMessage
    }
    
    private func buildMessage() -> NSMutableAttributedString {
        let messageAttribute = [
            NSFontAttributeName: Constants.messageFont(),
            NSForegroundColorAttributeName: Constants.outgoingMessageColor()
        ]
        let message = self.message.message
        
        var fullMessage: NSMutableAttributedString?

        fullMessage = NSMutableAttributedString(string: message!)
        fullMessage?.addAttributes(messageAttribute, range: NSMakeRange(0, (message?.characters.count)!))
        
        return fullMessage!
    }
    
    func getHeightOfViewCell() -> CGFloat {
        let message = self.buildMessage()
        let descriptionAttributes = [
            NSFontAttributeName: Constants.urlPreviewDescriptionFont()
        ]
        let description: NSString = self.previewData["description"] as! NSString
        let descriptionRect = description.boundingRect(with: CGSize(width: self.previewDescriptionLabelWidth.constant, height: CGFloat.greatestFiniteMagnitude), options: [NSStringDrawingOptions.usesLineFragmentOrigin], attributes: descriptionAttributes, context: nil)
        let descriptionLabelHeight = descriptionRect.size.height
        let messageRect: CGRect = message.boundingRect(with: CGSize(width: self.messageLabelWidth.constant, height: CGFloat.greatestFiniteMagnitude), options: [NSStringDrawingOptions.usesLineFragmentOrigin], context: nil)
        let messageHeight = messageRect.size.height

        let cellHeight = self.dateSeperatorViewTopMargin.constant + self.dateSeperatorViewHeight.constant + self.dateSeperatorViewBottomMargin.constant + self.messageLabelTopMargin.constant + messageHeight + self.messageLabelBottomMargin.constant + self.dividerViewHeight.constant + self.dividerViewBottomMargin.constant + self.previewSiteNameLabelHeight.constant + self.previewSiteNameLabelBottomMargin.constant + self.previewTitleLabelHeight.constant + self.previewTitleLabelBottomMargin.constant + descriptionLabelHeight + self.previewDescriptionLabelBottomMargin.constant + self.previewThumbnailImageViewHeight.constant
        
        return cellHeight
    }
    
    func hideUnreadCount() {
        self.unreadCountLabel.isHidden = true
    }
    
    func showUnreadCount() {
        if self.message.channelType == CHANNEL_TYPE_GROUP {
            self.unreadCountLabel.isHidden = false
            self.resendMessageButton.isHidden = true
            self.deleteMessageButton.isHidden = true
        }
    }
    
    func hideMessageControlButton() {
        self.resendMessageButton.isHidden = true
        self.deleteMessageButton.isHidden = true
    }
    
    func showMessageControlButton() {
        self.sendStatusLabel.isHidden = true
        self.messageDateLabel.isHidden = true
        self.unreadCountLabel.isHidden = true
        
        self.resendMessageButton.isHidden = false
        self.deleteMessageButton.isHidden = false
    }
    
    func showSendingStatus() {
        self.messageDateLabel.isHidden = true
        self.unreadCountLabel.isHidden = true
        self.resendMessageButton.isHidden = true
        self.deleteMessageButton.isHidden = true
        
        self.sendStatusLabel.isHidden = false
        self.sendStatusLabel.text = "Sending"
    }
    
    func showFailedStatus() {
        self.messageDateLabel.isHidden = true
        self.unreadCountLabel.isHidden = true
        self.resendMessageButton.isHidden = true
        self.deleteMessageButton.isHidden = true
        
        self.sendStatusLabel.isHidden = false
        self.sendStatusLabel.text = "Failed"
    }
    
    func showMessageDate() {
        self.unreadCountLabel.isHidden = true
        self.resendMessageButton.isHidden = true
        self.sendStatusLabel.isHidden = true
        
        self.messageDateLabel.isHidden = false
    }
    
    // MARK: TTTAttributedLabelDelegate
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        UIApplication.shared.openURL(url)
    }
}
