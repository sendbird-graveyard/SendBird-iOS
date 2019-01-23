//
//  OpenChannelSettingsViewController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/23/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import RSKImageCropper
import Photos
import AlamofireImage
import MobileCoreServices

class OpenChannelSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, OpenChannelSettingsChannelNameTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, SelectOperatorsDelegate, OpenChannelCoverImageNameSettingDelegate, NotificationDelegate, SBDChannelDelegate {

    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var loadingIndicatorView: CustomActivityIndicatorView!
    
    static let OPERATOR_MENU_COUNT = 7
    static let REGULAR_PARTICIPANT_MENU_COUNT = 4
    
    var operators: [SBDUser] = []
    var selectedUsers: [String:SBDUser] = [:]
    
    weak var delegate: OpenChannelSettingsDelegate?
    
    var channel: SBDOpenChannel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Open Channel Settings"
        self.navigationItem.largeTitleDisplayMode = .automatic
        let barButtonItemBack = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        guard let navigationController = self.navigationController else { return }
        let prevVC = navigationController.viewControllers[navigationController.viewControllers.count - 2]
        prevVC.navigationItem.backBarButtonItem = barButtonItemBack
        
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
        
        self.settingsTableView.delegate = self
        self.settingsTableView.dataSource = self
        self.settingsTableView.register(UINib(nibName: "OpenChannelSettingsChannelNameTableViewCell", bundle: nil), forCellReuseIdentifier: "OpenChannelSettingsChannelNameTableViewCell")
        self.settingsTableView.register(UINib(nibName: "OpenChannelSettingsSeperatorTableViewCell", bundle: nil), forCellReuseIdentifier: "OpenChannelSettingsSeperatorTableViewCell")
        self.settingsTableView.register(UINib(nibName: "OpenChannelSettingsMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "OpenChannelSettingsMenuTableViewCell")
        self.settingsTableView.register(UINib(nibName: "OpenChannelSettingsMeTableViewCell", bundle: nil), forCellReuseIdentifier: "OpenChannelSettingsMeTableViewCell")
        self.settingsTableView.register(UINib(nibName: "OpenChannelSettingsOperatorTableViewCell", bundle: nil), forCellReuseIdentifier: "OpenChannelSettingsOperatorTableViewCell")
        self.settingsTableView.register(UINib(nibName: "OpenChannelOperatorSectionTableViewCell", bundle: nil), forCellReuseIdentifier: "OpenChannelOperatorSectionTableViewCell")
        
        self.hideLoadingIndicatorView()
        self.view.bringSubviewToFront(self.loadingIndicatorView)
        
        self.refreshOperators()
    }

    override func viewWillDisappear(_ animated: Bool) {
        guard let navigationController = self.navigationController else { return }
        if navigationController.viewControllers.firstIndex(of: self) == nil {
            guard let delegate = self.delegate else { return }
            if delegate.responds(to: #selector(OpenChannelSettingsDelegate.didUpdateOpenChannel)) {
                delegate.didUpdateOpenChannel!()
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    // MARK: - NotificationDelegate
    func openChat(_ channelUrl: String) {
        guard let navigationController = self.navigationController else { return }
        navigationController.popViewController(animated: false)
        if let cvc = UIViewController.currentViewController() {
            (cvc as! OpenChannelChatViewController).openChat(channelUrl)
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
    
    func clickSettingsMenuTableView() {
        guard let cell = self.settingsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) else { return }
        guard let channelNameCell = cell as? OpenChannelSettingsChannelNameTableViewCell else { return }
        channelNameCell.channelNameTextField.resignFirstResponder()
        channelNameCell.channelNameTextField.isEnabled = false
        guard let channel = self.channel else { return }
        channelNameCell.channelNameTextField.text = channel.name
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let channel = self.channel else { return 0 }
        if channel.isOperator(with: SBDMain.getCurrentUser()!) {
            return self.operators.count + OpenChannelSettingsViewController.OPERATOR_MENU_COUNT
        }
        else {
            return self.operators.count + OpenChannelSettingsViewController.REGULAR_PARTICIPANT_MENU_COUNT
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        guard let channel = self.channel else { return cell }
        guard let currentUser = SBDMain.getCurrentUser() else { return cell }
        if indexPath.row == 0 {
            if let channelNameCell = tableView.dequeueReusableCell(withIdentifier: "OpenChannelSettingsChannelNameTableViewCell", for: indexPath) as? OpenChannelSettingsChannelNameTableViewCell {
                channelNameCell.delegate = self
                channelNameCell.channelNameTextField.text = channel.name
                channelNameCell.setEnableEditing(channel.isOperator(with: currentUser))
                if let url = URL(string: channel.coverUrl!) {
                    channelNameCell.channelCoverImageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "img_cover_image_placeholder_1"))
                }
                else {
                    channelNameCell.channelCoverImageView.image = UIImage(named: "img_cover_image_placeholder_1")
                }
                
                cell = channelNameCell
            }
        }
        else if indexPath.row == 1 {
            if let seperatorCell = tableView.dequeueReusableCell(withIdentifier: "OpenChannelSettingsSeperatorTableViewCell", for: indexPath) as? OpenChannelSettingsSeperatorTableViewCell {
                seperatorCell.bottomBorderLineView.isHidden = false
                cell = seperatorCell
            }
        }
        else if indexPath.row == 2 {
            if let participantCell = tableView.dequeueReusableCell(withIdentifier: "OpenChannelSettingsMenuTableViewCell", for: indexPath) as? OpenChannelSettingsMenuTableViewCell {
                participantCell.settingMenuLabel.text = "Participants"
                participantCell.settingMenuIconImageView.image = UIImage(named: "img_icon_participant")
                participantCell.countLabel.text = String(format: "%ld", channel.participantCount)
                
                cell = participantCell
                
                if channel.isOperator(with: currentUser) {
                    participantCell.dividerView.isHidden = false
                }
                else {
                    participantCell.dividerView.isHidden = true
                }
            }
        }
        else {
            if channel.isOperator(with: currentUser) {
                if indexPath.row == 3 {
                    if let muteCell = tableView.dequeueReusableCell(withIdentifier: "OpenChannelSettingsMenuTableViewCell", for: indexPath) as? OpenChannelSettingsMenuTableViewCell {
                        muteCell.dividerView.isHidden = false
                        muteCell.settingMenuLabel.text = "Muted Users"
                        muteCell.settingMenuIconImageView.image = UIImage(named: "img_icon_mute")
                        muteCell.countLabel.isHidden = true
                        
                        cell = muteCell
                    }
                }
                else if indexPath.row == 4 {
                    if let banCell = tableView.dequeueReusableCell(withIdentifier: "OpenChannelSettingsMenuTableViewCell", for: indexPath) as? OpenChannelSettingsMenuTableViewCell {
                        banCell.dividerView.isHidden = true
                        banCell.settingMenuLabel.text = "Banned Users"
                        banCell.settingMenuIconImageView.image = UIImage(named: "img_icon_ban")
                        banCell.countLabel.isHidden = true
                        
                        cell = banCell
                    }
                }
                else if indexPath.row == 5 {
                    if let seperatorCell = tableView.dequeueReusableCell(withIdentifier: "OpenChannelOperatorSectionTableViewCell", for: indexPath) as? OpenChannelOperatorSectionTableViewCell {
                        cell = seperatorCell
                    }
                }
                else if indexPath.row == 6 {
                    if let addOperatorCell = tableView.dequeueReusableCell(withIdentifier: "OpenChannelSettingsMenuTableViewCell", for: indexPath) as? OpenChannelSettingsMenuTableViewCell {
                        addOperatorCell.dividerView.isHidden = true
                        addOperatorCell.settingMenuLabel.text = "Add an operator"
                        addOperatorCell.settingMenuLabel.textColor = UIColor(named: "color_settings_menu_add_operator")
                        addOperatorCell.settingMenuIconImageView.image = UIImage(named: "img_icon_add_operator")
                        addOperatorCell.accessoryType = .none
                        addOperatorCell.countLabel.isHidden = true
                        
                        cell = addOperatorCell
                    }
                }
                else {
                    let opIndex = indexPath.row - OpenChannelSettingsViewController.OPERATOR_MENU_COUNT
                    if self.operators[opIndex].userId == currentUser.userId {
                        if let meOperatorCell = tableView.dequeueReusableCell(withIdentifier: "OpenChannelSettingsMeTableViewCell", for: indexPath) as? OpenChannelSettingsMeTableViewCell {
                            if let nickname = self.operators[opIndex].nickname {
                                meOperatorCell.nicknameLabel.text = nickname
                            }
                            
                            if let url = URL(string: Utils.transformUserProfileImage(user: self.operators[opIndex])) {
                                meOperatorCell.profileImageView.af_setImage(withURL: url, placeholderImage: Utils.getDefaultUserProfileImage(user: self.operators[opIndex]))
                            }
                            else {
                                meOperatorCell.profileImageView.image = Utils.getDefaultUserProfileImage(user: self.operators[opIndex])
                            }
                            
                            if self.operators.count == 1 {
                                meOperatorCell.bottomBorderView.isHidden = false
                            }
                            else {
                                meOperatorCell.bottomBorderView.isHidden = true
                            }
                            
                            cell = meOperatorCell
                        }
                    }
                    else {
                        if let operatorCell = tableView.dequeueReusableCell(withIdentifier: "OpenChannelSettingsOperatorTableViewCell", for: indexPath) as? OpenChannelSettingsOperatorTableViewCell {
                            operatorCell.user = self.operators[opIndex]
                            if let nickname = self.operators[opIndex].nickname {
                                operatorCell.nicknameLabel.text = nickname
                            }
                            
                            if let url = URL(string: Utils.transformUserProfileImage(user: self.operators[opIndex])) {
                                operatorCell.profileImageView.af_setImage(withURL: url, placeholderImage: Utils.getDefaultUserProfileImage(user: self.operators[opIndex]))
                            }
                            else {
                                operatorCell.profileImageView.image = Utils.getDefaultUserProfileImage(user: self.operators[opIndex])
                            }
                            
                            operatorCell.accessoryType = .disclosureIndicator
                            
                            cell = operatorCell
                            
                            if self.operators.count - 1 == opIndex {
                                operatorCell.dividerView.isHidden = true
                                operatorCell.bottomBorderView.isHidden = false
                            }
                            else {
                                operatorCell.dividerView.isHidden = false
                                operatorCell.bottomBorderView.isHidden = true
                            }
                            
                            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(OpenChannelSettingsViewController.longPress(_:)))
                            cell.addGestureRecognizer(longPressGesture)
                        }
                    }
                }
            }
            else {
                if indexPath.row >= 3 {
                    if self.operators.count > 0 {
                        if indexPath.row == 3 {
                            if let seperatorCell = tableView.dequeueReusableCell(withIdentifier: "OpenChannelOperatorSectionTableViewCell", for: indexPath) as? OpenChannelOperatorSectionTableViewCell {
                                cell = seperatorCell
                            }
                        }
                        else {
                            let opIndex = indexPath.row - OpenChannelSettingsViewController.REGULAR_PARTICIPANT_MENU_COUNT
                            if let operatorCell = tableView.dequeueReusableCell(withIdentifier: "OpenChannelSettingsOperatorTableViewCell", for: indexPath) as? OpenChannelSettingsOperatorTableViewCell {
                                if let nickname = self.operators[opIndex].nickname {
                                    operatorCell.nicknameLabel.text = nickname
                                }
                                
                                if let url = URL(string: Utils.transformUserProfileImage(user: self.operators[opIndex])) {
                                    operatorCell.profileImageView.af_setImage(withURL: url, placeholderImage: Utils.getDefaultUserProfileImage(user: self.operators[opIndex]))
                                }
                                else {
                                    operatorCell.profileImageView.image = Utils.getDefaultUserProfileImage(user: self.operators[opIndex])
                                }
                                operatorCell.accessoryType = .disclosureIndicator
                                
                                if self.operators.count - 1 == opIndex {
                                    operatorCell.dividerView.isHidden = true
                                    operatorCell.bottomBorderView.isHidden = false
                                }
                                else {
                                    operatorCell.dividerView.isHidden = false
                                    operatorCell.bottomBorderView.isHidden = true
                                }
                                
                                cell = operatorCell
                            }
                        }
                    }
                    else {
                        if let seperatorCell = tableView.dequeueReusableCell(withIdentifier: "OpenChannelSettingsSeperatorTableViewCell", for: indexPath) as? OpenChannelSettingsSeperatorTableViewCell {
                            seperatorCell.bottomBorderLineView.isHidden = true
                            cell = seperatorCell
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let channel = self.channel else { return 0 }
        guard let currentuser = SBDMain.getCurrentUser() else { return 0 }
        if indexPath.row == 0 {
            return 121
        }
        else if indexPath.row == 1 {
            return 35
        }
        else if indexPath.row == 2 {
            return 44
        }
        else {
            if channel.isOperator(with: currentuser) {
                if indexPath.row == 3 {
                    return 44
                }
                else if indexPath.row == 4 {
                    return 44
                }
                else if indexPath.row == 5 {
                    return 56
                }
                else if indexPath.row == 6 {
                    return 44
                }
                else {
                    return 48
                }
            }
            else {
                if indexPath.row == 3 {
                    return 56
                }
                else {
                    return 48
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentUser = SBDMain.getCurrentUser() else { return }
        guard let channel = self.channel else { return }
        self.clickSettingsMenuTableView()
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.row == 2 {
            let vc = OpenChannelParticipantListViewController.init(nibName: "OpenChannelParticipantListViewController", bundle: nil)
            vc.channel = self.channel
            guard let navigationController = self.navigationController else { return }
            navigationController.pushViewController(vc, animated: true)
        }
        else {
            if channel.isOperator(with: currentUser) {
                if indexPath.row == 3 {
                    // Mute
                    let vc = OpenChannelMutedUserListViewController.init(nibName: "OpenChannelMutedUserListViewController", bundle: nil)
                    vc.channel = self.channel
                    guard let navigationController = self.navigationController else { return }
                    navigationController.pushViewController(vc, animated: true)
                }
                else if indexPath.row == 4 {
                    // Ban
                    let vc = OpenChannelBannedUserListViewController.init(nibName: "OpenChannelBannedUserListViewController", bundle: nil)
                    vc.channel = self.channel
                    guard let navigationController = self.navigationController else { return }
                    navigationController.pushViewController(vc, animated: true)
                }
                else if indexPath.row == 6 {
                    // Add Operators
                    let vc = SelectOperatorsViewController.init(nibName: "SelectOperatorsViewController", bundle: nil)
                    vc.title = "Add an operator"
                    vc.delegate = self
                    guard let channel = self.channel else { return }
                    guard let operators = channel.operators as? [SBDUser] else { return }
                    for user in operators {
                        vc.selectedUsers[user.userId] = user
                    }
                    guard let navigationController = self.navigationController else { return }
                    navigationController.pushViewController(vc, animated: true)
                }
                else if indexPath.row - OpenChannelSettingsViewController.OPERATOR_MENU_COUNT > 0 {
                    let vc = UserProfileViewController.init(nibName: "UserProfileViewController", bundle: nil)
                    vc.user = self.operators[indexPath.row - OpenChannelSettingsViewController.OPERATOR_MENU_COUNT]
                    if let navigationController = self.navigationController {
                        navigationController.pushViewController(vc, animated: true)
                    }
                }
            }
            else {
                if indexPath.row - OpenChannelSettingsViewController.REGULAR_PARTICIPANT_MENU_COUNT >= 0 {
                    let vc = UserProfileViewController.init(nibName: "UserProfileViewController", bundle: nil)
                    vc.user = self.operators[indexPath.row - OpenChannelSettingsViewController.OPERATOR_MENU_COUNT]
                    if let navigationController = self.navigationController {
                        navigationController.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let channel = self.channel else { return false }
        self.showLoadingIndicatorView()
        channel.update(withName: textField.text, coverImage: nil, coverImageName: nil, data: nil, operatorUserIds: nil, customType: nil, progressHandler: nil) { (channel, error) in
            self.hideLoadingIndicatorView()
            
            if error != nil {
                return
            }

            DispatchQueue.main.async {
                self.settingsTableView.reloadData()
            }
        }
        
        return true
    }
    
    // MARK: - OpenChannelSettingsChannelNameTableViewCellDelegate
    func didClickChannelCoverImageNameEdit() {
        let vc = OpenChannelCoverImageNameSettingViewController.init(nibName: "OpenChannelCoverImageNameSettingViewController", bundle: nil)
        vc.delegate = self
        vc.channel = self.channel
        guard let navigationController = self.navigationController else { return }
        navigationController.pushViewController(vc, animated: true)
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
//                if let imagePath = info[UIImagePickerController.InfoKey.imageURL] as? URL {
//                    let imageName = imagePath.lastPathComponent
//                    let ext = imageName.pathExtension()
//                    guard let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)?.takeRetainedValue() else { return }
//                    guard let retainedValueMimeType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType)?.takeRetainedValue() else { return }
//                    let mimeType = retainedValueMimeType as String
//
//
//                }
                
                guard let imageAsset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset else { return }
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                options.isNetworkAccessAllowed = true
                options.deliveryMode = .highQualityFormat
                
                PHImageManager.default().requestImageData(for: imageAsset, options: options, resultHandler: { (imageData, dataUTI, orientation, info) in
                    guard let data = imageData else { return }
                    guard let image = UIImage(data: data) else { return }
                    guard let originalImage = image.jpegData(compressionQuality: 1.0) else { return }
                    
                    self.cropImage(originalImage)
                })
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
    
    // The original image has been cropped.
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        self.updateChannelCoverImage(croppedImage: croppedImage, controller: controller)
    }
    
    // The original image will be cropped.
    func imageCropViewController(_ controller: RSKImageCropViewController, willCropImage originalImage: UIImage) {
        // Use when `applyMaskToCroppedImage` set to YES.
    }
    
    func updateChannelCoverImage(croppedImage: UIImage, controller: RSKImageCropViewController) {
        let coverImageData = croppedImage.jpegData(compressionQuality: 0.5)
        
        self.showLoadingIndicatorView()
        guard let channel = self.channel else { return }
        channel.update(withName: nil, coverImage: coverImageData, coverImageName: "image.jpg", data: nil, operatorUserIds: nil, customType: nil, progressHandler: nil) { (channel, error) in
            self.hideLoadingIndicatorView()
            
            if error != nil {
                return
            }
            
            DispatchQueue.main.async {
                self.settingsTableView.reloadData()
            }
        }
        
        controller.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - SelectOperatorsDelegate
    func didSelectUsers(_ users: [String : SBDUser]) {
        self.showLoadingIndicatorView()
        
        guard let currentUser = SBDMain.getCurrentUser() else { return }
        
        var operators: [SBDUser] = Array(users.values)
        operators.append(currentUser)
        
        guard let channel = self.channel else { return }
        channel.update(withName: nil, coverUrl: nil, data: nil, operatorUsers: operators) { (channel, error) in
            self.hideLoadingIndicatorView()
            
            if error != nil {
                return
            }
            
            DispatchQueue.main.async {
                self.operators.removeAll()
                for op in channel!.operators! as! [SBDUser] {
                    if op.userId == currentUser.userId {
                        self.operators.insert(op, at: 0)
                    }
                    else {
                        self.operators.append(op)
                    }
                }
                
                self.settingsTableView.reloadData()
            }
        }
    }
    
    // MARK: - UIAlertController for operators
    @objc func longPress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            guard let cell = recognizer.view as? UITableViewCell else { return }
            if cell is OpenChannelSettingsOperatorTableViewCell {
                guard let operatorCell = cell as? OpenChannelSettingsOperatorTableViewCell else { return }
                guard let removedOperator = operatorCell.user else { return }
                var operators:[SBDUser] = []
                guard let channel = self.channel else { return }
                for user in channel.operators! as! [SBDUser] {
                    if user.userId == removedOperator.userId {
                        continue
                    }
                    
                    operators.append(user)
                }
                
                let vc = UIAlertController(title: removedOperator.nickname, message: nil, preferredStyle: .actionSheet)
                let actionRemoveUser = UIAlertAction(title: "Remove from operators", style: .destructive) { (action) in
                    self.showLoadingIndicatorView()
                    
                    guard let channel = self.channel else { return }
                    channel.update(withName: nil, coverUrl: nil, data: nil, operatorUsers: operators, completionHandler: { (channel, error) in
                        if error != nil {
                            self.hideLoadingIndicatorView()
                            
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.hideLoadingIndicatorView()
                            self.operators.removeAll()
                            guard let currentUser = SBDMain.getCurrentUser() else { return }
                            for op in channel!.operators! as! [SBDUser] {
                                if op.userId == currentUser.userId {
                                    self.operators.insert(op, at: 0)
                                }
                                else {
                                    self.operators.append(op)
                                }
                            }
                            self.settingsTableView.reloadData()
                        }
                    })
                }
                let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                vc.addAction(actionRemoveUser)
                vc.addAction(actionCancel)
                
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    func refreshOperators() {
        self.operators.removeAll()
        
        guard let channel = self.channel else { return }
        if let operators = channel.operators as? [SBDUser] {
            for op: SBDUser in operators {
                if op.userId == SBDMain.getCurrentUser()!.userId {
                    self.operators.insert(op, at: 0)
                }
                else {
                    self.operators.append(op)
                }
            }
        }
    }
    
    // MARK: - OpenChannelCoverImageNameSettingDelegate
    func didUpdateOpenChannel() {
        DispatchQueue.main.async {
            self.settingsTableView.reloadData()
        }
    }
    
    // MARK: - SBDChannelDelegate
    func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {
        if sender == self.channel {
            DispatchQueue.main.async {
                self.settingsTableView.reloadData()
            }
        }
    }
    
    func channel(_ sender: SBDBaseChannel, userWasBanned user: SBDUser) {
        if sender == self.channel {
            DispatchQueue.main.async {
                self.settingsTableView.reloadData()
            }
        }
    }
    
    func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {
        if sender == self.channel {
            DispatchQueue.main.async {
                self.settingsTableView.reloadData()
            }
        }
    }
    
    func channelWasChanged(_ sender: SBDBaseChannel) {
        if sender == self.channel {
            DispatchQueue.main.async {
                self.refreshOperators()
                self.settingsTableView.reloadData()
            }
        }
    }
    
    // MARK: - Utilities
    private func showLoadingIndicatorView() {
        DispatchQueue.main.async {
            self.loadingIndicatorView.isHidden = false
            self.loadingIndicatorView.startAnimating()
        }
    }
    
    private func hideLoadingIndicatorView() {
        DispatchQueue.main.async {
            self.loadingIndicatorView.isHidden = true
            self.loadingIndicatorView.stopAnimating()
        }
    }
}
