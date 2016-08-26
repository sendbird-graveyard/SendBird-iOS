//
//  GroupChannelViewController.swift
//  SampleUI
//
//  Created by Jed Kyung on 8/25/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import SendBirdSDK
import AVKit
import AVFoundation

protocol GroupChannelViewControllerDelegate: class {
    func didCloseGroupChannelViewController(vc: UIViewController)
}

class GroupChannelViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SBDConnectionDelegate, SBDChannelDelegate, UserListViewControllerDelegate {
    weak var delegate: GroupChannelViewControllerDelegate!
    
    private var avatars: NSMutableDictionary?
    private var users: NSMutableDictionary?
    private var outgoingBubbleImageData: JSQMessagesBubbleImage?
    private var incomingBubbleImageData: JSQMessagesBubbleImage?
    private var neutralBubbleImageData: JSQMessagesBubbleImage?
    private var messages: [JSQSBMessage] = []
    
    private var lastMessageTimestamp: Int64 = Int64.min
    private var firstMessageTimestamp: Int64 = Int64.max
    
    private var hasPrev: Bool = false
    
    private var previousMessageQuery: SBDPreviousMessageListQuery?
    private var delegateIndetifier: String?
    
    private var userIds: [String] = []
    private var groupChannelUrl: String?
    private var groupChannelStartType: Int?
    private var channel: SBDGroupChannel?
    private var timer: NSTimer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = String(format: "Group Channel(%d)", Int((self.channel?.memberCount)!))
        
        self.hasPrev = true
        
        self.avatars = NSMutableDictionary()
        self.users = NSMutableDictionary()
        
        self.lastMessageTimestamp = Int64.min
        self.firstMessageTimestamp = Int64.max
        
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(kJSQMessagesCollectionViewAvatarSizeDefault, kJSQMessagesCollectionViewAvatarSizeDefault)
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(kJSQMessagesCollectionViewAvatarSizeDefault, kJSQMessagesCollectionViewAvatarSizeDefault)
        
        self.showLoadEarlierMessagesHeader = false
        self.collectionView.collectionViewLayout.springinessEnabled = false
        self.collectionView.bounces = false

        let bubbleFactory = JSQMessagesBubbleImageFactory()
        let neutralBubbleFactory = JSQMessagesBubbleImageFactory.init(bubbleImage: UIImage.jsq_bubbleCompactTaillessImage(), capInsets: UIEdgeInsetsZero)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: #selector(OpenChannelViewController.actionPressed(_:)))
        
        self.inputToolbar.contentView.textView.delegate = self
        
        self.outgoingBubbleImageData = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        self.incomingBubbleImageData = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        self.neutralBubbleImageData = neutralBubbleFactory.neutralMessagesBubbleImageWithColor(UIColor.jsq_messageNeutralBubbleColor())
        
        if self.timer == nil {
            self.timer = NSTimer(timeInterval: 1, target: self, selector: #selector(GroupChannelViewController.timerCallback(_:)), userInfo: nil, repeats: true)
        }
        
        self.delegateIndetifier = self.description
        
        SBDMain.addChannelDelegate(self, identifier: self.delegateIndetifier!)
        SBDMain.addConnectionDelegate(self, identifier: self.delegateIndetifier!)
        
        self.startSendBird()
    }
    
    override func viewWillDisappear(animated: Bool) {
        if self.navigationController?.viewControllers.indexOf(self) == nil {
            SBDMain.removeChannelDelegateForIdentifier(self.delegateIndetifier!)
            SBDMain.removeConnectionDelegateForIdentifier(self.delegateIndetifier!)
            
            // TODO:
            if self.delegate != nil {
                self.delegate?.didCloseGroupChannelViewController(self)
            }
        }
        
        super.viewWillDisappear(animated)
    }

    func closePressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func actionPressed(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil)
        var inviteAction: UIAlertAction?
        if self.channel?.isDistinct == false {
            inviteAction = UIAlertAction(title: "Invite users to this channel", style: UIAlertActionStyle.Default, handler: { (action) in
                let vc = UserListViewController()
                
                vc.invitationMode = 1
                vc.channel = self.channel
                vc.delegate = self
                
                dispatch_async(dispatch_get_main_queue(), { 
                    self.navigationController?.pushViewController(vc, animated: true)
                })
            })
        }
        let leaveAction = UIAlertAction(title: "Leave this channel", style: UIAlertActionStyle.Default) { (action) in
            self.channel?.leaveChannelWithCompletionHandler({ (error) in
                if self.delegate != nil {
                    self.delegate?.didCloseGroupChannelViewController(self)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.navigationController?.popViewControllerAnimated(true)
                })
            })
        }
        let hideAction = UIAlertAction(title: "Hide this channel", style: UIAlertActionStyle.Default) { (action) in
            self.channel?.hideChannelWithCompletionHandler({ (error) in
                if self.delegate != nil {
                    self.delegate?.didCloseGroupChannelViewController(self)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.navigationController?.popViewControllerAnimated(true)
                })
            })
        }
        let seeMembersAction = UIAlertAction(title: "See members", style: UIAlertActionStyle.Default) { (action) in
            let vc = MemberListViewController()
            vc.channel = self.channel
            dispatch_async(dispatch_get_main_queue(), { 
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }
        
        alert.addAction(closeAction)
        if (inviteAction != nil) {
            alert.addAction(inviteAction!)
        }
        alert.addAction(leaveAction)
        alert.addAction(hideAction)
        alert.addAction(seeMembersAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func invitePressed(sender: UIBarButtonItem) {
        let vc = UserListViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func timerCallback(timer: NSTimer) {
        if self.channel?.getTypingMembers()?.count == 0 {
            self.showTypingIndicator = false
        }
        else {
            for typingUser in (self.channel?.getTypingMembers())! {
                self.collectionView.setCurrentTypingUser(typingUser.nickname, userId: typingUser.userId)
            }
            self.showTypingIndicator = true
            dispatch_async(dispatch_get_main_queue(), { 
                self.scrollToBottomAnimated(false)
            })
        }
    }
    
    func updateGroupChannel() {
        self.collectionView.reloadData()
    }
    
    private func startSendBird() {
        if self.channel != nil {
            self.previousMessageQuery = self.channel?.createPreviousMessageListQuery()
            self.loadMessages(Int64.max, initial: true)
        }
    }
    
    private func loadMessages(ts: Int64, initial: Bool) {
        if self.previousMessageQuery?.isLoading() == true {
            return;
        }
        
        if self.hasPrev == false {
            return;
        }
        
        self.previousMessageQuery?.loadPreviousMessagesWithLimit(30, reverse: !initial, completionHandler: { (messages, error) in
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
                    
                    if message.isKindOfClass(SBDUserMessage) == true {
                        let senderId = (message as! SBDUserMessage).sender?.userId
                        let senderImage = (message as! SBDUserMessage).sender?.profileUrl
                        let senderName = (message as! SBDUserMessage).sender?.nickname
                        let msgDate = NSDate.init(timeIntervalSince1970: Double((message as! SBDUserMessage).createdAt) / 1000.0)
                        let messageText = (message as! SBDUserMessage).message
                        
                        var initialName: NSString = ""
                        if senderName?.characters.count > 1 {
                            initialName = (senderName! as NSString).substringWithRange(NSRange(location: 0, length: 2))
                        }
                        else if senderName?.characters.count > 0 {
                            initialName = (senderName! as NSString).substringWithRange(NSRange(location: 0, length: 1))
                        }
                        
                        let placeholderImage = JSQMessagesAvatarImageFactory.circularAvatarPlaceholderImage(initialName as String, backgroundColor: UIColor.lightGrayColor(), textColor: UIColor.darkGrayColor(), font: UIFont.systemFontOfSize(13.0), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                        let avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImageURL(senderImage, highlightedImageURL: nil, placeholderImage: placeholderImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                        
                        self.avatars?.setObject(avatarImage, forKey: senderId!)
                        self.users?.setObject(senderName!, forKey: senderId!)
                        
                        jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, text: messageText)
                        jsqsbmsg!.message = message
                        msgCount += 1
                    }
                    else if message.isKindOfClass(SBDFileMessage) == true {
                        let senderId = (message as! SBDFileMessage).sender?.userId
                        let senderImage = (message as! SBDFileMessage).sender?.profileUrl
                        let senderName = (message as! SBDFileMessage).sender?.nickname
                        let msgDate = NSDate.init(timeIntervalSince1970: Double((message as! SBDFileMessage).createdAt) / 1000.0)
                        let url = (message as! SBDFileMessage).url
                        let type = (message as! SBDFileMessage).type
                        
                        var initialName: NSString = ""
                        if senderName?.characters.count > 1 {
                            initialName = (senderName! as NSString).substringWithRange(NSRange(location: 0, length: 2))
                        }
                        else if senderName?.characters.count > 0 {
                            initialName = (senderName! as NSString).substringWithRange(NSRange(location: 0, length: 1))
                        }
                        
                        let placeholderImage = JSQMessagesAvatarImageFactory.circularAvatarPlaceholderImage(initialName as String, backgroundColor: UIColor.lightGrayColor(), textColor: UIColor.darkGrayColor(), font: UIFont.systemFontOfSize(13.0), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                        let avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImageURL(senderImage, highlightedImageURL: nil, placeholderImage: placeholderImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                        
                        self.avatars?.setObject(avatarImage, forKey: senderId!)
                        self.users?.setObject(senderName!, forKey: senderId!)
                        
                        if type.hasPrefix("image") == true {
                            let photoItem = JSQPhotoMediaItem.init(imageURL: url)
                            jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, media: photoItem)
                        }
                        else if type.hasPrefix("video") == true {
                            let videoItem = JSQVideoMediaItem.init(fileURL: NSURL.init(string: url), isReadyToPlay: true)
                            jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, media: videoItem)
                        }
                        else {
                            let fileItem = JSQFileMediaItem.init(fileURL: NSURL.init(string: url))
                            jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, media: fileItem)
                        }
                        
                        jsqsbmsg!.message = message
                        msgCount += 1
                    }
                    else if message.isKindOfClass(SBDAdminMessage) == true {
                        let msgDate = NSDate.init(timeIntervalSince1970: Double((message as! SBDAdminMessage).createdAt) / 1000.0)
                        let messageText = (message as! SBDAdminMessage).message
                        
                        let jsqsbmsg = JSQSBMessage.init(senderId: "", senderDisplayName: "", date: msgDate, text: messageText)
                        jsqsbmsg.message = message
                        msgCount += 1
                    }
                    
                    if initial == true {
                        self.messages.append(jsqsbmsg!)
                    }
                    else {
                        self.messages.insert(jsqsbmsg!, atIndex: 0)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView.reloadData()
                    
                    if initial == true {
                        self.scrollToBottomAnimated(false)
                    }
                    else {
                        let totalMsgCount = self.collectionView.numberOfItemsInSection(0)
                        if msgCount - 1 > 0 && totalMsgCount > 0 {
                            self.collectionView.scrollToItemAtIndexPath(NSIndexPath.init(forRow: (msgCount - 1), inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
                        }
                    }
                })
            }
            else {
                self.hasPrev = false
            }
            
            self.channel?.markAsRead()
        })
    }
    
    func setGroupChannel(aGroupChannel: SBDGroupChannel) {
        self.channel = aGroupChannel
        self.groupChannelStartType = 1
    }
    
    // MARK: JSQMessages CollectionView DataSource
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.item)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
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
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = self.messages[indexPath.item]
        
        return self.avatars?.objectForKey(message.senderId) as! JSQMessageAvatarImageDataSource
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message = self.messages[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
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
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return nil
    }
    
    // MARK: UICollectionView DataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let msg = self.messages[indexPath.item]
        
        if msg.isMediaMessage == false {
            if msg.senderId == self.senderId {
                cell.textView.textColor = UIColor.blackColor()
            }
            else {
                cell.textView.textColor = UIColor.whiteColor()
            }
            
            cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView.textColor!, NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue | NSUnderlineStyle.PatternSolid.rawValue]
        }
        
        let unreadCount = self.channel?.getReadReceiptOfMessage(msg.message!)
        cell.setUnreadCount(UInt(unreadCount!))
        
        if indexPath.row == 0 {
            self.loadMessages(self.firstMessageTimestamp, initial: false)
        }
        
        return cell
    }
    
    // MARK: UICollectionView Delegate
    
    // MARK: JSQMessages collection view flow layout delegate
    
    // MARK: Adjusting cell label heights
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
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
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0.0
    }
    
    // MARK: Responding to collection view tap events
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        print("Load earlier messages!")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        print("Tapped avater!")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        print("Tapped message bubble! ", indexPath.row)
        let jsqMessage = self.messages[indexPath.row]
        
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let closeAction = UIAlertAction.init(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil)
        var deleteMessageAction: UIAlertAction?
        var blockUserAction: UIAlertAction?
        var openFileAction: UIAlertAction?
        
        if jsqMessage.message?.isKindOfClass(SBDBaseMessage) == true {
            let baseMessage = jsqMessage.message
            if baseMessage?.isKindOfClass(SBDUserMessage) == true {
                let sender = (baseMessage as! SBDUserMessage).sender
                
                if sender!.userId == SBDMain.getCurrentUser()!.userId {
                    deleteMessageAction = UIAlertAction.init(title: "Delete the message", style: UIAlertActionStyle.Destructive, handler: { (action) in
                        let selectedMessageIndexPath = indexPath
                        self.channel?.deleteMessage(baseMessage!, completionHandler: { (error) in
                            if error != nil {
                                let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.Alert)
                                let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil)
                                alert.addAction(closeAction)
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.presentViewController(alert, animated: true, completion: nil)
                                })
                            }
                            else {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.messages.removeAtIndex(selectedMessageIndexPath.row)
                                    self.collectionView.reloadData()
                                })
                            }
                        })
                    })
                }
                else {
                    blockUserAction = UIAlertAction.init(title: "Block user", style: UIAlertActionStyle.Destructive, handler: { (action) in
                        SBDMain.blockUser(sender!, completionHandler: { (blockedUser, error) in
                            if error != nil {
                                let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.Alert)
                                let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil)
                                alert.addAction(closeAction)
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.presentViewController(alert, animated: true, completion: nil)
                                })
                            }
                            else {
                                let alert = UIAlertController(title: "User Blocked", message: String(format: "%@ is blocked", blockedUser!.nickname!), preferredStyle: UIAlertControllerStyle.Alert)
                                let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil)
                                alert.addAction(closeAction)
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.presentViewController(alert, animated: true, completion: nil)
                                })
                            }
                        })
                    })
                }
            }
            else if baseMessage?.isKindOfClass(SBDFileMessage) == true {
                let fileMessage = baseMessage as! SBDFileMessage
                let sender = fileMessage.sender
                let type = fileMessage.type
                let url = fileMessage.url
                
                if sender!.userId == SBDMain.getCurrentUser()!.userId {
                    deleteMessageAction = UIAlertAction.init(title: "Delete the message", style: UIAlertActionStyle.Destructive, handler: { (action) in
                        let selectedMessageIndexPath = indexPath
                        self.channel?.deleteMessage(baseMessage!, completionHandler: { (error) in
                            if error != nil {
                                let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.Alert)
                                let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil)
                                alert.addAction(closeAction)
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.presentViewController(alert, animated: true, completion: nil)
                                })
                            }
                            else {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.messages.removeAtIndex(selectedMessageIndexPath.row)
                                    self.collectionView.reloadData()
                                })
                            }
                        })
                    })
                }
                else {
                    blockUserAction = UIAlertAction.init(title: "Block user", style: UIAlertActionStyle.Destructive, handler: { (action) in
                        SBDMain.blockUser(sender!, completionHandler: { (blockedUser, error) in
                            if error != nil {
                                let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.Alert)
                                let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil)
                                alert.addAction(closeAction)
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.presentViewController(alert, animated: true, completion: nil)
                                })
                            }
                            else {
                                let alert = UIAlertController(title: "User Blocked", message: String(format: "%@ is blocked", blockedUser!.nickname!), preferredStyle: UIAlertControllerStyle.Alert)
                                let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil)
                                alert.addAction(closeAction)
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.presentViewController(alert, animated: true, completion: nil)
                                })
                            }
                        })
                    })
                }
                
                if type.hasPrefix("video") == true {
                    openFileAction = UIAlertAction.init(title: "Play video", style: UIAlertActionStyle.Default, handler: { (action) in
                        let videoUrl = NSURL.init(string: url)
                        let player = AVPlayer.init(URL: videoUrl!)
                        let vc = AVPlayerViewController()
                        vc.player = player
                        self.presentViewController(vc, animated: true, completion: {
                            player.play()
                        })
                    })
                }
                else if type.hasPrefix("audio") == true {
                    openFileAction = UIAlertAction.init(title: "Play audio", style: UIAlertActionStyle.Default, handler: { (action) in
                        let audioUrl = NSURL.init(string: url)
                        let player = AVPlayer.init(URL: audioUrl!)
                        let vc = AVPlayerViewController()
                        vc.player = player
                        self.presentViewController(vc, animated: true, completion: {
                            player.play()
                        })
                    })
                }
                else if type.hasPrefix("image") == true {
                    openFileAction = UIAlertAction.init(title: "Open image on Safari", style: UIAlertActionStyle.Default, handler: { (action) in
                        let imageUrl = NSURL.init(string: url)
                        UIApplication.sharedApplication().openURL(imageUrl!)
                    })
                }
                else {
                    // TODO: Download file.
                }
            }
            else if baseMessage?.isKindOfClass(SBDAdminMessage) == true {
                
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
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {
        print("Tapped cell at ", NSStringFromCGPoint(touchLocation), "!")
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        if text.characters.count > 0 {
            self.channel?.endTyping()
            self.channel?.sendUserMessage(text, completionHandler: { (userMessage, error) in
                if error != nil {
                    print("Error: ", error)
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
                    let msgDate = NSDate.init(timeIntervalSince1970: Double((userMessage!.createdAt / 1000)))
                    let messageText = userMessage?.message
                    
                    let placeholderImage = JSQMessagesAvatarImageFactory.circularAvatarPlaceholderImage("TC", backgroundColor: UIColor.lightGrayColor(), textColor: UIColor.darkGrayColor(), font: UIFont.systemFontOfSize(13.0), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                    let avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImageURL(senderImage, highlightedImageURL: senderImage, placeholderImage: placeholderImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                    
                    self.avatars?.setObject(avatarImage, forKey: senderId!)
                    if senderName != nil {
                        self.users?.setObject(senderName!, forKey: senderId!)
                    }
                    else {
                        self.users?.setObject("UK", forKey: senderId!)
                    }
                    
                    jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, text: messageText)
                    jsqsbmsg!.message = userMessage
                    
                    self.messages.append(jsqsbmsg!)
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(500 * NSEC_PER_USEC)), dispatch_get_main_queue(), {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.collectionView.reloadData()
                            self.scrollToBottomAnimated(false)
                            
                            self.inputToolbar.contentView.textView.text = ""
                        })
                    })
                }
            })
        }
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        let mediaUI = UIImagePickerController()
        
        mediaUI.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        mediaUI.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        mediaUI.delegate = self
        
        self.presentViewController(mediaUI, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType]
        
        picker.dismissViewControllerAnimated(true) {
            if CFStringCompare(mediaType as! CFStringRef, kUTTypeImage, CFStringCompareFlags.CompareDiacriticInsensitive) == CFComparisonResult.CompareEqualTo {
                var originalImage: UIImage?
                var editedImage: UIImage?
                var imageToUse: UIImage?
                var imagePath: NSURL?
                
                var imageName: NSString?
                var imageType: String?
                
                editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
                originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage
                let refUrl = info[UIImagePickerControllerReferenceURL] as! NSURL
                imageName = refUrl.lastPathComponent
                
                if originalImage != nil {
                    imageToUse = originalImage
                }
                else {
                    imageToUse = editedImage
                }
                
                imagePath = info["UIImagePickerControllerReferenceURL"] as? NSURL
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
                
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), false, 0.0)
                imageToUse?.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                var imageFileData: NSData?
                let index = imageName!.rangeOfString(".").location + 1
                let extentionOfFile = imageName!.substringFromIndex(index)
                
                if extentionOfFile.caseInsensitiveCompare("png") == NSComparisonResult.OrderedSame {
                    imageType = "image/png"
                    imageFileData = UIImagePNGRepresentation(newImage)
                }
                else {
                    imageType = "image/jpg"
                    imageFileData = UIImageJPEGRepresentation(newImage, 1.0)
                }
                
                self.channel?.sendFileMessageWithBinaryData(imageFileData!, filename: imageName! as String, type: imageType!, size: UInt((imageFileData?.length)!), data: "", completionHandler: { (fileMessage, error) in
                    if error != nil {
                        return;
                    }
                    
                    if fileMessage != nil {
                        let senderId = fileMessage!.sender?.userId
                        let senderImage = fileMessage!.sender?.profileUrl
                        let senderName = fileMessage!.sender?.nickname
                        let msgDate = NSDate(timeIntervalSince1970: Double((fileMessage?.createdAt)!) / 1000)
                        let url = fileMessage?.url
                        
                        var initialName = ""
                        if senderName?.characters.count > 1 {
                            initialName = (senderName! as NSString).substringWithRange(NSMakeRange(0, 2)).uppercaseString
                        }
                        else if senderName?.characters.count > 0 {
                            initialName = (senderName! as NSString).substringWithRange(NSMakeRange(0, 1)).uppercaseString
                        }
                        
                        let placeholderImage = JSQMessagesAvatarImageFactory.circularAvatarPlaceholderImage(initialName, backgroundColor: UIColor.lightGrayColor(), textColor: UIColor.darkGrayColor(), font: UIFont.systemFontOfSize(13.0), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                        let avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImageURL(senderImage, highlightedImageURL: nil, placeholderImage: placeholderImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                        
                        self.avatars?.setObject(avatarImage, forKey: senderId!)
                        self.users?.setObject(senderName!, forKey: senderId!)
                        
                        let photoItem = JSQPhotoMediaItem(imageURL: url)
                        let jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, media: photoItem)
                        
                        self.messages.append(jsqsbmsg)
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(500 * NSEC_PER_USEC)), dispatch_get_main_queue(), {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.collectionView.reloadData()
                                self.scrollToBottomAnimated(false)
                            })
                        })
                    }
                })
            }
            else if CFStringCompare(mediaType as! CFStringRef, kUTTypeMovie, CFStringCompareFlags.CompareDiacriticInsensitive) == CFComparisonResult.CompareEqualTo {
                var videoName: NSString?
                var videoType: String?
                let videoURL = info[UIImagePickerControllerMediaURL] as? NSURL
                let videoFileData = NSData.init(contentsOfURL: videoURL!)
                videoName = (videoURL?.lastPathComponent)! as NSString
                
                let index = videoName!.rangeOfString(".").location + 1
                let extentionOfFile = videoName!.substringFromIndex(index)
                
                if extentionOfFile.caseInsensitiveCompare("mov") == NSComparisonResult.OrderedSame {
                    videoType = "video/quicktime"
                }
                else if extentionOfFile.caseInsensitiveCompare("mp4") == NSComparisonResult.OrderedSame {
                    videoType = "video/mp4"
                }
                else {
                    videoType = "video/mpeg"
                }
                
                self.channel?.sendFileMessageWithBinaryData(videoFileData!, filename: videoName! as String, type: videoType!, size: UInt((videoFileData?.length)!), data: "", completionHandler: { (fileMessage, error) in
                    if error != nil {
                        return;
                    }
                    
                    if fileMessage != nil {
                        let senderId = fileMessage!.sender?.userId
                        let senderImage = fileMessage!.sender?.profileUrl
                        let senderName = fileMessage!.sender?.nickname
                        let msgDate = NSDate(timeIntervalSince1970: Double((fileMessage?.createdAt)!) / 1000)
                        let url = fileMessage?.url
                        
                        var initialName = ""
                        if senderName?.characters.count > 1 {
                            initialName = (senderName! as NSString).substringWithRange(NSMakeRange(0, 2)).uppercaseString
                        }
                        else if senderName?.characters.count > 0 {
                            initialName = (senderName! as NSString).substringWithRange(NSMakeRange(0, 1)).uppercaseString
                        }
                        
                        let placeholderImage = JSQMessagesAvatarImageFactory.circularAvatarPlaceholderImage(initialName, backgroundColor: UIColor.lightGrayColor(), textColor: UIColor.darkGrayColor(), font: UIFont.systemFontOfSize(13.0), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                        let avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImageURL(senderImage, highlightedImageURL: nil, placeholderImage: placeholderImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                        
                        self.avatars?.setObject(avatarImage, forKey: senderId!)
                        self.users?.setObject(senderName!, forKey: senderId!)
                        
                        let videoItem = JSQVideoMediaItem(fileURL: NSURL.init(string: url!), isReadyToPlay: true)
                        let jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, media: videoItem)
                        
                        self.messages.append(jsqsbmsg)
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(500 * NSEC_PER_USEC)), dispatch_get_main_queue(), {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.collectionView.reloadData()
                                self.scrollToBottomAnimated(false)
                            })
                        })
                    }
                })
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true) {
            
        }
    }
    
    // MARK: UITextViewDelegate
    override func textViewDidChange(textView: UITextView) {
        self.inputToolbar.toggleSendButtonEnabled()
        if textView.text.characters.count > 0 {
            self.channel?.startTyping()
        }
        else {
            self.channel?.endTyping()
        }
    }
    
    func inviteUsers(aUserIds: [String]) {
        self.userIds = aUserIds
        self.groupChannelStartType = 0
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
        dispatch_async(dispatch_get_main_queue()) { 
            self.collectionView.reloadData()
        }
        
        self.previousMessageQuery = self.channel?.createPreviousMessageListQuery()
        self.loadMessages(Int64.max, initial: true)
    }
    
    func didFailReconnection() {
        print("didFailReconnection delegate in OpenChannelViewController")
    }
    
    // MARK: SBDBaseChannelDelegate
    func channel(sender: SBDBaseChannel, didReceiveMessage message: SBDBaseMessage) {
        print("channel(sender: SBDBaseChannel, didReceiveMessage message: SBDBaseMessage) in OpenChannelViewController")
        
        var jsqsbmsg: JSQSBMessage?
        
        if sender.channelUrl != self.channel?.channelUrl {
            return
        }
        
        if message.isKindOfClass(SBDUserMessage) == true {
            let userMessage = message as! SBDUserMessage
            let senderId = userMessage.sender?.userId
            let senderImage = userMessage.sender?.profileUrl
            let senderName = userMessage.sender?.nickname
            let msgDate = NSDate(timeIntervalSince1970: Double(message.createdAt) / 1000)
            let messageText = userMessage.message
            
            var initialName = ""
            if senderName?.characters.count > 1 {
                initialName = (senderName! as NSString).substringWithRange(NSMakeRange(0, 2)).uppercaseString
            }
            else if senderName?.characters.count > 0 {
                initialName = (senderName! as NSString).substringWithRange(NSMakeRange(0, 1)).uppercaseString
            }
            
            let placeholderImage = JSQMessagesAvatarImageFactory.circularAvatarPlaceholderImage(initialName, backgroundColor: UIColor.lightGrayColor(), textColor: UIColor.darkGrayColor(), font: UIFont.systemFontOfSize(13.0), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            let avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImageURL(senderImage, highlightedImageURL: nil, placeholderImage: placeholderImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            
            self.avatars?.setObject(avatarImage, forKey: senderId!)
            self.users?.setObject(senderName!, forKey: senderId!)
            
            jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, text: messageText)
            jsqsbmsg!.message = message
        }
        else if message.isKindOfClass(SBDFileMessage) == true {
            let fileMessage = message as! SBDFileMessage
            let senderId = fileMessage.sender?.userId
            let senderImage = fileMessage.sender?.profileUrl
            let senderName = fileMessage.sender?.nickname
            let msgDate = NSDate(timeIntervalSince1970: Double(fileMessage.createdAt) / 1000)
            let url = fileMessage.url
            let type = fileMessage.type
            
            var initialName = ""
            if senderName?.characters.count > 1 {
                initialName = (senderName! as NSString).substringWithRange(NSMakeRange(0, 2)).uppercaseString
            }
            else if senderName?.characters.count > 0 {
                initialName = (senderName! as NSString).substringWithRange(NSMakeRange(0, 1)).uppercaseString
            }
            
            let placeholderImage = JSQMessagesAvatarImageFactory.circularAvatarPlaceholderImage(initialName, backgroundColor: UIColor.lightGrayColor(), textColor: UIColor.darkGrayColor(), font: UIFont.systemFontOfSize(13.0), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            let avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImageURL(senderImage, highlightedImageURL: nil, placeholderImage: placeholderImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            
            self.avatars?.setObject(avatarImage, forKey: senderId!)
            self.users?.setObject(senderName!, forKey: senderId!)
            
            if type.hasPrefix("image") == true {
                let photoItem = JSQPhotoMediaItem.init(imageURL: url)
                jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, media: photoItem)
            }
            else if type.hasPrefix("video") == true {
                let videoItem = JSQVideoMediaItem.init(fileURL: NSURL.init(string: url), isReadyToPlay: true)
                jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, media: videoItem)
            }
            else {
                let fileItem = JSQFileMediaItem.init(fileURL: NSURL.init(string: url))
                jsqsbmsg = JSQSBMessage(senderId: senderId, senderDisplayName: senderName, date: msgDate, media: fileItem)
            }
            
            jsqsbmsg!.message = message
        }
        else if message.isKindOfClass(SBDAdminMessage) == true {
            let adminMessage = message as! SBDAdminMessage
            let msgDate = NSDate(timeIntervalSince1970: Double(adminMessage.createdAt) / 1000)
            let messageText = adminMessage.message
            
            let jsqsbmsg = JSQSBMessage(senderId: "", senderDisplayName: "", date: msgDate, text: messageText)
            jsqsbmsg.message = message
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
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(500 * NSEC_PER_USEC)), dispatch_get_main_queue(), {
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView.reloadData()
                self.scrollToBottomAnimated(false)
            })
        })
        
         self.channel?.markAsRead()
    }
    
    func channelDidUpdateReadReceipt(sender: SBDGroupChannel) {
        dispatch_async(dispatch_get_main_queue()) { 
            self.collectionView.reloadData()
        }
    }
    
    func channelDidUpdateTypingStatus(sender: SBDGroupChannel) {
        if sender.getTypingMembers()!.count == 0 {
            self.showTypingIndicator = false
        }
        else {
            for typingUser in sender.getTypingMembers()! {
                self.collectionView.setCurrentTypingUser(typingUser.nickname, userId: typingUser.userId)
            }
            
            self.showTypingIndicator = true
            dispatch_async(dispatch_get_main_queue(), { 
                self.scrollToBottomAnimated(false)
            })
        }
    }
    
    func channel(sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        
    }
    
    func channel(sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        
    }
    
    func channel(sender: SBDOpenChannel, userDidEnter user: SBDUser) {
        
    }
    
    func channel(sender: SBDOpenChannel, userDidExit user: SBDUser) {
        
    }
    
    func channel(sender: SBDOpenChannel, userWasMuted user: SBDUser) {
        
    }
    
    func channel(sender: SBDOpenChannel, userWasUnmuted user: SBDUser) {
        
    }
    
    func channel(sender: SBDOpenChannel, userWasBanned user: SBDUser) {
        
    }
    
    func channel(sender: SBDOpenChannel, userWasUnbanned user: SBDUser) {
        
    }
    
    func channelWasFrozen(sender: SBDOpenChannel) {
        
    }
    
    func channelWasUnfrozen(sender: SBDOpenChannel) {
        
    }
    
    func channelWasChanged(sender: SBDBaseChannel) {
        
    }
    
    func channelWasDeleted(channelUrl: String, channelType: SBDChannelType) {
        
    }
    
    func channel(sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        for msg in self.messages {
            if msg.message!.messageId == messageId {
                let row = self.messages.indexOf(msg)
                let deletedMessageIndexPath = NSIndexPath(forRow: row!, inSection: 0)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.messages.removeAtIndex(deletedMessageIndexPath.row)
                    self.collectionView.reloadData()
                })
                
                break
            }
        }
    }
    
    // MARK: UserListViewControllerDelegate
    func didCloseUserListViewController(vc: UIViewController, groupChannel: SBDGroupChannel) {
        self.channel?.refreshWithCompletionHandler({ (error) in
            self.title = String(format: "Group Channel(%d)", Int((self.channel?.memberCount)!))
        })
    }
}
