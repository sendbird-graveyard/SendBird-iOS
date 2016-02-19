//
//  ChattingTableViewController.swift
//  SendBirdSampleUI
//
//  Created by Jed Kyung on 2/1/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

import UIKit
import MobileCoreServices
import SendBirdSDK

class ChattingTableViewController: UIViewController, ChatMessageInputViewDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    let kMessageCellIdentifier: String = "MessageReuseIdentifier"
    let kFileLinkCellIdentifier: String = "FileLinkReuseIdentifier"
    let kSystemMessageCellIdentifier: String = "SystemMessageReuseIdentifier"
    let kFileMessageCellIdentifier: String = "FileMessageReuseIdentifier"
    let kBroadcastMessageCellIdentifier: String = "BroadcastMessageReuseIdentifier"
    let kStructuredMessageCellIdentifier: String = "StructuredMessageReuseIdentifier"
    
    let kActionSheetTagUrl: Int = 0
    let kActionSheetTagImage: Int = 1
    let kActionSheetTagStructuredMessage: Int = 2
    let kActionSheetTagMessage: Int = 3
    
    var container: UIView?
    var tableView: UITableView?
    var messageInputView: ChatMessageInputView?
    var channelUrl: String = ""
    var openImagePicker: Bool = false
    var indicatorView: IndicatorView?
    var channelListTableView: ChannelListTableView?
    var titleLabel: UILabel?
    var userId: String = ""
    var userName: String = ""
    
    private var bottomMargin: NSLayoutConstraint?
    private var messageArray: Array<SendBirdMessageModel>?
    private var viewMode: Int = kChannelListViewMode
    private var viewLoaded: Bool = false
    private var mMaxMessageTs: Int64 = Int64.min
    private var mMinMessageTs: Int64 = Int64.max

    private var updateMessageTs: ((model: SendBirdMessageModel!) -> Void)!
    private var scrolling: Bool = false
    private var pastMessageLoading: Bool = false
    private var endDragging: Bool = false
    
    private var cellHeight: NSMutableDictionary?

    private var messageSizingTableViewCell: MessageTableViewCell?
    private var fileLinkSizingTableViewCell: FileLinkTableViewCell?
    private var systemMessageSizingTableViewCell: SystemMessageTableViewCell?
    private var fileMessageSizingTableViewCell: FileMessageTableViewCell?
    private var broadcastMessageSizingTableViewCell: BroadcastMessageTableViewCell?
    
    private var imageCache: Array<AnyObject>?
    private var messageSender: SendBirdSender?

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        viewMode = kChattingViewMode
        viewLoaded = false
        clearMessageTss()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func clearMessageTss() {
        mMaxMessageTs = Int64.min
        mMinMessageTs = Int64.max
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barTintColor = SendBirdUtils.UIColorFromRGB(0x824096)
        self.navigationController?.navigationBar.translucent = false
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "_btn_setting"), style: UIBarButtonItemStyle.Plain, target: self, action: "aboutSendBird:")
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "_btn_close"), style: UIBarButtonItemStyle.Plain, target:self, action: "dismissModal:")
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
        if viewLoaded {
            if viewMode == kChattingViewMode {
                startChatting()
            }
            else if viewMode == kChannelListViewMode {
                clickChannelListButton()
            }
        }
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
    
    func setViewMode(mode: Int) {
        viewMode = mode
    }

    func initChannelTitle() {
        self.titleLabel?.text = "Loading"
    }
    
    func updateChannelTitle() {
        self.titleLabel?.text = String.init(format: "#%@", SendBirdUtils.getChannelNameFromUrl(self.channelUrl))
    }
    
    override func viewDidLoad() {
        viewLoaded = true
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
        
        self.titleLabel = UILabel.init(frame: CGRectMake(0, 0, 200, 44))
        self.titleLabel?.text = self.title
        self.titleLabel?.sizeThatFits(CGSizeMake(200, 44))
        self.titleLabel?.font = UIFont.boldSystemFontOfSize(17.0)
        self.titleLabel?.textColor = UIColor.whiteColor()
        self.titleLabel?.textAlignment = NSTextAlignment.Center
        
        self.navigationItem.titleView = self.titleLabel
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        self.openImagePicker = false
        self.initViews()
        self.channelListTableView!.viewDidLoad()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func setIndicatorHidden(hidden: Bool) {
        self.indicatorView?.hidden = hidden
    }

    private func startMessagingWithUser(targetUserId: String) {
        let viewController: MessagingTableViewController = MessagingTableViewController()
        viewController.setViewMode(kMessagingViewMode)
        viewController.initChannelTitle()
        viewController.channelUrl = ""
        viewController.userName = self.userName
        viewController.userId = self.userId
        viewController.targetUserId = targetUserId
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    
    func startChatting() {
        scrolling = false
        pastMessageLoading = true
        endDragging = false
        
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
        
        SendBird.loginWithUserId(self.userId, andUserName: self.userName)
        if self.viewMode == kChattingViewMode {
            SendBird.joinChannel(self.channelUrl)
        }
        SendBird.setEventHandlerConnectBlock({ (channel) -> Void in
                self.setIndicatorHidden(true)
                self.messageInputView!.setInputEnable(true)
                self.updateChannelTitle()
            }, errorBlock: { (code) -> Void in
                self.updateChannelTitle()
                self.setIndicatorHidden(true)
            }, channelLeftBlock: { (channel) -> Void in
                
            }, messageReceivedBlock: { (message) -> Void in
                self.updateChannelTitle()
                self.messageArray?.addSendBirdMessage(message, updateMessageTs: self.updateMessageTs)
                self.setIndicatorHidden(true)
            }, systemMessageReceivedBlock: { (message) -> Void in
                self.updateChannelTitle()
                self.messageArray?.addSendBirdMessage(message, updateMessageTs: self.updateMessageTs)
                self.scrollToBottomWithReloading(true, force: false, animated: false)
                self.setIndicatorHidden(true)
            }, broadcastMessageReceivedBlock: { (message) -> Void in
                self.updateChannelTitle()
                self.messageArray?.addSendBirdMessage(message, updateMessageTs: self.updateMessageTs)
                self.scrollToBottomWithReloading(true, force: false, animated: false)
                self.setIndicatorHidden(true)
            }, fileReceivedBlock: { (fileLink) -> Void in
                self.updateChannelTitle()
                self.messageArray?.addSendBirdMessage(fileLink, updateMessageTs: self.updateMessageTs)
                self.scrollToBottomWithReloading(true, force: false, animated: false)
                self.setIndicatorHidden(true)
            }, messagingStartedBlock: { (channel) -> Void in
                
            }, messagingUpdatedBlock: { (channel) -> Void in
                
            }, messagingEndedBlock: { (channel) -> Void in
                
            }, allMessagingEndedBlock: { () -> Void in
                
            }, messagingHiddenBlock: { (channel) -> Void in
                
            }, allMessagingHiddenBlock: { () -> Void in
                
            }, readReceivedBlock: { (status) -> Void in
                
            }, typeStartReceivedBlock: { (status) -> Void in
                
            }, typeEndReceivedBlock: { (status) -> Void in
                
            }, allDataReceivedBlock: { (sendBirdDataType, count) -> Void in
                self.scrollToBottomWithReloading(true, force: false, animated: false)
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
        
        if self.viewMode == kChattingViewMode {
            SendBird.queryMessageListInChannel(SendBird.getChannelUrl()).prevWithMessageTs(Int64.max, andLimit: 50, resultBlock: { (queryResult) -> Void in
                self.mMaxMessageTs = Int64.min
                for model in queryResult {
                    self.messageArray?.addSendBirdMessage(model as! SendBirdMessageModel, updateMessageTs: self.updateMessageTs)

                    if self.mMaxMessageTs < (model as! SendBirdMessageModel).getMessageTimestamp() {
                        self.mMaxMessageTs = (model as! SendBirdMessageModel).getMessageTimestamp()
                    }
                }
                self.tableView?.reloadData()
                if self.messageArray?.count > 0 {
                    self.tableView?.scrollToRowAtIndexPath(NSIndexPath.init(forRow: self.messageArray!.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                }
                SendBird.connectWithMessageTs(self.mMaxMessageTs)
                }, endBlock: { (error) -> Void in
                    
            })
        }
    }

    private func scrollToBottomWithReloading(reload: Bool, force: Bool, animated: Bool) {
        if reload {
            self.tableView?.reloadData()
        }
        
        if self.scrolling {
            return
        }
        
        if self.messageArray == nil {
            return
        }
        
        if self.pastMessageLoading || self.isScrollBottom() || force {
            let msgCount: Int = (self.messageArray?.count)!
            if msgCount > 0 {
                self.tableView?.scrollToRowAtIndexPath(NSIndexPath.init(forRow: msgCount - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
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
    
    private func initViews() {
        self.view.backgroundColor = UIColor.clearColor()
        self.view.opaque = false
        
        self.tableView = UITableView()
        self.tableView?.translatesAutoresizingMaskIntoConstraints = false
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.separatorColor = UIColor.clearColor()
        self.tableView?.backgroundColor = SendBirdUtils.UIColorFromRGB(0xf0f1f2)
        self.tableView?.contentInset = UIEdgeInsetsMake(6, 0, 6, 0)
        self.tableView?.bounces = false
        
        self.tableView?.registerClass(MessageTableViewCell.self, forCellReuseIdentifier: kMessageCellIdentifier)
        self.tableView?.registerClass(SystemMessageTableViewCell.self, forCellReuseIdentifier: kSystemMessageCellIdentifier)
        self.tableView?.registerClass(FileLinkTableViewCell.self, forCellReuseIdentifier: kFileLinkCellIdentifier)
        self.tableView?.registerClass(FileMessageTableViewCell.self, forCellReuseIdentifier: kFileMessageCellIdentifier)
        self.tableView?.registerClass(BroadcastMessageTableViewCell.self, forCellReuseIdentifier: kBroadcastMessageCellIdentifier)
        self.view.addSubview(self.tableView!)
        
        self.messageSizingTableViewCell = MessageTableViewCell()
        self.messageSizingTableViewCell?.translatesAutoresizingMaskIntoConstraints = false
        self.messageSizingTableViewCell?.hidden = true
        self.view.addSubview(self.messageSizingTableViewCell!)
        
        self.fileLinkSizingTableViewCell = FileLinkTableViewCell()
        self.fileLinkSizingTableViewCell?.translatesAutoresizingMaskIntoConstraints = false
        self.fileLinkSizingTableViewCell?.hidden = true
        self.view.addSubview(self.fileLinkSizingTableViewCell!)
        
        self.fileMessageSizingTableViewCell = FileMessageTableViewCell()
        self.fileMessageSizingTableViewCell?.translatesAutoresizingMaskIntoConstraints = false
        self.fileMessageSizingTableViewCell?.hidden = true
        self.view.addSubview(self.fileMessageSizingTableViewCell!)
        
        self.broadcastMessageSizingTableViewCell = BroadcastMessageTableViewCell()
        self.broadcastMessageSizingTableViewCell?.translatesAutoresizingMaskIntoConstraints = false
        self.broadcastMessageSizingTableViewCell?.hidden = true
        self.view.addSubview(self.broadcastMessageSizingTableViewCell!)
        
        self.messageInputView = ChatMessageInputView()
        self.messageInputView?.translatesAutoresizingMaskIntoConstraints = false
        self.messageInputView?.delegate = self
        self.messageInputView?.textFieldDelegate = self
        self.view.addSubview(self.messageInputView!)
        
        self.channelListTableView = ChannelListTableView()
        self.channelListTableView?.translatesAutoresizingMaskIntoConstraints = false
        self.channelListTableView?.hidden = true
        self.channelListTableView?.chattingTableViewController = self
        self.view.addSubview(self.channelListTableView!)
        
        self.indicatorView = IndicatorView()
        self.indicatorView?.translatesAutoresizingMaskIntoConstraints = false
        self.indicatorView?.hidden = true
        self.view.addSubview(self.indicatorView!)
        
        applyConstraints()
    }

    private func applyConstraints() {
        self.view.addConstraint(NSLayoutConstraint.init(item: self.tableView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.tableView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.tableView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.tableView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.messageInputView!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint.init(item: self.messageInputView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.messageInputView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.bottomMargin = NSLayoutConstraint.init(item: self.messageInputView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        self.view.addConstraint(self.bottomMargin!)
        self.view.addConstraint(NSLayoutConstraint.init(item: self.messageInputView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 44))
        
        self.view.addConstraint(NSLayoutConstraint.init(item: self.channelListTableView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.channelListTableView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.messageInputView!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.channelListTableView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.channelListTableView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint.init(item: self.indicatorView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.indicatorView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.indicatorView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.indicatorView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
    }
    
    func keyboardWillShow(notif: NSNotification) {
        let keyboardInfo: NSDictionary = notif.userInfo!
        let keyboardFrameEndRect: CGRect = (keyboardInfo.valueForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue)!
        bottomMargin?.constant = -keyboardFrameEndRect.size.height
        self.view.updateConstraints()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.scrollToBottomWithReloading(false, force: false, animated: false)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        bottomMargin?.constant = 0
        self.view.updateConstraints()
        self.scrollToBottomWithReloading(false, force: false, animated: false)
    }
    
    private func clearPreviousChatting() {
        self.messageArray?.removeAll()
        self.tableView?.reloadData()
        self.scrolling = false
        self.pastMessageLoading = true
        self.endDragging = false
    }

    // MARK: UIScrollViewDelegate
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.scrolling = true
    }

    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.scrolling = false
    }
    
    private func isScrollBottom() -> Bool {
        let offset: CGPoint = self.tableView!.contentOffset
        let bounds: CGRect = self.tableView!.bounds
        let size: CGSize = self.tableView!.contentSize
        let inset: UIEdgeInsets = self.tableView!.contentInset
        let y: Float = Float(offset.y) + Float(bounds.size.height) - Float(inset.bottom)
        let h: Float = Float(size.height)
        
        if y >= (h - 160) {
            return true
        }
        return false
    }
    
    private func didTapOnTableView(sender: AnyObject?) {
        self.messageInputView?.hideKeyboard()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 && self.endDragging == true {
            SendBird.queryMessageListInChannel(SendBird.getChannelUrl()).prevWithMessageTs(self.mMinMessageTs, andLimit: 30, resultBlock: { (queryResult) -> Void in
                NSLog("MinMessageTs: %lu", self.mMinMessageTs)
                for model in queryResult {
                    self.messageArray?.addSendBirdMessage(model as! SendBirdMessageModel, updateMessageTs: self.updateMessageTs)
                }
                self.tableView?.reloadData()
                self.tableView?.scrollToRowAtIndexPath(NSIndexPath.init(forRow: queryResult.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                }, endBlock: { (error) -> Void in
                    
            })
            self.endDragging = false
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.endDragging = true
    }
    
    // MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.messageArray != nil {
            return (self.messageArray?.count)!
        }
        else {
            return 0
        }
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        if self.messageArray![indexPath.row].isKindOfClass(SendBirdMessage) {
            cell = tableView.dequeueReusableCellWithIdentifier(kMessageCellIdentifier)
        }
        else if self.messageArray![indexPath.row].isKindOfClass(SendBirdFileLink) {
            cell = tableView.dequeueReusableCellWithIdentifier(kFileLinkCellIdentifier)
        }
        else if self.messageArray![indexPath.row].isKindOfClass(SendBirdBroadcastMessage) {
            cell = tableView.dequeueReusableCellWithIdentifier(kBroadcastMessageCellIdentifier)
        }
        else if self.messageArray![indexPath.row].isKindOfClass((SendBirdSystemMessage)) {
            cell = tableView.dequeueReusableCellWithIdentifier(kSystemMessageCellIdentifier)
        }
        else {
            cell = nil
        }
        
        if cell == nil {
            if self.messageArray![indexPath.row].isKindOfClass(SendBirdMessage) {
                cell = MessageTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kMessageCellIdentifier)
            }
            else if self.messageArray![indexPath.row].isKindOfClass(SendBirdFileLink) {
                let fileLink: SendBirdFileLink = self.messageArray![indexPath.row] as! SendBirdFileLink
                if fileLink.fileInfo.type.hasPrefix("image") == true {
                    cell = FileLinkTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kFileLinkCellIdentifier)
                }
                else {
                    cell = FileMessageTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kFileMessageCellIdentifier)
                }

            }
            else if self.messageArray![indexPath.row].isKindOfClass(SendBirdBroadcastMessage) {
                cell = BroadcastMessageTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kBroadcastMessageCellIdentifier)
            }
            else if self.messageArray![indexPath.row].isKindOfClass((SendBirdSystemMessage)) {
                cell = BroadcastMessageTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kBroadcastMessageCellIdentifier)
            }
            else {
                cell = nil
            }
        }
        else {
            if self.messageArray![indexPath.row].isKindOfClass(SendBirdMessage) {
                (cell as! MessageTableViewCell).setModel(self.messageArray![indexPath.row] as! SendBirdMessage)
            }
            else if self.messageArray![indexPath.row].isKindOfClass(SendBirdFileLink) {
                let fileLink: SendBirdFileLink = self.messageArray![indexPath.row] as! SendBirdFileLink
                if fileLink.fileInfo.type.hasPrefix("image") == true {
                    cell = FileLinkTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kFileLinkCellIdentifier)
                    (cell as! FileLinkTableViewCell).setModel(fileLink)
                }
                else {
                    cell = FileMessageTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: kFileMessageCellIdentifier)
                    (cell as! FileMessageTableViewCell).setModel(fileLink)
                }
            }
            else {
                (cell as! SystemMessageTableViewCell).setModel(self.messageArray![indexPath.row] as! SendBirdSystemMessage)
            }
        }
        
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var calculatedHeight: CGFloat = 0

        if self.cellHeight?.objectForKey(NSNumber.init(integer: Int(indexPath.row))) != nil && self.cellHeight?.objectForKey(NSNumber.init(integer: Int(indexPath.row)))?.floatValue > 0 {
            var ts: Int64 = 0
            if self.messageArray![indexPath.row].isKindOfClass(SendBirdMessage) == true {
                ts = (self.messageArray![indexPath.row] as! SendBirdMessage).getMessageTimestamp()
            }
            else if self.messageArray![indexPath.row].isKindOfClass(SendBirdBroadcastMessage) == true {
                ts = (self.messageArray![indexPath.row] as! SendBirdBroadcastMessage).getMessageTimestamp()
            }
            else if self.messageArray![indexPath.row].isKindOfClass(SendBirdFileLink) == true {
                ts = (self.messageArray![indexPath.row] as! SendBirdFileLink).getMessageTimestamp()
            }

            calculatedHeight = CGFloat(((self.cellHeight!.objectForKey(NSNumber.init(longLong: ts)))?.floatValue)!)
        } else {
            var ts: Int64 = 0
            if self.messageArray![indexPath.row].isKindOfClass(SendBirdMessage) == true {
                self.messageSizingTableViewCell?.setModel(self.messageArray![indexPath.row] as! SendBirdMessage)
                calculatedHeight = (self.messageSizingTableViewCell?.getHeightOfViewCell(self.view.frame.size.width))!
                ts = (self.messageArray![indexPath.row] as! SendBirdMessage).getMessageTimestamp()
            }
            else if self.messageArray![indexPath.row].isKindOfClass(SendBirdBroadcastMessage) == true {
                self.broadcastMessageSizingTableViewCell?.setModel(self.messageArray![indexPath.row] as! SendBirdBroadcastMessage)
                calculatedHeight = (self.broadcastMessageSizingTableViewCell?.getHeightOfViewCell(self.view.frame.size.width))!
                ts = (self.messageArray![indexPath.row] as! SendBirdBroadcastMessage).getMessageTimestamp()
            }
            else if self.messageArray![indexPath.row].isKindOfClass(SendBirdFileLink) == true {
                let fileLink: SendBirdFileLink = self.messageArray![indexPath.row] as! SendBirdFileLink
                if ((fileLink.fileInfo?.type.hasPrefix("image")) != nil) {
                    self.fileLinkSizingTableViewCell?.setModel(fileLink)
                    calculatedHeight = (self.fileLinkSizingTableViewCell?.getHeightOfViewCell(self.view.frame.size.width))!
                }
                else {
                    self.fileMessageSizingTableViewCell?.setModel(fileLink)
                    calculatedHeight = (self.fileMessageSizingTableViewCell?.getHeightOfViewCell(self.view.frame.size.width))!
                }
                ts = (self.messageArray![indexPath.row] as! SendBirdFileLink).getMessageTimestamp()
            }
            else {
                calculatedHeight = 32
            }
            
            self.cellHeight?.setObject(NSNumber.init(float: Float(calculatedHeight)), forKey: NSNumber.init(integer: Int(ts)))
        }

        return calculatedHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        messageInputView?.hideKeyboard()
        
        if self.messageArray![indexPath.row].isKindOfClass(SendBirdMessage) {
            let message: SendBirdMessage = self.messageArray![indexPath.row] as! SendBirdMessage
            let msgString: String = message.message
            let url: String = SendBirdUtils.getUrlFromstring(msgString)
            
            if url.characters.count > 0 {
                self.clickURL(url, sender: message.sender)
            }
            else {
                self.clickMessage(message.sender)
            }
        }
        else if self.messageArray![indexPath.row].isKindOfClass(SendBirdFileLink) {
            let fileLink: SendBirdFileLink = self.messageArray![indexPath.row] as! SendBirdFileLink
            if fileLink.fileInfo.type.hasPrefix("image") {
                self.clickImage(fileLink.fileInfo.url, sender: fileLink.sender)
            }
        }
    }
    
    private func clickMessage(sender: SendBirdSender) {
        let openMessaging: String = String.init(format: "Open Messaging with %@", sender.name)
        self.messageSender = sender
        if self.messageSender?.guestId == SendBird.getUserId() {
            return
        }
        let closeButtonText: String = "Close"
        let alert: UIAlertController = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let openMessagingAction: UIAlertAction = UIAlertAction.init(title: openMessaging, style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.startMessagingWithUser((self.messageSender?.guestId)!)
        }
        let closeAction: UIAlertAction = UIAlertAction.init(title: closeButtonText, style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(openMessagingAction)
        alert.addAction(closeAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func clickURL(url: String, sender: SendBirdSender) {
        self.messageSender = sender
        let closeButtonText: String = "Close"
        let openMessaging: String = String.init(format: "Open Messaging with %@", sender.name)
        let alert: UIAlertController = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let openLinkAction: UIAlertAction = UIAlertAction.init(title: "Open Link in Safari", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            let encodedUrl: String = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
            UIApplication.sharedApplication().openURL(NSURL.init(string: encodedUrl)!)
        }
        let closeAction: UIAlertAction = UIAlertAction.init(title: closeButtonText, style: UIAlertActionStyle.Cancel, handler: nil)
        
        if self.messageSender?.guestId != SendBird.getUserId() {
            let openMessagingAction: UIAlertAction = UIAlertAction.init(title: openMessaging, style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                self.startMessagingWithUser((self.messageSender?.guestId)!)
            }
            alert.addAction(openMessagingAction)
        }
        
        alert.addAction(openLinkAction)
        alert.addAction(closeAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func clickImage(url: String, sender: SendBirdSender) {
        self.messageSender = sender
        let closeButtonText: String = "Close"
        let openMessaging: String = String.init(format: "Open Messaging with %@", sender.name)
        let alert: UIAlertController = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let openLinkAction: UIAlertAction = UIAlertAction.init(title: "See Image in Safari", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            let encodedUrl: String = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
            UIApplication.sharedApplication().openURL(NSURL.init(string: encodedUrl)!)
        }
        let closeAction: UIAlertAction = UIAlertAction.init(title: closeButtonText, style: UIAlertActionStyle.Cancel, handler: nil)
        
        if self.messageSender?.guestId != SendBird.getUserId() {
            let openMessagingAction: UIAlertAction = UIAlertAction.init(title: openMessaging, style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                self.startMessagingWithUser((self.messageSender?.guestId)!)
            }
            alert.addAction(openMessagingAction)
        }
        
        alert.addAction(openLinkAction)
        alert.addAction(closeAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: ChatMessageInputViewDelegate
    func clickSendButton(message: String) {
        self.scrollToBottomWithReloading(true, force: true, animated: false)
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
        if self.channelListTableView?.hidden == true {
            self.titleLabel?.text = "Channels"
            self.channelListTableView?.hidden = false
            self.channelListTableView?.reloadChannels()
            self.messageInputView?.setInputEnable(false)
            SendBird.disconnect()
        }
        else {
            self.channelListTableView?.hidden = true
            self.messageInputView?.setInputEnable(true)
            SendBird.connect()
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
        self.scrollToBottomWithReloading(true, force: true, animated: false)
        let message: String = textField.text!
        if message.characters.count > 0 {
            textField.text = ""
            let messageId: String = NSUUID.init().UUIDString
            SendBird.sendMessage(message, withTempId: messageId)
        }
        
        return true
    }
}
