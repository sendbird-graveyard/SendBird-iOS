//
//  GroupChannelCoverImageNameSettingViewController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/16/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import RSKImageCropper
import Photos
import MobileCoreServices

class GroupChannelCoverImageNameSettingViewController: BaseViewController, UINavigationControllerDelegate {
    weak var delegate: GroupChannelCoverImageNameSettingDelegate?
    var channel: SBDGroupChannel?

    // TODO: Cover Image, Center crop (나중)
    // TODO: Cover Image 변경 시 적용 안됨.
    
    var coverImage: UIImage?
    
    @IBOutlet weak var loadingIndicatorView: CustomActivityIndicatorView!
    @IBOutlet weak var channelNameTextField: UITextField!
    
    @IBOutlet weak var profileImageView: ProfileImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Cover Image & Name"
        self.navigationItem.largeTitleDisplayMode = .never
        
        let barButtonItemDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(GroupChannelCoverImageNameSettingViewController.clickDoneButton(_:)))
        self.navigationItem.rightBarButtonItem = barButtonItemDone
        
        self.view.bringSubviewToFront(self.loadingIndicatorView)
        self.loadingIndicatorView.isHidden = true
        
        self.coverImage = nil
        self.channelNameTextField.attributedPlaceholder = NSAttributedString(string: Utils.createGroupChannelNameFromMembers(channel: self.channel!), attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0, weight: .regular),
            NSAttributedString.Key.foregroundColor: UIColor(named: "color_channelname_nickname_placeholder") as Any
            ])
        self.channelNameTextField.text = self.channel!.name
        
        self.profileImageView.isUserInteractionEnabled = true
        let tapCoverImageGesture = UITapGestureRecognizer(target: self, action: #selector(GroupChannelCoverImageNameSettingViewController.clickCoverImage))
        self.profileImageView.addGestureRecognizer(tapCoverImageGesture)

        
        if let coverUrl = self.channel?.coverUrl {
            if coverUrl.count > 0, !coverUrl.hasPrefix("https://sendbird.com/main/img/cover/") {
                self.profileImageView.setImage(withCoverUrl: coverUrl)
            }
        } else {
            if let currentUserID = SBDMain.getCurrentUser()?.userId  {
                let members = self.channel?.members as? [SBDMember] ?? []
                let filterMembers = members.filter { $0.userId != currentUserID }
                self.profileImageView.users = filterMembers.count < 4 ? filterMembers : Array(filterMembers[0...3])
            }
        }
        self.profileImageView.makeCircularWithSpacing(spacing: 1)
    }
    
    @objc func clickDoneButton(_ sender: Any) {
        self.updateChannelInfo()
    }
    
    func cropImage(_ imageData: Data) {
        guard let image = UIImage(data: imageData) else { return }
        let imageCropVC = RSKImageCropViewController(image: image)
        imageCropVC.delegate = self
        imageCropVC.cropMode = .square
        self.present(imageCropVC, animated: false, completion: nil)
    }
    
    @objc func clickCoverImage() {
        UploadControl().showImagePickerAlert(self)
    }

    func updateChannelInfo() {
        self.loadingIndicatorView.superViewSize = self.view.frame.size
        self.loadingIndicatorView.updateFrame()
        self.loadingIndicatorView.isHidden = false
        self.loadingIndicatorView.startAnimating()
        
        let params = SBDGroupChannelParams()
        
        if self.coverImage == nil {
            params.coverUrl = self.channel?.coverUrl
        } else {
            params.coverImage = self.coverImage?.jpegData(compressionQuality: 0.5)
        }
        
        params.name = self.channelNameTextField.text
        
        self.channel?.update(with: params) { channel, error in
            self.loadingIndicatorView.isHidden = true
            self.loadingIndicatorView.stopAnimating()
            
            if let error = error {
                AlertControl.showError(parent: self, error: error)
                return
            }
            
            self.delegate?.didUpdateGroupChannel()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

// MARK: - NotificationDelegate
extension GroupChannelCoverImageNameSettingViewController: NotificationDelegate {
    func openChat(_ channelURL: String) {
        self.navigationController?.popViewController(animated: false)
        let delegate = UIViewController.currentViewController() as? NotificationDelegate
        delegate?.openChat(channelURL)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension GroupChannelCoverImageNameSettingViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[.mediaType] as! CFString
        
        picker.dismiss(animated: true) { [weak self] in
            if CFStringCompare(mediaType, kUTTypeImage, []) == .compareEqualTo,
                let originalImage = info[.originalImage] as? UIImage,
                let imageData = originalImage.jpegData(compressionQuality: 1.0)
            {
                self?.cropImage(imageData)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - RSKImageCropViewControllerDelegate
extension GroupChannelCoverImageNameSettingViewController: RSKImageCropViewControllerDelegate {
    // Crop image has been canceled.
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: false, completion: nil)
    }
    
    // The original image has been cropped.
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        self.coverImage = croppedImage
        
        controller.dismiss(animated: false, completion: nil)
    }
    
    // The original image has been cropped. Additionally provides a rotation angle used to produce image.
    func imageCropViewController(_ controller: RSKImageCropViewController, willCropImage originalImage: UIImage) {
        // Use when `applyMaskToCroppedImage` set to true
    }
}

extension GroupChannelCoverImageNameSettingViewController {
    static func initiate() -> GroupChannelCoverImageNameSettingViewController {
        let vc = GroupChannelCoverImageNameSettingViewController.withStoryboard(storyboard: .groupChannel)
        return vc
    }
}
