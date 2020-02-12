//
//  UploadControl.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2019/12/13.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import MobileCoreServices

class UploadControl {
     
    /// Photo, Video, Browse File, Library, close...
    func showFilePickerAlert(_ parentVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate & UIViewController & UIDocumentPickerDelegate) {
        weak var parentVC = parentVC
        guard let parent = parentVC else { return }
        
        let photo = getPhotoAction(parent)
        let video = getVideoAction(parent)
        let file = getFileAction(parent)
        let library = getLibarayAction(parent)
        
        AlertControl.show(parent: parent,
                          actions: [photo, video, file, library, .cancelAction],
                          title: nil, style: .actionSheet)
        
        
    }
    
    /// Photo, Library, close...
    func showImagePickerAlert(_ parentVC: UIViewController & UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
        weak var parentVC = parentVC
        guard let parent = parentVC else { return }
        
        let photo = getPhotoAction(parent)
        let library = getLibarayAction(parent)
        
        AlertControl.show(parent: parent,
                          actions: [photo, library, .cancelAction],
                          title: nil,
                          style: .actionSheet)
        
    }
}

private extension UploadControl {
    
    typealias ImagePickerType = UIViewController & UIImagePickerControllerDelegate & UINavigationControllerDelegate
    typealias FilePickerType  = UIViewController & UIImagePickerControllerDelegate & UINavigationControllerDelegate & UIDocumentPickerDelegate
    
    func getFileAction(_ parent: FilePickerType) -> UIAlertAction {
        weak var parent = parent
        return UIAlertAction(title: "Browse Files...", style: .default) { action in
            DispatchQueue.main.async {
                let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
                documentPicker.allowsMultipleSelection = false
                documentPicker.delegate = parent
                parent?.present(documentPicker, animated: true, completion: nil)
            }
        }
    }
    
    func getPhotoAction(_ parent: ImagePickerType) -> UIAlertAction {
        weak var parent = parent
        return UIAlertAction(title: "Take Photo...", style: .default) { action in
            DispatchQueue.main.async {
                let mediaUI = UIImagePickerController()
                mediaUI.sourceType = .camera
                mediaUI.mediaTypes = [String(kUTTypeImage)]
                mediaUI.delegate = parent
                parent?.present(mediaUI, animated: true, completion: nil)
            }
        }
    }
    func getLibarayAction(_ parent: ImagePickerType) -> UIAlertAction {
        weak var parent = parent
        return UIAlertAction(title: "Choose from Library...", style: .default) { action in
            DispatchQueue.main.async {
                let mediaUI = UIImagePickerController()
                mediaUI.sourceType = .photoLibrary
                mediaUI.mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
                mediaUI.delegate = parent
                parent?.present(mediaUI, animated: true, completion: nil)
            }
        }
    }
    
    func getVideoAction(_ parent: ImagePickerType) -> UIAlertAction {
        weak var parent = parent
        return UIAlertAction(title: "Take Video...", style: .default) { action in
            DispatchQueue.main.async {
                let mediaUI = UIImagePickerController()
                mediaUI.sourceType = .camera
                mediaUI.mediaTypes = [String(kUTTypeMovie)]
                mediaUI.delegate = parent
                parent?.present(mediaUI, animated: true, completion: nil)
            }
        }
    }
    
    

}
