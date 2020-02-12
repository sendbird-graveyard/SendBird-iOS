//
//  CreateGroupChannelViewControllerB.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/15/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import RSKImageCropper 
import MobileCoreServices
import Photos

class CreateGroupChannelViewControllerB: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, NotificationDelegate {
    var members: [SBDUser] = []
    
    @IBOutlet weak var profileImageView: ProfileImageView!
    
    @IBOutlet weak var channelNameTextField: UITextField!
    @IBOutlet weak var loadingIndicatorView: CustomActivityIndicatorView!

    var coverImageData: Data?
    var createButtonItem: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Create Group Channel"
        self.navigationItem.largeTitleDisplayMode = .never

        self.createButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(CreateGroupChannelViewControllerB.clickCreateGroupChannel(_ :)))
        self.navigationItem.rightBarButtonItem = self.createButtonItem
        
        self.coverImageData = nil
        self.view.bringSubviewToFront(self.loadingIndicatorView)
        self.loadingIndicatorView.isHidden = true
        
        var memberNicknames: [String] = []
        var memberCount: Int = 0
        for user in self.members {
            memberNicknames.append(user.nickname!)
            memberCount += 1
            if memberCount == 4 {
                break
            }
        }
        
        let channelNamePlaceholder = memberNicknames.joined(separator: ", ")
        self.channelNameTextField.attributedPlaceholder = NSAttributedString(string: channelNamePlaceholder, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0, weight: .regular),
            NSAttributedString.Key.foregroundColor: UIColor(named: "color_channelname_nickname_placeholder") as Any
            ])
        self.profileImageView.isUserInteractionEnabled = true
        let tapCoverImageGesture = UITapGestureRecognizer(target: self, action: #selector(CreateGroupChannelViewControllerB.clickCoverImage(_ :)))
        self.profileImageView.addGestureRecognizer(tapCoverImageGesture)
        
        self.profileImageView.users = members
        self.profileImageView.makeCircularWithSpacing(spacing: 1)
    }
    
    @objc func clickCoverImage(_ sender: AnyObject) {
        UploadControl().showImagePickerAlert(self)
        
    }
    
    @objc func clickCreateGroupChannel(_ sender: AnyObject) {
        self.showLoadingIndicatorView()
        
        let channelName = self.channelNameTextField.text != "" ? self.channelNameTextField.text : self.channelNameTextField.placeholder
        
        let params = SBDGroupChannelParams()
        params.coverImage = self.coverImageData
        params.add(self.members)
        params.name = channelName
        
        SBDGroupChannel.createChannel(with: params) { (channel, error) in
            self.hideLoadingIndicatorView()
            
            if let error = error {
                AlertControl.showError(parent: self, error: error) 
                return
            }
            
            if let navigationController = self.navigationController as? CreateGroupChannelNavigationController {
                if (navigationController.channelCreationDelegate?.responds(to: #selector(CreateGroupChannelNavigationController.didChangeValue(forKey:))))! {
                    navigationController.channelCreationDelegate?.didCreateGroupChannel(channel!)
                }
                navigationController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func cropImage(_ imageData: Data) {
        if let image = UIImage(data: imageData) {
            let imageCropVC = RSKImageCropViewController(image: image)
            imageCropVC.delegate = self
            imageCropVC.cropMode = .square
            self.present(imageCropVC, animated: false, completion: nil)
        }
    }
    
    // MARK: - NotificationDelegate
    func openChat(_ channelURL: String) {
        self.navigationController?.popViewController(animated: false)
        let delegate = UIViewController.currentViewController() as? NotificationDelegate
        delegate?.openChat(channelURL)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            if CFStringCompare(mediaType, kUTTypeImage, []) == .compareEqualTo {
                if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    if let imageData = originalImage.jpegData(compressionQuality: 1.0) {
                        self.cropImage(imageData)
                    }
                }
            }
        }
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
        self.coverImageData = croppedImage.jpegData(compressionQuality: 0.5)
        controller.dismiss(animated: false, completion: nil)
    }
    
    // The original image will be cropped.
    func imageCropViewController(_ controller: RSKImageCropViewController, willCropImage originalImage: UIImage) {
        // Use when `applyMaskToCroppedImage` set to true
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

extension CreateGroupChannelViewControllerB {
    static func initiate() -> CreateGroupChannelViewControllerB {
        
        let vc = CreateGroupChannelViewControllerB.withStoryboard(storyboard: .groupChannel)
        return vc
    }
}
