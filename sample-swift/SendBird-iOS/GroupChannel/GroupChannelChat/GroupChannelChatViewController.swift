//
//  GroupChannelChatViewController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/2/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import RSKImageCropper
import Photos
import AVKit
import MobileCoreServices
import Alamofire
import AlamofireImage
import FLAnimatedImage


class GroupChannelChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, SBDChannelDelegate, GroupChannelMessageTableViewCellDelegate, GroupChannelSettingsDelegate, UIDocumentPickerDelegate, NotificationDelegate, SBDNetworkDelegate, SBDConnectionDelegate {
    
    @IBOutlet weak var inputMessageTextField: UITextField!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var typingIndicatorContainerView: UIView!
    @IBOutlet weak var typingIndicatorImageView: FLAnimatedImageView!
    @IBOutlet weak var typingIndicatorLabel: UILabel!
    @IBOutlet weak var loadingIndicatorView: CustomActivityIndicatorView!
    @IBOutlet weak var toastView: UIView!
    @IBOutlet weak var toastMessageLabel: UILabel!
    
    @IBOutlet weak var messageTableViewBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var inputMessageInnerContainerViewBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var sendUserMessageButton: UIButton!
    @IBOutlet weak var typingIndicatorContainerViewHeight: NSLayoutConstraint!
    
    var settingBarButton: UIBarButtonItem?
    
    weak var delegate: GroupChannelsUpdateListDelegate?
    var channel: SBDGroupChannel?

    var keyboardShown: Bool = false
    var keyboardHeight: CGFloat = 0
    
    var initialLoading: Bool = true
    var stopMeasuringVelocity: Bool = false
    var lastMessageHeight: CGFloat = 0
    var scrollLock: Bool = false
    var lastOffset: CGPoint = CGPoint(x: 0, y: 0)
    var lastOffsetCapture: TimeInterval = 0
    var isScrollingFast: Bool = false
    
    var hasPrevious: Bool?
    var minMessageTimestamp: Int64 = Int64.max
    var isLoading: Bool = false
    
    var messages: [SBDBaseMessage] = []
    
    var resendableMessages: [String:SBDBaseMessage] = [:]
    var preSendMessages: [String:SBDBaseMessage] = [:]
    var preSendFileData: [String:[String:AnyObject]] = [:]
    var resendableFileData: [String:[String:AnyObject]] = [:]
    var fileTransferProgress: [String:CGFloat] = [:]
    
    var selectedMessage: SBDBaseMessage?
    
    var channelUpdated: Bool = false
    
    var sendingImageVideoMessage: [String: Bool] = [:]
    var loadedImageHash: [String:Int] = [:]
    
    var rowRecalculateHeightCell = -1
    var pickerControllerOpened = false
    
    var typingIndicatorTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.largeTitleDisplayMode = .never
        self.settingBarButton = UIBarButtonItem(image: UIImage(named: "img_btn_channel_settings"), style: .plain, target: self, action: #selector(GroupChannelChatViewController.clickSettingBarButton(_:)))
        self.navigationItem.rightBarButtonItem = self.settingBarButton
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.leftBarButtonItems = nil
        
        let barButtonItemBack = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        if let navigationController = self.navigationController {
            let prevVC = navigationController.viewControllers[navigationController.viewControllers.count - 2]
            prevVC.navigationItem.backBarButtonItem = barButtonItemBack
        }
        
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.description)
        
        // TODO: Fix bug in SDK.
        SBDConnectionManager.add(self, identifier: self.description)
        
        self.title = Utils.createGroupChannelName(channel: self.channel!)
        
        let image = FLAnimatedImage.init(animatedGIFData: NSData(contentsOfFile: Bundle.main.path(forResource: "loading_typing", ofType: "gif")!) as Data?)
        self.typingIndicatorImageView.animatedImage = image
        
        self.typingIndicatorContainerView.isHidden = true
        
        self.messageTableView.rowHeight = UITableView.automaticDimension
        self.messageTableView.estimatedRowHeight = 140.0
        self.messageTableView.delegate = self
        self.messageTableView.dataSource = self
        self.messageTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 14, right: 0)
        self.messageTableView.register(UINib(nibName: "GroupChannelIncomingUserMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupChannelIncomingUserMessageTableViewCell")
        self.messageTableView.register(UINib(nibName: "GroupChannelIncomingImageVideoFileMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupChannelIncomingImageFileMessageTableViewCell")
        self.messageTableView.register(UINib(nibName: "GroupChannelIncomingImageVideoFileMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupChannelIncomingVideoFileMessageTableViewCell")
        self.messageTableView.register(UINib(nibName: "GroupChannelOutgoingUserMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupChannelOutgoingUserMessageTableViewCell")
        self.messageTableView.register(UINib(nibName: "GroupChannelNeutralAdminMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupChannelNeutralAdminMessageTableViewCell")
        self.messageTableView.register(UINib(nibName: "GroupChannelOutgoingImageVideoFileMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupChannelOutgoingImageFileMessageTableViewCell")
        self.messageTableView.register(UINib(nibName: "GroupChannelOutgoingImageVideoFileMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupChannelOutgoingVideoFileMessageTableViewCell")
        self.messageTableView.register(UINib(nibName: "GroupChannelOutgoingGeneralFileMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupChannelOutgoingGeneralFileMessageTableViewCell")
        self.messageTableView.register(UINib(nibName: "GroupChannelIncomingGeneralFileMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupChannelIncomingGeneralFileMessageTableViewCell")
        self.messageTableView.register(UINib(nibName: "GroupChannelOutgoingAudioFileMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupChannelOutgoingAudioFileMessageTableViewCell")
        self.messageTableView.register(UINib(nibName: "GroupChannelIncomingAudioFileMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupChannelIncomingAudioFileMessageTableViewCell")
        
        // Input Text Field
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        
        self.inputMessageTextField.leftView = leftPaddingView
        self.inputMessageTextField.rightView = rightPaddingView
        self.inputMessageTextField.leftViewMode = .always
        self.inputMessageTextField.rightViewMode = .always
        self.inputMessageTextField.addTarget(self, action: #selector(self.inputMessageTextFieldChanged(_:)), for: .editingChanged)
        self.sendUserMessageButton.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(_:)), name: UIWindow.keyboardDidHideNotification, object: nil)
        
        self.view.bringSubviewToFront(self.loadingIndicatorView)
        self.loadingIndicatorView.isHidden = true
        
        self.loadPreviousMessages(initial: true)
    }
    
    deinit {
        SBDConnectionManager.removeNetworkDelegate(forIdentifier: self.description)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let navigationController = self.navigationController, let topViewController = navigationController.topViewController {
            if navigationController.viewControllers.firstIndex(of: self) == nil {
                if navigationController is CreateGroupChannelNavigationController && !(topViewController is GroupChannelSettingsViewController) {
                    navigationController.dismiss(animated: false, completion: nil)
                }
                else {
                    super.viewWillDisappear(animated)
                }
                
                SBDMain.removeChannelDelegate(forIdentifier: self.description)
            }
            else {
                super.viewWillDisappear(animated)
            }
        }
        else {
            super.viewWillDisappear(animated)
        }
    }

    func showToast(_ message: String) {
        self.toastView.alpha = 1
        self.toastMessageLabel.text = message
        self.toastView.isHidden = false
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseIn, animations: {
            self.toastView.alpha = 0
        }) { (finished) in
            self.toastView.isHidden = true
        }
    }
    
    // MARK: - NotificationDelegate
    func openChat(_ channelUrl: String) {
        guard let channel = self.channel else { return }
        if channelUrl == channel.channelUrl { return }
        guard let navigationController = self.navigationController else { return }
        navigationController.popViewController(animated: false)
        let cvc = UIViewController.currentViewController()
        if cvc is GroupChannelsViewController {
            (cvc as! GroupChannelsViewController).openChat(channelUrl)
        }
        else if cvc is CreateGroupChannelViewControllerB {
            (cvc as! CreateGroupChannelViewControllerB).openChat(channelUrl)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func clickSettingBarButton(_ sender: AnyObject) {
        let vc = GroupChannelSettingsViewController.init(nibName: "GroupChannelSettingsViewController", bundle: nil)
        
        vc.delegate = self
        vc.channel = self.channel
        
        if let navigationController = self.navigationController {
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    @objc func hideTypingIndicator(_ timer: Timer) {
        self.typingIndicatorTimer?.invalidate()
        DispatchQueue.main.async {
            self.typingIndicatorContainerView.isHidden = true
            self.messageTableViewBottomMargin.constant = 0
            self.view.updateConstraints()
            self.view.layoutIfNeeded()
            
            self.stopMeasuringVelocity = true
            self.determineScrollLock()
            self.scrollToBottom(force: false)
        }
    }
    
    func loadPreviousMessages(initial: Bool) {
        if self.isLoading {
            return
        }
        
        self.isLoading = true
        
        var timestamp: Int64 = 0
        if initial {
            self.hasPrevious = true
            timestamp = Int64.max
        }
        else {
            timestamp = self.minMessageTimestamp
        }
        
        if self.hasPrevious == false {
            return
        }
        
        guard let channel = self.channel else { return }
        channel.getPreviousMessages(byTimestamp: timestamp, limit: 30, reverse: !initial, messageType: .all, customType: nil) { (msgs, error) in
            if error != nil {
                self.isLoading = false
                
                return
            }
            
            guard let messages = msgs else { return }
            
            if messages.count == 0 {
                self.hasPrevious = false
            }
            
            if initial {
                channel.markAsRead()
                
                if let delegate = self.delegate {
                    if delegate.responds(to: #selector(GroupChannelsUpdateListDelegate.updateGroupChannelList)) {
                        delegate.updateGroupChannelList!()
                    }
                    
                    if messages.count > 0 {
                        DispatchQueue.main.async {
                            self.messages.removeAll()
                            
                            for message in messages {
                                self.messages.append(message)
                                
                                if self.minMessageTimestamp > message.createdAt {
                                    self.minMessageTimestamp = message.createdAt
                                }
                            }
                            
                            if self.resendableMessages.count > 0 {
                                for message in self.resendableMessages.values {
                                    self.messages.append(message)
                                }
                            }
                            
                            self.initialLoading = true
                            
                            self.messageTableView.reloadData()
                            self.messageTableView.layoutIfNeeded()
                            
                            self.scrollToBottom(force: true)
                            self.initialLoading = false
                            self.isLoading = false
                        }
                    }
                }
            }
            else {
                if messages.count > 0 {
                    DispatchQueue.main.async {
                        var messageIndexPaths: [IndexPath] = []
                        var row: Int = 0
                        for message in messages {
                            self.messages.insert(message, at: 0)
                            
                            if self.minMessageTimestamp > message.createdAt {
                                self.minMessageTimestamp = message.createdAt
                            }
                            
                            messageIndexPaths.append(IndexPath(row: row, section: 0))
                            row += 1
                        }
                        
                        self.messageTableView.reloadData()
                        self.messageTableView.layoutIfNeeded()
                        
                        self.messageTableView.scrollToRow(at: IndexPath(row: messages.count-1, section: 0), at: .top, animated: false)
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    // MARK: - Keyboard
    func determineScrollLock() {
        if self.messages.count > 0 {
            if let indexPaths = self.messageTableView.indexPathsForVisibleRows {
                if let lastVisibleCellIndexPath = indexPaths.last {
                    let lastVisibleRow = lastVisibleCellIndexPath.row
                    if lastVisibleRow != self.messages.count - 1 {
                        self.scrollLock = true
                    }
                    else {
                        self.scrollLock = false
                    }
                }
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        self.determineScrollLock()
        
        self.keyboardShown = true
        guard let keyboardFrameBegin: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardFrameBeginRect = keyboardFrameBegin.cgRectValue
        self.keyboardHeight = keyboardFrameBeginRect.size.height
        
        DispatchQueue.main.async {
            self.inputMessageInnerContainerViewBottomMargin.constant = self.keyboardHeight - self.view.safeAreaInsets.bottom
            self.view.layoutIfNeeded()
            self.stopMeasuringVelocity = true
            self.scrollToBottom(force: false)
            self.keyboardShown = true
        }
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        self.keyboardShown = false
        self.keyboardHeight = 0
        DispatchQueue.main.async {
            self.inputMessageInnerContainerViewBottomMargin.constant = 0
            self.view.layoutIfNeeded()
            self.scrollToBottom(force: false)
        }
    }
    
    func hideKeyboardWhenFastScrolling() {
        if self.keyboardShown == false {
            return
        }
        
        DispatchQueue.main.async {
            self.inputMessageInnerContainerViewBottomMargin.constant = 0
            self.view.layoutIfNeeded()
            self.scrollToBottom(force: false)
        }
        self.view.endEditing(true)
    }
    
    @IBAction func clickSendUserMessageButton(_ sender: Any) {
        guard let messageText = self.inputMessageTextField.text else { return }
        guard let channel = self.channel else { return }
        
        if messageText.count == 0 {
            return
        }
        
        var preSendMessage: SBDUserMessage?
        preSendMessage = channel.sendUserMessage(messageText) { (userMessage, error) in
            self.inputMessageTextField.text = ""
            self.sendUserMessageButton.isEnabled = false
            if let channel = self.channel {
                channel.endTyping()
            }
            if error != nil {
                DispatchQueue.main.async {
                    guard let preSendMsg = preSendMessage else { return }
                    guard let requestId = preSendMsg.requestId else { return }
                    
                    self.preSendMessages.removeValue(forKey: requestId)
                    self.resendableMessages[requestId] = preSendMsg
                    self.messageTableView.reloadData()
                    self.scrollToBottom(force: false)
                }
                
                return
            }
            
            guard let message = userMessage else { return }
            guard let requestId = message.requestId else { return }
            
            DispatchQueue.main.async {
                self.determineScrollLock()
                
                if let preSendMessage = self.preSendMessages[requestId] {
                    if let index = self.messages.firstIndex(of: preSendMessage) {
                        self.messages[index] = message
                        self.preSendMessages.removeValue(forKey: requestId)
                        self.scrollToBottom(force: false)
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.determineScrollLock()
            if let preSendMsg = preSendMessage {
                if let requestId = preSendMsg.requestId {
                    self.preSendMessages[requestId] = preSendMsg
                    self.messages.append(preSendMsg)
                    self.messageTableView.reloadData()
                    self.scrollToBottom(force: false)
                }
            }
        }
    }
    
    @IBAction func clickSendFileMessageButton(_ sender: Any) {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take Photo...", style: .default) { (action) in
            DispatchQueue.main.async {
                let mediaUI = UIImagePickerController()
                mediaUI.sourceType = UIImagePickerController.SourceType.camera
                let mediaTypes = [String(kUTTypeImage)]
                mediaUI.mediaTypes = mediaTypes
                mediaUI.delegate = self
                self.present(mediaUI, animated: true, completion: nil)
            }
        }
        
        let takeVideoAction = UIAlertAction(title: "Take Video...", style: .default) { (action) in
            DispatchQueue.main.async {
                let mediaUI = UIImagePickerController()
                mediaUI.sourceType = UIImagePickerController.SourceType.camera
                let mediaTypes = [String(kUTTypeMovie)]
                mediaUI.mediaTypes = mediaTypes
                mediaUI.delegate = self
                self.present(mediaUI, animated: true, completion: nil)
            }
        }
        
        let browseDocumentsAction = UIAlertAction(title: "Browse Files...", style: .default) { (action) in
            DispatchQueue.main.async {
                let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: UIDocumentPickerMode.import)
                documentPicker.allowsMultipleSelection = false
                documentPicker.delegate = self
                self.present(documentPicker, animated: true, completion: nil)
            }
        }
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose from Library...", style: .default) { (action) in
            DispatchQueue.main.async {
                let mediaUI = UIImagePickerController()
                mediaUI.sourceType = UIImagePickerController.SourceType.photoLibrary
                let mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
                mediaUI.mediaTypes = mediaTypes
                mediaUI.delegate = self
                self.present(mediaUI, animated: true, completion: nil)
            }
        }
        
        let closeAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        
        vc.addAction(takePhotoAction)
        vc.addAction(takeVideoAction)
        vc.addAction(browseDocumentsAction)
        vc.addAction(chooseFromLibraryAction)
        vc.addAction(closeAction)
        
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - Scroll
    func scrollToBottom(force: Bool) {
        if self.messages.count == 0 {
            return
        }
        
        if self.scrollLock && force == false {
            return
        }
        
        let currentRowNumber = self.messageTableView.numberOfRows(inSection: 0)
        
        self.messageTableView.scrollToRow(at: IndexPath(row: currentRowNumber - 1, section: 0), at: .bottom, animated: false)
    }
    
    func scrollTo(position: Int) {
        if self.messages.count == 0 {
            return
        }
        
        self.messageTableView.scrollToRow(at: IndexPath(row: position, section: 0), at: .top, animated: false)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        
        var prevMessage: SBDBaseMessage?
        var nextMessage: SBDBaseMessage?
        if indexPath.row > 0 {
            prevMessage = self.messages[indexPath.row - 1]
        }
        if indexPath.row + 1 < self.messages.count {
            nextMessage = self.messages[indexPath.row + 1]
        }
        
        let currMessage = self.messages[indexPath.row]
        
        if currMessage is SBDAdminMessage {
            // Admin Message
            guard let adminMessage = self.messages[indexPath.row] as? SBDAdminMessage else { return cell }
            guard let adminMessageCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelNeutralAdminMessageTableViewCell") as? GroupChannelNeutralAdminMessageTableViewCell else { return cell }
            
            adminMessageCell.setMessage(currMessage: adminMessage, prevMessage: prevMessage)
            adminMessageCell.delegate = self
                
            cell = adminMessageCell
        }
        else if currMessage is SBDUserMessage {
            guard let userMessage = currMessage as? SBDUserMessage else { return cell }
            guard let sender = userMessage.sender else { return cell }
            if sender.userId == SBDMain.getCurrentUser()!.userId {
                // Outgoing User Message
                guard let userMessageCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelOutgoingUserMessageTableViewCell") as? GroupChannelOutgoingUserMessageTableViewCell else { return cell }
                userMessageCell.delegate = self
                userMessageCell.channel = self.channel
                
                var failed: Bool = false
                if let requestId = userMessage.requestId {
                    if self.resendableMessages[requestId] != nil {
                        failed = true
                    }
                }
            
                userMessageCell.setMessage(currMessage: userMessage, prevMessage: prevMessage, nextMessage: nextMessage, failed: failed)
                
                cell = userMessageCell
            }
            else {
                // Incoming User Message
                guard let userMessageCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelIncomingUserMessageTableViewCell") as? GroupChannelIncomingUserMessageTableViewCell else { return cell }
                userMessageCell.delegate = self
                userMessageCell.setMessages(currMessage: userMessage, prevMessage: prevMessage, nextMessage: nextMessage)
                    
                DispatchQueue.main.async {
                    guard let updateCell = tableView.cellForRow(at: indexPath) else { return }
                    guard let updateUserMessageCell = updateCell as? GroupChannelIncomingUserMessageTableViewCell else { return }
                    if let profileUrl = URL(string: Utils.transformUserProfileImage(user: sender)) {
                        updateUserMessageCell.profileImageView.af_setImage(withURL: profileUrl, placeholderImage: Utils.getDefaultUserProfileImage(user: sender))
                    }
                    else {
                        updateUserMessageCell.profileImageView.image = Utils.getDefaultUserProfileImage(user: sender)
                    }
                }
                
                cell = userMessageCell
            }
        }
        else if currMessage is SBDFileMessage {
            // File Message
            guard let fileMessage = currMessage as? SBDFileMessage else { return cell }
            guard let sender = fileMessage.sender else { return cell }
            guard let fileMessageRequestId = fileMessage.requestId else { return cell }
            guard let currentUser = SBDMain.getCurrentUser() else { return cell }
            if let _ = self.preSendMessages[fileMessageRequestId] {
                // Pre send outgoing message
                guard let fileDataDict = self.preSendFileData[fileMessageRequestId] else { return cell }
                if (fileDataDict["type"] as! String).hasPrefix("image") {
                    // Outgoing image file message
                    guard let imageFileMessageCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelOutgoingImageFileMessageTableViewCell") as? GroupChannelOutgoingImageVideoFileMessageTableViewCell else { return cell }
                    imageFileMessageCell.channel = self.channel
                    imageFileMessageCell.setMessage(currMessage: fileMessage, prevMessage: prevMessage, nextMessage: nextMessage, failed: false)
                    imageFileMessageCell.hideReadStatus()
                    imageFileMessageCell.hideElementsForFailure()
                    imageFileMessageCell.showBottomMargin()
                    imageFileMessageCell.hideAllPlaceholders()
                    if let progress = self.fileTransferProgress[fileMessageRequestId] {
                        imageFileMessageCell.showProgress(progress)
                    }
                    
                    if (fileDataDict["type"] as! String).hasPrefix("image/gif") {
                        DispatchQueue.main.async {
                            guard let updateCell = tableView.cellForRow(at: indexPath) else { return }
                            guard let updateImageFileMessageCell = updateCell as? GroupChannelOutgoingImageVideoFileMessageTableViewCell else { return }
                            guard let imageData = fileDataDict["data"] as? Data else { return }
                            updateImageFileMessageCell.imageFileMessageImageView.image = nil
                            updateImageFileMessageCell.imageFileMessageImageView.animatedImage = FLAnimatedImage(animatedGIFData: imageData)
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            guard let updateCell = tableView.cellForRow(at: indexPath) else { return }
                            guard let updateImageFileMessageCell = updateCell as? GroupChannelOutgoingImageVideoFileMessageTableViewCell else { return }
                            guard let imageData = fileDataDict["data"] as? Data else { return }
                            updateImageFileMessageCell.imageFileMessageImageView.image = nil
                            updateImageFileMessageCell.setAnimatedImage(nil, hash: 0)
                            updateImageFileMessageCell.imageFileMessageImageView.image = UIImage(data: imageData)
                        }
                    }
                    
                    cell = imageFileMessageCell
                }
                else if (fileDataDict["type"] as! String).hasPrefix("video") {
                    // Outgoing video file message
                    guard let videoFileMessageCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelOutgoingVideoFileMessageTableViewCell") as? GroupChannelOutgoingImageVideoFileMessageTableViewCell else { return cell }
                    videoFileMessageCell.channel = self.channel
                    videoFileMessageCell.setMessage(currMessage: fileMessage, prevMessage: prevMessage, nextMessage: nextMessage, failed: false)
                    videoFileMessageCell.hideReadStatus()
                    videoFileMessageCell.hideElementsForFailure()
                    videoFileMessageCell.showBottomMargin()
                    videoFileMessageCell.hideAllPlaceholders()
                    videoFileMessageCell.videoMessagePlaceholderImageView.isHidden = false
                    
                    videoFileMessageCell.imageFileMessageImageView.image = nil
                    videoFileMessageCell.imageFileMessageImageView.animatedImage = nil
                    
                    if let progress = self.fileTransferProgress[fileMessageRequestId] {
                        videoFileMessageCell.showProgress(progress)
                    }
                    
                    cell = videoFileMessageCell
                }
                else if (fileDataDict["type"] as! String).hasPrefix("audio") {
                    // Outgoing audio file message
                    guard let audioFileMessageCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelOutgoingAudioFileMessageTableViewCell") as? GroupChannelOutgoingAudioFileMessageTableViewCell else { return cell }
                    audioFileMessageCell.channel = self.channel
                    audioFileMessageCell.setMessage(currMessage: fileMessage, prevMessage: prevMessage, nextMessage: nextMessage, failed: false)
                    audioFileMessageCell.hideReadStatus()
                    audioFileMessageCell.hideElementsForFailure()
                    audioFileMessageCell.showBottomMargin()
                    audioFileMessageCell.delegate = nil
                    
                    DispatchQueue.main.async {
                        guard let updateCell = tableView.cellForRow(at: indexPath) else { return }
                        guard let updateAudioFileMessageCell = updateCell as? GroupChannelOutgoingAudioFileMessageTableViewCell else { return }
                        if let progress = self.fileTransferProgress[fileMessageRequestId] {
                            updateAudioFileMessageCell.showProgress(progress)
                        }
                    }
                    
                    cell = audioFileMessageCell
                }
                else {
                    // Outgoing general file message
                    guard let generalFileMessageCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelOutgoingGeneralFileMessageTableViewCell") as? GroupChannelOutgoingGeneralFileMessageTableViewCell else { return cell }
                    generalFileMessageCell.channel = self.channel
                    generalFileMessageCell.setMessage(currMessage: fileMessage, prevMessage: prevMessage, nextMessage: nextMessage, failed: false)
                    generalFileMessageCell.hideReadStatus()
                    generalFileMessageCell.hideElementsForFailure()
                    generalFileMessageCell.showBottomMargin()
                    generalFileMessageCell.delegate = nil
                    
                    DispatchQueue.main.async {
                        guard let updateCell = tableView.cellForRow(at: indexPath) else { return }
                        guard let updateAudioFileMessageCell = updateCell as? GroupChannelOutgoingGeneralFileMessageTableViewCell else { return }
                        if let progress = self.fileTransferProgress[fileMessageRequestId] {
                            updateAudioFileMessageCell.showProgress(progress)
                        }
                    }
                    
                    cell = generalFileMessageCell
                }
            }
            else if let _ = self.resendableFileData[fileMessageRequestId] {
                guard let fileDataDict = self.preSendFileData[fileMessageRequestId] else { return cell }
                if (fileDataDict["type"] as! String).hasPrefix("image") {
                    // Failed outgoing image file message
                    guard let imageFileMessageCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelOutgoingImageFileMessageTableViewCell") as? GroupChannelOutgoingImageVideoFileMessageTableViewCell else { return cell }
                    imageFileMessageCell.setMessage(currMessage: fileMessage, prevMessage: prevMessage, nextMessage: nextMessage, failed: true)
                    imageFileMessageCell.hideReadStatus()
                    imageFileMessageCell.hideProgress()
                    imageFileMessageCell.showElementsForFailure()
                    imageFileMessageCell.showBottomMargin()
                    imageFileMessageCell.hideAllPlaceholders()
                    imageFileMessageCell.delegate = self
                    
                    if (fileDataDict["type"] as! String).hasPrefix("image/gif") {
                        DispatchQueue.main.async {
                            guard let updateCell = tableView.cellForRow(at: indexPath) else { return }
                            guard let updateImageFileMessageCell = updateCell as? GroupChannelOutgoingImageVideoFileMessageTableViewCell else { return }
                            guard let imageData = fileDataDict["data"] as? Data else { return }
                            updateImageFileMessageCell.imageFileMessageImageView.image = nil
                            updateImageFileMessageCell.setAnimatedImage(FLAnimatedImage(animatedGIFData: imageData), hash: (imageData as NSData).hashValue)
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            guard let updateCell = tableView.cellForRow(at: indexPath) else { return }
                            guard let updateImageFileMessageCell = updateCell as? GroupChannelOutgoingImageVideoFileMessageTableViewCell else { return }
                            guard let imageData = fileDataDict["data"] as? Data else { return }
                            updateImageFileMessageCell.imageFileMessageImageView.image = nil
                            updateImageFileMessageCell.setAnimatedImage(nil, hash: 0)
                            updateImageFileMessageCell.imageFileMessageImageView.image = UIImage(data: imageData)
                        }
                    }
                    
                    cell = imageFileMessageCell
                }
                else if (fileDataDict["type"] as! String).hasPrefix("video") {
                    // Failed outgoing image file message
                    guard let videoFileMessageCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelOutgoingVideoFileMessageTableViewCell") as? GroupChannelOutgoingImageVideoFileMessageTableViewCell else { return cell }
                    videoFileMessageCell.setMessage(currMessage: fileMessage, prevMessage: prevMessage, nextMessage: nextMessage, failed: true)
                    videoFileMessageCell.hideReadStatus()
                    videoFileMessageCell.hideProgress()
                    videoFileMessageCell.showElementsForFailure()
                    videoFileMessageCell.showBottomMargin()
                    videoFileMessageCell.hideAllPlaceholders()
                    videoFileMessageCell.videoMessagePlaceholderImageView.isHidden = false
                    videoFileMessageCell.delegate = self
                    
                    cell = videoFileMessageCell
                }
                else {
                    // Failed outgoing audio file message
                    guard let audioFileMessageCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelOutgoingAudioFileMessageTableViewCell") as? GroupChannelOutgoingAudioFileMessageTableViewCell else { return cell }
                    audioFileMessageCell.setMessage(currMessage: fileMessage, prevMessage: prevMessage, nextMessage: nextMessage, failed: true)
                    audioFileMessageCell.hideReadStatus()
                    audioFileMessageCell.hideProgress()
                    audioFileMessageCell.showElementsForFailure()
                    audioFileMessageCell.showBottomMargin()
                    audioFileMessageCell.delegate = self

                    cell = audioFileMessageCell
                }
            }
            else {
                if sender.userId == currentUser.userId {
                    // Outgoing file message
                    if fileMessage.type.hasPrefix("image") {
                        guard let imageFileMessageCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelOutgoingImageFileMessageTableViewCell") as? GroupChannelOutgoingImageVideoFileMessageTableViewCell else { return cell }
                        imageFileMessageCell.delegate = self
                        imageFileMessageCell.channel = self.channel
                        imageFileMessageCell.hideElementsForFailure()
                        imageFileMessageCell.hideAllPlaceholders()
                        imageFileMessageCell.setMessage(currMessage: fileMessage, prevMessage: prevMessage, nextMessage: nextMessage, failed: false)
                        
                        if self.loadedImageHash[String(format: "%lld", fileMessage.messageId)] == nil || self.loadedImageHash[String(format: "%lld", fileMessage.messageId)] != imageFileMessageCell.hash {
                            imageFileMessageCell.imageMessagePlaceholderImageView.isHidden = false
                            imageFileMessageCell.setImage(nil)
                            imageFileMessageCell.setAnimatedImage(nil, hash: 0)
                        }
                        
                        cell = imageFileMessageCell
                        
                        if fileMessage.type.hasPrefix("image/gif") {
                            guard let url = URL(string: fileMessage.url) else { return cell }
                            imageFileMessageCell.imageFileMessageImageView.setAnimatedImage(url: url, success: { (image, hash) in
                                DispatchQueue.main.async {
                                    guard let updateCell = tableView.cellForRow(at: indexPath) else { return }
                                    guard let updateImageFileMessageCell = updateCell as? GroupChannelOutgoingImageVideoFileMessageTableViewCell else { return }
                                    updateImageFileMessageCell.hideAllPlaceholders()
                                    updateImageFileMessageCell.setAnimatedImage(image, hash: hash)
                                    self.loadedImageHash[String(format: "%lld", fileMessage.messageId)] = hash
                                }
                            }) { (error) in
                                DispatchQueue.main.async {
                                    guard let updateCell = tableView.cellForRow(at: indexPath) else { return }
                                    guard let updateImageFileMessageCell = updateCell as? GroupChannelOutgoingImageVideoFileMessageTableViewCell else { return }
                                    updateImageFileMessageCell.hideAllPlaceholders()
                                    updateImageFileMessageCell.imageMessagePlaceholderImageView.isHidden = false
                                    updateImageFileMessageCell.setImage(nil)
                                    updateImageFileMessageCell.setAnimatedImage(nil, hash: 0)
                                    self.loadedImageHash.removeValue(forKey: String(format: "%lld", fileMessage.messageId))
                                }
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                guard let updateCell = tableView.cellForRow(at: indexPath) else { return }
                                guard let updateImageFileMessageCell = updateCell as? GroupChannelOutgoingImageVideoFileMessageTableViewCell else { return }
                                if fileMessage.thumbnails != nil && fileMessage.thumbnails!.count > 0 {
                                    if let thumbnails = fileMessage.thumbnails {
                                        guard let url = URL(string: thumbnails[0].url) else { return }
                                        updateImageFileMessageCell.imageFileMessageImageView.af_setImage(withURL: url, placeholderImage: nil, completion: { (response) in
                                            updateImageFileMessageCell.hideAllPlaceholders()

                                            if response.error != nil {
                                                updateImageFileMessageCell.imageMessagePlaceholderImageView.isHidden = false
                                                updateImageFileMessageCell.setImage(nil)
                                                updateImageFileMessageCell.setAnimatedImage(nil, hash: 0)
                                                self.loadedImageHash.removeValue(forKey: String(format: "%lld", fileMessage.messageId))
                                                
                                                return
                                            }
                                            
                                            guard let data = response.data else { return }
                                            guard let image = UIImage(data: data) else { return }
                                            self.loadedImageHash[String(format: "%lld", fileMessage.messageId)] = image.jpegData(compressionQuality: 0.5).hashValue
                                        })
                                    }
                                }
                                else {
                                    guard let url = URL(string: fileMessage.url) else { return }
                                    updateImageFileMessageCell.imageFileMessageImageView.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: UIImageView.ImageTransition.noTransition, runImageTransitionIfCached: false, completion: { (response) in
                                        updateImageFileMessageCell.hideAllPlaceholders()
                                        
                                        if response.error != nil {
                                            updateImageFileMessageCell.imageMessagePlaceholderImageView.isHidden = false
                                            updateImageFileMessageCell.setImage(nil)
                                            updateImageFileMessageCell.setAnimatedImage(nil, hash: 0)
                                            self.loadedImageHash.removeValue(forKey: String(format: "%lld", fileMessage.messageId))
                                            
                                            return
                                        }
                                        
                                        guard let image = UIImage(data: response.data!) else { return }
                                        self.loadedImageHash[String(format: "%lld", fileMessage.messageId)] = image.jpegData(compressionQuality: 0.5).hashValue
                                    })
                                }
                            }
                        }
                    }
                    else if fileMessage.type.hasPrefix("video") {
                        guard let videoFileMessageCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelOutgoingVideoFileMessageTableViewCell") as? GroupChannelOutgoingImageVideoFileMessageTableViewCell else { return cell }
                        
                        videoFileMessageCell.delegate = self
                        
                        if videoFileMessageCell.imageHash == 0 || videoFileMessageCell.imageFileMessageImageView.image == nil {
                            videoFileMessageCell.setAnimatedImage(nil, hash: 0)
                            videoFileMessageCell.setImage(nil)
                        }
                        
                        videoFileMessageCell.hideAllPlaceholders()
                        videoFileMessageCell.videoPlayIconImageView.isHidden = false
                        
                        videoFileMessageCell.channel = self.channel
                        videoFileMessageCell.setMessage(currMessage: fileMessage, prevMessage: prevMessage, nextMessage: nextMessage, failed: false)

                        if self.loadedImageHash[String(format: "%lld", fileMessage.messageId)] == nil || self.loadedImageHash[String(format: "%lld", fileMessage.messageId)] != videoFileMessageCell.imageHash {
                            videoFileMessageCell.videoMessagePlaceholderImageView.isHidden = false
                            videoFileMessageCell.setImage(nil)
                            videoFileMessageCell.setAnimatedImage(nil, hash: 0)
                        }
                        
                        DispatchQueue.main.async {
                            guard let updateCell = tableView.cellForRow(at: indexPath) else { return }
                            guard let updateVideoFileMessageCell = updateCell as? GroupChannelOutgoingImageVideoFileMessageTableViewCell else { return }
                            if fileMessage.thumbnails != nil && fileMessage.thumbnails!.count > 0 {
                                if let thumbnails = fileMessage.thumbnails {
                                    guard let url = URL(string: thumbnails[0].url) else { return }
                                    updateVideoFileMessageCell.imageFileMessageImageView.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: UIImageView.ImageTransition.noTransition, runImageTransitionIfCached: false, completion: { (response) in
                                        if response.error != nil {
                                            updateVideoFileMessageCell.videoPlayIconImageView.isHidden = true
                                            updateVideoFileMessageCell.videoMessagePlaceholderImageView.isHidden = false
                                            updateVideoFileMessageCell.setAnimatedImage(nil, hash: 0)
                                            updateVideoFileMessageCell.setImage(nil)
                                            self.loadedImageHash.removeValue(forKey: String(format: "%lld", fileMessage.messageId))
                                            
                                            return
                                        }
                                        
                                        updateVideoFileMessageCell.hideAllPlaceholders()
                                        updateVideoFileMessageCell.videoPlayIconImageView.isHidden = false
                                        guard let data = response.data else { return }
                                        guard let image = UIImage(data: data) else { return }
                                        updateVideoFileMessageCell.setImage(image)
                                        self.loadedImageHash[String(format: "%lld", fileMessage.messageId)] = image.jpegData(compressionQuality: 0.5).hashValue
                                    })
                                }
                            }
                            else {
                                // Without thumbnails.
                                updateVideoFileMessageCell.hideAllPlaceholders()
                                updateVideoFileMessageCell.videoMessagePlaceholderImageView.isHidden = false
                                updateVideoFileMessageCell.setAnimatedImage(nil, hash: 0)
                                updateVideoFileMessageCell.setImage(nil)
                                self.loadedImageHash.removeValue(forKey: String(format: "%lld", fileMessage.messageId))
                            }
                        }
                        
                        cell = videoFileMessageCell
                    }
                    else if fileMessage.type.hasPrefix("audio") {
                        // Outgoing audio file message
                        guard let audioFileMessageCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelOutgoingAudioFileMessageTableViewCell") as? GroupChannelOutgoingAudioFileMessageTableViewCell else { return cell }
                        audioFileMessageCell.delegate = self
                        audioFileMessageCell.channel = self.channel
                        audioFileMessageCell.setMessage(currMessage: fileMessage, prevMessage: prevMessage, nextMessage: nextMessage, failed: false)
                        audioFileMessageCell.showProgress(1.0)
                        
                        cell = audioFileMessageCell
                    }
                    else {
                        // Outgoing general file message
                        guard let generalFileMessageCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelOutgoingGeneralFileMessageTableViewCell") as? GroupChannelOutgoingGeneralFileMessageTableViewCell else { return cell }
                        generalFileMessageCell.delegate = self
                        generalFileMessageCell.channel = self.channel
                        generalFileMessageCell.setMessage(currMessage: fileMessage, prevMessage: prevMessage, nextMessage: nextMessage, failed: false)
                        generalFileMessageCell.showProgress(1.0)
                        
                        cell = generalFileMessageCell
                    }
                }
                else {
                    if fileMessage.type.hasPrefix("image") {
                        // Incoming image file message
                        guard let imageFileMessageCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelIncomingImageFileMessageTableViewCell") as? GroupChannelIncomingImageVideoFileMessageTableViewCell else { return cell }
                        imageFileMessageCell.setMessage(currMessage: fileMessage, prevMessage: prevMessage, nextMessage: nextMessage)
                        imageFileMessageCell.delegate = self
                        imageFileMessageCell.hideAllPlaceholders()
                        
                        if self.loadedImageHash[String(format: "%lld", fileMessage.messageId)] == nil || self.loadedImageHash[String(format: "%lld", fileMessage.messageId)] != imageFileMessageCell.imageHash {
                            imageFileMessageCell.imageMessagePlaceholderImageView.isHidden = false
                            imageFileMessageCell.setImage(nil)
                            imageFileMessageCell.setAnimatedImage(nil, hash: 0)
                        }
                        
                        cell = imageFileMessageCell
                        if fileMessage.type == "image/gif" {
                            guard let url = URL(string: fileMessage.url) else { return cell }
                            imageFileMessageCell.imageFileMessageImageView.setAnimatedImage(url: url, success: { (image, hash) in
                                DispatchQueue.main.async {
                                    guard let updateCell = tableView.cellForRow(at: indexPath) else { return }
                                    guard let updateImageFileMessageCell = updateCell as? GroupChannelIncomingImageVideoFileMessageTableViewCell else { return }
                                    updateImageFileMessageCell.hideAllPlaceholders()
                                    if let url = URL(string: Utils.transformUserProfileImage(user: sender)) {
                                        updateImageFileMessageCell.profileImageView.af_setImage(withURL: url, placeholderImage: Utils.getDefaultUserProfileImage(user: sender))
                                    }
                                    else {
                                        updateImageFileMessageCell.profileImageView.image = Utils.getDefaultUserProfileImage(user: sender)
                                    }
                                    
                                    updateImageFileMessageCell.setAnimatedImage(image, hash: hash)
                                    self.loadedImageHash[String(format: "%lld", fileMessage.messageId)] = hash
                                }
                            }) { (error) in
                                DispatchQueue.main.async {
                                    guard let updateCell = tableView.cellForRow(at: indexPath) else { return }
                                    guard let updateImageFileMessageCell = updateCell as? GroupChannelIncomingImageVideoFileMessageTableViewCell else { return }
                                    updateImageFileMessageCell.hideAllPlaceholders()
                                    updateImageFileMessageCell.imageMessagePlaceholderImageView.isHidden = false
                                    if let url = URL(string: Utils.transformUserProfileImage(user: sender)) {
                                        updateImageFileMessageCell.profileImageView.af_setImage(withURL: url, placeholderImage: Utils.getDefaultUserProfileImage(user: sender))
                                    }
                                    else {
                                        updateImageFileMessageCell.profileImageView.image = Utils.getDefaultUserProfileImage(user: sender)
                                    }
                                    updateImageFileMessageCell.setImage(nil)
                                    updateImageFileMessageCell.setAnimatedImage(nil, hash: 0)
                                    self.loadedImageHash.removeValue(forKey: String(format: "%lld", fileMessage.messageId))
                                }
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                guard let updateCell = tableView.cellForRow(at: indexPath) else { return }
                                guard let updateImageFileMessageCell = updateCell as? GroupChannelIncomingImageVideoFileMessageTableViewCell else { return }
                                if let url = URL(string: Utils.transformUserProfileImage(user: sender)) {
                                    updateImageFileMessageCell.profileImageView.af_setImage(withURL: url, placeholderImage: Utils.getDefaultUserProfileImage(user: sender))
                                }
                                else {
                                    updateImageFileMessageCell.profileImageView.image = Utils.getDefaultUserProfileImage(user: sender)
                                }
                                if fileMessage.thumbnails != nil && fileMessage.thumbnails!.count > 0 {
                                    if let thumbnails = fileMessage.thumbnails {
                                        guard let url = URL(string: thumbnails[0].url) else { return }
                                        updateImageFileMessageCell.imageFileMessageImageView.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: UIImageView.ImageTransition.noTransition, runImageTransitionIfCached: false, completion: { (response) in
                                            updateImageFileMessageCell.hideAllPlaceholders()
                                            
                                            if let url = URL(string: Utils.transformUserProfileImage(user: sender)) {
                                                updateImageFileMessageCell.profileImageView.af_setImage(withURL: url, placeholderImage: Utils.getDefaultUserProfileImage(user: sender))
                                            }
                                            else {
                                                updateImageFileMessageCell.profileImageView.image = Utils.getDefaultUserProfileImage(user: sender)
                                            }
                                            
                                            if response.error != nil {
                                                updateImageFileMessageCell.imageMessagePlaceholderImageView.isHidden = false
                                                updateImageFileMessageCell.setImage(nil)
                                                updateImageFileMessageCell.setAnimatedImage(nil, hash: 0)
                                                self.loadedImageHash.removeValue(forKey: String(format: "%lld", fileMessage.messageId))
                                                
                                                return
                                            }
                                            
                                            guard let data = response.data else { return }
                                            guard let image = UIImage(data: data) else { return }
                                            updateImageFileMessageCell.setImage(image)
                                            self.loadedImageHash[String(format: "%lld", fileMessage.messageId)] = image.jpegData(compressionQuality: 0.5).hashValue
                                        })
                                    }
                                }
                                else {
                                    // Without thunbnail.
                                    updateImageFileMessageCell.hideAllPlaceholders()
                                    updateImageFileMessageCell.videoMessagePlaceholderImageView.isHidden = false
                                    updateImageFileMessageCell.setAnimatedImage(nil, hash: 0)
                                    updateImageFileMessageCell.setImage(nil)
                                    self.loadedImageHash.removeValue(forKey: String(format: "%lld", fileMessage.messageId))
                                }
                            }
                        }
                    }
                    else if fileMessage.type.hasPrefix("video") {
                        // Incoming video file message
                        guard let videoFileMessageCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelIncomingVideoFileMessageTableViewCell") as? GroupChannelIncomingImageVideoFileMessageTableViewCell else { return cell }
                        
                        videoFileMessageCell.delegate = self
                        videoFileMessageCell.setMessage(currMessage: fileMessage, prevMessage: prevMessage, nextMessage: nextMessage)
                        videoFileMessageCell.videoMessagePlaceholderImageView.isHidden = false
                        videoFileMessageCell.hideAllPlaceholders()
                        
                        if self.loadedImageHash[String(format: "%lld", fileMessage.messageId)] == nil || self.loadedImageHash[String(format: "%lld", fileMessage.messageId)] != videoFileMessageCell.imageHash {
                            videoFileMessageCell.setImage(nil)
                            videoFileMessageCell.setAnimatedImage(nil, hash: 0)
                        }
                        
                        cell = videoFileMessageCell
                        DispatchQueue.main.async {
                            guard let updateCell = tableView.cellForRow(at: indexPath) else { return }
                            guard let updateImageFileMessageCell = updateCell as? GroupChannelIncomingImageVideoFileMessageTableViewCell else { return }
                            if let url = URL(string: Utils.transformUserProfileImage(user: sender)) {
                                updateImageFileMessageCell.profileImageView.af_setImage(withURL: url, placeholderImage: Utils.getDefaultUserProfileImage(user: sender))
                            }
                            else {
                                updateImageFileMessageCell.profileImageView.image = Utils.getDefaultUserProfileImage(user: sender)
                            }
                            if fileMessage.thumbnails != nil && fileMessage.thumbnails!.count > 0 {
                                if let thumbnails = fileMessage.thumbnails {
                                    guard let url = URL(string: thumbnails[0].url) else { return }
                                    updateImageFileMessageCell.imageFileMessageImageView.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: UIImageView.ImageTransition.noTransition, runImageTransitionIfCached: false, completion: { (response) in
                                        updateImageFileMessageCell.hideAllPlaceholders()
                                        updateImageFileMessageCell.videoPlayIconImageView.isHidden = true
                                        updateImageFileMessageCell.videoMessagePlaceholderImageView.isHidden = false
                                        
                                        if let url = URL(string: Utils.transformUserProfileImage(user: sender)) {
                                            updateImageFileMessageCell.profileImageView.af_setImage(withURL: url, placeholderImage: Utils.getDefaultUserProfileImage(user: sender))
                                        }
                                        else {
                                            updateImageFileMessageCell.profileImageView.image = Utils.getDefaultUserProfileImage(user: sender)
                                        }
                                        
                                        if response.error != nil {
                                            updateImageFileMessageCell.setImage(nil)
                                            updateImageFileMessageCell.setAnimatedImage(nil, hash: 0)
                                            self.loadedImageHash.removeValue(forKey: String(format: "%lld", fileMessage.messageId))
                                            
                                            return
                                        }
                                        
                                        guard let data = response.data else { return }
                                        guard let image = UIImage(data: data) else { return }
                                        updateImageFileMessageCell.videoMessagePlaceholderImageView.isHidden = true
                                        updateImageFileMessageCell.videoPlayIconImageView.isHidden = false
                                        updateImageFileMessageCell.setImage(image)
                                        self.loadedImageHash[String(format: "%lld", fileMessage.messageId)] = image.jpegData(compressionQuality: 0.5).hashValue
                                    })
                                }
                            }
                            else {
                                // Without thunbnail.
                                updateImageFileMessageCell.hideAllPlaceholders()
                                updateImageFileMessageCell.videoMessagePlaceholderImageView.isHidden = false
                                updateImageFileMessageCell.setAnimatedImage(nil, hash: 0)
                                updateImageFileMessageCell.setImage(nil)
                                self.loadedImageHash.removeValue(forKey: String(format: "%lld", fileMessage.messageId))
                            }
                        }
                    }
                    else if fileMessage.type.hasPrefix("audio") {
                        // Incoming audio file message.
                        guard let audioFileMessageCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelIncomingAudioFileMessageTableViewCell") as? GroupChannelIncomingAudioFileMessageTableViewCell else { return cell }
                        audioFileMessageCell.delegate = self
                        audioFileMessageCell.setMessage(currMessage: fileMessage, prevMessage: prevMessage, nextMessage: nextMessage)
                        
                        DispatchQueue.main.async {
                            guard let updateCell = tableView.cellForRow(at: indexPath) else { return }
                            guard let updateAudioFileMessageCell = updateCell as? GroupChannelIncomingAudioFileMessageTableViewCell else { return }
                            
                            if let url = URL(string: Utils.transformUserProfileImage(user: sender)) {
                                updateAudioFileMessageCell.profileImageView.af_setImage(withURL: url, placeholderImage: Utils.getDefaultUserProfileImage(user: sender))
                            }
                            else {
                                updateAudioFileMessageCell.profileImageView.image = Utils.getDefaultUserProfileImage(user: sender)
                            }
                        }
                        
                        cell = audioFileMessageCell
                    }
                    else {
                        // Incoming general file message.
                        guard let generalFileMessageCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelIncomingGeneralFileMessageTableViewCell") as? GroupChannelIncomingGeneralFileMessageTableViewCell else { return cell }
                        generalFileMessageCell.delegate = self
                        generalFileMessageCell.setMessage(currMessage: fileMessage, prevMessage: prevMessage, nextMessage: nextMessage)
                        
                        DispatchQueue.main.async {
                            guard let updateCell = tableView.cellForRow(at: indexPath) else { return }
                            guard let updateGeneralFileMessageCell = updateCell as? GroupChannelIncomingGeneralFileMessageTableViewCell else { return }
                            
                            if let url = URL(string: Utils.transformUserProfileImage(user: sender)) {
                                updateGeneralFileMessageCell.profileImageView.af_setImage(withURL: url, placeholderImage: Utils.getDefaultUserProfileImage(user: sender))
                            }
                            else {
                                updateGeneralFileMessageCell.profileImageView.image = Utils.getDefaultUserProfileImage(user: sender)
                            }
                        }
                        
                        cell = generalFileMessageCell
                    }
                }
            }
        }
        
        if indexPath.row == 0 && self.messages.count > 0 && self.initialLoading == false && self.isLoading == false {
            self.loadPreviousMessages(initial: false)
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    // MARK: - UITableViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.stopMeasuringVelocity = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.stopMeasuringVelocity = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.messageTableView {
            if self.stopMeasuringVelocity == false {
                let currentOffset = scrollView.contentOffset
                let currentTime = Date.timeIntervalSinceReferenceDate
                let timeDiff = currentTime - self.lastOffsetCapture
                if timeDiff > 0.1 {
                    let distance = currentOffset.y - self.lastOffset.y
                    //The multiply by 10, / 1000 isn't really necessary.......
                    let scrollSpeedNotAbs = distance * 10 / 1000
                    let scrollSpeed = abs(scrollSpeedNotAbs)
                    if scrollSpeed > 1.0 {
                        self.isScrollingFast = true
                    }
                    else {
                        self.isScrollingFast = false
                    }
                    
                    self.lastOffset = currentOffset
                    self.lastOffsetCapture = currentTime
                }
                
                if self.isScrollingFast {
                    self.hideKeyboardWhenFastScrolling()
                }
            }
        }
    }
    
    // MARK: - SBDChannelDelegate
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        if sender == self.channel {
            guard let channel = self.channel else { return }
            channel.markAsRead()
            if let delegate = self.delegate {
                if delegate.responds(to: #selector(GroupChannelsUpdateListDelegate.updateGroupChannelList)) {
                    delegate.updateGroupChannelList!()
                }
            }
            DispatchQueue.main.async {
                self.determineScrollLock()
                UIView.setAnimationsEnabled(false)
                self.messages.append(message)
//                self.messageTableView.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .none)
                self.messageTableView.reloadData()
                self.messageTableView.layoutIfNeeded()
                self.scrollToBottom(force: false)
                UIView.setAnimationsEnabled(true)
            }
        }
    }
    
    func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
        if sender == self.channel {
            DispatchQueue.main.async {
                UIView.setAnimationsEnabled(false)
                self.messageTableView.reloadData()
                self.messageTableView.layoutIfNeeded()
                self.messageTableView.setContentOffset(self.messageTableView.contentOffset, animated: false)
                UIView.setAnimationsEnabled(true)
            }
        }
    }
    
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        let typingIndicatorText = Utils.buildTypingIndicatorLabel(channel: sender)
        if self.typingIndicatorTimer != nil {
            self.typingIndicatorTimer!.invalidate()
            self.typingIndicatorTimer = nil
        }
        self.typingIndicatorTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(GroupChannelChatViewController.hideTypingIndicator(_:)), userInfo: nil, repeats: false)
        
        if typingIndicatorText.count > 0 {
            DispatchQueue.main.async {
                self.typingIndicatorContainerView.isHidden = false
                self.typingIndicatorLabel.text = typingIndicatorText
                self.messageTableViewBottomMargin.constant = self.typingIndicatorContainerViewHeight.constant
                self.view.updateConstraints()
                self.view.layoutIfNeeded()
                
                self.stopMeasuringVelocity = true
                self.determineScrollLock()
                self.scrollToBottom(force: false)
            }
        }
        else {
            DispatchQueue.main.async {
                self.typingIndicatorContainerView.isHidden = true
                self.messageTableViewBottomMargin.constant = 0
                self.view.updateConstraints()
                self.view.layoutIfNeeded()
                
                self.stopMeasuringVelocity = true
                self.determineScrollLock()
                self.scrollToBottom(force: false)
            }
        }
    }
    
    func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        let vc = UIAlertController(title: "Channel has been deleted.", message: "This channel has been deleted. It will be closed.", preferredStyle: .alert)
        let actionClose = UIAlertAction(title: "Close", style: .cancel) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        vc.addAction(actionClose)
        
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        DispatchQueue.main.async {
            guard let channel = self.channel else { return }
            
            if sender == channel {
                self.deleteMessageFromTableView(messageId)
            }
        }
    }
    
    func channelWasChanged(_ sender: SBDBaseChannel) {
        DispatchQueue.main.async {
            guard let channel = self.channel else { return }
            
            if sender == channel {
                self.title = channel.name
            }
        }
    }
    
    // MARK: - Crop Image
    func cropImage(_ imageData: Data) {
        if let image = UIImage(data: imageData) {
            let imageCropVC = RSKImageCropViewController(image: image)
            imageCropVC.delegate = self
            imageCropVC.cropMode = .square
            self.present(imageCropVC, animated: false, completion: nil)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        
        picker.dismiss(animated: true, completion: { [unowned self] () in
            if CFStringCompare(mediaType, kUTTypeImage, []) == .compareEqualTo {
                if let imagePath = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                    let imageName = imagePath.lastPathComponent
                    let ext = imageName.pathExtension()
                    guard let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)?.takeRetainedValue() else { return }
                    guard let retainedValueMimeType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType)?.takeRetainedValue() else { return }
                    let mimeType = retainedValueMimeType as String
                    
                    guard let imageAsset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset else { return }
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    options.isNetworkAccessAllowed = true
                    options.deliveryMode = .highQualityFormat
                    
                    if mimeType == "image/gif" {
                        PHImageManager.default().requestImageData(for: imageAsset, options: options, resultHandler: { (imageData, dataUTI, orientation, info) in
                            if let originalImageData = imageData {
                                self.sendImageFileMessage(imageData: originalImageData, imageName: imageName, mimeType: mimeType)
                            }
                        })
                    }
                    else {
                        var count = 0
                        let reqOptions = PHImageRequestOptions()
                        reqOptions.isSynchronous = true
                        reqOptions.isNetworkAccessAllowed = true
                        reqOptions.deliveryMode = .highQualityFormat
                        PHImageManager.default().requestImage(for: imageAsset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: reqOptions, resultHandler: { (result, info) in
                            count += 1
                            if result != nil {
                                guard let imageData = result?.jpegData(compressionQuality: 1.0) else { return }
                                self.sendImageFileMessage(imageData: imageData, imageName: imageName, mimeType: mimeType)
                            }
                        })
                    }
                }
                else {
                    guard let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
                    guard let imageData = originalImage.jpegData(compressionQuality: 1.0) else { return }
                    self.sendImageFileMessage(imageData: imageData, imageName: "image.jpg", mimeType: "image/jpeg")
                }
            } else if CFStringCompare(mediaType, kUTTypeMovie, []) == .compareEqualTo {
                self.sendVideoFileMessage(info: info)
            }
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - RSKImageCropViewControllerDelegate
    // Crop image has been canceled.
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: false, completion: nil)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        controller.dismiss(animated: false, completion: nil)
    }
    
    // The original image will be cropped.
    func imageCropViewController(_ controller: RSKImageCropViewController, willCropImage originalImage: UIImage) {
        // Use when `applyMaskToCroppedImage` set to YES.
    }
    
    // MARK: - SBDConnectionDelegate
    func didSucceedReconnection() {
        self.loadPreviousMessages(initial: true)
        guard let channel = self.channel else { return }
        channel.refresh(completionHandler: nil)
    }
    
    func didFailReconnection() {
        let connectState = SBDMain.getConnectState()
        print(connectState)
    }
    
    // MARK: - SBDNetworkDelegate
    func didReconnect() {
        // TODO: Fix bug in SDK.
    }
   
    // MARK - GroupChannelSettingsDelegate
    func didLeaveChannel() {
        guard let navigationController = self.navigationController else { return }
        if navigationController is CreateGroupChannelNavigationController {
            self.dismiss(animated: false, completion: nil)
        }
        else {
            navigationController.popViewController(animated: false)
        }
    }
    
    // MARK - GroupChannelMessageTableViewCellDelegate
    func didLongClickAdminMessage(_ message: SBDAdminMessage) {
        let vc = UIAlertController(title: message.message, message: nil, preferredStyle: .actionSheet)
        let actionCopyMessage = UIAlertAction(title: "Copy message", style: .default) { (action) in
            let pasteboard = UIPasteboard.general
            pasteboard.string = message.message
            
            self.showToast("Copied")
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        vc.addAction(actionCopyMessage)
        vc.addAction(actionCancel)
        
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func didLongClickUserMessage(_ message: SBDUserMessage) {
        let vc = UIAlertController(title: message.message, message: nil, preferredStyle: .actionSheet)
        var actionDeleteMessage: UIAlertAction?
        guard let channel = self.channel else { return }
        guard let sender = message.sender else { return }
        guard let currentUser = SBDMain.getCurrentUser() else { return }
        
        if sender.userId == currentUser.userId {
            actionDeleteMessage = UIAlertAction(title: "Delete message", style: .destructive, handler: { (action) in
                let subVc = UIAlertController(title: "Are you sure you want to delete this message?", message: nil, preferredStyle: .actionSheet)
                let subActionDeleteMessage = UIAlertAction(title: "Yes. Delete the message", style: .default, handler: { (action) in
                    channel.delete(message, completionHandler: { (error) in
                        if error != nil {
                            let vc = UIAlertController(title: "Error", message: error!.domain, preferredStyle: .alert)
                            let actionClose = UIAlertAction(title: "Close", style: .cancel, handler: nil)
                            vc.addAction(actionClose)
                            DispatchQueue.main.async {
                                self.present(vc, animated: true, completion: nil)
                            }
                            
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.deleteMessageFromTableView(message.messageId)
                        }
                    })
                })
                let subActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                subVc.addAction(subActionDeleteMessage)
                subVc.addAction(subActionCancel)
                DispatchQueue.main.async {
                    self.present(subVc, animated: true, completion: nil)
                }
            })
        }
        
        let actionCopyMessage = UIAlertAction(title: "Copy message", style: .default) { (action) in
            let pasteboard = UIPasteboard.general
            pasteboard.string = message.message
            
            self.showToast("Copied")
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        vc.addAction(actionCopyMessage)
        if actionDeleteMessage != nil {
            vc.addAction(actionDeleteMessage!)
        }
        
        vc.addAction(actionCancel)
        
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func didClickVideoFileMessage(_ message: SBDFileMessage) {
        if self.resendableFileData[message.requestId!] == nil && message.url.count > 0 {
            if let videoUrl = URL(string: message.url) {
                self.playMedia(videoUrl)
            }
        }
    }
    
    func didClickAudioFileMessage(_ message: SBDFileMessage) {
        if self.resendableFileData[message.requestId!] == nil && message.url.count > 0 {
            if let audioUrl = URL(string: message.url) {
                self.playMedia(audioUrl)
            }
        }
    }
    
    func didLongClickGeneralFileMessage(_ message: SBDFileMessage) {
        guard let requestId = message.requestId else { return }
        guard let url = URL(string: message.url) else { return }
        guard let sender = message.sender else { return }
        guard let currentUser = SBDMain.getCurrentUser() else { return }
        guard let channel = self.channel else { return }
        if self.resendableFileData[requestId] == nil {
            let vc = UIAlertController(title: "General file", message: nil, preferredStyle: .actionSheet)
            let actionSaveFile = UIAlertAction(title: "Save File", style: .default) { (action) in
                DownloadManager.download(url: url, filename: message.name, mimeType: message.type, addToMediaLibrary: false)
            }
            var actionDelete: UIAlertAction?
            
            if sender.userId == currentUser.userId {
                actionDelete = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                    let subVc = UIAlertController(title: "Are you sure you want to delete this message?", message: nil, preferredStyle: .actionSheet)
                    let subActionDeleteMessage = UIAlertAction(title: "Yes. Delete the message", style: .default, handler: { (action) in
                        channel.delete(message, completionHandler: { (error) in
                            if error != nil {
                                let vc = UIAlertController(title: "Error", message: error!.domain, preferredStyle: .alert)
                                let actionClose = UIAlertAction(title: "Close", style: .cancel, handler: nil)
                                vc.addAction(actionClose)
                                DispatchQueue.main.async {
                                    self.present(vc, animated: true, completion: nil)
                                }
                                
                                return
                            }
                            
                            DispatchQueue.main.async {
                                self.deleteMessageFromTableView(message.messageId)
                            }
                        })
                    })
                    let subActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    subVc.addAction(subActionDeleteMessage)
                    subVc.addAction(subActionCancel)
                    DispatchQueue.main.async {
                        self.present(subVc, animated: true, completion: nil)
                    }
                })
            }
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            vc.addAction(actionSaveFile)
            if actionDelete != nil {
                vc.addAction(actionDelete!)
            }
            vc.addAction(actionCancel)
            
            DispatchQueue.main.async {
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func didClickResendUserMessage(_ message: SBDUserMessage) {
        guard let messageText = message.message else { return }
        guard let channel = self.channel else { return }
        guard let params = SBDUserMessageParams(message: messageText) else { return }
        var preSendMessage: SBDUserMessage?
        preSendMessage = channel.sendUserMessage(with: params, completionHandler: { (userMessage, error) in
            if error != nil {
                DispatchQueue.main.async {
                    guard let preSendMessageRequestId = preSendMessage?.requestId else { return }
                    self.determineScrollLock()
                    self.preSendMessages.removeValue(forKey: preSendMessageRequestId)
                    self.resendableMessages[preSendMessageRequestId] = preSendMessage
                    self.messageTableView.reloadData()
                    self.scrollToBottom(force: false)
                }
                
                return
            }
            
            if let delegate = self.delegate {
                if delegate.responds(to: #selector(GroupChannelsUpdateListDelegate.updateGroupChannelList)) {
                    delegate.updateGroupChannelList!()
                }
            }
            
            DispatchQueue.main.async {
                self.determineScrollLock()
                self.messages[self.messages.firstIndex(of: self.preSendMessages[(userMessage?.requestId)!]!)!] = userMessage!
                self.preSendMessages.removeValue(forKey: (userMessage?.requestId)!)
                self.messageTableView.reloadData()
                self.scrollToBottom(force: false)
            }
        })
        
        DispatchQueue.main.async {
            self.determineScrollLock()
            self.messages[self.messages.firstIndex(of: message)!] = preSendMessage!
            self.resendableMessages.removeValue(forKey: (message.requestId)!)
            self.preSendMessages[(preSendMessage?.requestId)!] = preSendMessage
            self.messageTableView.reloadData()
            self.scrollToBottom(force: false)
        }
    }
    
    func didLongClickUserProfile(_ user: SBDUser) {
        guard let currentUser = SBDMain.getCurrentUser() else { return }
        if user.userId == currentUser.userId {
            return
        }
        
        let vc = UIAlertController(title: user.nickname, message: nil, preferredStyle: .actionSheet)
        let actionBlockUser = UIAlertAction(title: "Block user", style: .default) { (action) in
            SBDMain.blockUser(user, completionHandler: { (blockedUser, error) in
                
            })
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        vc.addAction(actionBlockUser)
        vc.addAction(actionCancel)

        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func didLongClickImageVideoFileMessage(_ message: SBDFileMessage) {
        guard let messageRequestId = message.requestId else { return }
        if self.resendableFileData[messageRequestId] == nil {
            var vc: UIAlertController?
            var deleteMessageActionTitle: String?
            var saveImageVideoActionTitle: String?
            var deleteMessageSubAlertTitle: String?
            var deleteMessageSubActionTitle: String?
            if message.type.hasPrefix("image") {
                vc = UIAlertController(title: "Image", message: nil, preferredStyle: .actionSheet)
                deleteMessageActionTitle = "Delete image"
                saveImageVideoActionTitle = "Save image to media library"
                deleteMessageSubAlertTitle = "Are you sure you want to delete this image?"
                deleteMessageSubActionTitle = "Yes. Delete the image"
            }
            else {
                vc = UIAlertController(title: "Video", message: nil, preferredStyle: .actionSheet)
                deleteMessageActionTitle = "Delete video"
                saveImageVideoActionTitle = "Save video to media library"
                deleteMessageSubAlertTitle = "Are you sure you want to delete this video?"
                deleteMessageSubActionTitle = "Yes. Delete the video"
            }
            
            var actionDeleteMessage: UIAlertAction?
            guard let sender = message.sender else { return }
            guard let currentUser = SBDMain.getCurrentUser() else { return }
            if sender.userId == currentUser.userId {
                actionDeleteMessage = UIAlertAction(title: deleteMessageActionTitle, style: .destructive, handler: { (action) in
                    let subVc = UIAlertController(title: deleteMessageSubAlertTitle, message: nil, preferredStyle: .actionSheet)
                    let subActionDeleteMessage = UIAlertAction(title: deleteMessageSubActionTitle, style: .default, handler: { (action) in
                        guard let channel = self.channel else { return }
                        channel.delete(message, completionHandler: { (error) in
                            if error != nil {
                                return
                            }
                            
                            // TODO:
                        })
                    })
                    let subActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    subVc.addAction(subActionDeleteMessage)
                    subVc.addAction(subActionCancel)
                    DispatchQueue.main.async {
                        self.present(subVc, animated: true, completion: nil)
                    }
                })
            }
            
            let actionSaveImageVideo = UIAlertAction(title: saveImageVideoActionTitle, style: .default) { (action) in
                if let url = URL(string: message.url) {
                    DownloadManager.download(url: url, filename: message.name, mimeType: message.type, addToMediaLibrary: true)
                }
            }
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            if vc != nil {
                vc?.addAction(actionSaveImageVideo)
                if actionDeleteMessage != nil {
                    vc?.addAction(actionDeleteMessage!)
                }
                vc?.addAction(actionCancel)
                
                DispatchQueue.main.async {
                    self.present(vc!, animated: true, completion: nil)
                }
            }
        }
    }
    
    func didClickImageVideoFileMessage(_ message: SBDFileMessage) {
        if message.requestId == nil ||  self.resendableFileData[message.requestId!] == nil {
            if message.type.hasPrefix("image") {
                self.loadingIndicatorView.isHidden = false
                self.loadingIndicatorView.startAnimating()
                let session = URLSession.shared
                guard let url = URL(string: message.url) else {
                    self.loadingIndicatorView.isHidden = true
                    self.loadingIndicatorView.stopAnimating()
                    return
                }
                let request = URLRequest(url: url)
                let task = session.dataTask(with: request) { (data, response, error) in
                    let resp = response as! HTTPURLResponse
                    if resp.statusCode >= 200 && resp.statusCode < 300 {
                        let photo = PhotoViewer()
                        photo.imageData = data
                        
                        DispatchQueue.main.async {
                            let photosViewController = CustomPhotosViewController(photos: [photo])
                            
                            self.loadingIndicatorView.isHidden = true
                            self.loadingIndicatorView.stopAnimating()
                            
                            self.present(photosViewController, animated: true, completion: nil)
                        }
                    }
                    else {
                        self.loadingIndicatorView.isHidden = true
                        self.loadingIndicatorView.stopAnimating()
                    }
                }
                task.resume()
            }
            else if message.type.hasPrefix("video") {
                guard let url = URL(string: message.url) else {
                    self.loadingIndicatorView.isHidden = true
                    self.loadingIndicatorView.stopAnimating()
                    return
                }
                let player = AVPlayer(url: url)
                let vc = AVPlayerViewController()
                vc.player = player
                self.present(vc, animated: true) {
                    player.play()
                }
            }
        }
    }
    
    func didClickUserProfile(_ user: SBDUser) {
        DispatchQueue.main.async {
            let vc = UserProfileViewController.init(nibName: "UserProfileViewController", bundle: nil)
            vc.user = user
            guard let navigationController = self.navigationController else { return }
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func didClickResendImageVideoFileMessage(_ message: SBDFileMessage) {
        guard let messageRequestId = message.requestId else { return }
        guard let imageData = self.resendableFileData[messageRequestId]!["data"] as? Data else { return }
        guard let filename = self.resendableFileData[messageRequestId]!["filename"] as? String else { return }
        guard let mimeType = self.resendableFileData[messageRequestId]!["type"] as? String else { return }
        guard let channel = self.channel else { return }
        
        let thumbnailSize = SBDThumbnailSize.make(withMaxWidth: 320.0, maxHeight: 320.0)
        
        var preSendMessage: SBDFileMessage?
        let fileMessageParams = SBDFileMessageParams(file: imageData)
        fileMessageParams?.fileName = filename
        fileMessageParams?.mimeType = mimeType
        fileMessageParams?.fileSize = UInt(imageData.count)
        fileMessageParams?.thumbnailSizes = [thumbnailSize] as? [SBDThumbnailSize]
        preSendMessage = channel.sendFileMessage(with: fileMessageParams!, progressHandler: { (bytesSent, totalBytesSent, totalBytesExpectedToSend) in
            DispatchQueue.main.async {
                guard let preSendMessageRequest = preSendMessage?.requestId else { return }
                self.fileTransferProgress[preSendMessageRequest] = CGFloat(totalBytesSent) / CGFloat(totalBytesExpectedToSend)
                for index in stride(from: self.messages.count - 1, to: -1, by: -1) {
                    let baseMessage = self.messages[index]
                    if baseMessage is SBDFileMessage {
                        let fileMessage = baseMessage as! SBDFileMessage
                        if fileMessage.requestId != nil && fileMessage.requestId == preSendMessageRequest {
                            self.determineScrollLock()
                            let indexPath = IndexPath(row: index, section: 0)
                            self.messageTableView.reloadRows(at: [indexPath], with: .none)
                        }
                    }
                }
            }
        }, completionHandler: { (fileMessage, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150), execute: {
                guard let fileMessageRequestId = fileMessage?.requestId else { return }
                guard let preSendMessage = self.preSendMessages[fileMessageRequestId] as? SBDFileMessage else { return }
                self.preSendMessages.removeValue(forKey: fileMessageRequestId)
                
                if error != nil {
                    DispatchQueue.main.async {
                        self.determineScrollLock()
                        self.resendableMessages[fileMessageRequestId] = preSendMessage
                        guard let preSendMessageRequestId = preSendMessage.requestId else { return }
                        self.resendableFileData[preSendMessageRequestId] = [
                            "data": imageData,
                            "type": mimeType,
                            "filename": filename
                            ] as [String:AnyObject]
                        self.messageTableView.reloadData()
                        self.scrollToBottom(force: false)
                    }
                    
                    return
                }
                
                if let delegate = self.delegate {
                    if delegate.responds(to: #selector(GroupChannelsViewController.updateGroupChannelList)) {
                        delegate.updateGroupChannelList!()
                    }
                }
                
                if fileMessage != nil {
                    DispatchQueue.main.async {
                        self.determineScrollLock()
                        self.resendableMessages.removeValue(forKey: fileMessageRequestId)
                        self.resendableFileData.removeValue(forKey: fileMessageRequestId)
                        self.messages[self.messages.firstIndex(of: preSendMessage)!] = fileMessage!
                        self.messageTableView.reloadData()
                    }
                }
            })
        })
        
        DispatchQueue.main.async {
            guard let preSendMessageRequestId = preSendMessage?.requestId else { return }
            self.determineScrollLock()
            
            self.fileTransferProgress[preSendMessageRequestId] = 0
            self.preSendFileData[preSendMessageRequestId] = [
                "data": imageData,
                "type": mimeType,
                "filename": filename,
                ] as [String:AnyObject]
            self.preSendMessages[preSendMessageRequestId] = preSendMessage
            self.messages[self.messages.firstIndex(of: message)!] = preSendMessage!
            self.resendableMessages.removeValue(forKey: messageRequestId)
            self.resendableFileData.removeValue(forKey: messageRequestId)
            self.preSendMessages[preSendMessageRequestId] = preSendMessage
            self.messageTableView.reloadData()
            self.scrollToBottom(force: false)
        }
    }
    
    func didClickResendAudioGeneralFileMessage(_ message: SBDFileMessage) {
        guard let messageRequestId = message.requestId else { return }
        guard let fileData = self.resendableFileData[messageRequestId]!["data"] as? Data else { return }
        guard let filename = self.resendableFileData[messageRequestId]!["filename"] as? String else { return }
        guard let mimeType = self.resendableFileData[messageRequestId]!["type"] as? String else { return }
        guard let channel = self.channel else { return }
        
        var preSendMessage: SBDFileMessage?
        let fileMessageParams = SBDFileMessageParams(file: fileData)
        fileMessageParams?.fileName = filename
        fileMessageParams?.mimeType = mimeType
        fileMessageParams?.fileSize = UInt(fileData.count)
        
        preSendMessage = channel.sendFileMessage(with: fileMessageParams!, progressHandler: { (bytesSent, totalBytesSent, totalBytesExpectedToSend) in
            DispatchQueue.main.async {
                guard let preSendMessageRequest = preSendMessage?.requestId else { return }
                self.fileTransferProgress[preSendMessageRequest] = CGFloat(totalBytesSent) / CGFloat(totalBytesExpectedToSend)
                for index in stride(from: self.messages.count - 1, to: -1, by: -1) {
                    let baseMessage = self.messages[index]
                    if baseMessage is SBDFileMessage {
                        let fileMessage = baseMessage as! SBDFileMessage
                        if fileMessage.requestId != nil && fileMessage.requestId == preSendMessageRequest {
                            self.determineScrollLock()
                            let indexPath = IndexPath(row: index, section: 0)
                            self.messageTableView.reloadRows(at: [indexPath], with: .none)
                        }
                    }
                }
            }
        }, completionHandler: { (fileMessage, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150), execute: {
                guard let fileMessageRequestId = fileMessage?.requestId else { return }
                guard let preSendMessage = self.preSendMessages[fileMessageRequestId] as? SBDFileMessage else { return }
                self.preSendMessages.removeValue(forKey: fileMessageRequestId)
                
                if error != nil {
                    DispatchQueue.main.async {
                        self.determineScrollLock()
                        self.resendableMessages[fileMessageRequestId] = preSendMessage
                        guard let preSendMessageRequestId = preSendMessage.requestId else { return }
                        self.resendableFileData[preSendMessageRequestId] = [
                            "data": fileData,
                            "type": mimeType,
                            "filename": filename
                            ] as [String:AnyObject]
                        self.messageTableView.reloadData()
                        self.messageTableView.layoutIfNeeded()
                        self.scrollToBottom(force: false)
                    }
                    
                    return
                }
                
                if let delegate = self.delegate {
                    if delegate.responds(to: #selector(GroupChannelsViewController.updateGroupChannelList)) {
                        delegate.updateGroupChannelList!()
                    }
                }
                
                if fileMessage != nil {
                    DispatchQueue.main.async {
                        self.determineScrollLock()
                        self.resendableMessages.removeValue(forKey: fileMessageRequestId)
                        self.resendableFileData.removeValue(forKey: fileMessageRequestId)
                        if let firstIndex = self.messages.firstIndex(of: preSendMessage) {
                            self.messages[firstIndex] = fileMessage!
                        }
                        self.messageTableView.reloadData()
                        self.messageTableView.layoutIfNeeded()
                    }
                }
            })
        })
        
        DispatchQueue.main.async {
            guard let preSendMessageRequestId = preSendMessage?.requestId else { return }
            self.determineScrollLock()
            
            self.fileTransferProgress[preSendMessageRequestId] = 0
            self.preSendFileData[preSendMessageRequestId] = [
                "data": fileData,
                "type": mimeType,
                "filename": filename,
                ] as [String:AnyObject]
            self.preSendMessages[preSendMessageRequestId] = preSendMessage
            self.messages[self.messages.firstIndex(of: message)!] = preSendMessage!
            self.resendableMessages.removeValue(forKey: messageRequestId)
            self.resendableFileData.removeValue(forKey: messageRequestId)
            self.preSendMessages[preSendMessageRequestId] = preSendMessage
            self.messageTableView.reloadData()
            self.messageTableView.layoutIfNeeded()
            self.scrollToBottom(force: false)
        }
    }
    
    @objc func inputMessageTextFieldChanged(_ sender: Any) {
        guard let channel = self.channel else { return }
        guard let textField = sender as? UITextField else { return }
        if textField.text!.count > 0 {
            channel.startTyping()
            self.sendUserMessageButton.isEnabled = true
        }
        else {
            channel.endTyping()
            self.sendUserMessageButton.isEnabled = false
        }
    }
    
    // MARK: - UIDocumentPickerDelegate
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.pickerControllerOpened = false
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.pickerControllerOpened = false
        if urls.count > 0 {
            let fileURL = urls[0]
            do {
                let fileData = try Data(contentsOf: fileURL)
                let filename = fileURL.lastPathComponent
                let ext = filename.pathExtension()
                guard let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)?.takeRetainedValue() else { return }
                guard let retainedValueMimeType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType)?.takeRetainedValue() else { return }
                let mimeType = retainedValueMimeType as String
                guard let channel = self.channel else { return }
                var preSendMessage: SBDFileMessage?
                
                guard let params = SBDFileMessageParams(file: fileData) else { return }
                params.fileName = filename
                params.mimeType = mimeType
                params.fileSize = UInt(fileData.count)
                preSendMessage = channel.sendFileMessage(with: params, progressHandler: { (bytesSent, totalBytesSent, totalBytesExpectedToSend) in
                    DispatchQueue.main.async {
                        guard let preSendMessageRequestId = preSendMessage!.requestId else { return }
                        self.fileTransferProgress[preSendMessageRequestId] = CGFloat(totalBytesSent) / CGFloat(totalBytesExpectedToSend)
                        for index in stride(from: self.messages.count - 1, to: -1, by: -1) {
                            let baseMessage = self.messages[index]
                            if baseMessage is SBDFileMessage {
                                guard let fileMessage = (baseMessage as? SBDFileMessage) else { continue }
                                guard let fileMessageRequestId = fileMessage.requestId else { continue }
                                
                                if fileMessageRequestId == preSendMessageRequestId {
                                    let indexPath = IndexPath(row: index, section: 0)
                                    self.messageTableView.reloadRows(at: [indexPath], with: .none)
                                    self.messageTableView.layoutIfNeeded()
                                }
                            }
                        }
                    }
                }, completionHandler: { (fileMessage, error) in
                    guard let message = fileMessage else { return }
                    guard let fileMessageRequestId = message.requestId else { return }
                    let preSendMessage = self.preSendMessages[fileMessageRequestId] as? SBDFileMessage
                    self.preSendMessages.removeValue(forKey: fileMessageRequestId)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150), execute: {
                        if error != nil {
                            self.resendableMessages[fileMessageRequestId] = preSendMessage
                            guard let preSendMessageRequestId = preSendMessage?.requestId else { return }
                            self.resendableFileData[preSendMessageRequestId] = [
                                "data": fileData,
                                "type": mimeType,
                                "filename": filename
                                ] as [String:AnyObject]
                            
                            DispatchQueue.main.async {
                                self.determineScrollLock()
                                self.messageTableView.reloadData()
                                self.messageTableView.layoutIfNeeded()
                                self.scrollToBottom(force: false)
                            }
                            
                            return
                        }
                        
                        guard let message = fileMessage else { return }
                        DispatchQueue.main.async {
                            guard let fileMessageRequestId = message.requestId else { return }
                            
                            self.resendableMessages.removeValue(forKey: fileMessageRequestId)
                            self.resendableFileData.removeValue(forKey: fileMessageRequestId)
                            
                            guard let preSendMessageIndex = self.messages.firstIndex(of: preSendMessage!) else { return }
                            
                            self.messages[preSendMessageIndex] = message
                            self.determineScrollLock()
                            self.messageTableView.reloadData()
                        }
                    })
                })
                
                DispatchQueue.main.async {
                    guard let preSendMsg = preSendMessage else { return }
                    guard let preSendMsgRequestId = preSendMsg.requestId else { return }
                    
                    self.fileTransferProgress[preSendMsgRequestId] = 0
                    self.preSendFileData[preSendMsgRequestId] = [
                        "data": fileData,
                        "type": mimeType,
                        "filename": filename,
                        ] as [String:AnyObject]
                    self.determineScrollLock()
                    self.preSendMessages[preSendMsgRequestId] = preSendMsg
                    self.messages.append(preSendMsg)
                    self.messageTableView.reloadData()
                    self.scrollToBottom(force: false)
                }
            }
            catch {
            }
        }
    }
    
    private func deleteMessageFromTableView(_ messageId: Int64) {
        if self.messages.count == 0 {
            return
        }
        
        for i in 0...self.messages.count-1 {
            let msg = self.messages[i]
            if msg.messageId == messageId {
                self.determineScrollLock()
                self.messages.removeObject(msg)
                self.messageTableView.reloadData()
                self.messageTableView.layoutIfNeeded()
                self.scrollToBottom(force: false)
                
                break
            }
        }
    }
    
    private func playMedia(_ url: URL) {
        let player = AVPlayer(url: url)
        let vc = AVPlayerViewController()
        vc.player = player
        self.present(vc, animated: true) {
            player.play()
        }
    }
    
    private func sendImageFileMessage(imageData: Data, imageName: String, mimeType: String) {
        // success, data is in imageData
        /***********************************/
        /* Thumbnail is a premium feature. */
        /***********************************/
        
        let thumbnailSize = SBDThumbnailSize.make(withMaxWidth: 320.0, maxHeight: 320.0)
        var preSendMessage: SBDFileMessage?
        
        let fileMessageParams = SBDFileMessageParams(file: imageData)!
        fileMessageParams.fileName = imageName
        fileMessageParams.mimeType = mimeType
        fileMessageParams.fileSize = UInt(imageData.count)
        fileMessageParams.thumbnailSizes = [thumbnailSize] as? [SBDThumbnailSize]
        fileMessageParams.data = nil
        fileMessageParams.customType = nil
        guard let channel = self.channel else { return }
        preSendMessage = channel.sendFileMessage(with: fileMessageParams, progressHandler: { [unowned self] (bytesSent, totalBytesSent, totalBytesExpectedToSend) in
            DispatchQueue.main.async {
                guard let preSendMessageRequestId = preSendMessage!.requestId else { return }
                
                if self.sendingImageVideoMessage[preSendMessageRequestId] == nil {
                    self.sendingImageVideoMessage[preSendMessageRequestId] = false
                }
                
                self.fileTransferProgress[preSendMessageRequestId] = CGFloat(totalBytesSent) / CGFloat(totalBytesExpectedToSend)
                for index in stride(from: self.messages.count - 1, to: -1, by: -1) {
                    let baseMessage = self.messages[index]
                    if baseMessage is SBDFileMessage {
                        let fileMessage = baseMessage as! SBDFileMessage
                        guard let fileMessageRequestId = fileMessage.requestId else { return }
                        if fileMessageRequestId == preSendMessageRequestId {
                            self.determineScrollLock()
                            let indexPath = IndexPath(row: index, section: 0)
                            if self.sendingImageVideoMessage[preSendMessageRequestId] == false {
                                self.messageTableView.reloadRows(at: [indexPath], with: .none)
                                self.sendingImageVideoMessage[preSendMessageRequestId] = true
                                self.scrollToBottom(force: false)
                            }
                            else {
                                if let cell = self.messageTableView.cellForRow(at: indexPath) as? GroupChannelOutgoingImageVideoFileMessageTableViewCell {
                                    cell.showProgress(CGFloat(totalBytesSent) / CGFloat(totalBytesExpectedToSend))
                                }
                            }
                            
                            break
                        }
                    }
                }
            }
            }, completionHandler: { [unowned self] (fileMessage, error) in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 150 * NSEC_PER_MSEC), execute: {
                    guard let fileMessageRequestId = fileMessage?.requestId else { return }
                    let preSendMessage = self.preSendMessages[fileMessageRequestId] as! SBDFileMessage
                    
                    self.preSendMessages.removeValue(forKey: fileMessageRequestId)
                    self.sendingImageVideoMessage.removeValue(forKey: fileMessageRequestId)
                    
                    if error != nil {
                        DispatchQueue.main.async {
                            self.resendableMessages[fileMessageRequestId] = preSendMessage
                            self.resendableFileData[preSendMessage.requestId!] = [
                                "data": imageData,
                                "type": mimeType,
                                "filename": imageName
                                ] as [String : AnyObject]
                            self.messageTableView.reloadData()
                            self.scrollToBottom(force: true)
                        }
                        
                        return
                    }
                    
                    if fileMessage != nil {
                        DispatchQueue.main.async {
                            self.determineScrollLock()
                            self.resendableMessages.removeValue(forKey: fileMessageRequestId)
                            self.resendableFileData.removeValue(forKey: fileMessageRequestId)
                            self.messages[self.messages.firstIndex(of: preSendMessage)!] = fileMessage!
                            let indexPath = IndexPath(row: self.messages.firstIndex(of: fileMessage!)!, section: 0)
                            self.messageTableView.reloadRows(at: [indexPath], with: .none)
                            self.messageTableView.layoutIfNeeded()
                            self.scrollToBottom(force: false)
                        }
                    }
                })
        })
        
        DispatchQueue.main.async {
            self.determineScrollLock()
            self.fileTransferProgress[preSendMessage!.requestId!] = 0
            self.preSendFileData[preSendMessage!.requestId!] = [
                "data": imageData,
                "type": mimeType,
                "filename": imageName
                ] as [String : AnyObject]
            self.preSendMessages[preSendMessage!.requestId!] = preSendMessage
            self.messages.append(preSendMessage!)
            self.messageTableView.reloadData()
            self.messageTableView.layoutIfNeeded()
            self.scrollToBottom(force: false)
        }
    }
    
    private func sendVideoFileMessage(info: [UIImagePickerController.InfoKey : Any]) {
        do {
            guard let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
            let videoFileData = try Data(contentsOf: videoUrl)
            let videoName = videoUrl.lastPathComponent
            let ext = videoName.pathExtension()
            guard let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)?.takeRetainedValue() else { return }
            guard let retainedValueMimeType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType)?.takeRetainedValue() else { return }
            let mimeType = retainedValueMimeType as String
            
            // success, data is in imageData
            /***********************************/
            /* Thumbnail is a premium feature. */
            /***********************************/
            
            let thumbnailSize = SBDThumbnailSize.make(withMaxWidth: 320.0, maxHeight: 320.0)
            
            var preSendMessage: SBDFileMessage?
            guard let channel = self.channel else { return }
            let fileMessageParams = SBDFileMessageParams(file: videoFileData)!
            fileMessageParams.fileName = videoName
            fileMessageParams.mimeType = mimeType
            fileMessageParams.fileSize = UInt(videoFileData.count)
            fileMessageParams.thumbnailSizes = [thumbnailSize] as? [SBDThumbnailSize]
            fileMessageParams.data = nil
            fileMessageParams.customType = nil
            preSendMessage = channel.sendFileMessage(with: fileMessageParams, progressHandler: { [unowned self] (bytesSent, totalBytesSent, totalBytesExpectedToSend) in
                DispatchQueue.main.async {
                    if self.sendingImageVideoMessage[preSendMessage!.requestId!] == nil {
                        self.sendingImageVideoMessage[preSendMessage!.requestId!] = false
                    }
                    
                    self.fileTransferProgress[preSendMessage!.requestId!] = CGFloat(totalBytesSent) / CGFloat(totalBytesExpectedToSend)
                    for index in stride(from: self.messages.count - 1, to: -1, by: -1) {
                        let baseMessage = self.messages[index]
                        if baseMessage is SBDFileMessage {
                            let fileMessage = baseMessage as! SBDFileMessage
                            if fileMessage.requestId != nil && fileMessage.requestId! == preSendMessage!.requestId! {
                                self.determineScrollLock()
                                let indexPath = IndexPath(row: index, section: 0)
                                if self.sendingImageVideoMessage[preSendMessage!.requestId!] == false {
                                    self.messageTableView.reloadRows(at: [indexPath], with: .none)
                                    self.sendingImageVideoMessage[preSendMessage!.requestId!] = true
                                    self.scrollToBottom(force: false)
                                }
                                else {
                                    let cell = self.messageTableView.cellForRow(at: indexPath) as! GroupChannelOutgoingImageVideoFileMessageTableViewCell
                                    cell.showProgress(CGFloat(totalBytesSent) / CGFloat(totalBytesExpectedToSend))
                                }
                                
                                break
                            }
                        }
                    }
                }
                }, completionHandler: { [unowned self] (fileMessage, error) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150), execute: {
                        let preSendMessage = self.preSendMessages[fileMessage!.requestId!] as! SBDFileMessage
                        
                        self.preSendMessages.removeValue(forKey: fileMessage!.requestId!)
                        self.sendingImageVideoMessage.removeValue(forKey: fileMessage!.requestId!)
                        
                        if error != nil {
                            DispatchQueue.main.async {
                                self.resendableMessages[fileMessage!.requestId!] = preSendMessage
                                self.resendableFileData[preSendMessage.requestId!] = [
                                    "data": videoFileData,
                                    "type": mimeType,
                                    "filename": videoName
                                    ] as [String : AnyObject]
                            }
                            
                            return
                        }
                        
                        if let message = fileMessage {
                            if let requestId = message.requestId {
                                DispatchQueue.main.async {
                                    self.determineScrollLock()
                                    self.resendableMessages.removeValue(forKey: requestId)
                                    self.resendableFileData.removeValue(forKey: requestId)
                                    let preSendMessageRow = self.messages.firstIndex(of: preSendMessage)!
                                    self.messages[preSendMessageRow] = message
                                    
                                    let fileMessageIndexPath = IndexPath(row: self.messages.firstIndex(of: fileMessage!)!, section: 0)
                                    self.messageTableView.reloadRows(at: [fileMessageIndexPath], with: .none)
                                    self.scrollToBottom(force: false)
                                }
                            }
                        }
                    })
            })
            
            DispatchQueue.main.async {
                self.fileTransferProgress[(preSendMessage?.requestId!)!] = 0
                self.preSendFileData[(preSendMessage?.requestId)!] = [
                    "data": videoFileData,
                    "type": mimeType,
                    "filename": videoName
                    ] as [String:AnyObject]
                self.determineScrollLock()
                self.preSendMessages[(preSendMessage?.requestId!)!] = preSendMessage
                self.messages.append(preSendMessage!)
                self.messageTableView.reloadData()
                self.scrollToBottom(force: false)
            }
        }
        catch {
        }
    }
}
