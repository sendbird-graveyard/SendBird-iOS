//
//  OpenChannelViewController.swift
//  SampleUI
//
//  Created by Jed Kyung on 8/19/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices

import JSQMessagesViewController
import SendBirdSDK
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol OpenChannelViewControllerDelegate: class {
    func didCloseOpenChannelViewController(_ vc: UIViewController)
}

class OpenChannelViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SBDConnectionDelegate, SBDChannelDelegate {
    var channel: SBDOpenChannel?
    weak var delegate: OpenChannelViewControllerDelegate!
    
    fileprivate var avatars: NSMutableDictionary?
    fileprivate var users: NSMutableDictionary?
    fileprivate var outgoingBubbleImageData: JSQMessagesBubbleImage?
    fileprivate var incomingBubbleImageData: JSQMessagesBubbleImage?
    fileprivate var neutralBubbleImageData: JSQMessagesBubbleImage?
    fileprivate var messages: [JSQSBMessage] = []
    
    fileprivate var lastMessageTimestamp: Int64 = Int64.min
    fileprivate var firstMessageTimestamp: Int64 = Int64.max
    
    fileprivate var hasPrev: Bool = false
    
    fileprivate var previousMessageQuery: SBDPreviousMessageListQuery?
    fileprivate var delegateIndetifier: String?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hasPrev = true
        
        self.avatars = NSMutableDictionary()
        self.users = NSMutableDictionary()
        
        self.lastMessageTimestamp = Int64.min
        self.firstMessageTimestamp = Int64.max
        
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height: kJSQMessagesCollectionViewAvatarSizeDefault)
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height: kJSQMessagesCollectionViewAvatarSizeDefault)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(OpenChannelViewController.actionPressed(_:)))
        
        self.showLoadEarlierMessagesHeader = false
        self.collectionView.collectionViewLayout.springinessEnabled = false
        self.collectionView.bounces = false
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        let neutralBubbleFactory = JSQMessagesBubbleImageFactory.init(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero)
        
        self.inputToolbar.contentView.textView.delegate = self
        
        self.outgoingBubbleImageData = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        self.incomingBubbleImageData = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        self.neutralBubbleImageData = neutralBubbleFactory?.neutralMessagesBubbleImage(with: UIColor.jsq_messageNeutralBubble())

        self.delegateIndetifier = self.description
        
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.delegateIndetifier!)
        SBDMain.add(self as SBDChannelDelegate, identifier: self.delegateIndetifier!)
        
        self.startSendBird()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.navigationController?.viewControllers.index(of: self) == nil {
            SBDMain.removeChannelDelegate(forIdentifier: self.delegateIndetifier!)
            SBDMain.removeConnectionDelegate(forIdentifier: self.delegateIndetifier!)

            self.channel?.exitChannel(completionHandler: { (error) in
                
            })
        }
        
        super.viewWillDisappear(animated)
    }

    func actionPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let closeAction = UIAlertAction.init(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
        let seeParticipantAction = UIAlertAction.init(title: "See participant list", style: UIAlertActionStyle.default) { (action) in
            let vc = ParticipantListViewController()
            vc.currentChannel = self.channel
            
            DispatchQueue.main.async(execute: { 
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }
        let seeBlockedUserListAction = UIAlertAction.init(title: "See blocked user list", style: UIAlertActionStyle.default) { (action) in
            let vc = BlockedUserListViewController()
            
            DispatchQueue.main.async(execute: {
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }
        let exitAction = UIAlertAction.init(title: "Exit from this channel", style: UIAlertActionStyle.default) { (action) in
            self.channel?.exitChannel(completionHandler: { (error) in
                DispatchQueue.main.async(execute: {
                    if self.delegate != nil {
                        self.delegate?.didCloseOpenChannelViewController(self)
                    }
                    
                    self.navigationController!.popViewController(animated: true)
                })
            })
        }

        alert.addAction(closeAction)
        alert.addAction(seeParticipantAction)
        alert.addAction(seeBlockedUserListAction)
        alert.addAction(exitAction)
        
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true, completion: nil)
        })
    }

    fileprivate func startSendBird() {
        if self.channel != nil {
            self.previousMessageQuery = self.channel?.createPreviousMessageListQuery()
            self.channel?.enter(completionHandler: { (error) in
                if (error != nil) {
                    let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(closeAction)
                    DispatchQueue.main.async(execute: {
                        self.present(alert, animated: true, completion: nil)
                    })
                }
                else {
                    self.loadMessage(Int64.max, initial: true)
                }
            })
        }
    }
    
    fileprivate func loadMessage(_ ts:Int64, initial:Bool) {
        if self.previousMessageQuery?.isLoading() == true {
            return;
        }
        
        if self.hasPrev == false {
            return;
        }
        
        self.previousMessageQuery?.loadPreviousMessages(withLimit: 30, reverse: !initial, completionHandler: { (messages, error) in
            if error != nil {
                print("Loading previous message error", error)
                
                return
            }
            
            if messages != nil && messages!.count > 0 {
                var msgCount: Int32 = 0
                
                for message: SBDBaseMessage in messages! {
                    if message.createdAt < self.firstMessageTimestamp {
                        self.firstMessageTimestamp = message.createdAt
                    }
                    
                    var jsqsbmsg: JSQSBMessage?
                    
                    if message.isKind(of: SBDUserMessage.self) == true {
                        let senderId = (message as! SBDUserMessage).sender?.userId
                        let senderImage = (message as! SBDUserMessage).sender?.profileUrl
                        let senderName = (message as! SBDUserMessage).sender?.nickname
                        let msgDate = Date.init(timeIntervalSince1970: Double((message as! SBDUserMessage).createdAt) / 1000.0)
                        let messageText = (message as! SBDUserMessage).message
                        
                        var initialName: NSString = ""
                        if senderName?.characters.count > 1 {
                            initialName = (senderName! as NSString).substring(with: NSRange(location: 0, length: 2)) as NSString
                        }
                        else if senderName?.characters.count > 0 {
                            initialName = (senderName! as NSString).substring(with: NSRange(location: 0, length: 1)) as NSString
                        }
                        
                        let placeholderImage = JSQMessagesAvatarImageFactory.circularAvatarPlaceholderImage(initialName as String, backgroundColor: UIColor.lightGray, textColor: UIColor.darkGray, font: UIFont.systemFont(ofSize: 13.0), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                        let avatarImage = JSQMessagesAvatarImageFactory.avatarImage(withImageURL: senderImage, highlightedImageURL: nil, placeholderImage: placeholderImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                        
                        self.avatars?.setObject(avatarImage, forKey: senderId! as NSCopying)
                        self.users?.setObject(senderName!, forKey: senderId! as NSCopying)
                        
                        jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, text: messageText)
                        jsqsbmsg!.message = message
                        msgCount += 1
                    }
                    else if message.isKind(of: SBDFileMessage.self) == true {
                        let senderId = (message as! SBDFileMessage).sender?.userId
                        let senderImage = (message as! SBDFileMessage).sender?.profileUrl
                        let senderName = (message as! SBDFileMessage).sender?.nickname
                        let msgDate = Date.init(timeIntervalSince1970: Double((message as! SBDFileMessage).createdAt) / 1000.0)
                        let url = (message as! SBDFileMessage).url
                        let type = (message as! SBDFileMessage).type
                        
                        var initialName: NSString = ""
                        if senderName?.characters.count > 1 {
                            initialName = (senderName! as NSString).substring(with: NSRange(location: 0, length: 2)) as NSString
                        }
                        else if senderName?.characters.count > 0 {
                            initialName = (senderName! as NSString).substring(with: NSRange(location: 0, length: 1)) as NSString
                        }
                        
                        let placeholderImage = JSQMessagesAvatarImageFactory.circularAvatarPlaceholderImage(initialName as String, backgroundColor: UIColor.lightGray, textColor: UIColor.darkGray, font: UIFont.systemFont(ofSize: 13.0), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                        let avatarImage = JSQMessagesAvatarImageFactory.avatarImage(withImageURL: senderImage, highlightedImageURL: nil, placeholderImage: placeholderImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                        
                        self.avatars?.setObject(avatarImage, forKey: senderId! as NSCopying)
                        self.users?.setObject(senderName!, forKey: senderId! as NSCopying)
                        
                        if type.hasPrefix("image") == true {
                            let photoItem = JSQPhotoMediaItem.init(imageURL: url)
                            jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, media: photoItem)
                        }
                        else if type.hasPrefix("video") == true {
                            let videoItem = JSQVideoMediaItem.init(fileURL: URL.init(string: url), isReadyToPlay: true)
                            jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, media: videoItem)
                        }
                        else {
                            let fileItem = JSQFileMediaItem.init(fileURL: URL.init(string: url))
                            jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, media: fileItem)
                        }
                        
                        jsqsbmsg!.message = message
                        msgCount += 1
                    }
                    else if message.isKind(of: SBDAdminMessage.self) == true {
                        let msgDate = Date.init(timeIntervalSince1970: Double((message as! SBDAdminMessage).createdAt) / 1000.0)
                        let messageText = (message as! SBDAdminMessage).message
                        
                        let jsqsbmsg = JSQSBMessage.init(senderId: "", senderDisplayName: "", date: msgDate, text: messageText)
                        jsqsbmsg?.message = message
                        msgCount += 1
                    }
                    
                    if initial == true {
                        self.messages.append(jsqsbmsg!)
                    }
                    else {
                        self.messages.insert(jsqsbmsg!, at: 0)
                    }
                }
                
                DispatchQueue.main.async(execute: { 
                    self.collectionView.reloadData()
                    
                    if initial == true {
                        self.scrollToBottom(animated: false)
                    }
                    else {
                        let totalMsgCount = self.collectionView.numberOfItems(inSection: 0)
                        if msgCount - 1 > 0 && totalMsgCount > 0 {
                            self.collectionView.scrollToItem(at: IndexPath.init(row: (msgCount - 1), section: 0), at: UICollectionViewScrollPosition.top, animated: false)
                        }
                    }
                })
            }
            else {
                self.hasPrev = false
            }
        })
    }
    
    // MARK: JSQMessages CollectionView DataSource
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        self.messages.remove(at: indexPath.row)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages[indexPath.item]
        
        if message.senderId.characters.count == 0 {
            return self.neutralBubbleImageData
            
        }
        else {
            if message.senderId == self.senderId {
                return self.outgoingBubbleImageData
            }
            else {
                return self.incomingBubbleImageData
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = self.messages[indexPath.item]
        print(self.avatars?.object(forKey: message.senderId))
        return self.avatars?.object(forKey: message.senderId) as! JSQMessagesAvatarImage as JSQMessageAvatarImageDataSource
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message = self.messages[indexPath.item]
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = self.messages[indexPath.item]
        
        if message.senderId == self.senderId {
            return nil
        }
        
        if indexPath.item - 1 > 0{
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return nil
            }
        }
        
        return NSAttributedString.init(string: message.senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return nil
    }
    
    // MARK: UICollectionView DataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let msg = self.messages[(indexPath as NSIndexPath).item]
        
        if msg.isMediaMessage == false {
            if msg.senderId == self.senderId {
                cell.textView.textColor = UIColor.black
                cell.setUnreadCount(0)
            }
            else {
                cell.textView.textColor = UIColor.white
            }
            
            cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView.textColor!, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        }
        
        cell.setUnreadCount(0)
        
        if (indexPath as NSIndexPath).row == 0 {
            self.loadMessage(self.firstMessageTimestamp, initial: false)
        }
        
        return cell
    }
    
    // MARK: UICollectionView Delegate
    
    // MARK: JSQMessages collection view flow layout delegate
    
    // MARK: Adjusting cell label heights
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let currentMessage = self.messages[indexPath.item]
        if currentMessage.senderId == self.senderId {
            return 0.0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 0.0
    }
    
    // MARK: Responding to collection view tap events
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        print("Load earlier messages!")
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        print("Tapped avater!")
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let jsqMessage = self.messages[indexPath.item]
        
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let closeAction = UIAlertAction.init(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
        var deleteMessageAction: UIAlertAction?
        var blockUserAction: UIAlertAction?
        var openFileAction: UIAlertAction?
        
        if jsqMessage.message?.isKind(of: SBDBaseMessage.self) == true {
            let baseMessage = jsqMessage.message
            if baseMessage?.isKind(of: SBDUserMessage.self) == true {
                let sender = (baseMessage as! SBDUserMessage).sender
                
                if sender!.userId == SBDMain.getCurrentUser()!.userId {
                    deleteMessageAction = UIAlertAction.init(title: "Delete the message", style: UIAlertActionStyle.destructive, handler: { (action) in
                        let selectedMessageIndexPath = indexPath
                        self.channel?.delete(baseMessage!, completionHandler: { (error) in
                            if error != nil {
                                let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                                let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                                alert.addAction(closeAction)
                                DispatchQueue.main.async(execute: {
                                    self.present(alert, animated: true, completion: nil)
                                })
                            }
                            else {
                                DispatchQueue.main.async(execute: {
                                    self.messages.remove(at: (selectedMessageIndexPath?.row)!)
                                    collectionView.reloadData()
                                })
                            }
                        })
                    })
                }
                else {
                    blockUserAction = UIAlertAction.init(title: "Block user", style: UIAlertActionStyle.destructive, handler: { (action) in
                        SBDMain.blockUser(sender!, completionHandler: { (blocked, error) in
                            if error != nil {
                                let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                                let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                                alert.addAction(closeAction)
                                DispatchQueue.main.async(execute: {
                                    self.present(alert, animated: true, completion: nil)
                                })
                            }
                            else {
                                let alert = UIAlertController(title: "User Blocked", message: String(format: "%@ is blocked", blocked!.nickname!), preferredStyle: UIAlertControllerStyle.alert)
                                let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                                alert.addAction(closeAction)
                                DispatchQueue.main.async(execute: {
                                    self.present(alert, animated: true, completion: nil)
                                })
                            }
                        })
                    })
                }
            }
            else if baseMessage?.isKind(of: SBDFileMessage.self) == true {
                let fileMessage = baseMessage as! SBDFileMessage
                let sender = fileMessage.sender
                let type = fileMessage.type
                let url = fileMessage.url
                
                if sender!.userId == SBDMain.getCurrentUser()!.userId {
                    deleteMessageAction = UIAlertAction.init(title: "Delete the message", style: UIAlertActionStyle.destructive, handler: { (action) in
                        let selectedMessageIndexPath = indexPath
                        self.channel?.delete(baseMessage!, completionHandler: { (error) in
                            if error != nil {
                                let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                                let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                                alert.addAction(closeAction)
                                DispatchQueue.main.async(execute: {
                                    self.present(alert, animated: true, completion: nil)
                                })
                            }
                            else {
                                DispatchQueue.main.async(execute: {
                                    self.messages.remove(at: (selectedMessageIndexPath?.row)!)
                                    collectionView.reloadData()
                                })
                            }
                        })
                    })
                }
                else {
                    blockUserAction = UIAlertAction.init(title: "Block user", style: UIAlertActionStyle.destructive, handler: { (action) in
                        SBDMain.blockUser(sender!, completionHandler: { (blockedUser, error) in
                            if error != nil {
                                let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                                let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                                alert.addAction(closeAction)
                                DispatchQueue.main.async(execute: {
                                    self.present(alert, animated: true, completion: nil)
                                })
                            }
                            else {
                                let alert = UIAlertController(title: "User Blocked", message: String(format: "%@ is blocked", blockedUser!.nickname!), preferredStyle: UIAlertControllerStyle.alert)
                                let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                                alert.addAction(closeAction)
                                DispatchQueue.main.async(execute: {
                                    self.present(alert, animated: true, completion: nil)
                                })
                            }
                        })
                    })
                }
                
                if type.hasPrefix("video") == true {
                    openFileAction = UIAlertAction.init(title: "Play video", style: UIAlertActionStyle.default, handler: { (action) in
                        let videoUrl = URL.init(string: url)
                        let player = AVPlayer.init(url: videoUrl!)
                        let vc = AVPlayerViewController()
                        vc.player = player
                        self.present(vc, animated: true, completion: { 
                            player.play()
                        })
                    })
                }
                else if type.hasPrefix("audio") == true {
                    openFileAction = UIAlertAction.init(title: "Play audio", style: UIAlertActionStyle.default, handler: { (action) in
                        let audioUrl = URL.init(string: url)
                        let player = AVPlayer.init(url: audioUrl!)
                        let vc = AVPlayerViewController()
                        vc.player = player
                        self.present(vc, animated: true, completion: {
                            player.play()
                        })
                    })
                }
                else if type.hasPrefix("image") == true {
                    openFileAction = UIAlertAction.init(title: "Open image on Safari", style: UIAlertActionStyle.default, handler: { (action) in
                        let imageUrl = URL.init(string: url)
                        UIApplication.shared.open(imageUrl!, options: [String:AnyObject](), completionHandler: { (result) in
                            
                        })
                    })
                }
                else {
                    // TODO: Download file.
                }
            }
            else if baseMessage?.isKind(of: SBDAdminMessage.self) == true {
                
            }
            
            alert.addAction(closeAction)
            if blockUserAction != nil {
                alert.addAction(blockUserAction!)
            }
            if openFileAction != nil {
                alert.addAction(openFileAction!)
            }
            if deleteMessageAction != nil {
                alert.addAction(deleteMessageAction!)
            }
            
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapCellAt indexPath: IndexPath!, touchLocation: CGPoint) {
        print("Tapped cell at ", NSStringFromCGPoint(touchLocation), "!")
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text.characters.count > 0 {
            self.channel?.sendUserMessage(text, completionHandler: { (userMessage, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(closeAction)
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    if userMessage?.createdAt > self.lastMessageTimestamp {
                        self.lastMessageTimestamp = userMessage!.createdAt
                    }
                    
                    if userMessage?.createdAt < self.firstMessageTimestamp {
                        self.firstMessageTimestamp = userMessage!.createdAt
                    }
                    
                    var jsqsbmsg: JSQSBMessage?
                    
                    let senderId = userMessage?.sender?.userId
                    let senderImage = userMessage?.sender?.profileUrl
                    let senderName = userMessage?.sender?.nickname
                    let msgDate = Date.init(timeIntervalSince1970: Double((userMessage!.createdAt / 1000)))
                    let messageText = userMessage?.message
                    
                    var initialName = ""
                    if senderName?.characters.count > 1 {
                        initialName = (senderName! as NSString).substring(with: NSMakeRange(0, 2)).uppercased()
                    }
                    else if senderName?.characters.count > 0 {
                        initialName = (senderName! as NSString).substring(with: NSMakeRange(0, 1)).uppercased()
                    }
                    
                    let placeholderImage = JSQMessagesAvatarImageFactory.circularAvatarPlaceholderImage(initialName, backgroundColor: UIColor.lightGray, textColor: UIColor.darkGray, font: UIFont.systemFont(ofSize: 13.0), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                    let avatarImage = JSQMessagesAvatarImageFactory.avatarImage(withImageURL: senderImage, highlightedImageURL: senderImage, placeholderImage: placeholderImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                    
                    self.avatars?.setObject(avatarImage, forKey: senderId! as NSCopying)
                    if senderName != nil {
                        self.users?.setObject(senderName!, forKey: senderId! as NSCopying)
                    }
                    else {
                        self.users?.setObject("UK", forKey: senderId! as NSCopying)
                    }
                    
                    jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, text: messageText)
                    jsqsbmsg!.message = userMessage
                    
                    self.messages.append(jsqsbmsg!)
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(500 * NSEC_PER_USEC)) / Double(NSEC_PER_SEC), execute: { 
                        DispatchQueue.main.async(execute: { 
                            self.collectionView.reloadData()
                            self.scrollToBottom(animated: false)
                            
                            self.inputToolbar.contentView.textView.text = ""
                        })
                    })
                }
            })
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let mediaUI = UIImagePickerController()
        
        mediaUI.sourceType = UIImagePickerControllerSourceType.photoLibrary
        mediaUI.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        mediaUI.delegate = self
        
        self.present(mediaUI, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType]

        picker.dismiss(animated: true) { 
            if CFStringCompare(mediaType as! CFString, kUTTypeImage, CFStringCompareFlags.compareDiacriticInsensitive) == CFComparisonResult.compareEqualTo {
                var originalImage: UIImage?
                var editedImage: UIImage?
                var imageToUse: UIImage?
                var imagePath: URL?
                
                var imageName: NSString?
                var imageType: String?
                
                editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
                originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage
                let refUrl = info[UIImagePickerControllerReferenceURL] as! URL
                imageName = refUrl.lastPathComponent as NSString?
                
                if originalImage != nil {
                    imageToUse = originalImage
                }
                else {
                    imageToUse = editedImage
                }
                
                imagePath = info["UIImagePickerControllerReferenceURL"] as? URL
                imageName = (imagePath?.lastPathComponent)! as NSString
                
                var newWidth: CGFloat = 0.0
                var newHeight: CGFloat = 0.0
                if imageToUse!.size.width > imageToUse!.size.height {
                    newWidth = 450.0
                    newHeight = newWidth * imageToUse!.size.height / imageToUse!.size.width
                }
                else {
                    newHeight = 450.0
                    newWidth = newHeight * imageToUse!.size.width / imageToUse!.size.height
                }
                
                UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 0.0)
                imageToUse?.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                var imageFileData: Data?
                let index = imageName!.range(of: ".").location + 1
                let extentionOfFile = imageName!.substring(from: index)
                
                if extentionOfFile.caseInsensitiveCompare("png") == ComparisonResult.orderedSame {
                    imageType = "image/png"
                    imageFileData = UIImagePNGRepresentation(newImage!)
                }
                else {
                    imageType = "image/jpg"
                    imageFileData = UIImageJPEGRepresentation(newImage!, 1.0)
                }
                
                self.channel?.sendFileMessage(withBinaryData: imageFileData!, filename: imageName! as String, type: imageType!, size: UInt((imageFileData?.count)!), data: "", completionHandler: { (fileMessage, error) in
                    if error != nil {
                        let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(closeAction)
                        DispatchQueue.main.async(execute: { 
                            self.present(alert, animated: true, completion: nil)
                        })
                        
                        return;
                    }
                    
                    if fileMessage != nil {
                        let senderId = fileMessage!.sender?.userId
                        let senderImage = fileMessage!.sender?.profileUrl
                        let senderName = fileMessage!.sender?.nickname
                        let msgDate = Date(timeIntervalSince1970: Double((fileMessage?.createdAt)!) / 1000)
                        let url = fileMessage?.url
                        
                        var initialName = ""
                        if senderName?.characters.count > 1 {
                            initialName = (senderName! as NSString).substring(with: NSMakeRange(0, 2)).uppercased()
                        }
                        else if senderName?.characters.count > 0 {
                            initialName = (senderName! as NSString).substring(with: NSMakeRange(0, 1)).uppercased()
                        }
                        
                        let placeholderImage = JSQMessagesAvatarImageFactory.circularAvatarPlaceholderImage(initialName, backgroundColor: UIColor.lightGray, textColor: UIColor.darkGray, font: UIFont.systemFont(ofSize: 13.0), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                        let avatarImage = JSQMessagesAvatarImageFactory.avatarImage(withImageURL: senderImage, highlightedImageURL: nil, placeholderImage: placeholderImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                        
                        self.avatars?.setObject(avatarImage, forKey: senderId! as NSCopying)
                        self.users?.setObject(senderName!, forKey: senderId! as NSCopying)
                        
                        let photoItem = JSQPhotoMediaItem(imageURL: url)
                        let jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, media: photoItem)
                        jsqsbmsg?.message = fileMessage
                        
                        self.messages.append(jsqsbmsg!)
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(500 * NSEC_PER_USEC)) / Double(NSEC_PER_SEC), execute: {
                            DispatchQueue.main.async(execute: { 
                                self.collectionView.reloadData()
                                self.scrollToBottom(animated: false)
                            })
                        })
                    }
                })
            }
            else if CFStringCompare(mediaType as! CFString, kUTTypeMovie, CFStringCompareFlags.compareDiacriticInsensitive) == CFComparisonResult.compareEqualTo {
                var videoName: NSString?
                var videoType: String?
                let videoURL = info[UIImagePickerControllerMediaURL] as? URL
                let videoFileData = try? Data.init(contentsOf: videoURL!)
                videoName = (videoURL?.lastPathComponent)! as NSString

                let index = videoName!.range(of: ".").location + 1
                let extentionOfFile = videoName!.substring(from: index)
                
                if extentionOfFile.caseInsensitiveCompare("mov") == ComparisonResult.orderedSame {
                    videoType = "video/quicktime"
                }
                else if extentionOfFile.caseInsensitiveCompare("mp4") == ComparisonResult.orderedSame {
                    videoType = "video/mp4"
                }
                else {
                    videoType = "video/mpeg"
                }
                
                self.channel?.sendFileMessage(withBinaryData: videoFileData!, filename: videoName! as String, type: videoType!, size: UInt((videoFileData?.count)!), data: "", completionHandler: { (fileMessage, error) in
                    if error != nil {
                        let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(closeAction)
                        DispatchQueue.main.async(execute: { 
                            self.present(alert, animated: true, completion: nil)
                        })
                        
                        return;
                    }
                    
                    if fileMessage != nil {
                        let senderId = fileMessage!.sender?.userId
                        let senderImage = fileMessage!.sender?.profileUrl
                        let senderName = fileMessage!.sender?.nickname
                        let msgDate = Date(timeIntervalSince1970: Double((fileMessage?.createdAt)!) / 1000)
                        let url = fileMessage?.url
                        
                        var initialName = ""
                        if senderName?.characters.count > 1 {
                            initialName = (senderName! as NSString).substring(with: NSMakeRange(0, 2)).uppercased()
                        }
                        else if senderName?.characters.count > 0 {
                            initialName = (senderName! as NSString).substring(with: NSMakeRange(0, 1)).uppercased()
                        }
                        
                        let placeholderImage = JSQMessagesAvatarImageFactory.circularAvatarPlaceholderImage(initialName, backgroundColor: UIColor.lightGray, textColor: UIColor.darkGray, font: UIFont.systemFont(ofSize: 13.0), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                        let avatarImage = JSQMessagesAvatarImageFactory.avatarImage(withImageURL: senderImage, highlightedImageURL: nil, placeholderImage: placeholderImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                        
                        self.avatars?.setObject(avatarImage, forKey: senderId! as NSCopying)
                        self.users?.setObject(senderName!, forKey: senderId! as NSCopying)
                        
                        let videoItem = JSQVideoMediaItem(fileURL: URL.init(string: url!), isReadyToPlay: true)
                        let jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, media: videoItem)
                        
                        self.messages.append(jsqsbmsg!)
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(500 * NSEC_PER_USEC)) / Double(NSEC_PER_SEC), execute: {
                            DispatchQueue.main.async(execute: {
                                self.collectionView.reloadData()
                                self.scrollToBottom(animated: false)
                            })
                        })
                    }
                })
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { 
            
        }
    }
    
    // MARK: SBDConnectionDelegate
    func didStartReconnection() {
        print("didStartReconnection in OpenChannelViewController")
    }
    
    func didSucceedReconnection() {
        print("didSucceedReconnection delegate in OpenChannelViewController")
        self.lastMessageTimestamp = Int64.min
        self.firstMessageTimestamp = Int64.max

        self.messages.removeAll()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
        self.previousMessageQuery = self.channel?.createPreviousMessageListQuery()
        self.loadMessage(Int64.max, initial: true)
    }
    
    func didFailReconnection() {
        print("didFailReconnection delegate in OpenChannelViewController")
        let alert = UIAlertController(title: "Error", message: "Reconnection failed", preferredStyle: UIAlertControllerStyle.alert)
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(closeAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: SBDBaseChannelDelegate
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        print("channel(sender: SBDBaseChannel, didReceiveMessage message: SBDBaseMessage) in OpenChannelViewController")
        
        var jsqsbmsg: JSQSBMessage?
        
        if sender.channelUrl != self.channel?.channelUrl {
            return
        }
        
        if message.isKind(of: SBDUserMessage.self) == true {
            let userMessage = message as! SBDUserMessage
            let senderId = userMessage.sender?.userId
            let senderImage = userMessage.sender?.profileUrl
            let senderName = userMessage.sender?.nickname
            let msgDate = Date(timeIntervalSince1970: Double(message.createdAt) / 1000)
            let messageText = userMessage.message
            
            var initialName = ""
            if senderName?.characters.count > 1 {
                initialName = (senderName! as NSString).substring(with: NSMakeRange(0, 2)).uppercased()
            }
            else if senderName?.characters.count > 0 {
                initialName = (senderName! as NSString).substring(with: NSMakeRange(0, 1)).uppercased()
            }
            
            let placeholderImage = JSQMessagesAvatarImageFactory.circularAvatarPlaceholderImage(initialName, backgroundColor: UIColor.lightGray, textColor: UIColor.darkGray, font: UIFont.systemFont(ofSize: 13.0), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            let avatarImage = JSQMessagesAvatarImageFactory.avatarImage(withImageURL: senderImage, highlightedImageURL: nil, placeholderImage: placeholderImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            
            self.avatars?.setObject(avatarImage, forKey: senderId! as NSCopying)
            self.users?.setObject(senderName!, forKey: senderId! as NSCopying)
            
            jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, text: messageText)
            jsqsbmsg!.message = message
        }
        else if message.isKind(of: SBDFileMessage.self) == true {
            let fileMessage = message as! SBDFileMessage
            let senderId = fileMessage.sender?.userId
            let senderImage = fileMessage.sender?.profileUrl
            let senderName = fileMessage.sender?.nickname
            let msgDate = Date(timeIntervalSince1970: Double(fileMessage.createdAt) / 1000)
            let url = fileMessage.url
            let type = fileMessage.type
            
            var initialName = ""
            if senderName?.characters.count > 1 {
                initialName = (senderName! as NSString).substring(with: NSMakeRange(0, 2)).uppercased()
            }
            else if senderName?.characters.count > 0 {
                initialName = (senderName! as NSString).substring(with: NSMakeRange(0, 1)).uppercased()
            }
            
            let placeholderImage = JSQMessagesAvatarImageFactory.circularAvatarPlaceholderImage(initialName, backgroundColor: UIColor.lightGray, textColor: UIColor.darkGray, font: UIFont.systemFont(ofSize: 13.0), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            let avatarImage = JSQMessagesAvatarImageFactory.avatarImage(withImageURL: senderImage, highlightedImageURL: nil, placeholderImage: placeholderImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            
            self.avatars?.setObject(avatarImage, forKey: senderId! as NSCopying)
            self.users?.setObject(senderName!, forKey: senderId! as NSCopying)
            
            if type.hasPrefix("image") == true {
                let photoItem = JSQPhotoMediaItem.init(imageURL: url)
                jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, media: photoItem)
            }
            else if type.hasPrefix("video") == true {
                let videoItem = JSQVideoMediaItem.init(fileURL: URL.init(string: url), isReadyToPlay: true)
                jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, media: videoItem)
            }
            else {
                let fileItem = JSQFileMediaItem.init(fileURL: URL.init(string: url))
                jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, media: fileItem)
            }
            
            jsqsbmsg!.message = message
        }
        else if message.isKind(of: SBDAdminMessage.self) == true {
            let adminMessage = message as! SBDAdminMessage
            let msgDate = Date(timeIntervalSince1970: Double(adminMessage.createdAt) / 1000)
            let messageText = adminMessage.message
            
            let jsqsbmsg = JSQSBMessage(senderId: "", senderDisplayName: "", date: msgDate, text: messageText)
            jsqsbmsg?.message = message
        }
        
        if message.createdAt > self.lastMessageTimestamp {
            self.lastMessageTimestamp = message.createdAt
        }
        
        if message.createdAt < self.firstMessageTimestamp {
            self.firstMessageTimestamp = message.createdAt
        }
        
        if jsqsbmsg != nil {
            self.messages.append(jsqsbmsg!)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(500 * NSEC_PER_USEC)) / Double(NSEC_PER_SEC), execute: {
            DispatchQueue.main.async(execute: {
                self.collectionView.reloadData()
                self.scrollToBottom(animated: false)
            })
        })
    }
    
    func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
        
    }
    
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        
    }
    
    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDOpenChannel, userWasMuted user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDOpenChannel, userWasUnmuted user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDOpenChannel, userWasBanned user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDOpenChannel, userWasUnbanned user: SBDUser) {
        
    }
    
    func channelWasFrozen(_ sender: SBDOpenChannel) {
        
    }
    
    func channelWasUnfrozen(_ sender: SBDOpenChannel) {
        
    }
    
    func channelWasChanged(_ sender: SBDBaseChannel) {
        
    }
    
    func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        
    }
    
    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        for msg in self.messages {
            if msg.message!.messageId == messageId {
                let row = self.messages.index(of: msg)
                let deletedMessageIndexPath = IndexPath(row: row!, section: 0)
                
                DispatchQueue.main.async(execute: {
                    self.messages.remove(at: (deletedMessageIndexPath as NSIndexPath).row)
                    self.collectionView.reloadData()
                })
                
                break
            }
        }
    }
}
