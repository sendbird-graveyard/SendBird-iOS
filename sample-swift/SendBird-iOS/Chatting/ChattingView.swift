//
//  ChattingView.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/7/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

protocol ChattingViewDelegate: class {
    func loadMoreMessage(view: UIView)
    func startTyping(view: UIView)
    func endTyping(view: UIView)
    func hideKeyboardWhenFastScrolling(view: UIView)
}

class ChattingView: ReusableViewFromXib, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var chattingTableView: UITableView!
    @IBOutlet weak var inputContainerViewHeight: NSLayoutConstraint!
    var messages: [SBDBaseMessage] = []
    
    var resendableMessages: [String:SBDBaseMessage] = [:]
    var preSendMessages: [String:SBDBaseMessage] = [:]
    
    var resendableFileData: [String:[String:AnyObject]] = [:]
    var preSendFileData: [String:[String:AnyObject]] = [:]

    @IBOutlet weak var fileAttachButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    var stopMeasuringVelocity: Bool = true
    var initialLoading: Bool = true
    
    var delegate: (ChattingViewDelegate & MessageDelegate)?

    @IBOutlet weak var typingIndicatorContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var typingIndicatorImageView: UIImageView!
    @IBOutlet weak var typingIndicatorLabel: UILabel!
    @IBOutlet weak var typingIndicatorContainerView: UIView!
    @IBOutlet weak var typingIndicatorImageHeight: NSLayoutConstraint!
    
    var incomingUserMessageSizingTableViewCell: IncomingUserMessageTableViewCell?
    var outgoingUserMessageSizingTableViewCell: OutgoingUserMessageTableViewCell?
    var neutralMessageSizingTableViewCell: NeutralMessageTableViewCell?
    var incomingFileMessageSizingTableViewCell: IncomingFileMessageTableViewCell?
    var outgoingImageFileMessageSizingTableViewCell: OutgoingImageFileMessageTableViewCell?
    var outgoingFileMessageSizingTableViewCell: OutgoingFileMessageTableViewCell?
    var incomingImageFileMessageSizingTableViewCell: IncomingImageFileMessageTableViewCell?
    var incomingVideoFileMessageSizingTableViewCell: IncomingVideoFileMessageTableViewCell?
    var outgoingVideoFileMessageSizingTableViewCell: OutgoingVideoFileMessageTableViewCell?
    var incomingGeneralUrlPreviewMessageTableViewCell: IncomingGeneralUrlPreviewMessageTableViewCell?
    var outgoingGeneralUrlPreviewMessageTableViewCell: OutgoingGeneralUrlPreviewMessageTableViewCell?
    var outgoingGeneralUrlPreviewTempMessageTableViewCell: OutgoingGeneralUrlPreviewTempMessageTableViewCell?

    @IBOutlet weak var placeholderLabel: UILabel!
    
    var lastMessageHeight: CGFloat = 0
    var scrollLock: Bool = false
    
    var lastOffset: CGPoint = CGPoint(x: 0, y: 0)
    var lastOffsetCapture: TimeInterval = 0
    var isScrollingFast: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        self.chattingTableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0)
        self.messageTextView.textContainerInset = UIEdgeInsetsMake(15.5, 0, 14, 0)
    }
    
    func initChattingView() {
        self.initialLoading = true
        self.lastMessageHeight = 0
        self.scrollLock = false
        self.stopMeasuringVelocity = false
        
        self.typingIndicatorContainerView.isHidden = true
        self.typingIndicatorContainerViewHeight.constant = 0
        self.typingIndicatorImageHeight.constant = 0
        
//        self.typingIndicatorContainerView.layoutIfNeeded()
        
        self.messageTextView.delegate = self
        
        self.chattingTableView.register(IncomingUserMessageTableViewCell.nib(), forCellReuseIdentifier: IncomingUserMessageTableViewCell.cellReuseIdentifier())
        self.chattingTableView.register(OutgoingUserMessageTableViewCell.nib(), forCellReuseIdentifier: OutgoingUserMessageTableViewCell.cellReuseIdentifier())
        self.chattingTableView.register(NeutralMessageTableViewCell.nib(), forCellReuseIdentifier: NeutralMessageTableViewCell.cellReuseIdentifier())
        self.chattingTableView.register(IncomingFileMessageTableViewCell.nib(), forCellReuseIdentifier: IncomingFileMessageTableViewCell.cellReuseIdentifier())
        self.chattingTableView.register(OutgoingImageFileMessageTableViewCell.nib(), forCellReuseIdentifier: OutgoingImageFileMessageTableViewCell.cellReuseIdentifier())
        self.chattingTableView.register(OutgoingFileMessageTableViewCell.nib(), forCellReuseIdentifier: OutgoingFileMessageTableViewCell.cellReuseIdentifier())
        self.chattingTableView.register(IncomingImageFileMessageTableViewCell.nib(), forCellReuseIdentifier: IncomingImageFileMessageTableViewCell.cellReuseIdentifier())
        self.chattingTableView.register(IncomingVideoFileMessageTableViewCell.nib(), forCellReuseIdentifier: IncomingVideoFileMessageTableViewCell.cellReuseIdentifier())
        self.chattingTableView.register(OutgoingVideoFileMessageTableViewCell.nib(), forCellReuseIdentifier: OutgoingVideoFileMessageTableViewCell.cellReuseIdentifier())
        
        self.chattingTableView.register(IncomingGeneralUrlPreviewMessageTableViewCell.nib(), forCellReuseIdentifier: IncomingGeneralUrlPreviewMessageTableViewCell.cellReuseIdentifier())
        self.chattingTableView.register(OutgoingGeneralUrlPreviewMessageTableViewCell.nib(), forCellReuseIdentifier: OutgoingGeneralUrlPreviewMessageTableViewCell.cellReuseIdentifier())
        self.chattingTableView.register(OutgoingGeneralUrlPreviewTempMessageTableViewCell.nib(), forCellReuseIdentifier: OutgoingGeneralUrlPreviewTempMessageTableViewCell.cellReuseIdentifier())
        
        self.chattingTableView.delegate = self
        self.chattingTableView.dataSource = self
        
        self.initSizingCell()
    }
    
    func initSizingCell() {
        self.incomingUserMessageSizingTableViewCell = IncomingUserMessageTableViewCell.nib().instantiate(withOwner: self, options: nil)[0] as? IncomingUserMessageTableViewCell
        self.incomingUserMessageSizingTableViewCell?.frame = self.frame
        self.incomingUserMessageSizingTableViewCell?.isHidden = true
        self.addSubview(self.incomingUserMessageSizingTableViewCell!)
        
        self.outgoingUserMessageSizingTableViewCell = OutgoingUserMessageTableViewCell.nib().instantiate(withOwner: self, options: nil)[0] as? OutgoingUserMessageTableViewCell
        self.outgoingUserMessageSizingTableViewCell?.frame = self.frame
        self.outgoingUserMessageSizingTableViewCell?.isHidden = true
        self.addSubview(self.outgoingUserMessageSizingTableViewCell!)
        
        self.neutralMessageSizingTableViewCell = NeutralMessageTableViewCell.nib().instantiate(withOwner: self, options: nil)[0] as? NeutralMessageTableViewCell
        self.neutralMessageSizingTableViewCell?.frame = self.frame
        self.neutralMessageSizingTableViewCell?.isHidden = true
        self.addSubview(self.neutralMessageSizingTableViewCell!)
        
        self.incomingFileMessageSizingTableViewCell = IncomingFileMessageTableViewCell.nib().instantiate(withOwner: self, options: nil)[0] as? IncomingFileMessageTableViewCell
        self.incomingFileMessageSizingTableViewCell?.frame = self.frame
        self.incomingFileMessageSizingTableViewCell?.isHidden = true
        self.addSubview(self.incomingFileMessageSizingTableViewCell!)
        
        self.outgoingImageFileMessageSizingTableViewCell = OutgoingImageFileMessageTableViewCell.nib().instantiate(withOwner: self, options: nil)[0] as? OutgoingImageFileMessageTableViewCell
        self.outgoingImageFileMessageSizingTableViewCell?.frame = self.frame
        self.outgoingImageFileMessageSizingTableViewCell?.isHidden = true
        self.addSubview(self.outgoingImageFileMessageSizingTableViewCell!)
        
        self.outgoingFileMessageSizingTableViewCell = OutgoingFileMessageTableViewCell.nib().instantiate(withOwner: self, options: nil)[0] as? OutgoingFileMessageTableViewCell
        self.outgoingFileMessageSizingTableViewCell?.frame = self.frame
        self.outgoingFileMessageSizingTableViewCell?.isHidden = true
        self.addSubview(self.outgoingFileMessageSizingTableViewCell!)
        
        self.incomingImageFileMessageSizingTableViewCell = IncomingImageFileMessageTableViewCell.nib().instantiate(withOwner: self, options: nil)[0] as? IncomingImageFileMessageTableViewCell
        self.incomingImageFileMessageSizingTableViewCell?.frame = self.frame
        self.incomingImageFileMessageSizingTableViewCell?.isHidden = true
        self.addSubview(self.incomingImageFileMessageSizingTableViewCell!)
        
        self.incomingVideoFileMessageSizingTableViewCell = IncomingVideoFileMessageTableViewCell.nib().instantiate(withOwner: self, options: nil)[0] as? IncomingVideoFileMessageTableViewCell
        self.incomingVideoFileMessageSizingTableViewCell?.frame = self.frame
        self.incomingVideoFileMessageSizingTableViewCell?.isHidden = true
        self.addSubview(self.incomingVideoFileMessageSizingTableViewCell!)
        
        self.outgoingVideoFileMessageSizingTableViewCell = OutgoingVideoFileMessageTableViewCell.nib().instantiate(withOwner: self, options: nil)[0] as? OutgoingVideoFileMessageTableViewCell
        self.outgoingVideoFileMessageSizingTableViewCell?.frame = self.frame
        self.outgoingVideoFileMessageSizingTableViewCell?.isHidden = true
        self.addSubview(self.outgoingVideoFileMessageSizingTableViewCell!)

        self.incomingGeneralUrlPreviewMessageTableViewCell = IncomingGeneralUrlPreviewMessageTableViewCell.nib().instantiate(withOwner: self, options: nil)[0] as? IncomingGeneralUrlPreviewMessageTableViewCell
        self.incomingGeneralUrlPreviewMessageTableViewCell?.frame = self.frame
        self.incomingGeneralUrlPreviewMessageTableViewCell?.isHidden = true
        self.addSubview(self.incomingGeneralUrlPreviewMessageTableViewCell!)

        self.outgoingGeneralUrlPreviewMessageTableViewCell = OutgoingGeneralUrlPreviewMessageTableViewCell.nib().instantiate(withOwner: self, options: nil)[0] as? OutgoingGeneralUrlPreviewMessageTableViewCell
        self.outgoingGeneralUrlPreviewMessageTableViewCell?.frame = self.frame
        self.outgoingGeneralUrlPreviewMessageTableViewCell?.isHidden = true
        self.addSubview(self.outgoingGeneralUrlPreviewMessageTableViewCell!)

        self.outgoingGeneralUrlPreviewTempMessageTableViewCell = OutgoingGeneralUrlPreviewTempMessageTableViewCell.nib().instantiate(withOwner: self, options: nil)[0] as? OutgoingGeneralUrlPreviewTempMessageTableViewCell
        self.outgoingGeneralUrlPreviewTempMessageTableViewCell?.frame = self.frame
        self.outgoingGeneralUrlPreviewTempMessageTableViewCell?.isHidden = true
        self.addSubview(self.outgoingGeneralUrlPreviewTempMessageTableViewCell!)
    }
    
    func scrollToBottom(force: Bool) {
        if self.messages.count == 0 {
            return
        }
        
        if self.scrollLock == true && force == false {
            return
        }
        
        self.chattingTableView.scrollToRow(at: IndexPath.init(row: self.messages.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
    }
    
    func scrollToPosition(position: Int) {
        if self.messages.count == 0 {
            return
        }
        
        self.chattingTableView.scrollToRow(at: IndexPath.init(row: position, section: 0), at: UITableViewScrollPosition.top, animated: false)
    }
    
    func startTypingIndicator(text: String) {
        // Typing indicator
        self.typingIndicatorContainerView.isHidden = false
        self.typingIndicatorLabel.text = text
        
        self.typingIndicatorContainerViewHeight.constant = 26.0
        self.typingIndicatorImageHeight.constant = 26.0
        self.typingIndicatorContainerView.layoutIfNeeded()

        if self.typingIndicatorImageView.isAnimating == false {
            var typingImages: [UIImage] = []
            for i in 1...50 {
                let typingImageFrameName = String.init(format: "%02d", i)
                typingImages.append(UIImage(named: typingImageFrameName)!)
            }
            self.typingIndicatorImageView.animationImages = typingImages
            self.typingIndicatorImageView.animationDuration = 1.5
            
            DispatchQueue.main.async {
                self.typingIndicatorImageView.startAnimating()
            }
        }
    }
    
    func endTypingIndicator() {
        DispatchQueue.main.async {
            self.typingIndicatorImageView.stopAnimating()
        }

        self.typingIndicatorContainerView.isHidden = true
        self.typingIndicatorContainerViewHeight.constant = 0
        self.typingIndicatorImageHeight.constant = 0
        
        self.typingIndicatorContainerView.layoutIfNeeded()
    }
    
    // MARK: UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        if textView == self.messageTextView {
            if textView.text.characters.count > 0 {
                self.placeholderLabel.isHidden = true
                if self.delegate != nil {
                    self.delegate?.startTyping(view: self)
                }
            }
            else {
                self.placeholderLabel.isHidden = false
                if self.delegate != nil {
                    self.delegate?.endTyping(view: self)
                }
            }
        }
    }
    
    // MARK: UITableViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.stopMeasuringVelocity = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.stopMeasuringVelocity = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.chattingTableView {
            if self.stopMeasuringVelocity == false {
                let currentOffset = scrollView.contentOffset
                let currentTime = NSDate.timeIntervalSinceReferenceDate
                
                let timeDiff = currentTime - self.lastOffsetCapture
                if timeDiff > 0.1 {
                    let distance = currentOffset.y - self.lastOffset.y
                    let scrollSpeedNotAbs = distance * 10 / 1000
                    let scrollSpeed = fabs(scrollSpeedNotAbs)
                    if scrollSpeed > 0.5 {
                        self.isScrollingFast = true
                    }
                    else {
                        self.isScrollingFast = false
                    }
                    
                    self.lastOffset = currentOffset
                    self.lastOffsetCapture = currentTime
                }
                
                if self.isScrollingFast {
                    if self.delegate != nil {
                        self.delegate?.hideKeyboardWhenFastScrolling(view: self)
                    }
                }
            }
            
            if scrollView.contentOffset.y + scrollView.frame.size.height + self.lastMessageHeight < scrollView.contentSize.height {
                self.scrollLock = true
            }
            else {
                self.scrollLock = false
            }
            
            if scrollView.contentOffset.y == 0 {
                if self.messages.count > 0 && self.initialLoading == false {
                    if self.delegate != nil {
                        self.delegate?.loadMoreMessage(view: self)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        
        let msg = self.messages[indexPath.row]
        
        if msg is SBDUserMessage {
            let userMessage = msg as! SBDUserMessage
            let sender = userMessage.sender
            
            if sender?.userId == SBDMain.getCurrentUser()?.userId {
                // Outgoing
                if userMessage.customType == "url_preview" {
                    if indexPath.row > 0 {
                        self.outgoingGeneralUrlPreviewMessageTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.outgoingGeneralUrlPreviewMessageTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                    self.outgoingGeneralUrlPreviewMessageTableViewCell?.setModel(aMessage: userMessage)
                    height = (self.outgoingGeneralUrlPreviewMessageTableViewCell?.getHeightOfViewCell())!
                }
                else {
                    if indexPath.row > 0 {
                        self.outgoingUserMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.outgoingUserMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                    self.outgoingUserMessageSizingTableViewCell?.setModel(aMessage: userMessage)
                    height = (self.outgoingUserMessageSizingTableViewCell?.getHeightOfViewCell())!
                }
            }
            else {
                // Incoming
                if userMessage.customType == "url_preview" {
                    if indexPath.row > 0 {
                        self.incomingGeneralUrlPreviewMessageTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.incomingGeneralUrlPreviewMessageTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                    self.incomingGeneralUrlPreviewMessageTableViewCell?.setModel(aMessage: userMessage)
                    height = CGFloat((self.incomingGeneralUrlPreviewMessageTableViewCell?.getHeightOfViewCell())!)
                }
                else {
                    if indexPath.row > 0 {
                        self.incomingUserMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.incomingUserMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                    self.incomingUserMessageSizingTableViewCell?.setModel(aMessage: userMessage)
                    height = (self.incomingUserMessageSizingTableViewCell?.getHeightOfViewCell())!
                }
                
            }
        }
        else if msg is SBDFileMessage {
            let fileMessage = msg as! SBDFileMessage
            let sender = fileMessage.sender
            
            if sender?.userId == SBDMain.getCurrentUser()?.userId {
                // Outgoing
                if fileMessage.type.hasPrefix("video") {
                    if indexPath.row > 0 {
                        self.outgoingVideoFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.outgoingVideoFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                    self.outgoingVideoFileMessageSizingTableViewCell?.setModel(aMessage: fileMessage)
                    height = (self.outgoingVideoFileMessageSizingTableViewCell?.getHeightOfViewCell())!
                }
                else if fileMessage.type.hasPrefix("audio") {
                    if indexPath.row > 0 {
                        self.outgoingFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.outgoingFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                    self.outgoingFileMessageSizingTableViewCell?.setModel(aMessage: fileMessage)
                    height = (self.outgoingFileMessageSizingTableViewCell?.getHeightOfViewCell())!
                }
                else if fileMessage.type.hasPrefix("image") {
                    if indexPath.row > 0 {
                        self.outgoingImageFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.outgoingImageFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                    self.outgoingImageFileMessageSizingTableViewCell?.setModel(aMessage: fileMessage)
                    height = (self.outgoingImageFileMessageSizingTableViewCell?.getHeightOfViewCell())!
                }
                else {
                    if indexPath.row > 0 {
                        self.outgoingFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.outgoingFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                    self.outgoingFileMessageSizingTableViewCell?.setModel(aMessage: fileMessage)
                    height = (self.outgoingFileMessageSizingTableViewCell?.getHeightOfViewCell())!
                }
            }
            else {
                // Incoming
                if fileMessage.type.hasPrefix("video") {
                    if indexPath.row > 0 {
                        self.incomingVideoFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.incomingVideoFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                    self.incomingVideoFileMessageSizingTableViewCell?.setModel(aMessage: fileMessage)
                    height = (self.incomingVideoFileMessageSizingTableViewCell?.getHeightOfViewCell())!
                }
                else if fileMessage.type.hasPrefix("audio") {
                    if indexPath.row > 0 {
                        self.incomingFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.incomingFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                    self.incomingFileMessageSizingTableViewCell?.setModel(aMessage: fileMessage)
                    height = (self.incomingFileMessageSizingTableViewCell?.getHeightOfViewCell())!
                }
                else if fileMessage.type.hasPrefix("image") {
                    if indexPath.row > 0 {
                        self.incomingImageFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.incomingImageFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                    self.incomingImageFileMessageSizingTableViewCell?.setModel(aMessage: fileMessage)
                    height = (self.incomingImageFileMessageSizingTableViewCell?.getHeightOfViewCell())!
                }
                else {
                    if indexPath.row > 0 {
                        self.incomingFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.incomingFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                    self.incomingFileMessageSizingTableViewCell?.setModel(aMessage: fileMessage)
                    height = (self.incomingFileMessageSizingTableViewCell?.getHeightOfViewCell())!
                }
            }
        }
        else if msg is SBDAdminMessage {
            let adminMessage = msg as! SBDAdminMessage
            if indexPath.row > 0 {
                self.neutralMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
            }
            else {
                self.neutralMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
            }
            
            self.neutralMessageSizingTableViewCell?.setModel(aMessage: adminMessage)
            height = (self.neutralMessageSizingTableViewCell?.getHeightOfViewCell())!
        }
        else if msg is OutgoingGeneralUrlPreviewTempModel {
            let tempModel: OutgoingGeneralUrlPreviewTempModel = msg as! OutgoingGeneralUrlPreviewTempModel
            if indexPath.row > 0 {
                self.outgoingGeneralUrlPreviewTempMessageTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
            }
            else {
                self.outgoingGeneralUrlPreviewTempMessageTableViewCell?.setPreviousMessage(aPrevMessage: nil)
            }
            self.outgoingGeneralUrlPreviewTempMessageTableViewCell?.setModel(aMessage: tempModel)
            height = (self.outgoingGeneralUrlPreviewTempMessageTableViewCell?.getHeightOfViewCell())!
        }
        
        if self.messages.count > 0 && self.messages.count - 1 == indexPath.row {
            self.lastMessageHeight = height
        }
        
        return height
    }
    
    /*
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        
        let msg = self.messages[indexPath.row]
        
        if msg is SBDUserMessage {
            let userMessage = msg as! SBDUserMessage
            let sender = userMessage.sender
            
            if sender?.userId == SBDMain.getCurrentUser()?.userId {
                // Outgoing
                if indexPath.row > 0 {
                    self.outgoingUserMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                }
                else {
                    self.outgoingUserMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                }
                self.outgoingUserMessageSizingTableViewCell?.setModel(aMessage: userMessage)
                height = (self.outgoingUserMessageSizingTableViewCell?.getHeightOfViewCell())!
            }
            else {
                // Incoming
                if indexPath.row > 0 {
                    self.incomingUserMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                }
                else {
                    self.incomingUserMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                }
                self.incomingUserMessageSizingTableViewCell?.setModel(aMessage: userMessage)
                height = (self.incomingUserMessageSizingTableViewCell?.getHeightOfViewCell())!
            }
        }
        else if msg is SBDFileMessage {
            let fileMessage = msg as! SBDFileMessage
            let sender = fileMessage.sender
            
            if sender?.userId == SBDMain.getCurrentUser()?.userId {
                // Outgoing
                if fileMessage.type.hasPrefix("video") {
                    if indexPath.row > 0 {
                        self.outgoingFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.outgoingFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                    self.outgoingFileMessageSizingTableViewCell?.setModel(aMessage: fileMessage)
                    height = (self.outgoingFileMessageSizingTableViewCell?.getHeightOfViewCell())!
                }
                else if fileMessage.type.hasPrefix("audio") {
                    if indexPath.row > 0 {
                        self.outgoingFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.outgoingFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                    self.outgoingFileMessageSizingTableViewCell?.setModel(aMessage: fileMessage)
                    height = (self.outgoingFileMessageSizingTableViewCell?.getHeightOfViewCell())!
                }
                else if fileMessage.type.hasPrefix("image") {
                    if indexPath.row > 0 {
                        self.outgoingImageFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.outgoingImageFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                    self.outgoingImageFileMessageSizingTableViewCell?.setModel(aMessage: fileMessage)
                    height = (self.outgoingImageFileMessageSizingTableViewCell?.getHeightOfViewCell())!
                }
                else {
                    if indexPath.row > 0 {
                        self.outgoingFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.outgoingFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                    self.outgoingFileMessageSizingTableViewCell?.setModel(aMessage: fileMessage)
                    height = (self.outgoingFileMessageSizingTableViewCell?.getHeightOfViewCell())!
                }
            }
            else {
                // Incoming
                if fileMessage.type.hasPrefix("video") {
                    if indexPath.row > 0 {
                        self.incomingFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.incomingFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                    self.incomingFileMessageSizingTableViewCell?.setModel(aMessage: fileMessage)
                    height = (self.incomingFileMessageSizingTableViewCell?.getHeightOfViewCell())!
                }
                else if fileMessage.type.hasPrefix("audio") {
                    if indexPath.row > 0 {
                        self.incomingFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.incomingFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                    self.incomingFileMessageSizingTableViewCell?.setModel(aMessage: fileMessage)
                    height = (self.incomingFileMessageSizingTableViewCell?.getHeightOfViewCell())!
                }
                else if fileMessage.type.hasPrefix("image") {
                    if indexPath.row > 0 {
                        self.incomingImageFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.incomingImageFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                    self.incomingImageFileMessageSizingTableViewCell?.setModel(aMessage: fileMessage)
                    height = (self.incomingImageFileMessageSizingTableViewCell?.getHeightOfViewCell())!
                }
                else {
                    if indexPath.row > 0 {
                        self.incomingFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.incomingFileMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                    self.incomingFileMessageSizingTableViewCell?.setModel(aMessage: fileMessage)
                    height = (self.incomingFileMessageSizingTableViewCell?.getHeightOfViewCell())!
                }
            }
        }
        else if msg is SBDAdminMessage {
            let adminMessage = msg as! SBDAdminMessage
            if indexPath.row > 0 {
                self.neutralMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
            }
            else {
                self.neutralMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
            }
            
            self.neutralMessageSizingTableViewCell?.setModel(aMessage: adminMessage)
            height = (self.neutralMessageSizingTableViewCell?.getHeightOfViewCell())!
        }
        
        if self.messages.count > 0 && self.messages.count - 1 == indexPath.row {
            self.lastMessageHeight = height
        }
        
        return height
    }
 */
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        let msg = self.messages[indexPath.row]
        
        if msg is SBDUserMessage {
            let userMessage = msg as! SBDUserMessage
            let sender = userMessage.sender
            
            if sender?.userId == SBDMain.getCurrentUser()?.userId {
                // Outgoing
                if userMessage.customType == "url_preview" {
                    cell = tableView.dequeueReusableCell(withIdentifier: OutgoingGeneralUrlPreviewMessageTableViewCell.cellReuseIdentifier())
                    cell?.frame = CGRect(x: (cell?.frame.origin.x)!, y: (cell?.frame.origin.y)!, width: (cell?.frame.size.width)!, height: (cell?.frame.size.height)!)
                    if indexPath.row > 0 {
                        (cell as! OutgoingGeneralUrlPreviewMessageTableViewCell).setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        (cell as! OutgoingGeneralUrlPreviewMessageTableViewCell).setPreviousMessage(aPrevMessage: nil)
                    }
                    (cell as! OutgoingGeneralUrlPreviewMessageTableViewCell).setModel(aMessage: userMessage)
                    (cell as! OutgoingGeneralUrlPreviewMessageTableViewCell).delegate = self.delegate
                    
                    if self.preSendMessages[userMessage.requestId!] != nil {
                        (cell as! OutgoingGeneralUrlPreviewMessageTableViewCell).showSendingStatus()
                    }
                    else {
                        if self.resendableMessages[userMessage.requestId!] != nil {
                            (cell as! OutgoingGeneralUrlPreviewMessageTableViewCell).showMessageControlButton()
//                            (cell as! OutgoingGeneralUrlPreviewMessageTableViewCell).showFailedStatus()
                        }
                        else {
                            (cell as! OutgoingGeneralUrlPreviewMessageTableViewCell).showMessageDate()
                            (cell as! OutgoingGeneralUrlPreviewMessageTableViewCell).showUnreadCount()
                        }
                    }
                }
                else {
                    cell = tableView.dequeueReusableCell(withIdentifier: OutgoingUserMessageTableViewCell.cellReuseIdentifier())
                    cell?.frame = CGRect(x: (cell?.frame.origin.x)!, y: (cell?.frame.origin.y)!, width: (cell?.frame.size.width)!, height: (cell?.frame.size.height)!)
                    if indexPath.row > 0 {
                        (cell as! OutgoingUserMessageTableViewCell).setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        (cell as! OutgoingUserMessageTableViewCell).setPreviousMessage(aPrevMessage: nil)
                    }
                    (cell as! OutgoingUserMessageTableViewCell).setModel(aMessage: userMessage)
                    (cell as! OutgoingUserMessageTableViewCell).delegate = self.delegate
                    
                    if self.preSendMessages[userMessage.requestId!] != nil {
                        (cell as! OutgoingUserMessageTableViewCell).showSendingStatus()
                    }
                    else {
                        if self.resendableMessages[userMessage.requestId!] != nil {
                            (cell as! OutgoingUserMessageTableViewCell).showMessageControlButton()
//                            (cell as! OutgoingUserMessageTableViewCell).showFailedStatus()
                        }
                        else {
                            (cell as! OutgoingUserMessageTableViewCell).showMessageDate()
                            (cell as! OutgoingUserMessageTableViewCell).showUnreadCount()
                        }
                    }
                }
                
            }
            else {
                // Incoming
                if userMessage.customType == "url_preview" {
                    cell = tableView.dequeueReusableCell(withIdentifier: IncomingGeneralUrlPreviewMessageTableViewCell.cellReuseIdentifier())
                    cell?.frame = CGRect(x: (cell?.frame.origin.x)!, y: (cell?.frame.origin.y)!, width: (cell?.frame.size.width)!, height: (cell?.frame.size.height)!)
                    if indexPath.row > 0 {
                        (cell as! IncomingGeneralUrlPreviewMessageTableViewCell).setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        (cell as! IncomingGeneralUrlPreviewMessageTableViewCell).setPreviousMessage(aPrevMessage: nil)
                    }
                    (cell as! IncomingGeneralUrlPreviewMessageTableViewCell).setModel(aMessage: userMessage)
                    (cell as! IncomingGeneralUrlPreviewMessageTableViewCell).delegate = self.delegate
                }
                else {
                    cell = tableView.dequeueReusableCell(withIdentifier: IncomingUserMessageTableViewCell.cellReuseIdentifier())
                    cell?.frame = CGRect(x: (cell?.frame.origin.x)!, y: (cell?.frame.origin.y)!, width: (cell?.frame.size.width)!, height: (cell?.frame.size.height)!)
                    if indexPath.row > 0 {
                        (cell as! IncomingUserMessageTableViewCell).setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        (cell as! IncomingUserMessageTableViewCell).setPreviousMessage(aPrevMessage: nil)
                    }
                    (cell as! IncomingUserMessageTableViewCell).setModel(aMessage: userMessage)
                    (cell as! IncomingUserMessageTableViewCell).delegate = self.delegate
                }
            }
        }
        else if msg is SBDFileMessage {
            let fileMessage = msg as! SBDFileMessage
            let sender = fileMessage.sender
            
            if sender?.userId == SBDMain.getCurrentUser()?.userId {
                // Outgoing
                if fileMessage.type.hasPrefix("video") {
                    cell = tableView.dequeueReusableCell(withIdentifier: OutgoingVideoFileMessageTableViewCell.cellReuseIdentifier())
                    cell?.frame = CGRect(x: (cell?.frame.origin.x)!, y: (cell?.frame.origin.y)!, width: (cell?.frame.size.width)!, height: (cell?.frame.size.height)!)
                    if indexPath.row > 0 {
                        (cell as! OutgoingVideoFileMessageTableViewCell).setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        (cell as! OutgoingVideoFileMessageTableViewCell).setPreviousMessage(aPrevMessage: nil)
                    }
                    (cell as! OutgoingVideoFileMessageTableViewCell).setModel(aMessage: fileMessage)
                    (cell as! OutgoingVideoFileMessageTableViewCell).delegate = self.delegate
                    
                    if self.preSendMessages[fileMessage.requestId!] != nil {
                        (cell as! OutgoingVideoFileMessageTableViewCell).showSendingStatus()
                    }
                    else {
                        if self.resendableMessages[fileMessage.requestId!] != nil {
                            (cell as! OutgoingVideoFileMessageTableViewCell).showMessageControlButton()
//                            (cell as! OutgoingVideoFileMessageTableViewCell).showFailedStatus()
                        }
                        else {
                            (cell as! OutgoingVideoFileMessageTableViewCell).showMessageDate()
                            (cell as! OutgoingVideoFileMessageTableViewCell).showUnreadCount()
                        }
                    }
                }
                else if fileMessage.type.hasPrefix("audio") {
                    cell = tableView.dequeueReusableCell(withIdentifier: OutgoingFileMessageTableViewCell.cellReuseIdentifier())
                    cell?.frame = CGRect(x: (cell?.frame.origin.x)!, y: (cell?.frame.origin.y)!, width: (cell?.frame.size.width)!, height: (cell?.frame.size.height)!)
                    if indexPath.row > 0 {
                        (cell as! OutgoingFileMessageTableViewCell).setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        (cell as! OutgoingFileMessageTableViewCell).setPreviousMessage(aPrevMessage: nil)
                    }
                    (cell as! OutgoingFileMessageTableViewCell).setModel(aMessage: fileMessage)
                    (cell as! OutgoingFileMessageTableViewCell).delegate = self.delegate
                    
                    if self.preSendMessages[fileMessage.requestId!] != nil {
                        (cell as! OutgoingFileMessageTableViewCell).showSendingStatus()
                    }
                    else {
                        if self.resendableMessages[fileMessage.requestId!] != nil {
                            (cell as! OutgoingFileMessageTableViewCell).showMessageControlButton()
//                            (cell as! OutgoingFileMessageTableViewCell).showFailedStatus()
                        }
                        else {
                            (cell as! OutgoingFileMessageTableViewCell).showMessageDate()
                            (cell as! OutgoingFileMessageTableViewCell).showUnreadCount()
                        }
                    }
                }
                else if fileMessage.type.hasPrefix("image") {
                    cell = tableView.dequeueReusableCell(withIdentifier: OutgoingImageFileMessageTableViewCell.cellReuseIdentifier())
                    cell?.frame = CGRect(x: (cell?.frame.origin.x)!, y: (cell?.frame.origin.y)!, width: (cell?.frame.size.width)!, height: (cell?.frame.size.height)!)
                    if indexPath.row > 0 {
                        (cell as! OutgoingImageFileMessageTableViewCell).setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        (cell as! OutgoingImageFileMessageTableViewCell).setPreviousMessage(aPrevMessage: nil)
                    }
                    (cell as! OutgoingImageFileMessageTableViewCell).setModel(aMessage: fileMessage)
                    (cell as! OutgoingImageFileMessageTableViewCell).delegate = self.delegate
                    
                    if self.preSendMessages[fileMessage.requestId!] != nil {
                        (cell as! OutgoingImageFileMessageTableViewCell).showSendingStatus()
                        (cell as! OutgoingImageFileMessageTableViewCell).setImageData(data: self.preSendFileData[fileMessage.requestId!]!["data"] as! Data, type: self.preSendFileData[fileMessage.requestId!]!["type"] as! String)
                        (cell as! OutgoingImageFileMessageTableViewCell).hasImageCacheData = true
                    }
                    else {
                        if self.resendableMessages[fileMessage.requestId!] != nil {
                            (cell as! OutgoingImageFileMessageTableViewCell).showMessageControlButton()
//                            (cell as! OutgoingImageFileMessageTableViewCell).showFailedStatus()
                            (cell as! OutgoingImageFileMessageTableViewCell).setImageData(data: self.resendableFileData[fileMessage.requestId!]?["data"] as! Data, type: self.resendableFileData[fileMessage.requestId!]?["type"] as! String)
                            (cell as! OutgoingImageFileMessageTableViewCell).hasImageCacheData = true
                        }
                        else {
                            if fileMessage.url.characters.count > 0 && self.preSendFileData[fileMessage.requestId!] != nil {
                                (cell as! OutgoingImageFileMessageTableViewCell).setImageData(data: self.preSendFileData[fileMessage.requestId!]?["data"] as! Data, type: self.preSendFileData[fileMessage.requestId!]?["type"] as! String)
                                (cell as! OutgoingImageFileMessageTableViewCell).hasImageCacheData = true
                                self.preSendFileData.removeValue(forKey: fileMessage.requestId!);
                            }
                            else {
                                (cell as! OutgoingImageFileMessageTableViewCell).hasImageCacheData = false
                            }
                            (cell as! OutgoingImageFileMessageTableViewCell).showMessageDate()
                            (cell as! OutgoingImageFileMessageTableViewCell).showUnreadCount()
                        }
                    }
                }
                else {
                    cell = tableView.dequeueReusableCell(withIdentifier: OutgoingFileMessageTableViewCell.cellReuseIdentifier())
                    cell?.frame = CGRect(x: (cell?.frame.origin.x)!, y: (cell?.frame.origin.y)!, width: (cell?.frame.size.width)!, height: (cell?.frame.size.height)!)
                    if indexPath.row > 0 {
                        (cell as! OutgoingFileMessageTableViewCell).setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        (cell as! OutgoingFileMessageTableViewCell).setPreviousMessage(aPrevMessage: nil)
                    }
                    (cell as! OutgoingFileMessageTableViewCell).setModel(aMessage: fileMessage)
                    (cell as! OutgoingFileMessageTableViewCell).delegate = self.delegate
                    
                    if self.preSendMessages[fileMessage.requestId!] != nil {
                        (cell as! OutgoingFileMessageTableViewCell).showSendingStatus()
                    }
                    else {
                        if self.resendableMessages[fileMessage.requestId!] != nil {
                            (cell as! OutgoingFileMessageTableViewCell).showMessageControlButton()
//                            (cell as! OutgoingFileMessageTableViewCell).showFailedStatus()
                        }
                        else {
                            (cell as! OutgoingFileMessageTableViewCell).showMessageDate()
                            (cell as! OutgoingFileMessageTableViewCell).showUnreadCount()
                        }
                    }
                }
            }
            else {
                // Incoming
                if fileMessage.type.hasPrefix("video") {
                    cell = tableView.dequeueReusableCell(withIdentifier: IncomingVideoFileMessageTableViewCell.cellReuseIdentifier())
                    cell?.frame = CGRect(x: (cell?.frame.origin.x)!, y: (cell?.frame.origin.y)!, width: (cell?.frame.size.width)!, height: (cell?.frame.size.height)!)
                    if indexPath.row > 0 {
                        (cell as! IncomingVideoFileMessageTableViewCell).setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        (cell as! IncomingVideoFileMessageTableViewCell).setPreviousMessage(aPrevMessage: nil)
                    }
                    (cell as! IncomingVideoFileMessageTableViewCell).setModel(aMessage: fileMessage)
                    (cell as! IncomingVideoFileMessageTableViewCell).delegate = self.delegate
                }
                else if fileMessage.type.hasPrefix("audio") {
                    cell = tableView.dequeueReusableCell(withIdentifier: IncomingFileMessageTableViewCell.cellReuseIdentifier())
                    cell?.frame = CGRect(x: (cell?.frame.origin.x)!, y: (cell?.frame.origin.y)!, width: (cell?.frame.size.width)!, height: (cell?.frame.size.height)!)
                    if indexPath.row > 0 {
                        (cell as! IncomingFileMessageTableViewCell).setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        (cell as! IncomingFileMessageTableViewCell).setPreviousMessage(aPrevMessage: nil)
                    }
                    (cell as! IncomingFileMessageTableViewCell).setModel(aMessage: fileMessage)
                    (cell as! IncomingFileMessageTableViewCell).delegate = self.delegate
                }
                else if fileMessage.type.hasPrefix("image") {
                    cell = tableView.dequeueReusableCell(withIdentifier: IncomingImageFileMessageTableViewCell.cellReuseIdentifier())
                    cell?.frame = CGRect(x: (cell?.frame.origin.x)!, y: (cell?.frame.origin.y)!, width: (cell?.frame.size.width)!, height: (cell?.frame.size.height)!)
                    if indexPath.row > 0 {
                        (cell as! IncomingImageFileMessageTableViewCell).setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        (cell as! IncomingImageFileMessageTableViewCell).setPreviousMessage(aPrevMessage: nil)
                    }
                    (cell as! IncomingImageFileMessageTableViewCell).setModel(aMessage: fileMessage)
                    (cell as! IncomingImageFileMessageTableViewCell).delegate = self.delegate
                }
                else {
                    cell = tableView.dequeueReusableCell(withIdentifier: IncomingFileMessageTableViewCell.cellReuseIdentifier())
                    cell?.frame = CGRect(x: (cell?.frame.origin.x)!, y: (cell?.frame.origin.y)!, width: (cell?.frame.size.width)!, height: (cell?.frame.size.height)!)
                    if indexPath.row > 0 {
                        (cell as! IncomingFileMessageTableViewCell).setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        (cell as! IncomingFileMessageTableViewCell).setPreviousMessage(aPrevMessage: nil)
                    }
                    (cell as! IncomingFileMessageTableViewCell).setModel(aMessage: fileMessage)
                    (cell as! IncomingFileMessageTableViewCell).delegate = self.delegate
                }
            }
        }
        else if msg is SBDAdminMessage {
            let adminMessage = msg as! SBDAdminMessage
            
            cell = tableView.dequeueReusableCell(withIdentifier: NeutralMessageTableViewCell.cellReuseIdentifier())
            cell?.frame = CGRect(x: (cell?.frame.origin.x)!, y: (cell?.frame.origin.y)!, width: (cell?.frame.size.width)!, height: (cell?.frame.size.height)!)
            if indexPath.row > 0 {
                (cell as! NeutralMessageTableViewCell).setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
            }
            else {
                (cell as! NeutralMessageTableViewCell).setPreviousMessage(aPrevMessage: nil)
            }
            
            (cell as! NeutralMessageTableViewCell).setModel(aMessage: adminMessage)
        }
        else if msg is OutgoingGeneralUrlPreviewTempModel {
            let model = msg as! OutgoingGeneralUrlPreviewTempModel
            
            cell = tableView.dequeueReusableCell(withIdentifier: OutgoingGeneralUrlPreviewTempMessageTableViewCell.cellReuseIdentifier())
            cell?.frame = CGRect(x: (cell?.frame.origin.x)!, y: (cell?.frame.origin.y)!, width: (cell?.frame.size.width)!, height: (cell?.frame.size.height)!)
            if indexPath.row > 0 {
                (cell as! OutgoingGeneralUrlPreviewTempMessageTableViewCell).setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
            }
            else {
                (cell as! OutgoingGeneralUrlPreviewTempMessageTableViewCell).setPreviousMessage(aPrevMessage: nil)
            }
            
            (cell as! OutgoingGeneralUrlPreviewTempMessageTableViewCell).setModel(aMessage: model)
        }
        
        
        return cell!
    }
}
