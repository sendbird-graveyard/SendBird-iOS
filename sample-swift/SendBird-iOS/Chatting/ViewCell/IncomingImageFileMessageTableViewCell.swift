//
//  IncomingImageFileMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/6/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import AlamofireImage
import SendBirdSDK
import FLAnimatedImage

class IncomingImageFileMessageTableViewCell: UITableViewCell {
    weak var delegate: MessageDelegate?
    
    @IBOutlet weak var dateContainerTopMargin: NSLayoutConstraint!
    @IBOutlet weak var dateContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var dateContainerBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var fileImageHeight: NSLayoutConstraint!

    @IBOutlet weak var dateSeperatorContainerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fileImageView: FLAnimatedImageView!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var dateSeperatorLabel: UILabel!
    
    @IBOutlet weak var imageLoadingIndicator: UIActivityIndicatorView!
    
    private var message: SBDFileMessage!
    private var prevMessage: SBDBaseMessage!
    
    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }

    @objc private func clickProfileImage() {
        if self.delegate != nil {
            self.delegate?.clickProfileImage(viewCell: self, user: self.message!.sender!)
        }
    }
    
    @objc private func clickFileMessage() {
        if self.delegate != nil {
            self.delegate?.clickMessage(view: self, message: self.message!)
        }
    }
    
    func setModel(aMessage: SBDFileMessage) {
        self.message = aMessage
        
        self.profileImageView.af_setImage(withURL: URL(string: (self.message.sender?.profileUrl!)!)!, placeholderImage: UIImage(named: "img_profile"))
        
        let profileImageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickProfileImage))
        self.profileImageView.isUserInteractionEnabled = true
        self.profileImageView.addGestureRecognizer(profileImageTapRecognizer)
        
        let messageContainerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickFileMessage))
        self.fileImageView.isUserInteractionEnabled = true
        self.fileImageView.addGestureRecognizer(messageContainerTapRecognizer)
        
        self.imageLoadingIndicator.isHidden = true
        self.fileImageView.animatedImage = nil;
        self.fileImageView.image = nil;
        let url = self.message.url
        if self.message.type == "image/gif" {
            DispatchQueue.main.async {
                let cachedImageData = FLAnimatedImage(animatedGIFData: AppDelegate.imageCache().object(forKey: url as AnyObject) as? Data)
                if cachedImageData != nil {
                    self.fileImageView.animatedImage = cachedImageData;
                }
                else {
                    self.fileImageView.animatedImage = nil
                    DispatchQueue.main.async {
                        self.imageLoadingIndicator.isHidden = false
                        self.imageLoadingIndicator.startAnimating()
                    }
                    
                    let session = URLSession(configuration: URLSessionConfiguration.default)
                    let request = URLRequest(url: URL(string: url)!)
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
        self.profileImageView.isHidden = false
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
                            self.profileImageView.isHidden = true
                        }
                        else {
                            // Set default margin.
                            self.profileImageView.isHidden = false
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
}
