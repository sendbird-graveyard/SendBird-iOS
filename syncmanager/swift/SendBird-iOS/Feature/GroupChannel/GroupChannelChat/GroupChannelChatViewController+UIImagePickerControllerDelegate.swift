//
//  GroupChannelChatViewController+UIImagePickerControllerDelegate.swift
//  SendBird-iOS
//
//  Created by sw.kim on 2019/11/28.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import RSKImageCropper
import Photos
import AVKit
import MobileCoreServices 
import FLAnimatedImage

// MARK: - UIImagePickerControllerDelegate
extension GroupChannelChatViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[.mediaType] as! CFString
        
        picker.dismiss(animated: true) { [unowned self] () in
            
            // Video
            if CFStringCompare(mediaType, kUTTypeMovie, []) == .compareEqualTo {
                self.sendVideoFileMessage(info: info)
                return
            }
            
            // Image
            guard CFStringCompare(mediaType, kUTTypeImage, []) == .compareEqualTo else { return }
            
            guard let imagePath = info[.imageURL] as? URL else {
                guard let originalImage = info[.originalImage] as? UIImage else { return }
                guard let imageData = originalImage.jpegData(compressionQuality: 1.0) else { return }
                self.sendImageFileMessage(imageData: imageData, imageName: "image.jpg", mimeType: "image/jpeg")
                return
            }
            
            let imageName = imagePath.lastPathComponent
            let ext = imageName.pathExtension()
            guard let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)?.takeRetainedValue() else { return }
            guard let retainedValueMimeType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType)?.takeRetainedValue() else { return }
            let mimeType = retainedValueMimeType as String
            
            guard let imageAsset = info[.phAsset] as? PHAsset else { return }
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat
            
            if mimeType == "image/gif" {
                PHImageManager.default().requestImageData(for: imageAsset, options: options) { imageData, dataUTI, orientation, info in
                    guard let originalImageData = imageData else { return }
                    self.sendImageFileMessage(imageData: originalImageData, imageName: imageName, mimeType: mimeType)
                    
                }
            } else {
                PHImageManager.default().requestImage(for: imageAsset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options) { result, info in
                    guard let imageData = result?.jpegData(compressionQuality: 1.0) else { return }
                    self.sendImageFileMessage(imageData: imageData, imageName: imageName, mimeType: mimeType)
                    
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
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        controller.dismiss(animated: false, completion: nil)
    }
    
    // The original image will be cropped.
    func imageCropViewController(_ controller: RSKImageCropViewController, willCropImage originalImage: UIImage) {
        // Use when `applyMaskToCroppedImage` set to YES.
    }
}

