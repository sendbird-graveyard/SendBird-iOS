//
//  GroupChannelChatViewController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/2/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import SendBirdSyncManager
import RSKImageCropper
import Photos
import AVKit
import MobileCoreServices 
import FLAnimatedImage
import Hero

class GroupChannelChatViewController: BaseViewController, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate {
    
    @IBOutlet weak var inputMessageTextField: UITextField!
    @IBOutlet weak var typingIndicatorContainerView: UIView!
    @IBOutlet weak var typingIndicatorImageView: FLAnimatedImageView!
    @IBOutlet weak var typingIndicatorLabel: UILabel!
    @IBOutlet weak var toastView: UIView!
    @IBOutlet weak var toastMessageLabel: UILabel!
    
    @IBOutlet weak var messageTableViewBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var inputMessageInnerContainerViewBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var sendUserMessageButton: UIButton!
    @IBOutlet weak var typingIndicatorContainerViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.estimatedRowHeight = 140.0
            
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 14, right: 0)
            
            // Incoming
            self.tableView.register(MessageIncomingUserCell.self)
            self.tableView.register(MessageIncomingImageVideoFileCell.self)
            self.tableView.register(MessageIncomingGeneralFileCell.self)
            self.tableView.register(MessageIncomingAudioFileCell.self)
            
            // Outgoing
            self.tableView.register(MessageOutgoingUserCell.self)
            self.tableView.register(MessageOutgoingImageVideoFileCell.self)
            self.tableView.register(MessageOutgoingGeneralFileCell.self)
            self.tableView.register(MessageOutgoingAudioFileCell.self)
            
            // Neutral
            self.tableView.register(MessageNeutralAdminCell.self)
        }
    }
      
    var collection: SBSMMessageCollection?
     
    var settingBarButton: UIBarButtonItem?
    var backButton: UIBarButtonItem?
    
    weak var delegate: GroupChannelsUpdateListDelegate?
    var channel: SBDGroupChannel?
    
    var keyboardShown: Bool = false
    var keyboardHeight: CGFloat = 0
     
    var scrollLock: Bool = false 
    
    var hasPrevious: Bool = true
    var minMessageTimestamp: Int64 = Int64.max
    var isTableViewLoading: Bool = false
    
    var isTableViewInitiating = true
    
    let messageControl = MessageControl()
     
    var typingIndicatorTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCollection()
        
        self.navigationItem.largeTitleDisplayMode = .never
        self.settingBarButton = UIBarButtonItem(image: UIImage(named: "img_btn_channel_settings"),
                                                style: .plain, target: self,
                                                action: #selector(GroupChannelChatViewController.clickSettingBarButton(_:)))
        
        self.navigationItem.rightBarButtonItem = self.settingBarButton
        
        self.channel?.markAsRead()
        if self.splitViewController?.displayMode != .allVisible {
            self.backButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.clickBackButton(_:)))
            self.navigationItem.leftBarButtonItem = self.backButton
        }
        /*
         * When use delegate, must remove the delete in deinit.
         */
        
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.delegateIdentifier)
        SBDMain.add(self as SBDChannelDelegate, identifier: self.delegateIdentifier)
         
        SBSMSyncManager.resumeSynchronize()
        
        self.title = Utils.createGroupChannelName(channel: self.channel!)
        let image = FLAnimatedImage(animatedGIFData: NSData(contentsOfFile: Bundle.main.path(forResource: "loading_typing", ofType: "gif")!) as Data?)
        self.typingIndicatorImageView.animatedImage = image
        
        self.typingIndicatorContainerView.isHidden = true
        
        
        // Input Text Field
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        
        self.inputMessageTextField.leftView = leftPaddingView
        self.inputMessageTextField.rightView = rightPaddingView
        self.inputMessageTextField.leftViewMode = .always
        self.inputMessageTextField.rightViewMode = .always
        self.inputMessageTextField.addTarget(self, action: #selector(self.inputMessageTextFieldChanged(_:)), for: .editingChanged)
        self.sendUserMessageButton.isEnabled = false
        
        let messageViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(recognizer:)))
        self.tableView.addGestureRecognizer(messageViewTapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)),
                                               name: UIWindow.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(_:)),
                                               name: UIWindow.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)),
                                               name: UIWindow.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(_:)),
                                               name: UIWindow.keyboardDidHideNotification, object: nil)
          
        self.collection?.fetch(in: .next) { hasMore, error in
            
        }
         
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isTableViewInitiating = false
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard
            let navigationController = self.navigationController,
            let topViewController = navigationController.topViewController,
            navigationController.viewControllers.firstIndex(of: self) == nil
            else
        {
                super.viewWillDisappear(animated)
                return
        }
        
        if navigationController is CreateGroupChannelNavigationController && !(topViewController is GroupChannelSettingsViewController) {
            navigationController.dismiss(animated: false, completion: nil)
            
        } else {
            super.viewWillDisappear(animated)
        }
        
    }
    
    deinit {
        collection?.remove()
        collection?.delegate = nil
        SBDMain.removeConnectionDelegate(forIdentifier: self.delegateIdentifier)
        SBDMain.removeChannelDelegate(forIdentifier: self.delegateIdentifier)
    }
}

extension GroupChannelChatViewController {
  
    func setCollection() {
        guard let channel = channel else { return }
        let filter = SBSMMessageFilter()

        let lastSeenAt: Int64? = .max // UserPreferences.lastSeenAt(channelUrl: self.channel.channelUrl)
        self.collection = SBSMMessageCollection(channel: channel, filter: filter, viewpointTimestamp: lastSeenAt ?? LONG_LONG_MAX)
        self.collection?.delegate = self
    }
    
    func showToast(_ message: String) {
        self.toastView.alpha = 1
        self.toastMessageLabel.text = message
        self.toastView.isHidden = false
        
        UIView.animate( withDuration: 0.5,
                        delay: 0.5,
                        options: .curveEaseIn,
                        animations: { self.toastView.alpha = 0 },
                        completion: { finished in self.toastView.isHidden = true }
        )
    }
 
    @objc func clickSettingBarButton(_ sender: AnyObject) {
        let vc = GroupChannelSettingsViewController.initiate()
        vc.delegate = self
        vc.channel = self.channel
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func clickBackButton(_ sender: AnyObject) {
        if self.splitViewController?.displayMode == .allVisible { return }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideTypingIndicator(_ timer: Timer) {
        self.typingIndicatorTimer?.invalidate()
        DispatchQueue.main.async {
            self.typingIndicatorContainerView.isHidden = true
            self.messageTableViewBottomMargin.constant = 0
            self.view.updateConstraints()
            self.view.layoutIfNeeded()
            
            self.determineScrollLock()
        }
    }
    
    @objc func inputMessageTextFieldChanged(_ sender: Any) {
        guard let channel = self.channel else { return }
        guard let textField = sender as? UITextField else { return }
        if textField.text!.count > 0 {
            channel.startTyping()
            self.sendUserMessageButton.isEnabled = true
        } else {
            channel.endTyping()
            self.sendUserMessageButton.isEnabled = false
        }
    }

    func loadPreviousMessages() {
        guard
            self.hasPrevious,
            self.tableView.scrollsToTop,
            !self.isTableViewLoading
            else { return }
         
        self.isTableViewLoading = true
        
        collection?.fetch(in: .previous) { hasMore, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isTableViewLoading = false
                
                if let error = error {
                    return
                }
                
                self.hasPrevious = hasMore
            }
        }
    }
    
    func isLastMessageVisible() -> Bool {
        let oldCount = self.tableView.numberOfRows(inSection: 0)
        let oldVisibleRow = self.tableView.indexPathsForVisibleRows?.sorted()
        let oldVisibleLastRow = oldVisibleRow?.last?.row
        
        return oldVisibleLastRow == nil || oldVisibleLastRow == oldCount - 1
    }
}

// MARK: - Action
extension GroupChannelChatViewController {
    
    @IBAction func clickSendUserMessageButton(_ sender: Any) {
        guard let messageText = self.inputMessageTextField.text else { return }
        guard let channel = self.channel else { return }
        
        if messageText.count == 0 {
            return
        }
        
        self.inputMessageTextField.text = ""
        self.sendUserMessageButton.isEnabled = false
        
        var pendingMessage: SBDUserMessage?
        pendingMessage = channel.sendUserMessage(messageText) { message, error in
            self.channel?.endTyping()
            self.setSent(message: message, error: error)
        }
        
        self.setPending(pendingMessage)
    }
    
    @IBAction func clickSendFileMessageButton(_ sender: Any) {
        UploadControl().showFilePickerAlert(self)
    }
}

extension GroupChannelChatViewController {
    
    func playMedia(_ message: SBDFileMessage) {
        self.playMedia(message.url)
    }
    
    func playMedia(_ urlString: String) {
        self.playMedia(URL(string: urlString))
    }
    
    func playMedia(_ url: URL?) {
        guard let url = url else { return }
        let player = AVPlayer(url: url)
        let vc = AVPlayerViewController()
        vc.hero.isEnabled = true
        vc.contentOverlayView?.hero.id = "media"
        
        vc.player = player
        self.present(vc, animated: true) {
            player.play()
        }
    }
    
    func sendImageFileMessage(imageData: Data, imageName: String, mimeType: String) {
        self.sendFileMessage(fileData: imageData, fileName: imageName, mimeType: mimeType)
    }
    
    func sendVideoFileMessage(info: [UIImagePickerController.InfoKey : Any]) {
        guard let videoUrl = info[.mediaURL] as? URL, let videoFileData = try? Data(contentsOf: videoUrl) else { return }
        
        let videoName = videoUrl.lastPathComponent
        let ext = videoName.pathExtension()
        
        guard
            let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)?.takeRetainedValue(),
            let retainedValueMimeType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType)?.takeRetainedValue()
            else { return }
        
        let mimeType = retainedValueMimeType as String
        
        self.sendFileMessage(fileData: videoFileData, fileName: videoName, mimeType: mimeType)
    }

    func sendFileMessage(fileData: Data, fileName: String, mimeType: String) {
        // success, data is in fileData
        /***********************************/
        /* Thumbnail is a premium feature. */
        /***********************************/
        let thumbnailSize = SBDThumbnailSize.make(withMaxWidth: 320.0, maxHeight: 320.0)!
        
        guard let params = SBDFileMessageParams(file: fileData) else { return }
        
        params.fileName = fileName
        params.mimeType = mimeType
        params.fileSize = UInt(fileData.count)
        params.thumbnailSizes = [thumbnailSize]
        params.data = nil
        params.customType = nil
        
        sendFileMessage(by: params)
    }
    
    func sendFileMessage(by params: SBDFileMessageParams) {
        guard let channel = self.channel else { return }
        
        var pendingMessage: SBDFileMessage?
        pendingMessage = channel.sendFileMessage(with: params, progressHandler: { [weak self] bytesSent, totalBytesSent, totalBytesExpectedToSend in
            DispatchQueue.main.async {
                guard let self = self else { return }
                    
                let progress = CGFloat(totalBytesSent) / CGFloat(totalBytesExpectedToSend)

                guard let indexPath = self.messageControl.findIndexPath(by: pendingMessage!) else { return }
                guard let cell = self.tableView.cellForRow(at: indexPath) as? MessageOutgoingImageVideoFileCell else { return }

                cell.showProgress(progress)
            }
        }, completionHandler: { [weak self] message, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150)) {
                guard let self = self else { return }
                guard let message = message else { return }

                self.collection?.appendMessage(message)
            }
        })
        
        self.messageControl.updatePendingFileMessage(message: pendingMessage!, params: params)
        self.collection?.appendMessage(pendingMessage!)
    }
    
    func resendFileMessage(with message: SBDFileMessage) {
        guard let indexPath = self.messageControl.findIndexPath(by: message) else {
            assertionFailure("IndexPath must exist!")
            return
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? MessageOutgoingCell else {
            assertionFailure("Cell must exist!")
            return
        }
        
        self.channel?.resendFileMessage(with: message, binaryData: nil, progressHandler: { bytesSent, totalBytesSent, totalBytesExpectedToSend in
            let progress = CGFloat(totalBytesSent) / CGFloat(totalBytesExpectedToSend)
            cell.showProgress(progress)
        }, completionHandler: { message, error in
            self.setSent(message: message, error: error)
        })
    }
}

// MARK: - NotificationDelegate
extension GroupChannelChatViewController: NotificationDelegate {
    func openChat(_ channelUrl: String) {
        guard let channel = self.channel, channelUrl == channel.channelUrl else { return }
        
        navigationController?.popViewController(animated: false)
        
        let delegate = UIViewController.currentViewController() as? NotificationDelegate
        delegate?.openChat(channelUrl)
        
    }
}

// MARK: - SBDNetworkDelegate
extension GroupChannelChatViewController: SBDNetworkDelegate { 
    func didReconnect() {
        // TODO: Fix bug in SDK.
    }
}

// MARK: - Crop Image
extension GroupChannelChatViewController {
    func cropImage(_ imageData: Data) {
        guard let image = UIImage(data: imageData) else { return }
        let imageCropVC = RSKImageCropViewController(image: image)
        imageCropVC.delegate = self
        imageCropVC.cropMode = .square
        self.present(imageCropVC, animated: false, completion: nil)
        
    }
}

// MARK: - SBDConnectionDelegate
extension GroupChannelChatViewController: SBDConnectionDelegate {
    func didSucceedReconnection() {
        SBSMSyncManager.resumeSynchronize()
        self.channel?.refresh(completionHandler: nil)
        self.fetchAllNextMessages()
    }
    
    func didFailReconnection() {
        let connectState = SBDMain.getConnectState()
        print(connectState)
    }
}

// MARK - GroupChannelSettingsDelegate
extension GroupChannelChatViewController: GroupChannelSettingsDelegate {
    func didLeaveChannel() {
        
        if navigationController is CreateGroupChannelNavigationController {
            self.dismiss(animated: false, completion: nil)
        } else {
            navigationController?.popViewController(animated: false)
        }
    }
    
    
    func deleteMessageFromTableView(_ messageId: Int64) {
        self.messageControl.remove(messageId)
        self.tableView.reloadData()
    }
}

extension GroupChannelChatViewController {
     
    func fetchAllNextMessages() {
        self.collection?.fetchAllNextMessages { hasMore, error in
            if let error = error {
                if error.code != SBSMErrorCode.duplicatedFetch.rawValue {
                    AlertControl.showError(parent: self, error: error)
                }
                return
            }
        }
    }

    func setPending(_ message: SBDBaseMessage?) {
        guard let message = message else { return }
        self.collection?.appendMessage(message);
    }
    
    func setSent(message: SBDBaseMessage?, error: SBDError? = nil) {
        guard let message = message else {
            assertionFailure()
            return
        }
        
        self.collection?.appendMessage(message)
    }
    
    func insertRows(messages: [SBDBaseMessage]) {
        self.isTableViewLoading = true
        
        DispatchQueue.main.async {
            defer {
                self.isTableViewLoading = false
            }
            var indexPaths: [IndexPath] = []
            let isLastMessageVisible = self.isLastMessageVisible()

            for message in messages {
                if message.requestState() == .pending && message.isKind(of: SBDFileMessage.self) {
                    let params = self.messageControl.pendingFileMessageParams[message.requestID]
                    if let index = self.messageControl.insertPendingMessage(by: MessageModel(message, params: params)) {
                        indexPaths.append(index)
                    }
                }
                else {
                    if let index = self.messageControl.insert(by: message) {
                        indexPaths.append(index)
                    }
                }
            }
            
            if isLastMessageVisible {
                self.tableView.reloadData()
            }
            else {
                self.tableView.insertRows(at: indexPaths, with: .none)
            }
            self.tableView.layoutIfNeeded()
            
            if isLastMessageVisible {
                self.scrollToBottom(animated: false, force: true)
            }
        }
    }
    
    func updateMessages(messages: [SBDBaseMessage]) {
        DispatchQueue.main.async {
            for i in stride(from: 0, through: self.messageControl.models.count - 1, by: 1) {
                let model = self.messageControl.models[i]
                let existingReqId = model.requestID
                let existingMessageId = model.messageID
                for message in messages {
                    let updatedReqId = message.requestID
                    let updatedMessageId = message.messageId
                    
                    if existingReqId.count > 0 && updatedReqId.count > 0 && existingReqId == updatedReqId {
                        self.messageControl.models[i] = MessageModel(message)
                        break
                    }
                    else if existingMessageId > 0 && updatedMessageId > 0 && existingMessageId == updatedMessageId {
                        self.messageControl.models[i] = MessageModel(message)
                        break
                    }
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    func removeMessages(messages: [SBDBaseMessage]) {
        DispatchQueue.main.async {
            let isLastMessageVisible = self.isLastMessageVisible()
            var removedMessageModels: [MessageModel] = []
            
            var removedMessageIndexPathes: [IndexPath] = []
            for i in stride(from: 0, through: self.messageControl.models.count - 1, by: 1) {
                let model = self.messageControl.models[i]
                let existingReqId = model.requestID
                let existingMessageId = model.messageID
                for message in messages {
                    let updatedReqId = message.requestID
                    let updatedMessageId = message.messageId
                    
                    if existingReqId.count > 0 && updatedReqId.count > 0 && existingReqId == updatedReqId {
                        removedMessageModels.append(self.messageControl.models[i])
                        removedMessageIndexPathes.append(IndexPath(row: i, section: 0))

                        break
                    }
                    else if existingMessageId > 0 && updatedMessageId > 0 && existingMessageId == updatedMessageId {
                        removedMessageModels.append(self.messageControl.models[i])
                        removedMessageIndexPathes.append(IndexPath(row: i, section: 0))
                        
                        break
                    }
                }
            }
            
            for removedModel in removedMessageModels {
                self.messageControl.models.removeObject(removedModel)
            }

            self.tableView.reloadData()
            if isLastMessageVisible {
                self.scrollToBottom(animated: true, force: false)
            }
        }
    }
}
 
extension GroupChannelChatViewController {
    static func initiate() -> GroupChannelChatViewController {
        let vc = GroupChannelChatViewController.withStoryboard(storyboard: .groupChannel)
        return vc
    }
}
