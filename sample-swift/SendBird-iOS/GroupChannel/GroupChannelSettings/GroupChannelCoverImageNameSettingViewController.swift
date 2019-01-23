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
import AlamofireImage

class GroupChannelCoverImageNameSettingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, NotificationDelegate {
    weak var delegate: GroupChannelCoverImageNameSettingDelegate?
    var channel: SBDGroupChannel?

    var coverImage: UIImage?
    
    @IBOutlet weak var loadingIndicatorView: CustomActivityIndicatorView!
    @IBOutlet weak var channelNameTextField: UITextField!
    
    @IBOutlet weak var coverImageContainerView: UIView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Cover Image & Name"
        self.navigationItem.largeTitleDisplayMode = .never
        
        if let navigationController = self.navigationController {
            let barButtonItemBack = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
            let prevVC = navigationController.viewControllers[navigationController.viewControllers.count - 2]
            prevVC.navigationItem.backBarButtonItem = barButtonItemBack
        }
        
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
        
        self.coverImageContainerView.isUserInteractionEnabled = true
        let tapCoverImageGesture = UITapGestureRecognizer(target: self, action: #selector(GroupChannelCoverImageNameSettingViewController.clickCoverImage))
        self.coverImageContainerView.addGestureRecognizer(tapCoverImageGesture)
        
        self.singleCoverImageContainerView.isHidden = true
        self.doubleCoverImageContainerView.isHidden = true
        self.tripleCoverImageContainerView.isHidden = true
        self.quadrupleCoverImageContainerView.isHidden = true
        var currentMembers: [SBDMember] = []
        var count = 0
        for member in self.channel?.members as! [SBDMember] {
            if member.userId == SBDMain.getCurrentUser()?.userId {
                continue
            }
            currentMembers.append(member)
            count += 1
            if count == 4 {
                break
            }
        }
        
        if (self.channel?.coverUrl?.count)! > 0 && !(self.channel?.coverUrl?.hasPrefix("https://sendbird.com/main/img/cover/"))! {
            self.singleCoverImageContainerView.isHidden = false
            
            if let url = URL(string: (self.channel?.coverUrl)!) {
                self.singleCoverImageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "img_cover_image_placeholder_1"))
            }
            else {
                self.singleCoverImageView.image = UIImage(named: "img_cover_image_placeholder_1")
            }
        }
        else {
            if currentMembers.count == 0 {
                self.singleCoverImageContainerView.isHidden = false
                self.singleCoverImageView.image = UIImage(named: "img_default_profile_image_1")
            }
            else if currentMembers.count == 1 {
                self.singleCoverImageContainerView.isHidden = false
                let url0 = Utils.transformUserProfileImage(user: currentMembers[0])
                if url0.count > 0 {
                    self.singleCoverImageView.af_setImage(withURL: URL(string: url0)!, placeholderImage: Utils.getDefaultUserProfileImage(user: currentMembers[0]))
                }
                else {
                    self.singleCoverImageView.image = Utils.getDefaultUserProfileImage(user: currentMembers[0])
                }
            }
            else if currentMembers.count == 2 {
                self.doubleCoverImageContainerView.isHidden = false
                let url0 = Utils.transformUserProfileImage(user: currentMembers[0])
                if url0.count > 0 {
                    self.doubleCoverImageView1.af_setImage(withURL: URL(string: url0)!, placeholderImage: Utils.getDefaultUserProfileImage(user: currentMembers[0]))
                }
                else {
                    self.doubleCoverImageView1.image = Utils.getDefaultUserProfileImage(user: currentMembers[0])
                }
                
                let url1 = Utils.transformUserProfileImage(user: currentMembers[1])
                if url1.count > 0 {
                    self.doubleCoverImageView2.af_setImage(withURL: URL(string: url1)!, placeholderImage: Utils.getDefaultUserProfileImage(user: currentMembers[1]))
                }
                else {
                    self.doubleCoverImageView2.image = Utils.getDefaultUserProfileImage(user: currentMembers[1])
                }
            }
            else if currentMembers.count == 3 {
                self.tripleCoverImageContainerView.isHidden = false
                let url0 = Utils.transformUserProfileImage(user: currentMembers[0])
                if url0.count > 0 {
                    self.tripleCoverImageView1.af_setImage(withURL: URL(string: url0)!, placeholderImage: Utils.getDefaultUserProfileImage(user: currentMembers[0]))
                }
                else {
                    self.tripleCoverImageView1.image = Utils.getDefaultUserProfileImage(user: currentMembers[0])
                }
                
                let url1 = Utils.transformUserProfileImage(user: currentMembers[1])
                if url1.count > 0 {
                    self.tripleCoverImageView2.af_setImage(withURL: URL(string: url1)!, placeholderImage: Utils.getDefaultUserProfileImage(user: currentMembers[1]))
                }
                else {
                    self.tripleCoverImageView2.image = Utils.getDefaultUserProfileImage(user: currentMembers[1])
                }
                
                let url2 = Utils.transformUserProfileImage(user: currentMembers[2])
                if url2.count > 0 {
                    self.tripleCoverImageView3.af_setImage(withURL: URL(string: url2)!, placeholderImage: Utils.getDefaultUserProfileImage(user: currentMembers[2]))
                }
                else {
                    self.tripleCoverImageView3.image = Utils.getDefaultUserProfileImage(user: currentMembers[2])
                }
            }
            else if currentMembers.count == 4 {
                self.quadrupleCoverImageContainerView.isHidden = false
                let url0 = Utils.transformUserProfileImage(user: currentMembers[0])
                if url0.count > 0 {
                    self.quadrupleCoverImageView1.af_setImage(withURL: URL(string: url0)!, placeholderImage: Utils.getDefaultUserProfileImage(user: currentMembers[0]))
                }
                else {
                    self.quadrupleCoverImageView1.image = Utils.getDefaultUserProfileImage(user: currentMembers[0])
                }
                
                let url1 = Utils.transformUserProfileImage(user: currentMembers[1])
                if url1.count > 0 {
                    self.quadrupleCoverImageView2.af_setImage(withURL: URL(string: url1)!, placeholderImage: Utils.getDefaultUserProfileImage(user: currentMembers[1]))
                }
                else {
                    self.quadrupleCoverImageView2.image = Utils.getDefaultUserProfileImage(user: currentMembers[1])
                }
                
                let url2 = Utils.transformUserProfileImage(user: currentMembers[2])
                if url2.count > 0 {
                    self.quadrupleCoverImageView3.af_setImage(withURL: URL(string: url2)!, placeholderImage: Utils.getDefaultUserProfileImage(user: currentMembers[2]))
                }
                else {
                    self.quadrupleCoverImageView3.image = Utils.getDefaultUserProfileImage(user: currentMembers[2])
                }
                
                let url3 = Utils.transformUserProfileImage(user: currentMembers[3])
                if url3.count > 0 {
                    self.quadrupleCoverImageView4.af_setImage(withURL: URL(string: url3)!, placeholderImage: Utils.getDefaultUserProfileImage(user: currentMembers[3]))
                }
                else {
                    self.quadrupleCoverImageView4.image = Utils.getDefaultUserProfileImage(user: currentMembers[3])
                }
            }
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
    
    @objc func clickDoneButton(_ sender: Any) {
        self.updateChannelInfo()
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
        if cvc is GroupChannelSettingsViewController {
            (cvc as! GroupChannelSettingsViewController).openChat(channelUrl)
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        weak var weakSelf: GroupChannelCoverImageNameSettingViewController? = self
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
        self.coverImage = croppedImage
        
        self.singleCoverImageView.image = croppedImage
        self.singleCoverImageContainerView.isHidden = false
        self.doubleCoverImageContainerView.isHidden = true
        self.tripleCoverImageContainerView.isHidden = true
        self.quadrupleCoverImageContainerView.isHidden = true

        controller.dismiss(animated: false, completion: nil)
    }
    
    // The original image has been cropped. Additionally provides a rotation angle used to produce image.
    func imageCropViewController(_ controller: RSKImageCropViewController, willCropImage originalImage: UIImage) {
        // Use when `applyMaskToCroppedImage` set to true
    }
    
    @objc func clickCoverImage() {
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
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose from Library...", style: .default) { (action) in
            DispatchQueue.main.async {
                let mediaUI = UIImagePickerController()
                mediaUI.sourceType = UIImagePickerController.SourceType.photoLibrary
                let mediaTypes = [String(kUTTypeImage)]
                mediaUI.mediaTypes = mediaTypes
                mediaUI.delegate = self
                self.present(mediaUI, animated: true, completion: nil)
            }
        }
        
        let closeAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        
        vc.addAction(takePhotoAction)
        vc.addAction(chooseFromLibraryAction)
        vc.addAction(closeAction)
        
        self.present(vc, animated: true, completion: nil)
    }

    func updateChannelInfo() {
        self.loadingIndicatorView.isHidden = false
        self.loadingIndicatorView.startAnimating()
        
        let params = SBDGroupChannelParams()
        if self.coverImage != nil {
            params.coverImage = self.coverImage?.jpegData(compressionQuality: 0.5)
        }
        else {
            params.coverUrl = self.channel?.coverUrl
        }
        
        params.name = self.channelNameTextField.text
        
        if let channel = self.channel {
            channel.update(with: params) { (channel, error) in
                self.loadingIndicatorView.isHidden = true
                self.loadingIndicatorView.stopAnimating()
                
                if error != nil {
                    Utils.showAlertController(error: error!, viewController: self)
                    return
                }
                
                if let delegate = self.delegate {
                    if delegate.responds(to: #selector(GroupChannelCoverImageNameSettingDelegate.didUpdateGroupChannel)) {
                        delegate.didUpdateGroupChannel!()
                    }
                }
                
                if let navigationController = self.navigationController {
                    navigationController.popViewController(animated: true)
                }
            }
        }
    }
}
