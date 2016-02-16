//
//  MessagingTableViewController.swift
//  SendBirdSampleUI
//
//  Created by Jed Kyung on 2/7/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

import UIKit
import SendBirdSDK
import MobileCoreServices

class MessagingTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MessageInputViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate {
    let kMessageCellIdentifier: String = "MessageReuseIdentifier"
    let kMyMessageCellIdentifier: String = "MyMessageReuseIdentifier"
    let kFileLinkCellIdentifier: String = "FileLinkReuseIdentifier"
    let kMyFileLinkCellIdentifier: String = "MyFileLinkReuseIdentifier"
    let kSystemMessageCellIdentifier: String = "SystemMessageReuseIdentifier"
    let kFileMessageCellIdentifier: String = "FileMessageReuseIdentifier"
    let kBroadcastMessageCellIdentifier: String = "BroadcastMessageReuseIdentifier"
    let kMyStructuredMessageCellIdentifier: String = "MyStructuredMessageReuseIdentifier"
    let kStructuredMessageCellIdentifier: String = "StructuredMessageReuseIdentifier"
    
    let kMemberCellIdentifier: String = "MemberReuseIdentifier"
    let kMessagingChannelCellIdentifier: String = "MessagingChannelReuseIdentifier"

    let kTypingViewHeight: CGFloat = 36.0
    
    var container: UIView?
    var tableView: UITableView?
    var messageInputView: MessageInputView?
    var channelUrl: NSString?
    var openImagePicker: Bool?
    var indicatorView: MessagingIndicatorView?
    var userId: NSString?
    var userName: NSString?
    var channelMemberListTableView: UITableView?
    var messagingChannelListTableView: UITableView?
    var currentMessagingChannel: SendBirdMessagingChannel?
    var typingNowView: TypingNowView?
    var targetUserId: NSString?
    
    var mMaxMessageTs: Int64?
    var mMinMessageTs: Int64?
    
    private var bottomMargin: NSLayoutConstraint?
    private var tableViewBottomMargin: NSLayoutConstraint?
    private var messageArray: Array<SendBirdMessageModel>?
    
    private var messageSizingTableViewCell: MessagingMessageTableViewCell?
    private var myMessageSizingTableViewCell: MessagingMyMessageTableViewCell?
    private var fileLinkSizingTableViewCell: MessagingFileLinkTableViewCell?
    private var systemMessageSizingTableViewCell: MessagingSystemMessageTableViewCell?
    private var fileMessageSizingTableViewCell: MessagingFileMessageTableViewCell?
    private var broadcastMessageSizingTableViewCell: MessagingBroadcastMessageTableViewCell?
    private var myFileLinkSizingTableViewCell: MessagingMyFileLinkTableViewCell?
    
    private var memberSizingTableViewCell: MemberTableViewCell?
    
    private var imageCache: NSMutableArray?
    private var cellHeight: NSMutableDictionary?
    
    private var scrolling: Bool?
    private var messagingChannelScrolling: Bool?
    private var pastMessageLoading: Bool?
    
    private var endDragging: Bool?
    private var messagingChannelEndDragging: Bool?
    
    private var viewMode: Int?
    private var memberListQuery: SendBirdMemberListQuery?
    private var membersInChannel: NSMutableArray?
    private var messagingChannelListQuery: SendBirdMessagingChannelListQuery?
    private var messagingChannels: NSMutableArray?
    
    private var readStatus: NSMutableDictionary?
    private var typeStatus: NSMutableDictionary?
    private var mTimer: NSTimer?
    
    private var updateMessageTs: ((model: SendBirdMessageModel!) -> Void)!
    
    private var userListQuery: SendBirdUserListQuery?

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.viewMode = kChattingViewMode
        self.clearMessageTss()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func clearMessageTss() {
        self.mMaxMessageTs = SendBirdUtils.getMessagingMaxMessageTs()
        self.mMinMessageTs = Int64.max
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barTintColor = SendBirdUtils.UIColorFromRGB(0x533a9c)
        self.navigationController?.navigationBar.translucent = false
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "_btn_setting"), style: UIBarButtonItemStyle.Plain, target: self, action: "aboutSendBird:")
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "_btn_close"), style: UIBarButtonItemStyle.Plain, target: self, action: "dismissModal:")
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
        self.setNavigationButton()
    }
    
    func dismissModal(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func aboutSendBird(sender: AnyObject) {
        let title: String = "SendBird"
        let message: String = SENDBIRD_SAMPLE_UI_VER
        let closeButtonText: String = "Close"
        
        let alert: UIAlertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let closeAction: UIAlertAction = UIAlertAction.init(title: closeButtonText, style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(closeAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func openMenuActionSheet(sender: AnyObject) {
        let closeButtonText: String = "Close"
        let alert: UIAlertController = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let inviteAction: UIAlertAction = UIAlertAction.init(title: "Invite Member", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.openLobbyMemberListForInvite()
        }
        
        let closeAction: UIAlertAction = UIAlertAction.init(title: closeButtonText, style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(inviteAction)
        alert.addAction(closeAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func dismissLobbyMemberListForInvite(sender: AnyObject) {
        self.closeLobbyMemberListForInvite()
    }
    
    func editMessagingChannel(sender: AnyObject) {
        self.viewMode = kMessagingChannelListEditViewMode
        self.setNavigationButton()
        self.messagingChannelListTableView?.reloadData()
    }
    
    func goBack(sender: AnyObject) {
        self.viewMode = kMessagingChannelListViewMode
        self.setNavigationButton()
        self.messagingChannelListTableView?.reloadData()
    }
    
    func leaveChannel(sender: AnyObject) {
        let indexPaths: Array = (self.messagingChannelListTableView?.indexPathsForSelectedRows)!
        if indexPaths.count > 0 {
            for indexPath in indexPaths {
                let row: Int = indexPath.row
                let channel: SendBirdChannel = (self.messagingChannels?.objectAtIndex(row).channel)!
                SendBird.endMessagingWithChannelUrl(channel.url)
            }
        }
    }
    
    func hideChannel(sender: AnyObject) {
        let indexPaths: Array = (self.messagingChannelListTableView?.indexPathsForSelectedRows)!
        if indexPaths.count > 0 {
            for indexPath in indexPaths {
                let row: Int = indexPath.row
                let channel: SendBirdChannel = (self.messagingChannels?.objectAtIndex(row).channel)!
                SendBird.hideMessagingWithChannelUrl(channel.url)
            }
        }
    }
    
    func inviteMember(sender: AnyObject) {
        var userIds: Array<String> = Array()
        for var i = 0; i < self.membersInChannel?.count; i++ {
            if self.channelMemberListTableView?.cellForRowAtIndexPath(NSIndexPath.init(forRow: i, inSection: 0))?.selected == true {
                let member: SendBirdAppUser = self.membersInChannel?.objectAtIndex(i) as! SendBirdAppUser
                userIds.append(member.guestId)
            }
        }
        
        if userIds.count > 0 {
            if self.currentMessagingChannel != nil && self.currentMessagingChannel?.isGroupMessagingChannel() == true {
                SendBird.inviteMessagingWithChannelUrl(self.currentMessagingChannel?.getUrl(), andUserIds: userIds)
            }
            else {
                for item in (self.currentMessagingChannel?.members)! {
                    let member: SendBirdMemberInMessagingChannel = item as! SendBirdMemberInMessagingChannel
                    if member.guestId == self.userId {
                        continue
                    }
                    else {
                        userIds.append(member.guestId)
                    }
                }
                SendBird.startMessagingWithUserIds(userIds)
            }
        }
        self.viewMode = kMessagingViewMode
        self.setNavigationButton()
        self.messageInputView?.setInputEnable(true)
        self.channelMemberListTableView?.hidden = true
    }
    
    func setViewMode(mode: Int) {
        self.viewMode = mode
    }
    
    func setReadStatus(userId: String, ts: Int64) {
        if self.readStatus == nil {
            self.readStatus = NSMutableDictionary()
        }
        
        if readStatus?.objectForKey(userId) == nil {
            readStatus?.setObject(NSNumber.init(longLong: ts), forKey: userId)
        }
        else {
            let oldTs: Int64 = (self.readStatus?.objectForKey(userId)?.longLongValue)!
            if oldTs < ts {
                self.readStatus?.setObject(NSNumber.init(longLong: ts), forKey: userId)
            }
        }
    }
    
    func setTypeStatus(userId: String, ts: Int64) {
        if userId == SendBird.getUserId() {
            return
        }
        
        if self.typeStatus == nil {
            self.typeStatus = NSMutableDictionary()
        }
        
        if ts <= 0 {
            self.typeStatus?.removeObjectForKey(userId)
        }
        else {
            self.typeStatus?.setObject(NSNumber.init(longLong: ts), forKey: userId)
        }
    }
    
    func setNavigationButton() {
        if self.viewMode == kMessagingChannelListViewMode {
            self.navigationItem.rightBarButtonItems = Array()
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "_btn_close"), style: UIBarButtonItemStyle.Plain, target: self, action: "dismissModal:")
            self.navigationItem.leftBarButtonItem!.tintColor = UIColor.whiteColor()
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "_sendbird_btn_list_edit"), style: UIBarButtonItemStyle.Plain, target: self, action: "editMessagingChannel:")
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
        else if self.viewMode == kMessagingChannelListEditViewMode {
            self.navigationItem.rightBarButtonItems = Array()
            let leaveButtonItem: UIBarButtonItem = UIBarButtonItem.init(title: "Leave", style: UIBarButtonItemStyle.Plain, target: self, action: "leaveChannel:")
            leaveButtonItem.tintColor = UIColor.whiteColor()
            
            let hideButtonItem: UIBarButtonItem = UIBarButtonItem.init(title: "Hide", style: UIBarButtonItemStyle.Plain, target: self, action: "hideChannel:")
            hideButtonItem.tintColor = UIColor.whiteColor()
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "_btn_back"), style: UIBarButtonItemStyle.Plain, target: self, action: "goBack:")
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
            
            self.navigationItem.rightBarButtonItems = [leaveButtonItem, hideButtonItem]
            leaveButtonItem.enabled = false
            hideButtonItem.enabled = false
        }
        else if self.viewMode == kMessagingViewMode || self.viewMode == kMessagingMemberViewMode {
            self.navigationItem.rightBarButtonItems = Array()
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "_btn_setting"), style: UIBarButtonItemStyle.Plain, target: self, action: "openMenuActionSheet:")
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "_btn_close"), style: UIBarButtonItemStyle.Plain, target: self, action: "dismissModal:")
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        }
        else if self.viewMode == kMessagingMemberForGroupChatViewMode {
            self.navigationItem.rightBarButtonItems = Array()
            let inviteButtonItem: UIBarButtonItem = UIBarButtonItem.init(title: "Confirm", style: UIBarButtonItemStyle.Plain, target: self, action: "inviteMember:")
            inviteButtonItem.tintColor = UIColor.whiteColor()
            
            self.navigationItem.rightBarButtonItem = inviteButtonItem
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "_btn_close"), style: UIBarButtonItemStyle.Plain, target: self, action: "dismissLobbyMemberListForInvite:")
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        }
    }
    
    func initChannelTitle() {
        self.title = ""
    }
    
    func updateChannelTitle() {
        self.title = SendBirdUtils.getChannelNameFromUrl(self.channelUrl as! String)
    }
    
    override func viewDidLoad() {
        updateMessageTs = {(model: SendBirdMessageModel!) -> (Void) in
            if model.hasMessageId() == false {
                return
            }
            
            self.mMaxMessageTs = self.mMaxMessageTs < model.getMessageTimestamp() ? model.getMessageTimestamp() : self.mMaxMessageTs
            self.mMinMessageTs = self.mMinMessageTs > model.getMessageTimestamp() ? model.getMessageTimestamp() : self.mMinMessageTs
        }
        
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        
        ImageCache.initImageCache()
        SendBird.sharedInstance().taskQueue.cancelAllOperations()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.imageCache = NSMutableArray()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        self.openImagePicker = false
        self.membersInChannel = NSMutableArray()
        self.messagingChannels = NSMutableArray()
        self.initViews()
        
        if self.mTimer == nil {
            self.mTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerCallback:", userInfo: nil, repeats: true)
        }
        
        self.startChatting()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func setIndicatorHidden(hidden: Bool) {
        self.indicatorView?.hidden = hidden
    }
    
    func timerCallback(timer: NSTimer) {
        if self.viewMode == kMessagingViewMode {
            if self.checkTypeStatus() {
                self.showTyping()
            }
        }
    }
    
    func checkTypeStatus() -> Bool {
        if self.typeStatus != nil {
            for item in self.typeStatus! {
                if item.key as! String == SendBird.getUserId() {
                    let lastTypedTimestamp: Int64 = (item.value as! Int64) / 1000
                    let nowTimestamp = NSDate().timeIntervalSince1970
                    
                    if Int64(nowTimestamp) - lastTypedTimestamp > 10 {
                        self.typeStatus?.removeObjectForKey(item.key)
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    
    func startChatting() {
        self.scrolling = false
        self.messagingChannelScrolling = false;
        self.pastMessageLoading = true;
        self.endDragging = false;
        self.messagingChannelEndDragging = false;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(3) * NSEC_PER_SEC)), dispatch_get_main_queue()) { () -> Void in
            self.pastMessageLoading = false
        }
        self.cellHeight = NSMutableDictionary()
        self.initChannelTitle()
        if self.messageArray != nil {
            self.messageArray?.removeAll()
        }
        else {
            self.messageArray = Array()
        }
        self.tableView?.reloadData()
        
        SendBird.loginWithUserId(self.userId as! String, andUserName: self.userName as! String, andUserImageUrl: "", andAccessToken: "")
        SendBird.registerNotificationHandlerMessagingChannelUpdatedBlock({ (channel) -> Void in
            if self.viewMode == kMessagingViewMode {
                if SendBird.getCurrentChannel() != nil && SendBird.getCurrentChannel().channelId == channel.getId() {
                    self.updateMessagingChannel(channel)
                }
            }
            else {
                for oldChannel in self.messagingChannels! {
                    if (oldChannel as! SendBirdMessagingChannel).getId() == channel.getId() {
                        self.messagingChannels?.removeObject(oldChannel)
                        break;
                    }
                }
                self.messagingChannels?.insertObject(channel, atIndex: 0)
                self.messagingChannelListTableView?.reloadData()
            }
            
            }) { (mention) -> Void in
                
        }
        if self.viewMode == kMessagingChannelListViewMode {
            self.title = "Message"
            self.messageInputView?.setInputEnable(false)
        }
        else if self.viewMode == kMessagingMemberViewMode {
            self.title = "Users"
            self.messageInputView?.setInputEnable(false)
        }
        else if self.viewMode == kMessagingMemberForGroupChatViewMode {
            self.title = "Users"
            self.messageInputView?.setInputEnable(false)
        }
        
        SendBird.setEventHandlerConnectBlock({ (channel) -> Void in
            self.setIndicatorHidden(true)
            self.messageInputView!.setInputEnable(true)
            SendBird.markAsRead()
            }, errorBlock: { (code) -> Void in
                self.setIndicatorHidden(true)
            }, channelLeftBlock: { (channel) -> Void in
                
            }, messageReceivedBlock: { (message) -> Void in
                self.messageArray?.addSendBirdMessage(message, updateMessageTs: self.updateMessageTs)
                self.scrollToBottomWithReloading(true, force: false, animated: false)
                SendBird.markAllAsRead()
                self.setIndicatorHidden(true)
            }, systemMessageReceivedBlock: { (message) -> Void in
                self.messageArray?.addSendBirdMessage(message, updateMessageTs: self.updateMessageTs)
                self.scrollToBottomWithReloading(true, force: false, animated: false)
                self.setIndicatorHidden(true)
            }, broadcastMessageReceivedBlock: { (message) -> Void in
                self.messageArray?.addSendBirdMessage(message, updateMessageTs: self.updateMessageTs)
                self.scrollToBottomWithReloading(true, force: false, animated: false)
                self.setIndicatorHidden(true)
            }, fileReceivedBlock: { (fileLink) -> Void in
                self.messageArray?.addSendBirdMessage(fileLink, updateMessageTs: self.updateMessageTs)
                self.scrollToBottomWithReloading(true, force: false, animated: false)
                self.setIndicatorHidden(true)
                SendBird.markAsRead()
            }, messagingStartedBlock: { (channel) -> Void in
                self.currentMessagingChannel = channel
                self.channelUrl = channel.channel.url
                
                if self.readStatus != nil {
                    self.readStatus?.removeAllObjects()
                }
                if self.typeStatus != nil {
                    self.typeStatus?.removeAllObjects()
                }
                
                self.messageArray?.removeAll()
                
                self.updateMessagingChannel(channel)
                self.messageInputView?.setInputEnable(true)
                SendBird.queryMessageListInChannel(channel.getUrl()).prevWithMessageTs(Int64.max, andLimit: 30, resultBlock: { (queryResult) -> Void in
                    for model in queryResult {
                        self.messageArray?.addSendBirdMessage(model as! SendBirdMessageModel, updateMessageTs: self.updateMessageTs)
                    }
                    self.tableView?.reloadData()
                    
                    let pos: Int = queryResult.count > 30 ? 30 : queryResult.count
                    if pos > 0 {
                        self.tableView?.scrollToRowAtIndexPath(NSIndexPath.init(forRow: pos - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                    }
                    
                    SendBird.joinChannel(channel.getUrl())
                    SendBird.connectWithMessageTs(self.mMaxMessageTs!)
                    }, endBlock: { (error) -> Void in
                        
                })
            }, messagingUpdatedBlock: { (channel) -> Void in
                self.updateMessagingChannel(channel)
            }, messagingEndedBlock: { (channel) -> Void in
                if self.viewMode == kMessagingChannelListEditViewMode {
                    self.viewMode = kMessagingChannelListViewMode
                    self.setNavigationButton()
                    self.messagingChannelListQuery?.nextWithResultBlock({ (queryResult) -> Void in
                        self.messagingChannels?.removeAllObjects()
                        self.messagingChannels?.addObjectsFromArray(queryResult as [AnyObject])
                        }, endBlock: { (error) -> Void in
                            
                    })
                }
            }, allMessagingEndedBlock: { () -> Void in
                
            }, messagingHiddenBlock: { (channel) -> Void in
                if self.viewMode == kMessagingChannelListEditViewMode {
                    self.viewMode = kMessagingChannelListViewMode
                    self.setNavigationButton()
                    self.messagingChannelListQuery = SendBird.queryMessagingChannelList()
                    self.messagingChannelListQuery?.setLimit(15)
                    self.messagingChannelListQuery?.nextWithResultBlock({ (queryResult) -> Void in
                        self.messagingChannels?.removeAllObjects()
                        self.messagingChannels?.addObjectsFromArray(queryResult as [AnyObject])
                        self.messagingChannelListTableView?.reloadData()
                        }, endBlock: { (code) -> Void in
                            
                    })
                }
            }, allMessagingHiddenBlock: { () -> Void in
                
            }, readReceivedBlock: { (status) -> Void in
                self.setReadStatus(status.user.guestId, ts: status.timestamp)
                self.tableView?.reloadData()
            }, typeStartReceivedBlock: { (status) -> Void in
                self.setTypeStatus(status.user.guestId, ts: status.timestamp)
                self.showTyping()
            }, typeEndReceivedBlock: { (status) -> Void in
                self.setTypeStatus(status.user.guestId, ts: 0)
                self.showTyping()
            }, allDataReceivedBlock: { (sendBirdDataType, count) -> Void in
                if UInt32(sendBirdDataType) == SendBirdDataTypeMessage.rawValue {
                    self.scrollToBottomWithReloading(true, force: false, animated: false)
                }
            }) { (send, message, data, messageId) -> Void in
                if send == false && self.messageInputView?.isInputEnable() == true {
                    self.messageInputView?.messageTextField?.text = message
                    self.messageInputView?.showSendButton()
                }
                else {
                    self.messageInputView?.messageTextField?.text = ""
                    self.messageInputView?.hideSendButton()
                }
        }
        
        if self.viewMode == kMessagingMemberViewMode {
            self.channelMemberListTableView?.hidden = false
            
            self.userListQuery = SendBird.queryUserList()
            self.userListQuery?.nextWithResultBlock({ (queryResult) -> Void in
                for user in queryResult {
                    if (user as! SendBirdAppUser).guestId == SendBird.getUserId() {
                        continue
                    }
                    self.membersInChannel?.addObject(user)
                }
                self.channelMemberListTableView?.reloadData()
                
                }, endBlock: { (code) -> Void in
                    
            })
        }
        else if viewMode == kMessagingChannelListViewMode {
            self.messagingChannelListTableView?.hidden = false
            self.messagingChannelListQuery = SendBird.queryMessagingChannelList()
            self.messagingChannelListQuery?.setLimit(15)
            if self.messagingChannelListQuery?.hasNext() == true {
                self.messagingChannelListQuery?.nextWithResultBlock({ (queryResult) -> Void in
                    self.messagingChannels?.removeAllObjects()
                    self.messagingChannels?.addObjectsFromArray(queryResult as [AnyObject])
                    self.messagingChannelListTableView?.reloadData()
                    
                    }, endBlock: { (code) -> Void in
                        
                })
            }
            
            SendBird.joinChannel("")
            SendBird.connect()
        }
        else if viewMode == kMessagingViewMode {
            self.startMessagingWithUser(self.targetUserId as! String)
        }
    }
    
    func loadNextUserList() {
        self.userListQuery?.nextWithResultBlock({ (queryResult) -> Void in
            for user in queryResult {
                if (user as! SendBirdAppUser).guestId == SendBird.getUserId() {
                    continue
                }
                self.membersInChannel?.addObject(user)
            }
            self.channelMemberListTableView?.reloadData()
            }, endBlock: { (code) -> Void in
                
        })
    }
    
    func updateMessagingChannel(channel: SendBirdMessagingChannel) {
        self.setMessagingChannelTitle(channel)
        
        if self.readStatus == nil {
            self.readStatus = NSMutableDictionary()
        }
        
        let newReadStatus: NSMutableDictionary = NSMutableDictionary()
        for member in channel.members {
            var currentStatus: NSNumber = 0
            if (self.readStatus?.objectForKey(member.guestId)) != nil {
                currentStatus = (self.readStatus?.objectForKey(member.guestId)) as! NSNumber
                currentStatus = NSNumber.init(longLong: 0)
            }
            newReadStatus.setObject(NSNumber.init(longLong: max(currentStatus.longLongValue, channel.getLastReadMillis(member.guestId))), forKey: member.guestId)
        }

        self.readStatus?.removeAllObjects()
        for item in newReadStatus {
            self.readStatus?.setObject(item.value, forKey: item.key as! String)
        }
        self.tableView?.reloadData()
    }
    
    func openLobbyMemberListForInvite() {
        self.title = "Invite"
        self.messageInputView?.setInputEnable(false)
        self.viewMode = kMessagingMemberForGroupChatViewMode
        self.setNavigationButton()
        self.channelMemberListTableView?.hidden = false
        
        if self.membersInChannel != nil {
            self.membersInChannel?.removeAllObjects()
        }
        else {
            self.membersInChannel = NSMutableArray()
        }
        self.userListQuery = SendBird.queryUserList()
        self.userListQuery?.nextWithResultBlock({ (queryResult) -> Void in
            for user in queryResult {
                if (user as! SendBirdAppUser).guestId == SendBird.getUserId() {
                    continue
                }
                self.membersInChannel?.addObject(user)
            }
            self.channelMemberListTableView?.reloadData()
            
            }, endBlock: { (code) -> Void in
                
        })
    }
    
    func closeLobbyMemberListForInvite() {
        self.messageInputView?.setInputEnable(false)
        self.viewMode = kMessagingViewMode
        self.setNavigationButton()
        self.channelMemberListTableView?.hidden = true
    }
    
    func scrollToBottomWithReloading(reload: Bool, force: Bool, animated: Bool) {
        if reload {
            self.tableView?.reloadData()
        }
        
        if self.scrolling == true {
            return
        }
        
        if self.messageArray == nil {
            return
        }
        
        if self.pastMessageLoading == true || self.isScrollBottom() == true || force {
            let msgCount: Int = (self.messageArray?.count)!
            if msgCount > 0 {
                self.tableView?.scrollToRowAtIndexPath(NSIndexPath.init(forRow: (msgCount - 1), inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if self.openImagePicker == false {
            SendBird.disconnect()
        }
    }
    
    func initViews() {
        self.view.backgroundColor = UIColor.clearColor()
        self.view.opaque = false
        
        // Messaging
        self.tableView = UITableView()
        self.tableView?.translatesAutoresizingMaskIntoConstraints = false
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.separatorColor = UIColor.clearColor()
        self.tableView?.backgroundColor = SendBirdUtils.UIColorFromRGB(0xffffff)
        self.tableView?.contentInset = UIEdgeInsetsMake(6, 0, 6, 0)
        self.tableView?.bounces = false
        
        self.tableView?.registerClass(MessagingMessageTableViewCell.self, forCellReuseIdentifier: kMessageCellIdentifier)
        self.tableView?.registerClass(MessagingSystemMessageTableViewCell.self, forCellReuseIdentifier: kSystemMessageCellIdentifier)
        self.tableView?.registerClass(MessagingFileLinkTableViewCell.self, forCellReuseIdentifier: kFileLinkCellIdentifier)
        self.tableView?.registerClass(MessagingFileMessageTableViewCell.self, forCellReuseIdentifier: kFileMessageCellIdentifier)
        self.tableView?.registerClass(MessagingBroadcastMessageTableViewCell.self, forCellReuseIdentifier: kBroadcastMessageCellIdentifier)
        self.tableView?.registerClass(MessagingMyMessageTableViewCell.self, forCellReuseIdentifier: kMyMessageCellIdentifier)
        self.tableView?.registerClass(MessagingMyFileLinkTableViewCell.self, forCellReuseIdentifier: kMyFileLinkCellIdentifier)
        self.view.addSubview(self.tableView!)
        
        self.messageSizingTableViewCell = MessagingMessageTableViewCell()
        self.messageSizingTableViewCell?.translatesAutoresizingMaskIntoConstraints = false
        self.messageSizingTableViewCell?.hidden = true
        self.view.addSubview(self.messageSizingTableViewCell!)
        
        self.myMessageSizingTableViewCell = MessagingMyMessageTableViewCell()
        self.myMessageSizingTableViewCell?.translatesAutoresizingMaskIntoConstraints = false
        self.myMessageSizingTableViewCell?.hidden = true
        self.view.addSubview(self.myMessageSizingTableViewCell!)
        
        self.fileLinkSizingTableViewCell = MessagingFileLinkTableViewCell()
        self.fileLinkSizingTableViewCell?.translatesAutoresizingMaskIntoConstraints = false
        self.fileLinkSizingTableViewCell?.hidden = true
        self.view.addSubview(self.fileLinkSizingTableViewCell!)
        
        self.fileMessageSizingTableViewCell = MessagingFileMessageTableViewCell()
        self.fileMessageSizingTableViewCell?.translatesAutoresizingMaskIntoConstraints = false
        self.fileMessageSizingTableViewCell?.hidden = true
        self.view.addSubview(self.fileMessageSizingTableViewCell!)
        
        self.broadcastMessageSizingTableViewCell = MessagingBroadcastMessageTableViewCell()
        self.broadcastMessageSizingTableViewCell?.translatesAutoresizingMaskIntoConstraints = false
        self.broadcastMessageSizingTableViewCell?.hidden = true
        self.view.addSubview(self.broadcastMessageSizingTableViewCell!)
        
        self.myFileLinkSizingTableViewCell = MessagingMyFileLinkTableViewCell()
        self.myFileLinkSizingTableViewCell?.translatesAutoresizingMaskIntoConstraints = false
        self.myFileLinkSizingTableViewCell?.hidden = true
        self.view.addSubview(self.myFileLinkSizingTableViewCell!)
        
        self.messageInputView = MessageInputView()
        self.messageInputView?.translatesAutoresizingMaskIntoConstraints = false
        self.messageInputView?.setDelegate(self)
        self.messageInputView?.messageInputViewDelegate = self
        self.view.addSubview(self.messageInputView!)
        
        self.indicatorView = MessagingIndicatorView()
        self.indicatorView?.translatesAutoresizingMaskIntoConstraints = false
        self.indicatorView?.hidden = true
        self.view.addSubview(self.indicatorView!)
        
        // Member List in Channel
        self.channelMemberListTableView = UITableView()
        self.channelMemberListTableView?.translatesAutoresizingMaskIntoConstraints = false
        self.channelMemberListTableView?.delegate = self
        self.channelMemberListTableView?.dataSource = self
        self.channelMemberListTableView?.hidden = true
        self.channelMemberListTableView?.allowsMultipleSelection = true
        self.channelMemberListTableView?.separatorColor = UIColor.clearColor()
        
        self.channelMemberListTableView?.registerClass(MemberTableViewCell.self, forCellReuseIdentifier: kMemberCellIdentifier)
        self.view.addSubview(self.channelMemberListTableView!)
        
        // Messaging Channel List
        self.messagingChannelListTableView = UITableView()
        self.messagingChannelListTableView?.translatesAutoresizingMaskIntoConstraints = false
        self.messagingChannelListTableView?.delegate = self
        self.messagingChannelListTableView?.dataSource = self
        self.messagingChannelListTableView?.hidden = true
        self.messagingChannelListTableView?.allowsMultipleSelection = false
        self.messagingChannelListTableView?.separatorColor = UIColor.clearColor()
        self.messagingChannelListTableView?.bounces = false
        
        self.messagingChannelListTableView?.registerClass(MessagingChannelTableViewCell.self, forCellReuseIdentifier: kMessagingChannelCellIdentifier)
        self.view.addSubview(self.messagingChannelListTableView!)
        
        let lpgr: UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: "handleLongPress:")
        lpgr.minimumPressDuration = 1.2
        lpgr.delegate = self
        self.messagingChannelListTableView?.addGestureRecognizer(lpgr)
        
        // Typing-now View
        self.typingNowView = TypingNowView()
        self.typingNowView?.translatesAutoresizingMaskIntoConstraints = false
        self.typingNowView?.hidden = true
        self.view.addSubview(self.typingNowView!)
        
        self.applyConstraints()
    }
    
    func applyConstraints() {
        // Messaging Table View
        self.view.addConstraint(NSLayoutConstraint.init(item: self.tableView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.tableView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.tableView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.tableViewBottomMargin = NSLayoutConstraint.init(item: self.tableView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.messageInputView!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        self.view.addConstraint(self.tableViewBottomMargin!)
        
        // Message Input View
        self.view.addConstraint(NSLayoutConstraint.init(item: self.messageInputView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.messageInputView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.bottomMargin = NSLayoutConstraint.init(item: self.messageInputView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        self.view.addConstraint(self.bottomMargin!)
        self.view.addConstraint(NSLayoutConstraint.init(item: self.messageInputView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 44))
        
        // Typing-now View
        self.view.addConstraint(NSLayoutConstraint.init(item: self.typingNowView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.messageInputView!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.typingNowView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.typingNowView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.typingNowView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kTypingViewHeight))
        
        // Messaging Channel List Table View
        self.view.addConstraint(NSLayoutConstraint.init(item: self.messagingChannelListTableView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.messagingChannelListTableView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.messageInputView!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.messagingChannelListTableView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.messagingChannelListTableView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        
        // Channel Member List Table View
        self.view.addConstraint(NSLayoutConstraint.init(item: self.channelMemberListTableView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.channelMemberListTableView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.messageInputView!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.channelMemberListTableView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.channelMemberListTableView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        
        // Indicator View
        self.view.addConstraint(NSLayoutConstraint.init(item: self.indicatorView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.indicatorView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.indicatorView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.indicatorView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
    }
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let p: CGPoint = gestureRecognizer.locationInView(self.messagingChannelListTableView!)
        let indexPath: NSIndexPath? = self.messagingChannelListTableView!.indexPathForRowAtPoint(p)
        if indexPath == nil {
            NSLog("long press on table view but not on a row")
        }
        else if gestureRecognizer.state == UIGestureRecognizerState.Began {
            NSLog("long press on table view at row %ld", indexPath!.row);
            let jmc: SendBirdMessagingChannel = (self.messagingChannels?.objectAtIndex(indexPath!.row)) as! SendBirdMessagingChannel
            SendBird.markAsReadForChannel(jmc.getUrl())
        }
        else {
            NSLog("gestureRecognizer.state = %ld", gestureRecognizer.state.rawValue)
        }
    }
    
    func keyboardWillShow(notif: NSNotification) {
        let keyboardInfo: NSDictionary = notif.userInfo!
        let keyboardFrameEnd: NSValue = keyboardInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardFrameEndRect: CGRect = keyboardFrameEnd.CGRectValue()
        self.bottomMargin?.constant = -keyboardFrameEndRect.size.height
        self.view.updateConstraints()
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.scrollToBottomWithReloading(false, force: false, animated: false)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.bottomMargin?.constant = 0
        self.view.updateConstraints()
        self.scrollToBottomWithReloading(false, force: false, animated: false)
    }
    
    func clearPreviousChatting() {
        self.messageArray?.removeAll()
        self.tableView?.reloadData()
        self.scrolling = false
        self.pastMessageLoading = true
        self.endDragging = false
    }
    
    func showTyping() {
        if self.typeStatus?.count == 0 {
            self.hideTyping()
        }
        else {
            self.tableViewBottomMargin?.constant = -kTypingViewHeight
            self.view.updateConstraints()
            if self.typeStatus != nil {
                self.typingNowView?.setModel(self.typeStatus!)
                self.typingNowView?.hidden = false
            }
        }
    }
    
    func setMessagingChannelTitle(channel: SendBirdMessagingChannel) {
        var member: SendBirdMemberInMessagingChannel?
        if channel.members.count > 0 {
            member = channel.members.objectAtIndex(0) as? SendBirdMemberInMessagingChannel
        }
        
        for var i = 0; i < channel.members.count; i++ {
            if channel.members.objectAtIndex(i).guestId == SendBird.getUserId() {
                member = channel.members.objectAtIndex(i) as? SendBirdMemberInMessagingChannel
                break;
            }
        }
        
        if channel.members.count > 2 {
            self.title = String.init(format: "Group Chat %lu", channel.members.count)
        }
        else {
            if member != nil {
                self.title = member!.name
            }
        }
    }
    
    func hideTyping() {
        self.tableViewBottomMargin?.constant = 0
        self.view.updateConstraints()
        self.typingNowView?.hidden = true
    }
    
    func startMessagingWithUser(userId: String) {
        self.channelMemberListTableView?.hidden = true
        self.messagingChannelListTableView?.hidden = true
        self.tableView?.hidden = false
        SendBird.startMessagingWithUserId(userId)
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if scrollView == self.channelMemberListTableView {
            
        }
        else if scrollView == self.messagingChannelListTableView {
            self.messagingChannelScrolling = true
        }
        else {
            self.scrolling = true
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == self.channelMemberListTableView {
            
        }
        else if scrollView == self.messagingChannelListTableView {
            self.messagingChannelScrolling = false
        }
        else {
            self.scrolling = false
        }
    }
    
    func isScrollBottom() -> Bool {
        let offset: CGPoint = (self.tableView?.contentOffset)!
        let bounds: CGRect = (self.tableView?.bounds)!
        let size: CGSize = (self.tableView?.contentSize)!
        let inset: UIEdgeInsets = (self.tableView?.contentInset)!
        let y: CGFloat = offset.y + bounds.size.height - inset.bottom
        let h: CGFloat = size.height
        
        if y >= (h - 400) {
            return true
        }
        return false
    }
    
    func didTapOnTableView(sender: AnyObject) {
        self.messageInputView?.hideKeyboard()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.channelMemberListTableView {
            
        }
        else if scrollView == self.messagingChannelListTableView {
            let offset: CGPoint = scrollView.contentOffset
            let bounds: CGRect = scrollView.bounds
            let size: CGSize = scrollView.contentSize
            let inset: UIEdgeInsets = scrollView.contentInset
            let y: CGFloat = offset.y + bounds.size.height - inset.bottom
            let h: CGFloat = size.height
            if y > h - 5 && self.messagingChannelEndDragging == true {
                self.messagingChannelListQuery?.nextWithResultBlock({ (queryResult) -> Void in
                    if queryResult.count <= 0 {
                        return
                    }
                    for model in queryResult {
                        self.messagingChannels?.addObject(model as! SendBirdMessagingChannel)
                    }
                    self.messagingChannelListTableView?.reloadData()
                    
                    }, endBlock: { (code) -> Void in
                        
                })
                self.messagingChannelEndDragging = false
            }
        }
        else if scrollView == self.tableView {
            if scrollView.contentOffset.y < 0 && self.endDragging == true {
                SendBird.queryMessageListInChannel(SendBird.getChannelUrl()).prevWithMessageTs(self.mMinMessageTs!, andLimit: 30, resultBlock: { (queryResult) -> Void in
                    if queryResult.count <= 0 {
                        return
                    }
                    for model in queryResult {
                        self.messageArray?.addSendBirdMessage(model as! SendBirdMessageModel, updateMessageTs: self.updateMessageTs)
                    }
                    self.tableView?.reloadData()
                    self.tableView?.scrollToRowAtIndexPath(NSIndexPath.init(forRow: queryResult.count, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                    
                    }, endBlock: { (error) -> Void in
                        
                })
                self.endDragging = false
            }
            else {
                let offset: CGPoint = scrollView.contentOffset
                let bounds: CGRect = scrollView.bounds
                let size: CGSize = scrollView.contentSize
                let inset: UIEdgeInsets = scrollView.contentInset
                let y: CGFloat = offset.y + bounds.size.height - inset.bottom
                let h: CGFloat = size.height
                if y > h - 5 && self.endDragging == true {
                    NSLog("scroll mMaxMessageTs: %lld", self.mMaxMessageTs!);
                    SendBird.queryMessageListInChannel(SendBird.getChannelUrl()).nextWithMessageTs(self.mMaxMessageTs!, andLimit: 30, resultBlock: { (queryResult) -> Void in
                        if queryResult.count <= 0 {
                            return
                        }
                        for model in queryResult {
                            self.messageArray?.addSendBirdMessage(model as! SendBirdMessageModel, updateMessageTs: self.updateMessageTs)
                        }
                        self.tableView?.reloadData()
                        self.tableView?.scrollToRowAtIndexPath(NSIndexPath.init(forRow: self.messageArray!.count - queryResult.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                        
                        }, endBlock: { (error) -> Void in
                            
                    })
                    self.endDragging = false
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == self.channelMemberListTableView {
            
        }
        else if scrollView == self.messagingChannelListTableView {
            self.messagingChannelEndDragging = true
        }
        else {
            self.endDragging = true
        }
    }
    
    // MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == self.channelMemberListTableView {
            return 1
        }
        else if tableView == self.messagingChannelListTableView {
            return 1
        }
        else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.channelMemberListTableView {
            return (self.membersInChannel?.count)!
        }
        else if tableView == self.messagingChannelListTableView {
            return (self.messagingChannels?.count)!
        }
        else {
            return (self.messageArray?.count)!
        }
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.channelMemberListTableView {
            var cell: UITableViewCell? = nil
            
            if self.membersInChannel?.objectAtIndex(indexPath.row).isKindOfClass(SendBirdAppUser.self) == true {
                cell = tableView.dequeueReusableCellWithIdentifier(kMemberCellIdentifier)
            }
            
            if cell == nil {
                if self.membersInChannel?.objectAtIndex(indexPath.row).isKindOfClass(SendBirdAppUser.self) == true {
                    cell = MemberTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kMemberCellIdentifier)
                }
            }
            
            let member: SendBirdAppUser = (self.membersInChannel?.objectAtIndex(indexPath.row))! as! SendBirdAppUser
            if self.viewMode == kMessagingMemberForGroupChatViewMode {
                (cell as! MemberTableViewCell).setModel(member, check: true)
            }
            else {
                (cell as! MemberTableViewCell).setModel(member, check: false)
            }
            
            if indexPath.row + 1 == self.membersInChannel?.count {
                self.loadNextUserList()
            }
            
            return cell!
        }
        else if tableView == self.messagingChannelListTableView {
            var cell: UITableViewCell? = nil
            if self.messagingChannels?.objectAtIndex(indexPath.row).isKindOfClass(SendBirdMessagingChannel.self) == true {
                cell = tableView.dequeueReusableCellWithIdentifier(kMessagingChannelCellIdentifier)
            }
            
            if cell == nil {
                if ((self.messagingChannels?.objectAtIndex(indexPath.row).isKindOfClass(SendBirdMessagingChannel.self)) != nil) {
                    cell = MessagingChannelTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kMessagingChannelCellIdentifier)
                }
            }
            
            let messagingChannel: SendBirdMessagingChannel = (self.messagingChannels?.objectAtIndex(indexPath.row))! as! SendBirdMessagingChannel
            if self.viewMode == kMessagingChannelListEditViewMode {
                (cell as! MessagingChannelTableViewCell).setModel(messagingChannel, check: true)
            }
            else {
                (cell as! MessagingChannelTableViewCell).setModel(messagingChannel, check: false)
            }
            
            return cell!
        }
        else {
            var cell: UITableViewCell? = nil
            
            if self.messageArray![indexPath.row].isKindOfClass(SendBirdMessage.self) == true {
                let message: SendBirdMessage = self.messageArray![indexPath.row] as! SendBirdMessage
                let sender: SendBirdSender = message.sender
                
                if sender.guestId == SendBird.getUserId() {
                    cell = tableView.dequeueReusableCellWithIdentifier(kMyMessageCellIdentifier)
                }
                else {
                    cell = tableView.dequeueReusableCellWithIdentifier(kMessageCellIdentifier)
                }
            }
            else if self.messageArray![indexPath.row].isKindOfClass(SendBirdFileLink.self) == true {
                let message: SendBirdFileLink = self.messageArray![indexPath.row] as! SendBirdFileLink
                let sender: SendBirdSender = message.sender
                
                if sender.guestId == SendBird.getUserId() {
                    cell = tableView.dequeueReusableCellWithIdentifier(kMyFileLinkCellIdentifier)
                }
                else {
                    cell = tableView.dequeueReusableCellWithIdentifier(kFileLinkCellIdentifier)
                }
            }
            else if self.messageArray![indexPath.row].isKindOfClass(SendBirdBroadcastMessage.self) == true {
                cell = tableView.dequeueReusableCellWithIdentifier(kBroadcastMessageCellIdentifier)
            }
            else {
                cell = tableView.dequeueReusableCellWithIdentifier(kSystemMessageCellIdentifier)
            }
            
            if cell == nil {
                if self.messageArray![indexPath.row].isKindOfClass(SendBirdMessage.self) == true {
                    let message: SendBirdMessage = self.messageArray![indexPath.row] as! SendBirdMessage
                    let sender: SendBirdSender = message.sender
                    
                    if sender.guestId == SendBird.getUserId() {
                        cell = MessagingMyMessageTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kMyMessageCellIdentifier)
                        (cell as! MessagingMyMessageTableViewCell).readStatus = self.readStatus
                    }
                    else {
                        cell = MessagingMessageTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kMessageCellIdentifier)
                    }
                }
                else if self.messageArray![indexPath.row].isKindOfClass(SendBirdFileLink.self) == true {
                    let fileLink: SendBirdFileLink = self.messageArray![indexPath.row] as! SendBirdFileLink
                    if fileLink.fileInfo.type.hasPrefix("image") {
                        let sender: SendBirdSender = fileLink.sender
                        
                        if sender.guestId == SendBird.getUserId() {
                            cell = MessagingMyFileLinkTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kMyFileLinkCellIdentifier)
                            (cell as! MessagingMyFileLinkTableViewCell).readStatus = self.readStatus
                        }
                        else {
                            cell = MessagingFileLinkTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kFileLinkCellIdentifier)
                        }
                    }
                    else {
                        cell = MessagingFileMessageTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kFileMessageCellIdentifier)
                    }
                }
                else if self.messageArray![indexPath.row].isKindOfClass(SendBirdBroadcastMessage.self) == true {
                    cell = MessagingBroadcastMessageTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kBroadcastMessageCellIdentifier)
                }
                else {
                    cell = MessagingSystemMessageTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kSystemMessageCellIdentifier)
                }
            }
            else {
                if self.messageArray![indexPath.row].isKindOfClass(SendBirdMessage.self) {
                    let message: SendBirdMessage = self.messageArray![indexPath.row] as! SendBirdMessage
                    let sender: SendBirdSender = message.sender
                    
                    if sender.guestId == SendBird.getUserId() {
                        (cell as! MessagingMyMessageTableViewCell).readStatus = self.readStatus
                        (cell as! MessagingMyMessageTableViewCell).setModel(self.messageArray![indexPath.row] as! SendBirdMessage)
                    }
                    else {
                        (cell as! MessagingMessageTableViewCell).setModel(self.messageArray![indexPath.row] as! SendBirdMessage)
                    }
                }
                else if self.messageArray![indexPath.row].isKindOfClass(SendBirdFileLink.self) {
                    let fileLink: SendBirdFileLink = self.messageArray![indexPath.row] as! SendBirdFileLink
                    if fileLink.fileInfo.type.hasPrefix("image") == true {
                        let sender: SendBirdSender = fileLink.sender
                        
                        if sender.guestId == SendBird.getUserId() {
                            cell = MessagingMyFileLinkTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kMyFileLinkCellIdentifier)
                                (cell as! MessagingMyFileLinkTableViewCell).readStatus = self.readStatus
                            (cell as! MessagingMyFileLinkTableViewCell).setModel(fileLink)
                        }
                        else {
                            cell = MessagingFileLinkTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kFileLinkCellIdentifier)
                            (cell as! MessagingFileLinkTableViewCell).setModel(fileLink)
                        }
                    }
                    else {
                        cell = MessagingFileMessageTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kFileMessageCellIdentifier)
                        (cell as! MessagingFileMessageTableViewCell).setModel(fileLink)
                    }
                }
                else if self.messageArray![indexPath.row].isKindOfClass(SendBirdBroadcastMessage.self) == true {
                    (cell as! MessagingBroadcastMessageTableViewCell).setModel(self.messageArray![indexPath.row] as! SendBirdBroadcastMessage)
                }
                else {
                    (cell as! MessagingSystemMessageTableViewCell).setModel(self.messageArray![indexPath.row] as! SendBirdSystemMessage)
                }
            }
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell!
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == self.channelMemberListTableView {
            return 60
        }
        else if tableView == self.messagingChannelListTableView {
            return 60
        }
        else {
            var calculatedHeight: CGFloat = 0
            var ts: Int64 = 0
            if self.messageArray![indexPath.row].isKindOfClass(SendBirdMessage.self) == true {
                ts = self.messageArray![indexPath.row].getMessageTimestamp()
            }
            else if self.messageArray![indexPath.row].isKindOfClass(SendBirdBroadcastMessage.self) {
                ts = self.messageArray![indexPath.row].getMessageTimestamp()
            }
            else if self.messageArray![indexPath.row].isKindOfClass(SendBirdFileLink.self) {
                ts = self.messageArray![indexPath.row].getMessageTimestamp()
            }
            
            if self.cellHeight?.objectForKey(NSNumber.init(longLong: ts)) != nil && self.cellHeight?.objectForKey(NSNumber.init(longLong: ts))!.floatValue > 0 {
                calculatedHeight = CGFloat((self.cellHeight?.objectForKey(NSNumber.init(longLong: ts))?.floatValue)!)
            }
            else {
                var ts: Int64 = 0
                
                if self.messageArray![indexPath.row].isKindOfClass(SendBirdMessage.self) == true {
                    let message: SendBirdMessage = self.messageArray![indexPath.row] as! SendBirdMessage
                    let sender: SendBirdSender = message.sender
                    
                    if sender.guestId == SendBird.getUserId() {
                        self.myMessageSizingTableViewCell?.setModel(message)
                        calculatedHeight = (self.myMessageSizingTableViewCell?.getHeightOfViewCell(self.view.frame.size.width))!
                    }
                    else {
                        self.messageSizingTableViewCell?.setModel(message)
                        calculatedHeight = (self.messageSizingTableViewCell?.getHeightOfViewCell(self.view.frame.size.width))!
                    }
                    
                    ts = self.messageArray![indexPath.row].getMessageTimestamp()
                }
                else if self.messageArray![indexPath.row].isKindOfClass(SendBirdBroadcastMessage.self) == true {
                    self.broadcastMessageSizingTableViewCell?.setModel(self.messageArray![indexPath.row] as! SendBirdBroadcastMessage)
                    calculatedHeight = (self.broadcastMessageSizingTableViewCell?.getHeightOfViewCell(self.view.frame.size.width))!
                    ts = self.messageArray![indexPath.row].getMessageTimestamp()
                }
                else if self.messageArray![indexPath.row].isKindOfClass(SendBirdFileLink.self) == true {
                    let fileLink: SendBirdFileLink = self.messageArray![indexPath.row] as! SendBirdFileLink
                    if fileLink.fileInfo.type.hasPrefix("image") {
                        let sender: SendBirdSender = fileLink.sender
                        
                        if sender.guestId == SendBird.getUserId() {
                            self.myFileLinkSizingTableViewCell?.setModel(fileLink)
                            calculatedHeight = (self.myFileLinkSizingTableViewCell?.getHeightOfViewCell(self.view.frame.size.width))!
                        }
                        else {
                            self.fileLinkSizingTableViewCell?.setModel(fileLink)
                            calculatedHeight = (self.fileLinkSizingTableViewCell?.getHeightOfViewCell(self.view.frame.size.width))!
                        }
                    }
                    else {
                        self.fileMessageSizingTableViewCell?.setModel(fileLink)
                        calculatedHeight = (self.fileMessageSizingTableViewCell?.getHeightOfViewCell(self.view.frame.size.width))!
                    }
                    ts = self.messageArray![indexPath.row].getMessageTimestamp()
                }
                else {
                    calculatedHeight = 32
                }

                self.cellHeight?.setObject(NSNumber.init(float: Float(calculatedHeight)), forKey: NSNumber.init(longLong: ts))
            }
            
            var prevSender: SendBirdSender? = nil
            var contMsg: Bool = false
            if indexPath.row > 0 {
                if self.messageArray![indexPath.row - 1].isKindOfClass(SendBirdMessage.self) == true {
                    prevSender = (self.messageArray![indexPath.row - 1] as! SendBirdMessage).sender
                }
                else if self.messageArray![indexPath.row - 1].isKindOfClass(SendBirdFileLink.self) == true {
                    prevSender = (self.messageArray![indexPath.row - 1] as! SendBirdFileLink).sender
                }

                if self.messageArray![indexPath.row].isKindOfClass(SendBirdMessage.self) == true {
                    let message: SendBirdMessage = self.messageArray![indexPath.row] as! SendBirdMessage
                    let sender: SendBirdSender = message.sender
                    
                    if prevSender != nil {
                        if sender.guestId == prevSender?.guestId {
                            contMsg = true
                        }
                    }
                }
                else if self.messageArray![indexPath.row].isKindOfClass(SendBirdFileLink.self) == true {
                    let fileLink: SendBirdFileLink = self.messageArray![indexPath.row] as! SendBirdFileLink
                    let sender: SendBirdSender = fileLink.sender
                    if prevSender != nil {
                        if sender.guestId == prevSender?.guestId {
                            contMsg = true
                        }
                    }
                }
            }
            if contMsg {
                calculatedHeight = calculatedHeight - 10
            }
            
            return calculatedHeight
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.channelMemberListTableView {
            if self.viewMode == kMessagingMemberForGroupChatViewMode {
                tableView.cellForRowAtIndexPath(indexPath)?.selected = true
                self.navigationItem.rightBarButtonItem?.enabled = true
                for item in self.navigationItem.rightBarButtonItems! {
                    (item as UIBarButtonItem).enabled = true
                }
            }
            else {
                tableView.hidden = true
                self.tableView?.hidden = false
                let member: SendBirdAppUser = self.membersInChannel?.objectAtIndex(indexPath.row) as! SendBirdAppUser
                SendBird.startMessagingWithUserId(member.guestId)
            }
        }
        else if tableView == self.messagingChannelListTableView {
            if self.viewMode == kMessagingChannelListEditViewMode {
                tableView.cellForRowAtIndexPath(indexPath)?.selected = true
                self.navigationItem.rightBarButtonItem?.enabled = true
                for item in self.navigationItem.rightBarButtonItems! {
                    (item as UIBarButtonItem).enabled = true
                }
            }
            else {
                tableView.hidden = true
                self.tableView?.hidden = false
                let messagingChannel: SendBirdMessagingChannel = self.messagingChannels?.objectAtIndex(indexPath.row) as! SendBirdMessagingChannel
                let channel: SendBirdChannel = messagingChannel.channel
                SendBird.joinMessagingWithChannelUrl(channel.url)
                self.viewMode = kMessagingViewMode
                self.setNavigationButton()
            }
        }
        else {
            self.messageInputView?.hideKeyboard()
            
            if self.messageArray![indexPath.row].isKindOfClass(SendBirdMessage.self) == true {
                let message: SendBirdMessage = self.messageArray![indexPath.row] as! SendBirdMessage
                let msgString: String = message.message
                let url: String = SendBirdUtils.getUrlFromstring(msgString)
                if msgString.characters.count > 0 {
                    self.clickURL(url)
                }
            }
            else if self.messageArray![indexPath.row].isKindOfClass(SendBirdFileLink.self) {
                let fileLink: SendBirdFileLink = self.messageArray![indexPath.row] as! SendBirdFileLink
                if fileLink.fileInfo.type.hasPrefix("image") == true {
                    self.clickImage(fileLink.fileInfo.url)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.messagingChannelListTableView {
            if self.viewMode == kMessagingChannelListEditViewMode || self.viewMode == kMessagingMemberForGroupChatViewMode {
                tableView.cellForRowAtIndexPath(indexPath)?.selected = false
                if tableView.indexPathsForSelectedRows?.count > 0 {
                    self.navigationItem.rightBarButtonItem?.enabled = true
                    for item in self.navigationItem.rightBarButtonItems! {
                        item.enabled = true
                    }
                }
                else {
                    self.navigationItem.rightBarButtonItem?.enabled = false
                    for item in self.navigationItem.rightBarButtonItems! {
                        item.enabled = false
                    }
                }
            }
        }
        else if tableView == self.channelMemberListTableView {
            if self.viewMode == kMessagingMemberForGroupChatViewMode {
                tableView.cellForRowAtIndexPath(indexPath)?.selected = false
            }
        }
    }
    
    func clickURL(url: String) {
        let closeButtonText: String = "Close"
        let alert: UIAlertController = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let openLinkAction: UIAlertAction = UIAlertAction.init(title: "Open Link in Safari", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            let encodedUrl: String = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
            UIApplication.sharedApplication().openURL(NSURL.init(string: encodedUrl)!)
        }
        let closeAction: UIAlertAction = UIAlertAction.init(title: closeButtonText, style: UIAlertActionStyle.Cancel, handler: nil)

        alert.addAction(openLinkAction)
        alert.addAction(closeAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func clickImage(url: String) {
        let closeButtonText: String = "Close"
        let alert: UIAlertController = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let openLinkAction: UIAlertAction = UIAlertAction.init(title: "See Image in Safari", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            let encodedUrl: String = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
            UIApplication.sharedApplication().openURL(NSURL.init(string: encodedUrl)!)
        }
        let closeAction: UIAlertAction = UIAlertAction.init(title: closeButtonText, style: UIAlertActionStyle.Cancel, handler: nil)
        
        alert.addAction(openLinkAction)
        alert.addAction(closeAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: MessageInputViewDelegate
    func clickSendButton(message: String) {
        self.scrollToBottomWithReloading(false, force: true, animated: false)
        if message.characters.count > 0 {
            let messageId: String = NSUUID.init().UUIDString
            SendBird.sendMessage(message, withTempId: messageId)
        }
    }
    
    func clickFileAttachButton() {
        let mediaUI: UIImagePickerController = UIImagePickerController()
        mediaUI.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        let mediaTypes: NSMutableArray = NSMutableArray.init(array: [kUTTypeImage])
        mediaUI.mediaTypes = mediaTypes as NSArray as! [String]
        mediaUI.delegate = self
        self.openImagePicker = true
        self.presentViewController(mediaUI, animated: true, completion: nil)
    }
    
    func clickChannelListButton() {
        self.clearPreviousChatting()
        if self.messagingChannelListTableView?.hidden == true {
            self.messagingChannelListTableView?.hidden = false
            self.messageInputView?.setInputEnable(false)
            self.messagingChannelListTableView?.hidden = false
            self.messagingChannelListQuery = SendBird.queryMessagingChannelList()
            self.messagingChannelListQuery?.setLimit(15)
            self.messagingChannelListQuery?.nextWithResultBlock({ (queryResult) -> Void in
                self.messagingChannels?.removeAllObjects()
                self.messagingChannels?.addObjectsFromArray(queryResult as [AnyObject])
                self.messagingChannelListTableView?.reloadData()
                
                }, endBlock: { (code) -> Void in
                    
            })
        }
        else {
            self.messagingChannelListTableView?.hidden = true
            self.messageInputView?.setInputEnable(true)
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType: String = info[UIImagePickerControllerMediaType] as! String
        var originalImage: UIImage?
        var editedImage: UIImage?
        var imageToUse: UIImage?
        
        self.setIndicatorHidden(false)
        picker.dismissViewControllerAnimated(true) { () -> Void in
            if CFStringCompare(mediaType as CFString, kUTTypeImage, CFStringCompareFlags.CompareCaseInsensitive) == CFComparisonResult.CompareEqualTo {
                editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
                originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage
                
                if originalImage != nil {
                    imageToUse = originalImage
                }
                else {
                    imageToUse = editedImage
                }
                
                let imageFileData: NSData = UIImagePNGRepresentation(imageToUse!)!
                
                SendBird.uploadFile(imageFileData, type: "image/jpg", hasSizeOfFile: UInt(imageFileData.length), withCustomField: "", uploadBlock: { (fileInfo, error) -> Void in
                    self.openImagePicker = false
                    SendBird.sendFile(fileInfo)
                    self.setIndicatorHidden(true)
                })
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true) { () -> Void in
            self.openImagePicker = false
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.scrollToBottomWithReloading(false, force: true, animated: false)
        let message: String = textField.text!
        if message.characters.count > 0 {
            SendBird.typeEnd()
            textField.text = ""
            let messageId: String = NSUUID.init().UUIDString
            SendBird.sendMessage(message, withTempId: messageId)
        }
        
        return true
    }
    
    func reloadCell(indexPath: NSIndexPath) {
        
    }
}
