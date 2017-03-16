//
//  OutgoingImageFileMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/7/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import AlamofireImage
import SendBirdSDK
import FLAnimatedImage

class OutgoingImageFileMessageTableViewCell: UITableViewCell {
    weak var delegate: MessageDelegate?
    
    @IBOutlet weak var dateContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var dateContainerBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var fileImageHeight: NSLayoutConstraint!
    @IBOutlet weak var dateContainerTopMargin: NSLayoutConstraint!
    
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var resendMessageButton: UIButton!
    @IBOutlet weak var deleteMessageButton: UIButton!
    @IBOutlet weak var unreadCountLabel: UILabel!
    @IBOutlet weak var dateSeperatorContainerView: UIView!
    @IBOutlet weak var dateSeperatorLabel: UILabel!
    @IBOutlet weak var fileImageView: FLAnimatedImageView!
    @IBOutlet weak var sendStatusLabel: UILabel!
    @IBOutlet weak var imageLoadingIndicator: UIActivityIndicatorView!
    
    private var message: SBDFileMessage!
    private var prevMessage: SBDBaseMessage!
    
    public var hasImageCacheData: Bool?

    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    
    @objc private func clickFileMessage() {
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
    
    func setModel(aMessage: SBDFileMessage) {
        self.message = aMessage
        
        let messageContainerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickFileMessage))
        self.fileImageView.isUserInteractionEnabled = true
        self.fileImageView.addGestureRecognizer(messageContainerTapRecognizer)

        self.imageLoadingIndicator.isHidden = true
        self.fileImageView.animatedImage = nil;
        self.fileImageView.image = nil;
        let url: String?
        url = self.message.url
        if url != nil && (url?.characters.count)! > 0 && self.message.type == "image/gif" {
            DispatchQueue.main.async {
                let cachedImageData = FLAnimatedImage(animatedGIFData: AppDelegate.imageCache().object(forKey: url as AnyObject) as? Data)
                if cachedImageData != nil {
                    self.fileImageView.animatedImage = cachedImageData;
                }
                else {
                    self.fileImageView.animatedImage = nil
                    
                    if self.hasImageCacheData == false {
                        DispatchQueue.main.async {
                            self.imageLoadingIndicator.isHidden = false
                            self.imageLoadingIndicator.startAnimating()
                        }
                    }
                    
                    let session = URLSession(configuration: URLSessionConfiguration.default)
                    let request = URLRequest(url: URL(string: url!)!)
                    session.dataTask(with: request, completionHandler: { (data, response, error) in
                        if error != nil {
                            // TODO: Show download failed.
                            
                            session.invalidateAndCancel()
                            
                            return;
                        }
                        
                        let resp = response as! HTTPURLResponse
                        if resp.statusCode >= 200 && resp.statusCode < 300 {
                            let animatedImage = FLAnimatedImage(animatedGIFData: data as Data!)
                            AppDelegate.imageCache().setObject(data as AnyObject, forKey: url as AnyObject)
                            DispatchQueue.main.async {
                                self.fileImageView.animatedImage = animatedImage;
                                
                                DispatchQueue.main.async {
                                    self.imageLoadingIndicator.isHidden = true
                                    self.imageLoadingIndicator.stopAnimating()
                                }
                            }
                        }
                        else {
                            // TODO: Show download failed.
                        }
                        
                        session.invalidateAndCancel()
                    }).resume()
                    
//                    let imageLoadQueue = DispatchQueue(label: "com.sendbird.imageloadqueue");
//                    imageLoadQueue.async {
//                        if let data = NSData(contentsOf: NSURL(string: url) as! URL) {
//                            let animatedImage = FLAnimatedImage(animatedGIFData: data as Data!)
//                            AppDelegate.imageCache().setObject(animatedImage!, forKey: url as AnyObject)
//                            DispatchQueue.main.async {
//                                self.fileImageView.animatedImage = animatedImage;
//
//                                DispatchQueue.main.async {
//                                    self.imageLoadingIndicator.isHidden = true
//                                    self.imageLoadingIndicator.stopAnimating()
//                                }
//                            }
//                        }
//                    }
                }
            }
        }
        else {
            /***********************************/
            /* Thumbnail is a premium feature. */
            /***********************************/
            if self.message.thumbnails != nil && (self.message.thumbnails?.count)! > 0 {
                if (self.message.thumbnails?[0].url.characters.count)! > 0 {
                    self.fileImageView.af_setImage(withURL: URL(string: (self.message.thumbnails?[0].url)!)!)
                }
            }
            else {
                if self.message.url.characters.count > 0 {
                    self.fileImageView.af_setImage(withURL:URL(string: self.message.url)!)
                }
            }
        }

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
        
        let messageTimestamp = Double(self.message.createdAt) / 1000.0
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        let messageCreatedDate = NSDate(timeIntervalSince1970: messageTimestamp)
        let messageDateString = dateFormatter.string(from: messageCreatedDate as Date)
        
        let messageDateAttributedString = NSMutableAttributedString(string: messageDateString, attributes: messageDateAttribute)
        self.messageDateLabel.attributedText = messageDateAttributedString
        
        // Seperator Date
        let seperatorDateFormatter = DateFormatter()
        seperatorDateFormatter.dateStyle = DateFormatter.Style.medium
        self.dateSeperatorLabel.text = seperatorDateFormatter.string(from: messageCreatedDate as Date)
        
        // Relationship between the current message and the previous message
        self.dateSeperatorContainerView.isHidden = false;
        self.dateContainerHeight.constant = 24.0;
        self.dateContainerTopMargin.constant = 10.0;
        self.dateContainerBottomMargin.constant = 10.0;
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
                self.dateContainerTopMargin.constant = 10.0
                self.dateContainerBottomMargin.constant = 10.0
            }
            else {
                // Hide date seperator.
                self.dateSeperatorContainerView.isHidden = true
                self.dateContainerHeight.constant = 0
                self.dateContainerBottomMargin.constant = 0
                
                // Continuous Message
                if self.prevMessage is SBDAdminMessage {
                    self.dateContainerTopMargin.constant = 10.0
                }
                else {
                    var prevMessageSender: SBDUser?
                    var currMessageSender: SBDUser?
                    
                    if self.prevMessage is SBDUserMessage {
                        prevMessageSender = (self.prevMessage as! SBDUserMessage).sender
                    }
                    else if self.prevMessage is SBDFileMessage {
                        prevMessageSender = (self.prevMessage as! SBDFileMessage).sender
                    }
                    
                    currMessageSender = self.message.sender
                    
                    if prevMessageSender != nil && currMessageSender != nil {
                        if prevMessageSender?.userId == currMessageSender?.userId {
                            // Reduce margin
                            self.dateContainerTopMargin.constant = 5.0
                        }
                        else {
                            // Set default margin.
                            self.dateContainerTopMargin.constant = 10.0
                        }
                    }
                    else {
                        self.dateContainerTopMargin.constant = 10.0
                    }
                }
            }
        }
        else {
            // Show date seperator.
            self.dateSeperatorContainerView.isHidden = false
            self.dateContainerHeight.constant = 24.0
            self.dateContainerTopMargin.constant = 10.0
            self.dateContainerBottomMargin.constant = 10.0
        }
        
        self.layoutIfNeeded()
    }
    
    func setPreviousMessage(aPrevMessage: SBDBaseMessage?) {
        self.prevMessage = aPrevMessage
    }
    
    func getHeightOfViewCell() -> CGFloat {
        let height = self.dateContainerTopMargin.constant + self.dateContainerHeight.constant + self.dateContainerBottomMargin.constant + self.fileImageHeight.constant
        
        return height
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
    
    func setImageData(data: Data, type: String) {
        if type == "image/gif" {
            let imageLoadQueue = DispatchQueue(label: "com.sendbird.imageloadqueue");
            imageLoadQueue.async {
                let animatedImage = FLAnimatedImage(animatedGIFData: data)
                DispatchQueue.main.async {
                    self.fileImageView.animatedImage = animatedImage;
                }
            }
        }
        else {
            self.fileImageView.image = UIImage(data: data)
        }
    }
}
