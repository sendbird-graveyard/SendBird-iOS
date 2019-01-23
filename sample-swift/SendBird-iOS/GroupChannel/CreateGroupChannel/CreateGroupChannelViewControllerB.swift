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
import AlamofireImage
import MobileCoreServices
import Photos

class CreateGroupChannelViewControllerB: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, NotificationDelegate {
    var members: [SBDUser] = []
    
    @IBOutlet weak var coverImageContainerView: UIView!
    @IBOutlet weak var channelNameTextField: UITextField!
    
    @IBOutlet weak var singleCoverImageContainerView: UIView!
    @IBOutlet weak var singleCoverImageView: UIImageView!
    
    @IBOutlet weak var doubleCoverImageContainerView: UIView!
    @IBOutlet weak var doubleCoverImageView1: UIImageView!
    @IBOutlet weak var doubleCoverImageView2: UIImageView!
    
    @IBOutlet weak var tripleCoverImageContainerView: UIView!
    @IBOutlet weak var tripleCoverImageView1: UIImageView!
    @IBOutlet weak var tripleCoverImageView2: UIImageView!
    @IBOutlet weak var tripleCoverImageView3: UIImageView!
    
    @IBOutlet weak var quadrupleCoverImageContainerView: UIView!
    @IBOutlet weak var quadrupleCoverImageView1: UIImageView!
    @IBOutlet weak var quadrupleCoverImageView2: UIImageView!
    @IBOutlet weak var quadrupleCoverImageView3: UIImageView!
    @IBOutlet weak var quadrupleCoverImageView4: UIImageView!
    
    @IBOutlet weak var loadingIndicatorView: CustomActivityIndicatorView!
    
    var coverImageData: Data?
    var createButtonItem: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Create Group Channel"
        
        self.navigationItem.largeTitleDisplayMode = .never
        let barButtonItemBack = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        let prevVC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2]
        prevVC!.navigationItem.backBarButtonItem = barButtonItemBack
        
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
        self.coverImageContainerView.isUserInteractionEnabled = true
        let tapCoverImageGesture = UITapGestureRecognizer(target: self, action: #selector(CreateGroupChannelViewControllerB.clickCoverImage(_ :)))
        self.coverImageContainerView.addGestureRecognizer(tapCoverImageGesture)
        
        self.singleCoverImageContainerView.isHidden = true
        self.doubleCoverImageContainerView.isHidden = true
        self.tripleCoverImageContainerView.isHidden = true
        self.quadrupleCoverImageContainerView.isHidden = true
        
        if members.count == 1 {
            self.singleCoverImageContainerView.isHidden = false
            Utils.setProfileImage(imageView: self.singleCoverImageView, user: members[0])
        }
        else if members.count == 2 {
            self.doubleCoverImageContainerView.isHidden = false
            Utils.setProfileImage(imageView: self.doubleCoverImageView1, user: members[0])
            Utils.setProfileImage(imageView: self.doubleCoverImageView2, user: members[1])
        }
        else if members.count == 3 {
            self.tripleCoverImageContainerView.isHidden = false
            Utils.setProfileImage(imageView: self.tripleCoverImageView1, user: members[0])
            Utils.setProfileImage(imageView: self.tripleCoverImageView2, user: members[1])
            Utils.setProfileImage(imageView: self.tripleCoverImageView3, user: members[2])
        }
        else if members.count >= 4 {
            self.quadrupleCoverImageContainerView.isHidden = false
            Utils.setProfileImage(imageView: self.quadrupleCoverImageView1, user: members[0])
            Utils.setProfileImage(imageView: self.quadrupleCoverImageView2, user: members[1])
            Utils.setProfileImage(imageView: self.quadrupleCoverImageView3, user: members[2])
            Utils.setProfileImage(imageView: self.quadrupleCoverImageView4, user: members[3])
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

    @objc func clickCoverImage(_ sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionTakePhoto = UIAlertAction(title: "Take Photo...", style: .default) { (action) in
            DispatchQueue.main.async {
                let mediaUI = UIImagePickerController()
                mediaUI.sourceType = UIImagePickerController.SourceType.camera
                let mediaTypes = [String(kUTTypeImage)]
                mediaUI.mediaTypes = mediaTypes
                mediaUI.delegate = self
                self.present(mediaUI, animated: true, completion: nil)
            }
        }
        
        let actionChooseFromLibrary = UIAlertAction(title: "Choose from Library...", style: .default) { (action) in
            DispatchQueue.main.async {
                let mediaUI = UIImagePickerController()
                mediaUI.sourceType = UIImagePickerController.SourceType.photoLibrary
                let mediaTypes = [String(kUTTypeImage)]
                mediaUI.mediaTypes = mediaTypes
                mediaUI.delegate = self
                self.present(mediaUI, animated: true, completion: nil)
            }
        }
        
        let actionClose = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        
        alertController.addAction(actionTakePhoto)
        alertController.addAction(actionChooseFromLibrary)
        alertController.addAction(actionClose)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func clickCreateGroupChannel(_ sender: AnyObject) {
        self.showLoadingIndicatorView()
        let channelName = self.channelNameTextField.text
        
        let params = SBDGroupChannelParams()
        params.coverImage = self.coverImageData
        params.isDistinct = true
        if let isDistinct = UserDefaults.standard.object(forKey: Constants.ID_CREATE_DISTINCT_CHANNEL) {
            params.isDistinct = isDistinct as! Bool
        }
        params.add(self.members)
        params.name = channelName
        
        SBDGroupChannel.createChannel(with: params) { (channel, error) in
            self.hideLoadingIndicatorView()
            
            if error != nil {
                let alertController = UIAlertController(title: "Error", message: error?.domain, preferredStyle: .alert)
                let actionClose = UIAlertAction(title: "Close", style: .cancel, handler: nil)
                alertController.addAction(actionClose)
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
                
                return
            }
            
            let vc = GroupChannelChatViewController.init(nibName: "GroupChannelChatViewController", bundle: nil)
            vc.channel = channel

            if let navigationController = self.navigationController {
                if (navigationController as! CreateGroupChannelNavigationController).channelCreationDelegate != nil && ((navigationController as! CreateGroupChannelNavigationController).channelCreationDelegate?.responds(to: #selector(CreateGroupChannelNavigationController.didChangeValue(forKey:))))! {
                    (navigationController as! CreateGroupChannelNavigationController).channelCreationDelegate?.didCreateGroupChannel!(channel!)
                }
                navigationController.pushViewController(vc, animated: true)
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
    func openChat(_ channelUrl: String) {
        self.navigationController?.popViewController(animated: false)
        let cvc = UIViewController.currentViewController()
        if cvc is CreateGroupChannelViewControllerA {
            (cvc as! CreateGroupChannelViewControllerA).openChat(channelUrl)
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        weak var weakSelf: CreateGroupChannelViewControllerB? = self
        picker.dismiss(animated: true) {
            let strongSelf = weakSelf
            if CFStringCompare(mediaType, kUTTypeImage, []) == .compareEqualTo {
                if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    if let imageData = originalImage.jpegData(compressionQuality: 1.0) {
                        strongSelf?.cropImage(imageData)
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
        self.singleCoverImageView.image = croppedImage
        self.singleCoverImageContainerView.isHidden = false
        self.doubleCoverImageContainerView.isHidden = true
        self.tripleCoverImageContainerView.isHidden = true
        self.quadrupleCoverImageContainerView.isHidden = true
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
