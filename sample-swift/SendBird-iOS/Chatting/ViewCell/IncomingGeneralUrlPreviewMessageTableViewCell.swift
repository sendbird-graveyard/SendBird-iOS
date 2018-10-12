//
//  IncomingGeneralUrlPreviewMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 6/6/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import TTTAttributedLabel
import Alamofire
import AlamofireImage
import FLAnimatedImage

class IncomingGeneralUrlPreviewMessageTableViewCell: UITableViewCell, TTTAttributedLabelDelegate {
    
    @IBOutlet weak var dateSeperatorView: UIView!
    @IBOutlet weak var dateSeperatorLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var previewThumbnailImageView: FLAnimatedImageView!
    @IBOutlet weak var previewSiteNameLabel: UILabel!
    @IBOutlet weak var previewTitleLabel: UILabel!
    @IBOutlet weak var previewDescriptionLabel: UILabel!
    @IBOutlet weak var previewThumbnailLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var messageLabel: TTTAttributedLabel!
    
    @IBOutlet weak var dateSeperatorTopMargin: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorHeight: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var messageTopMargin: NSLayoutConstraint!
    @IBOutlet weak var messageBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var dividerHeight: NSLayoutConstraint!
    @IBOutlet weak var dividerBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var previewSiteNameHeight: NSLayoutConstraint!
    @IBOutlet weak var previewSiteNameBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var previewTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var previewTitleBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var previewDescriptionBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var previewThumbnailImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var messageWidth: NSLayoutConstraint!
    @IBOutlet weak var previewDescriptionWidth: NSLayoutConstraint!
    @IBOutlet weak var previewThumbnailImageWidth: NSLayoutConstraint!
    
    weak var delegate: MessageDelegate!
    private var message: SBDUserMessage!
    private var prevMessage: SBDBaseMessage!
    var previewData: Dictionary<String, Any>!
    private var displayNickname: Bool!
    
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
    
    @objc private func clickPreview() {
        if self.delegate != nil {
            self.delegate?.clickMessage(view: self, message: self.message)
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

        let siteName = self.previewData?["site_name"] as? String
        let title = self.previewData?["title"] as? String
        let description = self.previewData?["description"] as? String
        
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

        self.profileImageView.af_setImage(withURL: URL(string: (self.message.sender?.profileUrl)!)!, placeholderImage: UIImage(named: "img_profile"), filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: UIImageView.ImageTransition.noTransition, runImageTransitionIfCached: true, completion: nil)
        
        let profileImageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickProfileImage))
        profileImageTapRecognizer.delegate = self
        self.profileImageView.isUserInteractionEnabled = true
        self.profileImageView.addGestureRecognizer(profileImageTapRecognizer)
        
        // Message Date
        let messageDateAttribute = [
            NSAttributedString.Key.font: Constants.messageDateFont(),
            NSAttributedString.Key.foregroundColor: Constants.messageDateColor()
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
        self.profileImageView.isHidden = false
        self.dateSeperatorView.isHidden = false
        self.dateSeperatorHeight.constant = 24.0
        self.dateSeperatorTopMargin.constant = 10.0
        self.dateSeperatorBottomMargin.constant = 10.0
        self.displayNickname = true
        if self.prevMessage != nil {
            // Day Changed
            let prevMessageDate: Date = Date(timeIntervalSince1970: Double(self.prevMessage.createdAt) / 1000.0)
            let currMessageDate: Date = Date(timeIntervalSince1970: Double(self.message.createdAt) / 1000.0)
            let prevMessageDateComponents: DateComponents = Calendar.current.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: prevMessageDate)
            let currMessageDateComponents: DateComponents = Calendar.current.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: currMessageDate)
            
            if prevMessageDateComponents.year != currMessageDateComponents.year || prevMessageDateComponents.month != currMessageDateComponents.month || prevMessageDateComponents.day != currMessageDateComponents.day {
                // Show date seperator.
                self.dateSeperatorView.isHidden = false
                self.dateSeperatorHeight.constant = 24.0
                self.dateSeperatorTopMargin.constant = 10.0
                self.dateSeperatorBottomMargin.constant = 10.0
            }
            else {
                // Hide date seperator.
                self.dateSeperatorView.isHidden = true
                self.dateSeperatorHeight.constant = 0
                self.dateSeperatorBottomMargin.constant = 0
                
                // Continuous Message
                if self.prevMessage.isKind(of: SBDAdminMessage.self) {
                    self.dateSeperatorTopMargin.constant = 10.0
                }
                else {
                    var prevMessageSender: SBDUser?
                    var currMessageSender: SBDUser?
                    
                    if self.prevMessage.isKind(of: SBDUserMessage.self) {
                        prevMessageSender = (self.prevMessage as! SBDUserMessage).sender
                    }
                    else if self.prevMessage.isKind(of: SBDFileMessage.self) {
                        prevMessageSender = (self.prevMessage as! SBDFileMessage).sender
                    }
                    
                    currMessageSender = self.message.sender
                    
                    if prevMessageSender != nil {
                        if prevMessageSender?.userId == currMessageSender?.userId {
                            // Reduce margin
                            self.dateSeperatorTopMargin.constant = 5.0
                            self.profileImageView.isHidden = true
                            self.displayNickname = false
                        }
                        else {
                            // Set default margin.
                            self.profileImageView.isHidden = false
                            self.dateSeperatorTopMargin.constant = 10.0
                        }
                    }
                    else {
                        self.dateSeperatorTopMargin.constant = 10.0
                    }
                }
            }
        }
        else {
            // Show date seperator.
            self.dateSeperatorView.isHidden = false
            self.dateSeperatorHeight.constant = 24.0
            self.dateSeperatorTopMargin.constant = 10.0
            self.dateSeperatorBottomMargin.constant = 10.0
        }
        
        self.previewSiteNameLabel.text = siteName
        self.previewTitleLabel.text = title
        self.previewDescriptionLabel.text = description
        
        let fullMessage = self.buildMessage()
        self.messageLabel.attributedText = fullMessage
        self.messageLabel.isUserInteractionEnabled = true
        self.messageLabel.linkAttributes = [
            NSAttributedString.Key.font: Constants.messageFont(),
            NSAttributedString.Key.foregroundColor: Constants.incomingMessageColor(),
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        let detector: NSDataDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: self.message.message!, options: [], range: NSMakeRange(0, (self.message.message?.count)!))
        if matches.count > 0 {
            self.messageLabel.delegate = self
            self.messageLabel.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
            for item in matches {
                let match = item
                let rangeOfOriginalMessage = match.range
                var range: NSRange
                if self.displayNickname {
                    range = NSMakeRange((self.message.sender?.nickname?.count)! + 1 + rangeOfOriginalMessage.location, rangeOfOriginalMessage.length)
                }
                else {
                    range = rangeOfOriginalMessage
                }
                
                self.messageLabel.addLink(to: match.url, with: range)
            }
        }
        
        self.layoutIfNeeded()
    }
    
    func setPreviousMessage(aPrevMessage: SBDBaseMessage?) {
        self.prevMessage = aPrevMessage
    }
    
    private func buildMessage() -> NSMutableAttributedString {
        var nicknameAttribute: [NSAttributedString.Key:NSObject]
        switch (self.message.sender?.nickname?.count)! % 5 {
        case 0:
            nicknameAttribute = [
                NSAttributedString.Key.font: Constants.nicknameFontInMessage(),
                NSAttributedString.Key.foregroundColor: Constants.nicknameColorInMessageNo0()
            ]
        case 1:
            nicknameAttribute = [
                NSAttributedString.Key.font: Constants.nicknameFontInMessage(),
                NSAttributedString.Key.foregroundColor: Constants.nicknameColorInMessageNo1()
            ]
        case 2:
            nicknameAttribute = [
                NSAttributedString.Key.font: Constants.nicknameFontInMessage(),
                NSAttributedString.Key.foregroundColor: Constants.nicknameColorInMessageNo2()
            ]
        case 3:
            nicknameAttribute = [
                NSAttributedString.Key.font: Constants.nicknameFontInMessage(),
                NSAttributedString.Key.foregroundColor: Constants.nicknameColorInMessageNo3()
            ]
        case 4:
            nicknameAttribute = [
                NSAttributedString.Key.font: Constants.nicknameFontInMessage(),
                NSAttributedString.Key.foregroundColor: Constants.nicknameColorInMessageNo4()
            ]
        default:
            nicknameAttribute = [
                NSAttributedString.Key.font: Constants.nicknameFontInMessage(),
                NSAttributedString.Key.foregroundColor: Constants.nicknameColorInMessageNo0()
            ]
        }
        
        let messageAttribute = [
            NSAttributedString.Key.font: Constants.messageFont()
        ]
        let nickname = self.message.sender?.nickname
        let message = self.message.message
        
        var fullMessage: NSMutableAttributedString?
        if self.displayNickname {
            fullMessage = NSMutableAttributedString(string: String(format: "%@\n%@", nickname!, message!))
            fullMessage?.addAttributes(nicknameAttribute, range: NSMakeRange(0, (nickname?.count)!))
            fullMessage?.addAttributes(messageAttribute, range: NSMakeRange((nickname?.count)! + 1, (message?.count)!))
        }
        else {
            fullMessage = NSMutableAttributedString(string: String(format: "%@", message!))
            fullMessage?.addAttributes(messageAttribute, range: NSMakeRange(0, (message?.count)!))
        }
        
        return fullMessage!
    }
    
    func getHeightOfViewCell() -> Float {
        let fullMessage = self.buildMessage()
        let fullMessageRect: CGRect = fullMessage.boundingRect(with: CGSize(width: self.messageWidth.constant, height: CGFloat.greatestFiniteMagnitude), options: [NSStringDrawingOptions.usesLineFragmentOrigin], context: nil)
        let attributes = [
            NSAttributedString.Key.font: Constants.urlPreviewDescriptionFont()
        ]

        let description: NSString = self.previewData["description"] as! NSString
        let descriptionRect = description.boundingRect(with: CGSize(width: self.previewDescriptionWidth.constant, height: CGFloat.greatestFiniteMagnitude), options: [NSStringDrawingOptions.usesLineFragmentOrigin], attributes: attributes, context: nil)
        
        var cellHeight: CGFloat = self.dateSeperatorTopMargin.constant
        cellHeight += self.dateSeperatorHeight.constant
        cellHeight += self.dateSeperatorBottomMargin.constant
        cellHeight += self.messageTopMargin.constant
        cellHeight += fullMessageRect.size.height
        cellHeight += self.messageBottomMargin.constant
        cellHeight += self.dividerHeight.constant
        cellHeight += self.dividerBottomMargin.constant
        cellHeight += self.previewSiteNameHeight.constant
        cellHeight += self.previewSiteNameBottomMargin.constant
        cellHeight += self.previewTitleHeight.constant
        cellHeight += self.previewTitleBottomMargin.constant
        cellHeight += descriptionRect.size.height
        cellHeight += self.previewDescriptionBottomMargin.constant
        cellHeight += self.previewThumbnailImageHeight.constant
        
        return Float(cellHeight)
    }
    
    // MARK: TTTAttributedLabelDelegate
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        UIApplication.shared.openURL(url)
    }
}
