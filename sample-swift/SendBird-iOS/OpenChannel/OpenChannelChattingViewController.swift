//
//  OpenChannelChattingViewController.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/13/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import AVKit
import AVFoundation
import MobileCoreServices

class OpenChannelChattingViewController: UIViewController, SBDConnectionDelegate, SBDChannelDelegate, ChattingViewDelegate, MessageDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var openChannel: SBDOpenChannel!
    
    @IBOutlet weak var chattingView: ChattingView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!

    private var messageQuery: SBDPreviousMessageListQuery!
    private var delegateIdentifier: String!
    private var hasNext: Bool = true
    private var refreshInViewDidAppear: Bool = true
    private var isLoading: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navItem.title = String(format: "%@(%ld)", self.openChannel.name, self.openChannel.participantCount)
        
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

    func keyboardDidShow(notification: Notification) {
        let keyboardInfo = notification.userInfo
        let keyboardFrameBegin = keyboardInfo?[UIKeyboardFrameBeginUserInfoKey]
        let keyboardFrameBeginRect = (keyboardFrameBegin as! NSValue).cgRectValue
        DispatchQueue.main.async {
            self.bottomMargin.constant = keyboardFrameBeginRect.size.height
            self.view.layoutIfNeeded()
            self.chattingView.stopMeasuringVelocity = true
            self.chattingView.scrollToBottom()
        }
    }
    
    func keyboardDidHide(notification: Notification) {
        DispatchQueue.main.async {
            self.bottomMargin.constant = 0
            self.view.layoutIfNeeded()
            self.chattingView.scrollToBottom()
        }
    }
    
    @objc private func close() {
        SBDMain.removeChannelDelegate(forIdentifier: self.delegateIdentifier)
        SBDMain.removeConnectionDelegate(forIdentifier: self.delegateIdentifier)
        
        self.openChannel.exitChannel { (error) in
            self.dismiss(animated: false) {
                
            }
        }
    }
    
    @objc private func openMoreMenu() {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let seeParticipantListAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "SeeParticipantListButton"), style: UIAlertActionStyle.default) { (action) in
            DispatchQueue.main.async {
                let plvc = ParticipantListViewController()
                plvc.channel = self.openChannel
                self.refreshInViewDidAppear = false
                self.present(plvc, animated: false, completion: nil)
            }
        }
        let seeBlockedUserListAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "SeeBlockedUserListButton"), style: UIAlertActionStyle.default) { (action) in
            DispatchQueue.main.async {
                let blvc = BlockedUserListViewController()
                self.refreshInViewDidAppear = false
                self.present(blvc, animated: false, completion: nil)
            }
        }
        let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
        vc.addAction(seeParticipantListAction)
        vc.addAction(seeBlockedUserListAction)
        vc.addAction(closeAction)
        
        self.present(vc, animated: true, completion: nil)
    }
    
    private func loadPreviousMessage(initial: Bool) {
        if initial == true {
            self.messageQuery = self.openChannel.createPreviousMessageListQuery()
            self.hasNext = true
            self.chattingView.messages.removeAll()
            self.chattingView.chattingTableView.reloadData()
        }
        
        if self.hasNext == false {
            return
        }
        
        if self.isLoading == true {
            return
        }
        
        self.isLoading = true
        
        self.messageQuery.loadPreviousMessages(withLimit: 30, reverse: !initial) { (messages, error) in
            if error != nil {
                let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                vc.addAction(closeAction)
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: nil)
                }
                
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
            }
            else {
                for message in messages! {
                    self.chattingView.messages.insert(message, at: 0)
                }
            }
            
            DispatchQueue.main.async {
                if initial == true {
                    self.chattingView.chattingTableView.isHidden = true
                    self.chattingView.initialLoading = true
                    self.chattingView.chattingTableView.reloadData()
                    self.chattingView.scrollToBottom()
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 250000000), execute: {
                        self.chattingView.chattingTableView.isHidden = false
                        self.chattingView.initialLoading = false
                        self.isLoading = false
                    })
                }
                else {
                    self.chattingView.chattingTableView.reloadData()
                    if (messages?.count)! > 0 {
                        self.chattingView.scrollToPosition(position: (messages?.count)! - 1)
                    }
                    self.isLoading = false
                }
            }
        }
    }
    
    @objc private func sendMessage() {
        if self.chattingView.messageTextView.text.characters.count > 0 {
            let message = self.chattingView.messageTextView.text
            self.chattingView.messageTextView.text = ""
            self.openChannel.sendUserMessage(message, completionHandler: { (userMessage, error) in
                if error != nil {
                    self.chattingView.resendableMessages[(userMessage?.requestId)!] = userMessage
                }
                
                self.chattingView.messages.append(userMessage!)
                DispatchQueue.main.async {
                    self.chattingView.chattingTableView.reloadData()
                    self.chattingView.scrollToBottom()
                }
            })
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
    
    // MARK: SBDConnectionDelegate
    func didStartReconnection() {
        
    }
    
    func didSucceedReconnection() {
        self.loadPreviousMessage(initial: true)
    }
    
    func didFailReconnection() {
        
    }
    
    // MARK: SBDChannelDelegate
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        if sender == self.openChannel {
            self.chattingView.messages.append(message)
            DispatchQueue.main.async {
                self.chattingView.chattingTableView.reloadData()
                self.chattingView.scrollToBottom()
            }
        }
    }

    func channelWasChanged(_ sender: SBDBaseChannel) {
        if sender == self.openChannel {
            DispatchQueue.main.async {
                self.navItem.title = String(format: "%@(%ld)", self.openChannel.name, self.openChannel.participantCount)
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
        if sender == self.openChannel {
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

    }
    
    func endTyping(view: UIView) {

    }
    
    func hideKeyboardWhenFastScrolling(view: UIView) {
        self.view.endEditing(true)
    }
    
    // MARK: MessageDelegate
    func clickProfileImage(viewCell: UITableViewCell, user: SBDUser) {
        let alert = UIAlertController(title: user.nickname, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let blockUserAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "BlockUserButton"), style: UIAlertActionStyle.default) { (action) in
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
        alert.addAction(blockUserAction)
        alert.addAction(closeAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
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
                    self.openChannel.delete(message, completionHandler: { (error) in
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
                    let url: URL = match.url! as URL
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
                    self.openChannel.delete(fileMessage, completionHandler: { (error) in
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
                imageName = refUrl.lastPathComponent as NSString
                
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
                imageToUse?.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight));
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
                
                self.openChannel.sendFileMessage(withBinaryData: imageFileData as! Data, filename: imageName as! String, type: imageType as! String, size: UInt((imageFileData?.length)!), data: "", completionHandler: { (fileMessage, error) in
                    if error != nil {
                        let alert = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                        let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(closeAction)
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                        return
                    }
                    
                    if fileMessage != nil {
                        self.chattingView.messages.append(fileMessage!)
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 500000000), execute: {
                            self.chattingView.chattingTableView.reloadData()
                            self.chattingView.scrollToBottom()
                        })
                    }
                })
            }
            else if CFStringCompare(mediaType as CFString, kUTTypeMovie, []) == CFComparisonResult.compareEqualTo {
                let videoUrl: URL = info[UIImagePickerControllerMediaURL] as! URL
                let videoFileData = NSData(contentsOf: videoUrl)
                imageName = videoUrl.lastPathComponent as NSString?
                
                let extentionOfFile: String = imageName!.substring(from: imageName!.range(of: ".").location + 1) as String
                
                if extentionOfFile.caseInsensitiveCompare("mov") == ComparisonResult.orderedSame {
                    imageType = "video/quicktime"
                }
                else if extentionOfFile.caseInsensitiveCompare("mp4") == ComparisonResult.orderedSame {
                    imageType = "video/mp4"
                }
                else {
                    imageType = "video/mpeg"
                }
                
                self.openChannel.sendFileMessage(withBinaryData: videoFileData as! Data, filename: imageName as! String, type: imageType as! String, size: UInt((videoFileData?.length)!), data: "", completionHandler: { (fileMessage, error) in
                    if error != nil {
                        let alert = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                        let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(closeAction)
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                        return
                    }
                    
                    if fileMessage != nil {
                        self.chattingView.messages.append(fileMessage!)
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 500000000), execute: {
                            self.chattingView.chattingTableView.reloadData()
                            self.chattingView.scrollToBottom()
                        })
                    }
                })
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
