//
//  GroupChannelChattingViewController.swift
//  SendBird-iOS-LocalCache-Sample-swift
//
//  Created by Jed Kyung on 10/10/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import SendBirdSyncManager
import AVKit
import AVFoundation
import MobileCoreServices
import Photos
import NYTPhotoViewer
import HTMLKit
import FLAnimatedImage

class GroupChannelChattingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChattingViewDelegate, MessageDelegate, SBSMMessageCollectionDelegate {
    var channel: SBDGroupChannel
    let targetLanguages: [String] = ["ar", "de", "fr", "nl", "ja", "ko", "pt", "es", "zh-CHS"]
    
    @IBOutlet weak var chattingView: ChattingView?
    @IBOutlet weak var navItem: UINavigationItem?
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    @IBOutlet weak var imageViewerLoadingView: UIView!
    @IBOutlet weak var imageViewerLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageViewerLoadingViewNavItem: UINavigationItem!
    
    private let delegateIdentifier: String = UUID.init().uuidString
    
    private var isLoading: Bool = false
    private var keyboardShown: Bool = false
    
    private var photosViewController: NYTPhotosViewController?
    @IBOutlet weak var navigationBarHeight: NSLayoutConstraint!
    
    let tableViewQueue: SBSMOperationQueue = SBSMOperationQueue.init()
    
    /**
     *  new properties for local cache
     */
    private var collection: SBSMMessageCollection?
    private var messageCollection: SBSMMessageCollection? {
        if self.collection == nil {
            let filter: SBSMMessageFilter = SBSMMessageFilter.init()
            let lastSeenAt: Int64? = UserPreferences.lastSeenAt(channelUrl: self.channel.channelUrl)
            self.collection = SBSMMessageCollection.init(channel: self.channel, filter: filter, viewpointTimestamp: lastSeenAt ?? LONG_LONG_MAX)
        }
        return self.collection
    }

    init(channel: SBDGroupChannel) {
        self.channel = channel
        super.init(nibName: String(describing: GroupChannelChattingViewController.self), bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configure()
        
        self.isLoading = true
        self.messageCollection?.delegate = self
        self.messageCollection?.fetch(in: .previous, completionHandler: { (error) in
            self.isLoading = false
        })
        
        self.messageCollection?.fetch(in: .next, completionHandler: nil)
    }
    
    private func configure() -> Void {
        let titleView: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 100, height: 64))
        let mainTitle: String = "Group Channel (\(self.channel.memberCount))"
        titleView.attributedText = Utils.generateNavigationTitle(mainTitle: mainTitle, subTitle: "")
        titleView.numberOfLines = 2
        titleView.textAlignment = NSTextAlignment.center
        
        let titleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickReconnect))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(titleTapRecognizer)
        
        self.navItem?.titleView = titleView
        
        // left
        let negativeLeftSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        negativeLeftSpacer.width = -2
        let leftCloseItem = UIBarButtonItem(image: UIImage(named: "btn_close"), style: UIBarButtonItem.Style.done, target: self, action: #selector(close))
        self.navItem?.leftBarButtonItems = [negativeLeftSpacer, leftCloseItem]
        
        // right
        let negativeRightSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        negativeRightSpacer.width = -2
        let rightOpenMoreMenuItem = UIBarButtonItem(image: UIImage(named: "btn_more"), style: UIBarButtonItem.Style.done, target: self, action: #selector(showMoreMenu))
        self.navItem?.rightBarButtonItems = [negativeRightSpacer, rightOpenMoreMenuItem]
        
        self.chattingView?.configureChattingView(channel: self.channel)
        self.chattingView?.fileAttachButton.addTarget(self, action: #selector(selectFileAttachment), for: UIControl.Event.touchUpInside)
        self.chattingView?.sendButton.addTarget(self, action: #selector(sendMessage), for: UIControl.Event.touchUpInside)
        self.chattingView?.delegate = self
    }
    
    deinit {
        if let view: ChattingView = self.chattingView {
            view.delegate = nil
        }
        self.messageCollection?.delegate = nil
        self.messageCollection?.remove()
        self.collection = nil
        SBDMain.removeChannelDelegate(forIdentifier: self.delegateIdentifier)
    }

    @objc private func keyboardDidShow(notification: Notification) {
        self.keyboardShown = true
        let keyboardFrameBegin = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey]
        let keyboardFrameBeginRect = (keyboardFrameBegin as! NSValue).cgRectValue
        DispatchQueue.main.async {
            self.bottomMargin.constant = keyboardFrameBeginRect.size.height
            self.view.layoutIfNeeded()
            self.chattingView?.stopMeasuringVelocity = true
            self.chattingView?.scrollToBottom(force: false)
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification) {
        self.keyboardShown = false
        DispatchQueue.main.async {
            self.bottomMargin.constant = 0
            self.view.layoutIfNeeded()
            self.chattingView?.scrollToBottom(force: false)
        }
    }
    
    @objc private func close() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc private func showMoreMenu() {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let seeMemberListAction = UIAlertAction(title: "Members", style: UIAlertAction.Style.default) { (action) in
            DispatchQueue.main.async {
                let mlvc: MemberListViewController = MemberListViewController(nibName: "MemberListViewController", bundle: Bundle.main)
                mlvc.channel = self.channel
                self.present(mlvc, animated: false, completion: nil)
            }
        }
        let inviteUserListAction = UIAlertAction(title: "Invite", style: UIAlertAction.Style.default) { (action) in
            DispatchQueue.main.async {
                let vc = CreateGroupChannelUserListViewController(nibName: "CreateGroupChannelUserListViewController", bundle: Bundle.main)
                vc.userSelectionMode = 1
                vc.groupChannel = self.channel
                self.present(vc, animated: false, completion: nil)
            }
        }
        
        let resetManager = UIAlertAction(title: "Reset Message List", style: UIAlertAction.Style.default) { (_) in
            self.messageCollection?.resetViewpointTimestamp(UserPreferences.lastSeenAt(channelUrl: self.channel.channelUrl) ?? LONG_LONG_MAX)
        }
        vc.addAction(resetManager)
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: nil)
        vc.addAction(seeMemberListAction)
        vc.addAction(inviteUserListAction)
        vc.addAction(closeAction)
        
        self.present(vc, animated: true, completion: nil)
    }
    
    private func sendUrlPreview(url: URL, message: String, aTempModel: OutgoingGeneralUrlPreviewTempModel) {
        let previewUrl = url
        let request = URLRequest(url: url)
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                self.sendMessageWithReplacement(replacement: aTempModel)
                session.invalidateAndCancel()
                
                return
            }
            
            let httpResponse: HTTPURLResponse = response as! HTTPURLResponse
            let contentType: String = httpResponse.allHeaderFields["Content-Type"] as! String
            if contentType.contains("text/html") {
                let htmlBody: NSString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                
                let parser: HTMLParser = HTMLParser(string: htmlBody as String)
                let document = parser.parseDocument()
                let head = document.head
                
                var title: String?
                var desc: String?
                
                var ogUrl: String?
                var ogSiteName: String?
                var ogTitle: String?
                var ogDesc: String?
                var ogImage: String?
                
                var twtSiteName: String?
                var twtTitle: String?
                var twtDesc: String?
                var twtImage: String?
                
                var finalUrl: String?
                var finalTitle: String?
                var finalSiteName: String?
                var finalDesc: String?
                var finalImage: String?
                
                for node in (head?.childNodes)! {
                    if node is HTMLElement {
                        let element: HTMLElement = node as! HTMLElement
                        if element.attributes["property"] != nil {
                            if ogUrl == nil && element.attributes["property"] as! String == "og:url" {
                                ogUrl = element.attributes["property"] as? String
                            }
                            else if ogSiteName == nil && element.attributes["property"] as! String == "og:site_name" {
                                ogSiteName = element.attributes["content"] as? String
                            }
                            else if ogTitle == nil && element.attributes["property"] as! String == "og:title" {
                                ogTitle = element.attributes["content"] as? String
                            }
                            else if ogDesc == nil && element.attributes["property"] as! String == "og:description" {
                                ogDesc = element.attributes["content"] as? String
                            }
                            else if ogImage == nil && element.attributes["property"] as! String == "og:image" {
                                ogImage = element.attributes["content"] as? String
                            }
                        }
                        else if element.attributes["name"] != nil {
                            if twtSiteName == nil && element.attributes["name"] as! String == "twitter:site" {
                                twtSiteName = element.attributes["content"] as? String
                            }
                            else if twtTitle == nil && element.attributes["name"] as! String == "twitter:title" {
                                twtTitle = element.attributes["content"] as? String
                            }
                            else if twtDesc == nil && element.attributes["name"] as! String == "twitter:description" {
                                twtDesc = element.attributes["content"] as? String
                            }
                            else if twtImage == nil && element.attributes["name"] as! String == "twitter:image" {
                                twtImage = element.attributes["content"] as? String
                            }
                            else if desc == nil && element.attributes["name"] as! String == "description" {
                                desc = element.attributes["content"] as? String
                            }
                        }
                        else if element.tagName == "title" {
                            if element.childNodes.count > 0 {
                                if element.childNodes[0] is HTMLText {
                                    title = (element.childNodes[0] as! HTMLText).data
                                }
                            }
                        }
                    }
                }
                
                if ogUrl != nil {
                    finalUrl = ogUrl
                }
                else {
                    finalUrl = previewUrl.absoluteString
                }
                
                if ogSiteName != nil {
                    finalSiteName = ogSiteName
                }
                else if twtSiteName != nil {
                    finalSiteName = twtSiteName
                }
                
                if ogTitle != nil {
                    finalTitle = ogTitle
                }
                else if twtTitle != nil {
                    finalTitle = twtTitle
                }
                else if title != nil {
                    finalTitle = title
                }
                
                if ogDesc != nil {
                    finalDesc = ogDesc
                }
                else if twtDesc != nil {
                    finalDesc = twtDesc
                }
                
                if ogImage != nil {
                    finalImage = ogImage
                }
                else if twtImage != nil {
                    finalImage = twtImage
                }
                
                if !(finalSiteName == nil || finalTitle == nil || finalDesc == nil) {
                    var data:[String:String] = [:]
                    data["site_name"] = finalSiteName
                    data["title"] = finalTitle
                    data["description"] = finalDesc
                    if finalImage != nil {
                        data["image"] = finalImage
                    }
                    
                    if finalUrl != nil {
                        data["url"] = finalUrl
                    }
                    
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.init(rawValue: 0))
                        let dataString = String(data: jsonData, encoding: String.Encoding.utf8)
                        
                        let theParams: SBDUserMessageParams? = SBDUserMessageParams.init(message: message)
                        guard let params: SBDUserMessageParams = theParams else {
                            return
                        }
                        params.data = dataString
                        params.customType = "url_preview"
                        self.channel.sendUserMessage(with: params, completionHandler: { (theMessage, theError) in
                            guard let message: SBDUserMessage = theMessage, let _: SBDError = theError else {
                                self.sendMessageWithReplacement(replacement: aTempModel)
                                return
                            }
                            
                            self.messageCollection?.appendMessage(message)
                            self.chattingView?.scrollToBottom(force: true)
                        })
                    }
                    catch {}
                }
                else {
                    self.sendMessageWithReplacement(replacement: aTempModel)
                }
            }
            
            session.invalidateAndCancel()
        }
        
        task.resume()
    }
    
    // MARK: Message Collection Delegate
    func collection(_ collection: SBSMMessageCollection, didReceiveEvent action: SBSMMessageEventAction, messages: [SBDBaseMessage]) {
        guard collection == self.messageCollection, messages.count > 0 else {
            return
        }
        
        var operation: SBSMOperation?
        operation = self.tableViewQueue.enqueue({
            let handler = {() -> Void in
                operation?.complete()
            }
            
            switch action {
            case SBSMMessageEventAction.insert:
                self.chattingView?.insert(messages: messages, collection: collection, completionHandler: {
                    UserPreferences.setLastSeenAt(channelUrl: self.channel.channelUrl, lastSeenAt: self.chattingView?.messages.last?.createdAt ?? 0)
                    handler()
                    
                    if Utils.isTopViewController(viewController: self) {
                        self.channel.markAsRead()
                    }
                })
                break
            case SBSMMessageEventAction.update:
                self.chattingView?.update(messages: messages, completionHandler: handler)
                break
            case SBSMMessageEventAction.remove:
                self.chattingView?.remove(messages: messages, completionHandler: handler)
                break
            case SBSMMessageEventAction.clear:
                self.chattingView?.clearAllMessages(completionHandler: handler)
                break
            case SBSMMessageEventAction.none:
                break
            default:
                break
            }
        })
    }
    
    // MARK: SendBird SDK
    private func sendMessageWithReplacement(replacement: OutgoingGeneralUrlPreviewTempModel) {
        guard let text: String = replacement.message else {
            return
        }
        
        let theParams: SBDUserMessageParams? = SBDUserMessageParams.init(message: text)
        guard let params: SBDUserMessageParams = theParams else {
            return
        }
        params.targetLanguages = self.targetLanguages
        var previewMessage: SBDUserMessage?
        previewMessage = self.channel.sendUserMessage(with: params, completionHandler: { (theMessage, theError) in
            if let thePreviewMessage: SBDUserMessage = previewMessage {
                self.messageCollection?.deleteMessage(thePreviewMessage)
            }
            self.chattingView?.scrollToBottom(force: true)
            
            guard let message: SBDUserMessage = theMessage, let _: SBDError = theError else {
                return
            }
            
            self.messageCollection?.appendMessage(message)
            previewMessage = nil
        })
        
        if let thePreviewMessage: SBDUserMessage = previewMessage {
            self.messageCollection?.appendMessage(thePreviewMessage)
        }
    }
    
    @objc private func sendMessage() {
        guard let text: String = self.chattingView?.messageTextView.text, text.count > 0 else {
            return
        }
        
        self.channel.endTyping()
        self.chattingView?.messageTextView.text = ""
        
        do {
            let detector: NSDataDetector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches: [NSTextCheckingResult] = detector.matches(in: text, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, text.count))
            var theUrl: URL?
            for item in matches {
                let match = item as NSTextCheckingResult
                theUrl = match.url
                break
            }
            
            if let url: URL = theUrl {
                let tempModel: OutgoingGeneralUrlPreviewTempModel = OutgoingGeneralUrlPreviewTempModel()
                tempModel.createdAt = Int64(NSDate().timeIntervalSince1970 * 1000)
                tempModel.message = text
                
                // TODO: ??
                self.messageCollection?.appendMessage(tempModel)
                self.sendUrlPreview(url: url, message: text, aTempModel: tempModel)
                return
            }
        }
        catch {}
        
        self.chattingView?.sendButton.isEnabled = false
        let theParams: SBDUserMessageParams? = SBDUserMessageParams.init(message: text)
        guard let params: SBDUserMessageParams = theParams else {
            return
        }
        params.targetLanguages = self.targetLanguages
        var previewMessage: SBDUserMessage?
        previewMessage = self.channel.sendUserMessage(with: params, completionHandler: { (theMessage, theError) in
            if let thePreviewMessage: SBDUserMessage = previewMessage {
                self.messageCollection?.deleteMessage(thePreviewMessage)
            }
            self.chattingView?.scrollToBottom(force: true)
            
            guard let message: SBDUserMessage = theMessage, let _: SBDError = theError else {
                if let requestId: String = theMessage?.requestId {
                    self.chattingView?.resendableMessages[requestId] = theMessage
                }
                return
            }
            
            self.messageCollection?.appendMessage(message)
            previewMessage = nil
        })
        
        if let thePreviewMessage: SBDUserMessage = previewMessage {
            self.messageCollection?.appendMessage(thePreviewMessage)
        }
        self.chattingView?.sendButton.isEnabled = true
    }
    
    @objc private func selectFileAttachment() {
        let presentPicker = {
            let mediaUI = UIImagePickerController()
            mediaUI.sourceType = UIImagePickerController.SourceType.photoLibrary
            let mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
            mediaUI.mediaTypes = mediaTypes
            mediaUI.delegate = self
            self.present(mediaUI, animated: true, completion: nil)
        }
        
        guard PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized else {
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == PHAuthorizationStatus.authorized {
                    presentPicker()
                }
            }
            return
        }
        
        presentPicker()
    }
    
    @objc func clickReconnect() {
        if SBDMain.getConnectState() != SBDWebSocketConnectionState.open && SBDMain.getConnectState() != SBDWebSocketConnectionState.connecting {
            SBDMain.reconnect()
        }
    }
    
    // MARK: SBDChannelDelegate
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        guard sender === self.channel else {
            return
        }
        
        guard let typingMembers: [SBDMember] = sender.getTypingMembers(), typingMembers.count > 0 else {
            self.chattingView?.endTypingIndicator()
            return
        }
        
        if typingMembers.count == 1 {
            self.chattingView?.startTypingIndicator(text: "\(typingMembers.first?.nickname ?? "someone") is typing...")
        }
        else {
            self.chattingView?.startTypingIndicator(text: "Several people are typing...")
        }
    }
    
    func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        let vc = UIAlertController(title: "Channel has been deleted.", message: "This channel has been deleted. It will be closed.", preferredStyle: UIAlertController.Style.alert)
        let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel) { (action) in
            self.close()
        }
        vc.addAction(closeAction)
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: Chatting View Delegate
    func loadMoreMessage(view: UIView) {
        if !self.isLoading {
            self.isLoading = true
            self.messageCollection?.fetch(in: SBSMMessageDirection.previous, completionHandler: { (error) in
                self.isLoading = false
            })
        }
    }
    
    func startTyping(view: UIView) {
        self.channel.startTyping()
    }
    
    func endTyping(view: UIView) {
        self.channel.endTyping()
    }
    
    func hideKeyboardWhenFastScrolling(view: UIView) {
        if self.keyboardShown == false {
            return
        }
        
        DispatchQueue.main.async {
            self.bottomMargin.constant = 0
            self.view.layoutIfNeeded()
            self.chattingView?.scrollToBottom(force: false)
        }
        self.view.endEditing(true)
    }
    
    // MARK: MessageDelegate
    func clickProfileImage(viewCell: UITableViewCell, user: SBDUser) {
        let vc = UIAlertController(title: user.nickname, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let seeBlockUserAction = UIAlertAction(title: "Block the user", style: UIAlertAction.Style.default) { (action) in
            SBDMain.blockUser(user, completionHandler: { (blockedUser, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        let vc = UIAlertController(title: "Error", message: error?.domain, preferredStyle: UIAlertController.Style.alert)
                        let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: nil)
                        vc.addAction(closeAction)
                        DispatchQueue.main.async {
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                    
                    return
                }
                
                DispatchQueue.main.async {
                    let vc = UIAlertController(title: "User blocked", message: "\(user.nickname ?? "he") is blocked.", preferredStyle: UIAlertController.Style.alert)
                    let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: nil)
                    vc.addAction(closeAction)
                    DispatchQueue.main.async {
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            })
        }
        let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: nil)
        vc.addAction(seeBlockUserAction)
        vc.addAction(closeAction)
        
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func clickMessage(view: UIView, message: SBDBaseMessage) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: nil)
        var deleteMessageAction: UIAlertAction?
        var openURLsAction: [UIAlertAction] = []
        
        if message is SBDUserMessage {
            let userMessage = message as! SBDUserMessage
            if userMessage.customType != nil && userMessage.customType == "url_preview" {
                let data: Data = (userMessage.data?.data(using: String.Encoding.utf8)!)!
                do {
                    let previewData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.init(rawValue: 0))
                    let url: URL? = URL(string: ((previewData as! Dictionary<String, Any>)["url"] as! String))
                    let options: Dictionary<UIApplication.OpenExternalURLOptionsKey, Any> = Dictionary<UIApplication.OpenExternalURLOptionsKey, Any>()
                    if url != nil && UIApplication.shared.canOpenURL(url!) {
                        UIApplication.shared.open(url!, options: options, completionHandler: nil)
                    }
                }
                catch {
                    
                }
                
            }
            else {
                let sender = (message as! SBDUserMessage).sender
                if sender?.userId == SBDMain.getCurrentUser()?.userId {
                    deleteMessageAction = UIAlertAction(title: "Delete the message", style: UIAlertAction.Style.destructive, handler: { (action) in
                        self.channel.delete(message, completionHandler: { (error) in
                            if error != nil {
                                let alert = UIAlertController(title: "Error", message: error?.domain, preferredStyle: UIAlertController.Style.alert)
                                let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: nil)
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
                    let matches = detector.matches(in: (message as! SBDUserMessage).message!, options: [], range: NSMakeRange(0, ((message as! SBDUserMessage).message?.count)!))
                    for match in matches as [NSTextCheckingResult] {
                        let url: URL = match.url!
                        let openURLAction = UIAlertAction(title: url.relativeString, style: UIAlertAction.Style.default, handler: { (action) in
                            let options: Dictionary<UIApplication.OpenExternalURLOptionsKey, Any> = Dictionary<UIApplication.OpenExternalURLOptionsKey, Any>()
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: options, completionHandler: nil)
                            }
                        })
                        openURLsAction.append(openURLAction)
                    }
                }
                catch {
                    
                }
            }
            
        }
        else if message is SBDFileMessage {
            let fileMessage: SBDFileMessage = message as! SBDFileMessage
            let sender = fileMessage.sender
            let type = fileMessage.type
            let url = fileMessage.url
            
            if sender?.userId == SBDMain.getCurrentUser()?.userId {
                deleteMessageAction = UIAlertAction(title: "Delete the message", style: UIAlertAction.Style.destructive, handler: { (action) in
                    self.channel.delete(fileMessage, completionHandler: { (error) in
                        if error != nil {
                            let alert = UIAlertController(title: "Error", message: error?.domain, preferredStyle: UIAlertController.Style.alert)
                            let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: nil)
                            alert.addAction(closeAction)
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    })
                })
            }
            
            if type.hasPrefix("video") {
                let videoUrl = NSURL(string: url)
                let player = AVPlayer(url: videoUrl! as URL)
                let vc = AVPlayerViewController()
                vc.player = player
                self.present(vc, animated: true, completion: {
                    player.play()
                })
                
                return
            }
            else if type.hasPrefix("audio") {
                let audioUrl = NSURL(string: url)
                let player = AVPlayer(url: audioUrl! as URL)
                let vc = AVPlayerViewController()
                vc.player = player
                self.present(vc, animated: true, completion: {
                    player.play()
                })
                
                return
            }
            else if type.hasPrefix("image") {
                self.showImageViewerLoading()
                let photo = ChatImage()
                let cachedData = FLAnimatedImageView.cachedImageForURL(url: URL(string: url)!)
                if cachedData != nil {
                    photo.imageData = cachedData
                    
                    self.photosViewController = NYTPhotosViewController(photos: [photo])
                    self.present(photosViewController: self.photosViewController)
                }
                else {
                    let session = URLSession.shared
                    let request = URLRequest(url: URL(string: url)!)
                    session.dataTask(with: request, completionHandler: { (data, response, error) in
                        if error != nil {
                            self.hideImageViewerLoading()
                            
                            return
                        }
                        
                        let resp = response as! HTTPURLResponse
                        if resp.statusCode >= 200 && resp.statusCode < 300 {
                            AppDelegate.imageCache.setObject(data as AnyObject, forKey: url as AnyObject)
                            let photo = ChatImage()
                            photo.imageData = data
                            
                            self.photosViewController = NYTPhotosViewController(photos: [photo])
                            self.present(photosViewController: self.photosViewController)
                        }
                        else {
                            self.hideImageViewerLoading()
                        }
                    }).resume()
                    
                    return
                }
            }
            else {
                // TODO: Download file. Is this possible on iOS?
            }
        }
        else if message is SBDAdminMessage {
            return
        }
        
        alert.addAction(closeAction)
        
        if openURLsAction.count > 0 {
            for action in openURLsAction {
                alert.addAction(action)
            }
        }
        
        if deleteMessageAction != nil {
            alert.addAction(deleteMessageAction!)
        }
        
        if openURLsAction.count > 0 || deleteMessageAction != nil {
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func isUrlPreview(message: SBDBaseMessage) -> Bool {
        guard let userMessage: SBDUserMessage = message as? SBDUserMessage else {
            return false
        }
        return (userMessage.customType == "url_preview")
    }
    
    private func openingUrlActions(from string: String) -> [UIAlertAction] {
        var theDetector: NSDataDetector?
        do {
            theDetector = try NSDataDetector.init(types: NSTextCheckingResult.CheckingType.link.rawValue)
        }
        catch {}
        
        guard let detector: NSDataDetector = theDetector else {
            return [UIAlertAction]()
        }
        
        let range: NSRange = NSMakeRange(0, string.count)
        let matches = detector.matches(in: string,
                                       options: NSRegularExpression.MatchingOptions.init(rawValue: 0),
                                       range: range)
        var actions: [UIAlertAction] = [UIAlertAction]()
        for match in matches {
            let theUrl: URL? = match.url
            if let url: URL = theUrl {
                let action: UIAlertAction = UIAlertAction.init(title: url.relativeString, style: UIAlertAction.Style.default) { (action) in
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [UIApplication.OpenExternalURLOptionsKey : Any](), completionHandler: nil)
                    }
                }
                actions.append(action)
            }
        }
        return actions
    }
    
    private func isBeingDelivered(message: SBDBaseMessage) -> Bool {
        let theSender: SBDUser? = message.value(forKey: "sender") as? SBDUser
        let theRequestId: String? = message.value(forKey: "requestId") as? String
        if let sender: SBDUser = theSender, sender.userId == SBDMain.getCurrentUser()?.userId,
            let requestId: String = theRequestId,
            let _: SBDBaseMessage = self.chattingView?.preSendMessages[requestId] {
            return true
        }
        
        return false
    }
    
    private func isPlayable(message: SBDBaseMessage) -> Bool {
        if message is SBDFileMessage, let fileMessage: SBDFileMessage = message as? SBDFileMessage, fileMessage.type.hasPrefix("image") {
            return true
        }
        return false
    }
    
    private func isImage(message: SBDBaseMessage) -> Bool {
        if message is SBDFileMessage, let fileMessage: SBDFileMessage = message as? SBDFileMessage {
            if fileMessage.type.hasPrefix("video") || fileMessage.type.hasPrefix("audio") {
                return true
            }
        }
        return false
    }
    
    func requestDelete(message: SBDBaseMessage) -> Void {
        self.channel.delete(message) { (theError) in
            if let error: SBDError = theError {
                let errorTitle: String = "Error"
                let alert: UIAlertController = UIAlertController.init(title: errorTitle, message: error.domain, preferredStyle: UIAlertController.Style.alert)
                
                let closeTitle: String = "Close"
                let closeAction: UIAlertAction = UIAlertAction.init(title: closeTitle, style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(closeAction)
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            self.messageCollection?.deleteMessage(message)
        }
    }
    
    func present(photosViewController: NYTPhotosViewController?) -> Void {
        guard let thePhotosViewController: NYTPhotosViewController = photosViewController else {
            return
        }
        
        thePhotosViewController.rightBarButtonItems = nil
        thePhotosViewController.rightBarButtonItem = nil
        
        let leftBarSpacer: UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        let leftCloseItem: UIBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "btn_close"), style: UIBarButtonItem.Style.done, target: self, action: #selector(closeImageViewer))
        thePhotosViewController.leftBarButtonItems = [leftBarSpacer, leftCloseItem]
        DispatchQueue.main.async {
            self.present(thePhotosViewController, animated: true, completion: {
                self.hideImageViewerLoading()
            })
        }
    }
    
    func presentPhoto(url: URL) -> Void {
        self.showImageViewerLoading()
        
        let theCachedData: Data? = FLAnimatedImageView.cachedImageForURL(url: url)
        guard let cachedData: Data = theCachedData else {
            let session: URLSession = URLSession.shared
            let request: URLRequest = URLRequest.init(url: url)
            let task: URLSessionDataTask = session.dataTask(with: request) { (theData, theResponse, theError) in
                guard let _: Error = theError, let httpResponse: HTTPURLResponse = theResponse as? HTTPURLResponse, let data: Data = theData else {
                    self.hideImageViewerLoading()
                    return
                }
                
                switch (httpResponse.statusCode) {
                case 200..<300:
                    let cachedResponse: CachedURLResponse = CachedURLResponse.init(response: httpResponse, data: data)
                    AppDelegate.imageCache.setObject(cachedResponse as AnyObject, forKey: request as AnyObject)
                    
                    let photo: ChatImage = ChatImage.init()
                    photo.imageData = data
                    let photosViewController: NYTPhotosViewController = NYTPhotosViewController(photos: [photo])
                    self.photosViewController = photosViewController
                    self.present(photosViewController: photosViewController)
                default:
                    return
                }
            }
            task.resume()
            return
        }
        
        let photo: ChatImage = ChatImage.init()
        photo.imageData = cachedData
        let photosViewController: NYTPhotosViewController = NYTPhotosViewController.init(photos: [photo])
        self.photosViewController = photosViewController
        self.present(photosViewController: photosViewController)
    }
    
    func clickResend(view: UIView, message: SBDBaseMessage) {
        let vc = UIAlertController(title: "Resend Message", message: "Do you want to resend the message?", preferredStyle: UIAlertController.Style.alert)
        let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: nil)
        let resendAction = UIAlertAction(title: "Resend", style: UIAlertAction.Style.default) { (action) in
            switch (message) {
            case is SBDUserMessage:
                guard let resendableMessage: SBDUserMessage = message as? SBDUserMessage, let text: String = resendableMessage.message, let requestId: String = resendableMessage.requestId else {
                    return
                }
                
                do {
                    let detector: NSDataDetector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                    let matches = detector.matches(in: text, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, (text.count)))
                    
                    var theUrl: URL?
                    for item in matches {
                        let match = item as NSTextCheckingResult
                        theUrl = match.url
                        break
                    }
                    
                    guard let url: URL = theUrl else {
                        return
                    }
                    
                    let tempModel = OutgoingGeneralUrlPreviewTempModel()
                    tempModel.createdAt = Int64(NSDate().timeIntervalSince1970 * 1000)
                    tempModel.message = text
                    
                    // TODO: check replacement
                    self.chattingView?.resendableMessages.removeValue(forKey: requestId)
                    
                    // Send preview
                    self.sendUrlPreview(url: url, message: text, aTempModel: tempModel)
                }
                catch {}
                
                let theParams: SBDUserMessageParams? = SBDUserMessageParams.init(message: text)
                guard let params: SBDUserMessageParams = theParams else {
                    return
                }
                params.data = resendableMessage.data
                params.customType = resendableMessage.customType
                if let translations: Dictionary = resendableMessage.translations, translations.count > 0, let targetLanguages: [String] = Array(translations.keys) as? [String] {
                    params.targetLanguages = targetLanguages
                }
                
                var thePreviewMessage: SBDUserMessage?
                thePreviewMessage = self.channel.sendUserMessage(with: params, completionHandler: { (theMessage, theError) in
                    if let previewMessage: SBDUserMessage = thePreviewMessage {
                        self.messageCollection?.deleteMessage(previewMessage)
                        thePreviewMessage = nil
                    }
                    self.chattingView?.scrollToBottom(force: true)
                    guard let _: SBDError = theError, let message: SBDUserMessage = theMessage else {
                        return
                    }
                    
                    self.messageCollection?.appendMessage(message)
                })
                
                if let previewMessage: SBDUserMessage = thePreviewMessage {
                    self.messageCollection?.appendMessage(previewMessage)
                }
            case is SBDFileMessage:
                guard let resendableMessage: SBDFileMessage = message as? SBDFileMessage, let requestId: String = resendableMessage.requestId else {
                    return
                }
                
                var thumbnailSizes: [SBDThumbnailSize] = [SBDThumbnailSize]()
                if let thumbnails: [SBDThumbnail] = resendableMessage.thumbnails {
                    for thumbnail in thumbnails {
                        thumbnailSizes.append(SBDThumbnailSize.make(withMaxCGSize: thumbnail.maxSize)!)
                    }
                }
                
                guard  let resendableFileData: [String: Any] = self.chattingView?.resendableFileData[requestId],
                    let fileData: Data = resendableFileData[requestId] as? Data else {
                    return
                }
                
                let theParams: SBDFileMessageParams? = SBDFileMessageParams.init(file: fileData)
                guard let params: SBDFileMessageParams = theParams else {
                    return
                }
                params.fileName = resendableMessage.name
                params.mimeType = resendableMessage.type
                params.fileSize = resendableMessage.size
                params.thumbnailSizes = thumbnailSizes
                params.data = resendableMessage.data
                params.customType = resendableMessage.customType
                var thePreviewMessage: SBDFileMessage?
                thePreviewMessage = self.channel.sendFileMessage(with: params, completionHandler: { (theMessage, theError) in
                    if let previewMessage: SBDFileMessage = thePreviewMessage {
                        self.messageCollection?.deleteMessage(previewMessage)
                        thePreviewMessage = nil
                    }
                    self.chattingView?.scrollToBottom(force: true)
                    guard let _: SBDError = theError, let message: SBDFileMessage = theMessage else {
                        self.chattingView?.resendableFileData[requestId] = self.chattingView?.preSendFileData[requestId]
                        self.chattingView?.preSendFileData.removeValue(forKey: requestId)
                        return
                    }
                    
                    self.messageCollection?.appendMessage(message)
                })
                
                if let previewMessage: SBDFileMessage = thePreviewMessage {
                    self.messageCollection?.appendMessage(previewMessage)
                    self.chattingView?.preSendFileData[requestId] = self.chattingView?.resendableFileData[requestId]
                    self.chattingView?.resendableFileData.removeValue(forKey: requestId)
                }
            default:
                break
            }
        }
        
        vc.addAction(closeAction)
        vc.addAction(resendAction)
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func clickDelete(view: UIView, message: SBDBaseMessage) {
        let vc = UIAlertController(title: "Delete Message", message: "Do you want to delete the message?", preferredStyle: UIAlertController.Style.alert)
        let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive) { (action) in
            guard let requestId: String = message.value(forKey: "requestId") as? String else {
                return
            }
            
            self.chattingView?.resendableFileData.removeValue(forKey: requestId)
            self.messageCollection?.deleteMessage(message)
        }
        
        vc.addAction(closeAction)
        vc.addAction(deleteAction)
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: SendBird SDK
    func sendFileMessage(fileData: Data, fileName: String, mimeType: String) -> Void {
        /***********************************/
        /* Thumbnail is a premium feature. */
        /***********************************/
        let theThumbnailSize: SBDThumbnailSize? = SBDThumbnailSize.make(withMaxWidth: 320.0, maxHeight: 320.0)
        
        let theParams: SBDFileMessageParams? = SBDFileMessageParams.init(file: fileData)
        guard let params: SBDFileMessageParams = theParams else {
            return
        }
        params.fileName = fileName
        params.mimeType = mimeType
        if let thumbnailSize: SBDThumbnailSize = theThumbnailSize {
            params.thumbnailSizes = [thumbnailSize]
        }
        let fileDataDict: Dictionary<String, Any> = ["data": fileData, "type": mimeType]
        
        var thePreviewMessage: SBDFileMessage?
        thePreviewMessage = self.channel.sendFileMessage(with: params) { (message, error) in
            self.chattingView?.scrollToBottom(force: true)
            
            guard let previewMessage: SBDFileMessage = thePreviewMessage, let requestId: String = previewMessage.requestId else {
                return
            }
            
            self.messageCollection?.deleteMessage(previewMessage)
            
            guard let _: SBDError = error else {
                self.chattingView?.resendableFileData[requestId] = fileDataDict
                return
            }
            
            if let fileMessage: SBDFileMessage = message {
                self.chattingView?.resendableFileData.removeValue(forKey: requestId)
                self.messageCollection?.appendMessage(fileMessage)
            }
        }
        
        if let previewMessage: SBDFileMessage = thePreviewMessage, let requestId: String = previewMessage.requestId {
            self.chattingView?.preSendFileData[requestId] = fileDataDict
            self.messageCollection?.appendMessage(previewMessage)
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            let mediaType: String? = info[UIImagePickerController.InfoKey.mediaType] as? String
            guard let theMediaType: String = mediaType else {
                return
            }
            
            if Utils.isKindOfImage(mediaType: theMediaType) {
                let imageUrl: URL? = info[UIImagePickerController.InfoKey.imageURL] as? URL
                let asset: PHAsset? = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset
                
                guard let theImageUrl: URL = imageUrl, let theAsset: PHAsset = asset else {
                    return
                }
                
                let mimeType: String? = Utils.infersMimeType(url: theImageUrl)
                guard let theMimeType: String = mimeType else {
                    return
                }
                
                if (theMimeType == "image/gif") {
                    let options: PHImageRequestOptions = PHImageRequestOptions()
                    options.isSynchronous = true
                    options.isNetworkAccessAllowed = false
                    options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
                    
                    PHImageManager.default().requestImageData(for: theAsset, options: options, resultHandler: { (theImageData, dataUTI, orientation, info) in
                        let isError: Bool? = info?[PHImageErrorKey] as? Bool
                        let isCloud: Bool? = info?[PHImageResultIsInCloudKey] as? Bool
                        
                        guard let hasError: Bool = isError, hasError == false else {
                            return
                        }
                        guard let hasCloud: Bool = isCloud, hasCloud == false else {
                            return
                        }
                        guard let imageData: Data = theImageData else {
                            return
                        }
                        
                        // sucess, data is in imagedata
                        self.sendFileMessage(fileData: imageData, fileName: theImageUrl.lastPathComponent, mimeType: theMimeType)
                    })
                }
                else {
                    PHImageManager.default().requestImage(for: theAsset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: nil, resultHandler: { (theResult, info) in
                        guard let result: UIImage = theResult, let imageData: Data = result.jpegData(compressionQuality: 1.0) else {
                            return
                        }
                        
                        // sucess, data is in imagedata
                        self.sendFileMessage(fileData: imageData, fileName: theImageUrl.lastPathComponent, mimeType: theMimeType)
                    })
                }
            }
            else if Utils.isKindOfVideo(mediaType: theMediaType) {
                let theVideoUrl: URL? = info[UIImagePickerController.InfoKey.mediaURL] as? URL
                guard let videoUrl: URL = theVideoUrl else {
                    return
                }
                
                do {
                    var theVideoFileData: Data?
                    try theVideoFileData = Data(contentsOf: videoUrl)
                    guard let fileData: Data = theVideoFileData else {
                        return
                    }
                    
                    let theMimeType: String? = Utils.infersMimeType(url: videoUrl)
                    guard let mimeType: String = theMimeType else {
                        return
                    }
                    
                    self.sendFileMessage(fileData: fileData, fileName: videoUrl.lastPathComponent, mimeType: mimeType)
                }
                catch {
                    return
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func showImageViewerLoading() {
        DispatchQueue.main.async {
            self.imageViewerLoadingView.isHidden = false
            self.imageViewerLoadingIndicator.isHidden = false
            self.imageViewerLoadingIndicator.startAnimating()
        }
    }
    
    func hideImageViewerLoading() {
        DispatchQueue.main.async {
            self.imageViewerLoadingView.isHidden = true
            self.imageViewerLoadingIndicator.isHidden = true
            self.imageViewerLoadingIndicator.stopAnimating()
        }
    }
    
    @objc func closeImageViewer() {
        self.photosViewController?.dismiss(animated: true, completion: nil)
    }
}
