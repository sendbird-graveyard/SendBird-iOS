//
//  GroupChannelChatViewController+UIDocumentPickerDelegate.swift
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
  
extension GroupChannelChatViewController: UIDocumentPickerDelegate {
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) { 
        guard let fileURL = urls.first else { return }
        guard let fileData = try? Data(contentsOf: fileURL) else { return }
        
        let filename = fileURL.lastPathComponent
        let ext = filename.pathExtension()
        guard let utType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)?.takeRetainedValue() else { return }
        let retainedValueMimeType = UTTypeCopyPreferredTagWithClass(utType, kUTTagClassMIMEType)?.takeRetainedValue()
        let mimeType = retainedValueMimeType == nil ? "application/octet-stream" : retainedValueMimeType! as String
        
        guard let params = SBDFileMessageParams(file: fileData) else { return }
        params.fileName = filename
        params.mimeType = mimeType
        params.fileSize = UInt(fileData.count)
        
        self.sendFileMessage(by: params)
    }
}
