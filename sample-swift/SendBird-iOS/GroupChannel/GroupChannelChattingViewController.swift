//
//  GroupChannelChattingViewController.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/10/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import AVKit
import AVFoundation
import MobileCoreServices

class GroupChannelChattingViewController: UIViewController, SBDConnectionDelegate, SBDChannelDelegate, ChattingViewDelegate, MessageDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var groupChannel: SBDGroupChannel!
    
    @IBOutlet weak var chattingView: ChattingView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    
    private var messageQuery: SBDPreviousMessageListQuery!
    private var delegateIdentifier: String!
    private var hasNext: Bool = true
    private var refreshInViewDidAppear: Bool = true
    private var isLoading: Bool = false
    private var keyboardShown: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let titleView: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 100, height: 64))
        titleView.attributedText = Utils.generateNavigationTitle(mainTitle: String(format:Bundle.sbLocalizedStringForKey(key: "GroupChannelTitle"), self.groupChannel.memberCount), subTitle: "")
        titleView.numberOfLines = 2
        titleView.textAlignment = NSTextAlignment.center
        
        let titleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickReconnect))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(titleTapRecognizer)
        
        self.navItem.titleView = titleView
        
        let negativeLeftSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeLeftSpacer.width = -2
        let negativeRightSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeRightSpacer.width = -2
        
        let leftCloseItem = UIBarButtonItem(image: UIImage(named: "btn_close"), style: UIBarButtonItemStyle.done, target: self, action: #selector(close))
        let rightOpenMoreMenuItem = UIBarButtonItem(image: UIImage(named: "btn_more"), style: UIBarButtonItemStyle.done, target: self, action: #selector(openMoreMenu))
        
        self.navItem.leftBarButtonItems = [negativeLeftSpacer, leftCloseItem]
        self.navItem.rightBarButtonItems = [negativeRightSpacer, rightOpenMoreMenuItem]
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        self.delegateIdentifier = self.description
        SBDMain.add(self as SBDChannelDelegate, identifier: self.delegateIdentifier)
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.delegateIdentifier)
        
        self.chattingView.fileAttachButton.addTarget(self, action: #selector(sendFileMessage), for: UIControlEvents.touchUpInside)
        self.chattingView.sendButton.addTarget(self, action: #selector(sendMessage), for: UIControlEvents.touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.refreshInViewDidAppear {
            self.chattingView.initChattingView()
            self.chattingView.delegate = self
            
            self.loadPreviousMessage(initial: true)
        }
        
        self.refreshInViewDidAppear = true
    }

    @objc private func keyboardDidShow(notification: Notification) {
        self.keyboardShown = true
        let keyboardInfo = notification.userInfo
        let keyboardFrameBegin = keyboardInfo?[UIKeyboardFrameEndUserInfoKey]
        let keyboardFrameBeginRect = (keyboardFrameBegin as! NSValue).cgRectValue
        DispatchQueue.main.async {
            self.bottomMargin.constant = keyboardFrameBeginRect.size.height
            self.view.layoutIfNeeded()
            self.chattingView.stopMeasuringVelocity = true
            self.chattingView.scrollToBottom(animated: true, force: false)
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification) {
        self.keyboardShown = false
        DispatchQueue.main.async {
            self.bottomMargin.constant = 0
            self.view.layoutIfNeeded()
            self.chattingView.scrollToBottom(animated: true, force: false)
        }
    }
    
    @objc private func close() {
        self.dismiss(animated: false) { 
            
        }
    }
    
    @objc private func openMoreMenu() {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let seeMemberListAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "SeeMemberListButton"), style: UIAlertActionStyle.default) { (action) in
            DispatchQueue.main.async {
                let mlvc = MemberListViewController(nibName: "MemberListViewController", bundle: Bundle.main)
                mlvc.channel = self.groupChannel
                self.refreshInViewDidAppear = false
                self.present(mlvc, animated: false, completion: nil)
            }
        }
        let seeBlockedUserListAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "SeeBlockedUserListButton"), style: UIAlertActionStyle.default) { (action) in
            DispatchQueue.main.async {
                let plvc = BlockedUserListViewController(nibName: "BlockedUserListViewController", bundle: Bundle.main)
                self.refreshInViewDidAppear = false
                self.present(plvc, animated: false, completion: nil)
            }
        }
        let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
        vc.addAction(seeMemberListAction)
        vc.addAction(seeBlockedUserListAction)
        vc.addAction(closeAction)
        
        self.present(vc, animated: true, completion: nil)
    }
    
    private func loadPreviousMessage(initial: Bool) {
        if initial == true {
            self.chattingView.resendableFileData.removeAll()
            self.chattingView.resendableMessages.removeAll()
            self.chattingView.preSendFileData.removeAll()
            self.chattingView.preSendMessages.removeAll()
            
            self.chattingView.chattingTableView.isHidden = true
            self.messageQuery = self.groupChannel.createPreviousMessageListQuery()
            self.hasNext = true
            self.chattingView.messages.removeAll()
            DispatchQueue.main.async {
                self.chattingView.chattingTableView.reloadData()
            }
        }
        
        if self.hasNext == false {
            self.chattingView.chattingTableView.isHidden = false;
            return
        }
        
        if self.isLoading == true {
            self.chattingView.chattingTableView.isHidden = false;
            return
        }
        
        self.isLoading = true
        
        self.messageQuery.loadPreviousMessages(withLimit: 40, reverse: !initial) { (messages, error) in
            if error != nil {
                let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                vc.addAction(closeAction)
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: nil)
                }
                
                self.chattingView.chattingTableView.isHidden = false
                self.isLoading = false
                
                return
            }
            
            if messages?.count == 0 {
                self.hasNext = false
            }
            
            if initial == true {
                for message in messages! {
                    self.chattingView.messages.append(message)
                }
                
                self.groupChannel.markAsRead()
            }
            else {
                for message in messages! {
                    self.chattingView.messages.insert(message, at: 0)
                }
            }
            
            if initial == true {
                self.chattingView.initialLoading = true
                
                DispatchQueue.main.async {
                    self.chattingView.chattingTableView.reloadData()
                    DispatchQueue.main.async {
                        self.chattingView.scrollToBottom(animated: false, force: true)
                        self.chattingView.chattingTableView.isHidden = false
                    }
                }
                
                self.chattingView.initialLoading = false
                self.isLoading = false
            }
            else {
                if (messages?.count)! > 0 {
                    DispatchQueue.main.async {
                        self.chattingView.chattingTableView.reloadData()
                        DispatchQueue.main.async {
                            self.chattingView.scrollToPosition(position: (messages?.count)! - 1)
                            self.chattingView.chattingTableView.isHidden = false
                        }
                    }
                }
                self.isLoading = false
            }
        }
    }
    
    @objc private func sendMessage() {
        if self.chattingView.messageTextView.text.characters.count > 0 {
            self.groupChannel.endTyping()
            let message = self.chattingView.messageTextView.text
            self.chattingView.messageTextView.text = ""
            
            let preSendMessage = self.groupChannel.sendUserMessage(message, data: "", customType: "", targetLanguages: [], completionHandler: { (userMessage, error) in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(150), execute: {
                    let preSendMessage = self.chattingView.preSendMessages[(userMessage?.requestId)!] as! SBDUserMessage
                    self.chattingView.preSendMessages.removeValue(forKey: (userMessage?.requestId)!)
                    
                    if error != nil {
                        self.chattingView.resendableMessages[(userMessage?.requestId)!] = userMessage
                        self.chattingView.chattingTableView.reloadData()
                        DispatchQueue.main.async {
                            self.chattingView.scrollToBottom(animated: true, force: true)
                        }
                        
                        return
                    }
                    
                    self.chattingView.messages[self.chattingView.messages.index(of: preSendMessage)!] = userMessage!
                    
                    self.chattingView.chattingTableView.reloadData()
                    DispatchQueue.main.async {
                        self.chattingView.scrollToBottom(animated: true, force: true)
                    }
                })
            })
            self.chattingView.preSendMessages[preSendMessage.requestId!] = preSendMessage
            self.chattingView.messages.append(preSendMessage)
            self.chattingView.chattingTableView.reloadData()
            DispatchQueue.main.async {
                self.chattingView.scrollToBottom(animated: true, force: true)
            }
        }
    }
    
    @objc private func sendFileMessage() {
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = UIImagePickerControllerSourceType.photoLibrary
        let mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
        mediaUI.mediaTypes = mediaTypes
        mediaUI.delegate = self
        self.refreshInViewDidAppear = false
        self.present(mediaUI, animated: true, completion: nil)
    }
    
    func clickReconnect() {
        if SBDMain.getConnectState() != SBDWebSocketConnectionState.SBDWebSocketOpen && SBDMain.getConnectState() != SBDWebSocketConnectionState.SBDWebSocketConnecting {
            SBDMain.reconnect()
        }
    }
    
    // MARK: SBDConnectionDelegate
    func didStartReconnection() {
        if self.navItem.titleView != nil && self.navItem.titleView is UILabel {
            (self.navItem.titleView as! UILabel).attributedText = Utils.generateNavigationTitle(mainTitle: String(format:Bundle.sbLocalizedStringForKey(key: "GroupChannelTitle"), self.groupChannel.memberCount), subTitle: Bundle.sbLocalizedStringForKey(key: "ReconnectingSubTitle"))
        }
    }
    
    func didSucceedReconnection() {
        self.loadPreviousMessage(initial: true)
        if self.navItem.titleView != nil && self.navItem.titleView is UILabel {
            (self.navItem.titleView as! UILabel).attributedText = Utils.generateNavigationTitle(mainTitle: String(format:Bundle.sbLocalizedStringForKey(key: "GroupChannelTitle"), self.groupChannel.memberCount), subTitle: Bundle.sbLocalizedStringForKey(key: "ReconnectedSubTitle"))
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            if self.navItem.titleView != nil && self.navItem.titleView is UILabel {
                (self.navItem.titleView as! UILabel).attributedText = Utils.generateNavigationTitle(mainTitle: String(format:Bundle.sbLocalizedStringForKey(key: "GroupChannelTitle"), self.groupChannel.memberCount), subTitle: "")
            }
        }
    }
    
    func didFailReconnection() {
        if self.navItem.titleView != nil && self.navItem.titleView is UILabel {
            (self.navItem.titleView as! UILabel).attributedText = Utils.generateNavigationTitle(mainTitle: String(format:Bundle.sbLocalizedStringForKey(key: "GroupChannelTitle"), self.groupChannel.memberCount), subTitle: Bundle.sbLocalizedStringForKey(key: "ReconnectionFailedSubTitle"))
        }
    }
    
    // MARK: SBDChannelDelegate
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        if sender == self.groupChannel {
            self.groupChannel.markAsRead()
            
            self.chattingView.messages.append(message)
            self.chattingView.chattingTableView.reloadData()
            DispatchQueue.main.async {
                self.chattingView.scrollToBottom(animated: true, force: false)
            }
        }
    }
    
    func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
        if sender == self.groupChannel {
            DispatchQueue.main.async {
                self.chattingView.chattingTableView.reloadData()
            }
        }
    }
    
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        if sender == self.groupChannel {
            if sender.getTypingMembers()?.count == 0 {
                self.chattingView.endTypingIndicator()
            }
            else {
                if sender.getTypingMembers()?.count == 1 {
                    self.chattingView.startTypingIndicator(text: String(format: Bundle.sbLocalizedStringForKey(key: "TypingMessageSingular"), (sender.getTypingMembers()?[0].nickname)!))
                }
                else {
                    self.chattingView.startTypingIndicator(text: Bundle.sbLocalizedStringForKey(key: "TypingMessagePlural"))
                }
            }
        }
    }
    
    func channelWasChanged(_ sender: SBDBaseChannel) {
        if sender == self.groupChannel {
            DispatchQueue.main.async {
                self.navItem.title = String(format: Bundle.sbLocalizedStringForKey(key: "GroupChannelTitle"), self.groupChannel.memberCount)
            }
        }
    }
    
    func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ChannelDeletedTitle"), message: Bundle.sbLocalizedStringForKey(key: "ChannelDeletedMessage"), preferredStyle: UIAlertControllerStyle.alert)
        let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel) { (action) in
            self.close()
        }
        vc.addAction(closeAction)
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        if sender == self.groupChannel {
            for message in self.chattingView.messages {
                if message.messageId == messageId {
                    self.chattingView.messages.remove(at: self.chattingView.messages.index(of: message)!)
                    DispatchQueue.main.async {
                        self.chattingView.chattingTableView.reloadData()
                    }
                    break
                }
            }
        }
    }
    
    // MARK: ChattingViewDelegate
    func loadMoreMessage(view: UIView) {
        self.loadPreviousMessage(initial: false)
    }
    
    func startTyping(view: UIView) {
        self.groupChannel.startTyping()
    }
    
    func endTyping(view: UIView) {
        self.groupChannel.endTyping()
    }
    
    func hideKeyboardWhenFastScrolling(view: UIView) {
        DispatchQueue.main.async {
            self.bottomMargin.constant = 0
            self.view.layoutIfNeeded()
            self.chattingView.scrollToBottom(animated: true, force: false)
        }
        self.view.endEditing(true)
    }
    
    // MARK: MessageDelegate
    func clickProfileImage(viewCell: UITableViewCell, user: SBDUser) {
        let vc = UIAlertController(title: user.nickname, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let seeBlockUserAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "BlockUserButton"), style: UIAlertActionStyle.default) { (action) in
            SBDMain.blockUser(user, completionHandler: { (blockedUser, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                        let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                        vc.addAction(closeAction)
                        DispatchQueue.main.async {
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                    
                    return
                }
                
                DispatchQueue.main.async {
                    let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "UserBlockedTitle"), message: String(format: Bundle.sbLocalizedStringForKey(key: "UserBlockedMessage"), user.nickname!), preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                    vc.addAction(closeAction)
                    DispatchQueue.main.async {
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            })
        }
        let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
        vc.addAction(seeBlockUserAction)
        vc.addAction(closeAction)
        
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func clickMessage(view: UIView, message: SBDBaseMessage) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
        var deleteMessageAction: UIAlertAction?
        var openFileAction: UIAlertAction?
        var openURLsAction: [UIAlertAction] = []
        
        if message is SBDUserMessage {
            let sender = (message as! SBDUserMessage).sender
            if sender?.userId == SBDMain.getCurrentUser()?.userId {
                deleteMessageAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "DeleteMessageButton"), style: UIAlertActionStyle.destructive, handler: { (action) in
                    self.groupChannel.delete(message, completionHandler: { (error) in
                        if error != nil {
                            let alert = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                            let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                            alert.addAction(closeAction)
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    })
                })
            }
            
            do {
                let detector: NSDataDetector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                let matches = detector.matches(in: (message as! SBDUserMessage).message!, options: [], range: NSMakeRange(0, ((message as! SBDUserMessage).message?.characters.count)!))
                for match in matches as [NSTextCheckingResult] {
                    let url: URL = match.url!
                    let openURLAction = UIAlertAction(title: url.relativeString, style: UIAlertActionStyle.default, handler: { (action) in
                        self.refreshInViewDidAppear = false
                        UIApplication.shared.openURL(url)
                    })
                    openURLsAction.append(openURLAction)
                }
            }
            catch {
                
            }
        }
        else if message is SBDFileMessage {
            let fileMessage: SBDFileMessage = message as! SBDFileMessage
            let sender = fileMessage.sender
            let type = fileMessage.type
            let url = fileMessage.url
            
            if sender?.userId == SBDMain.getCurrentUser()?.userId {
                deleteMessageAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "DeleteMessageButton"), style: UIAlertActionStyle.destructive, handler: { (action) in
                    self.groupChannel.delete(fileMessage, completionHandler: { (error) in
                        if error != nil {
                            let alert = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                            let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                            alert.addAction(closeAction)
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    })
                })
            }
            
            if type.hasPrefix("video") {
                openFileAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "PlayVideoButton"), style: UIAlertActionStyle.default, handler: { (action) in
                    let videoUrl = NSURL(string: url)
                    let player = AVPlayer(url: videoUrl as! URL)
                    let vc = AVPlayerViewController()
                    vc.player = player
                    self.refreshInViewDidAppear = false
                    self.present(vc, animated: true, completion: { 
                        player.play()
                    })
                })
            }
            else if type.hasPrefix("audio") {
                openFileAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "PlayAudioButton"), style: UIAlertActionStyle.default, handler: { (action) in
                    let audioUrl = NSURL(string: url)
                    let player = AVPlayer(url: audioUrl as! URL)
                    let vc = AVPlayerViewController()
                    vc.player = player
                    self.refreshInViewDidAppear = false
                    self.present(vc, animated: true, completion: {
                        player.play()
                    })
                })
            }
            else if type.hasPrefix("image") {
                openFileAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "OpenImageButton"), style: UIAlertActionStyle.default, handler: { (action) in
                    let imageUrl = NSURL(string: url)
                    self.refreshInViewDidAppear = false
                    UIApplication.shared.openURL(imageUrl as! URL)
                })
            }
            else {
                // TODO: Download file. Is this possible on iOS?
            }
        }
        else if message is SBDAdminMessage {
            return
        }
        
        alert.addAction(closeAction)
        if openFileAction != nil {
            alert.addAction(openFileAction!)
        }
        
        if openURLsAction.count > 0 {
            for action in openURLsAction {
                alert.addAction(action)
            }
        }
        
        if deleteMessageAction != nil {
            alert.addAction(deleteMessageAction!)
        }
        
        if openFileAction != nil || openURLsAction.count > 0 || deleteMessageAction != nil {
            DispatchQueue.main.async {
                self.refreshInViewDidAppear = false
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func clickResend(view: UIView, message: SBDBaseMessage) {
        if message is SBDUserMessage {
            let resendableUserMessage = message as! SBDUserMessage
            var targetLanguages:[String] = []
            if resendableUserMessage.translations != nil {
                targetLanguages = Array(resendableUserMessage.translations!.keys) as! [String]
            }
            
            let preSendMessage = self.groupChannel.sendUserMessage(resendableUserMessage.message, data: resendableUserMessage.data, customType: resendableUserMessage.customType, targetLanguages: targetLanguages, completionHandler: { (userMessage, error) in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(150), execute: {
                    DispatchQueue.main.async {
                        let preSendMessage = self.chattingView.preSendMessages[(userMessage?.requestId)!]
                        self.chattingView.preSendMessages.removeValue(forKey: (userMessage?.requestId)!)
                        
                        if error != nil {
                            self.chattingView.resendableMessages[(userMessage?.requestId)!] = userMessage
                            self.chattingView.chattingTableView.reloadData()
                            DispatchQueue.main.async {
                                self.chattingView.scrollToBottom(animated: true, force: true)
                            }
                            
                            let alert = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                            let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                            alert.addAction(closeAction)
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                            return
                        }
                        
                        if preSendMessage != nil {
                            self.chattingView.messages.remove(at: self.chattingView.messages.index(of: (preSendMessage! as SBDBaseMessage))!)
                            self.chattingView.messages.append(userMessage!)
                        }
                        
                        self.chattingView.chattingTableView.reloadData()
                        DispatchQueue.main.async {
                            self.chattingView.scrollToBottom(animated: true, force: true)
                        }
                    }
                })
            })
            self.chattingView.messages[self.chattingView.messages.index(of: resendableUserMessage)!] = preSendMessage
            self.chattingView.preSendMessages[preSendMessage.requestId!] = preSendMessage
            self.chattingView.chattingTableView.reloadData()
            DispatchQueue.main.async {
                self.chattingView.scrollToBottom(animated: true, force: true)
            }
        }
        else if message is SBDFileMessage {
            let resendableFileMessage = message as! SBDFileMessage
            
            var thumbnailSizes: [SBDThumbnailSize] = []
            for thumbnail in resendableFileMessage.thumbnails! as [SBDThumbnail] {
                thumbnailSizes.append(SBDThumbnailSize.make(withMaxCGSize: thumbnail.maxSize)!)
            }
            let preSendMessage = self.groupChannel.sendFileMessage(withBinaryData: self.chattingView.preSendFileData[resendableFileMessage.requestId!]!, filename: resendableFileMessage.name, type: resendableFileMessage.type, size: resendableFileMessage.size, thumbnailSizes: thumbnailSizes, data: resendableFileMessage.data, customType: resendableFileMessage.customType, progressHandler: nil, completionHandler: { (fileMessage, error) in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(150), execute: {
                    let preSendMessage = self.chattingView.preSendMessages[(fileMessage?.requestId)!]
                    self.chattingView.preSendMessages.removeValue(forKey: (fileMessage?.requestId)!)
                    
                    if error != nil {
                        self.chattingView.resendableMessages[(fileMessage?.requestId)!] = fileMessage
                        self.chattingView.resendableFileData[(fileMessage?.requestId)!] = self.chattingView.resendableFileData[resendableFileMessage.requestId!]
                        self.chattingView.resendableFileData.removeValue(forKey: resendableFileMessage.requestId!)
                        self.chattingView.chattingTableView.reloadData()
                        DispatchQueue.main.async {
                            self.chattingView.scrollToBottom(animated: true, force: true)
                        }
                        
                        let alert = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                        let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(closeAction)
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                        return
                    }
                    
                    if preSendMessage != nil {
                        self.chattingView.messages.remove(at: self.chattingView.messages.index(of: (preSendMessage! as SBDBaseMessage))!)
                        self.chattingView.messages.append(fileMessage!)
                    }
                    
                    self.chattingView.chattingTableView.reloadData()
                    DispatchQueue.main.async {
                        self.chattingView.scrollToBottom(animated: true, force: true)
                    }
                })
            })
            self.chattingView.messages[self.chattingView.messages.index(of: resendableFileMessage)!] = preSendMessage
            self.chattingView.preSendMessages[preSendMessage.requestId!] = preSendMessage
            self.chattingView.preSendFileData[preSendMessage.requestId!] = self.chattingView.resendableFileData[resendableFileMessage.requestId!]
            self.chattingView.preSendFileData.removeValue(forKey: resendableFileMessage.requestId!)
            self.chattingView.chattingTableView.reloadData()
            DispatchQueue.main.async {
                self.chattingView.scrollToBottom(animated: true, force: true)
            }
        }
    }
    
    func clickDelete(view: UIView, message: SBDBaseMessage) {
        self.chattingView.messages.remove(at: self.chattingView.messages.index(of: message)!)
        DispatchQueue.main.async {
            self.chattingView.chattingTableView.reloadData()
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        var originalImage: UIImage?
        var editedImage: UIImage?
        var imageToUse: UIImage?
        var imageName: NSString?
        var imageType: NSString?
        
        picker.dismiss(animated: true) { 
            if CFStringCompare(mediaType as CFString, kUTTypeImage, []) == CFComparisonResult.compareEqualTo {
                editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
                originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage
                let refUrl: URL = info[UIImagePickerControllerReferenceURL] as! URL
                imageName = refUrl.lastPathComponent as NSString?
                
                if originalImage != nil {
                    imageToUse = originalImage
                }
                else {
                    imageToUse = editedImage
                }
                
                var newWidth: CGFloat = 0
                var newHeight: CGFloat = 0
                if (imageToUse?.size.width)! > (imageToUse?.size.height)! {
                    newWidth = 450
                    newHeight = newWidth * (imageToUse?.size.height)! / (imageToUse?.size.width)!
                }
                else {
                    newHeight = 450
                    newWidth = newHeight * (imageToUse?.size.width)! / (imageToUse?.size.height)!
                }
                
                UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 0.0)
                imageToUse?.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                var imageFileData: NSData?
                let extentionOfFile: String = imageName!.substring(from: imageName!.range(of: ".").location + 1)
                
                if extentionOfFile.caseInsensitiveCompare("png") == ComparisonResult.orderedSame {
                    imageType = "image/png"
                    imageFileData = UIImagePNGRepresentation(newImage!)! as NSData?
                }
                else {
                    imageType = "image/jpg"
                    imageFileData = UIImageJPEGRepresentation(newImage!, 1.0) as NSData?
                }
                
                /***********************************/
                /* Thumbnail is a premium feature. */
                /***********************************/
                let thumbnailSize = SBDThumbnailSize.make(withMaxWidth: 320.0, maxHeight: 320.0)
                let preSendMessage = self.groupChannel.sendFileMessage(withBinaryData: imageFileData as! Data, filename: imageName as! String, type: imageType as! String, size: UInt((imageFileData?.length)!), thumbnailSizes: [thumbnailSize!], data: "", customType: "", progressHandler: nil, completionHandler: { (fileMessage, error) in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(150), execute: {
                        DispatchQueue.main.async {
                            let preSendMessage = self.chattingView.preSendMessages[(fileMessage?.requestId)!] as! SBDFileMessage
                            self.chattingView.preSendMessages.removeValue(forKey: (fileMessage?.requestId)!)
                            
                            if error != nil {
                                self.chattingView.resendableMessages[(fileMessage?.requestId)!] = preSendMessage
                                self.chattingView.resendableFileData[preSendMessage.requestId!] = imageFileData as Data?
                                self.chattingView.chattingTableView.reloadData()
                                DispatchQueue.main.async {
                                    self.chattingView.scrollToBottom(animated: true, force: true)
                                }
                                
                                let alert = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                                let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                                alert.addAction(closeAction)
                                DispatchQueue.main.async {
                                    self.present(alert, animated: true, completion: nil)
                                }
                                
                                return
                            }
                            if fileMessage != nil {
                                self.chattingView.resendableMessages.removeValue(forKey: (fileMessage?.requestId)!)
                                self.chattingView.resendableFileData.removeValue(forKey: (fileMessage?.requestId)!)
                                self.chattingView.messages[self.chattingView.messages.index(of: preSendMessage)!] = fileMessage!
                                
                                DispatchQueue.main.async {
                                    self.chattingView.chattingTableView.reloadData()
                                    DispatchQueue.main.async {
                                        self.chattingView.scrollToBottom(animated: true, force: true)
                                    }
                                }
                            }
                        }
                    })
                })
                
                self.chattingView.preSendFileData[preSendMessage.requestId!] = imageFileData as Data?
                self.chattingView.preSendMessages[preSendMessage.requestId!] = preSendMessage
                self.chattingView.messages.append(preSendMessage)
                self.chattingView.chattingTableView.reloadData()
                DispatchQueue.main.async {
                    self.chattingView.scrollToBottom(animated: true, force: true)
                }
            }
            else if CFStringCompare(mediaType as CFString, kUTTypeMovie, []) == CFComparisonResult.compareEqualTo {
                let videoUrl: URL = info[UIImagePickerControllerMediaURL] as! URL
                let videoFileData = NSData(contentsOf: videoUrl)
                let videoName = videoUrl.lastPathComponent as NSString?
                var videoType: String?
                
                let extentionOfFile: String = videoName!.substring(from: videoName!.range(of: ".").location + 1) as String
                
                if extentionOfFile.caseInsensitiveCompare("mov") == ComparisonResult.orderedSame {
                    videoType = "video/quicktime"
                }
                else if extentionOfFile.caseInsensitiveCompare("mp4") == ComparisonResult.orderedSame {
                    videoType = "video/mp4"
                }
                else {
                    videoType = "video/mpeg"
                }
                
                let preSendMessage = self.groupChannel.sendFileMessage(withBinaryData: videoFileData as! Data, filename: videoName as! String, type: videoType!, size: UInt((videoFileData?.length)!), data: "", completionHandler: { (fileMessage, error) in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(150), execute: {
                        DispatchQueue.main.async {
                            let preSendMessage = self.chattingView.preSendMessages[(fileMessage?.requestId!)!] as! SBDFileMessage
                            self.chattingView.preSendMessages.removeValue(forKey: (fileMessage?.requestId!)!)
                        
                            if error != nil {
                                self.chattingView.resendableMessages[(fileMessage?.requestId)!] = preSendMessage
                                self.chattingView.resendableFileData[preSendMessage.requestId!] = videoFileData as Data?
                                self.chattingView.chattingTableView.reloadData()
                                DispatchQueue.main.async {
                                    self.chattingView.scrollToBottom(animated: true, force: true)
                                }
                                
                                let alert = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                                let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                                alert.addAction(closeAction)
                                DispatchQueue.main.async {
                                    self.present(alert, animated: true, completion: nil)
                                }
                                
                                return
                            }
                            
                            if fileMessage != nil {
                                self.chattingView.resendableMessages.removeValue(forKey: (fileMessage?.requestId!)!)
                                self.chattingView.resendableFileData.removeValue(forKey: (fileMessage?.requestId)!)
                                self.chattingView.messages[self.chattingView.messages.index(of: preSendMessage)!] = fileMessage!
                                
                                DispatchQueue.main.async {
                                    self.chattingView.chattingTableView.reloadData()
                                    DispatchQueue.main.async {
                                        self.chattingView.scrollToBottom(animated: true, force : false)
                                    }
                                }
                            }
                        }
                    })
                })
                
                self.chattingView.preSendFileData[preSendMessage.requestId!] = videoFileData as? Data
                self.chattingView.preSendMessages[preSendMessage.requestId!] = preSendMessage
                self.chattingView.messages.append(preSendMessage)
                self.chattingView.chattingTableView.reloadData()
                DispatchQueue.main.async {
                    self.chattingView.scrollToBottom(animated: true, force: true)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
