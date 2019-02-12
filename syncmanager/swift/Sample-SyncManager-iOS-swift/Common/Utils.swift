//
//  Utils.swift
//  SendBird-iOS-LocalCache-Sample-swift
//
//  Created by Jed Kyung on 10/6/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import CommonCrypto
import MobileCoreServices

typealias MessageComparison = (SBDBaseMessage, SBDBaseMessage) -> Bool
typealias ChannelComparison = (SBDGroupChannel, SBDGroupChannel) -> Bool

typealias BatchTableviewProcess = (UITableView) -> Void
typealias BoolHandler = (Bool) -> Void

class SBSMIndex: NSObject {
    private let _indexOfObject: Int
    private let _indexOfPreviousObject: Int
    
    override init() {
        _indexOfObject = NSNotFound
        _indexOfPreviousObject = NSNotFound
    }
    
    init(index: Int, previousIndex: Int) {
        _indexOfObject = index
        _indexOfPreviousObject = previousIndex
    }
    
    func containsObject() -> Bool {
        return (self._indexOfObject != NSNotFound)
    }

    var indexOfObject: Int {
        get {
            return _indexOfObject
        }
    }
    
    var indexOfPreviousObject: Int {
        get {
            return _indexOfPreviousObject
        }
    }
}

class Utils: NSObject {
    static func imageFromColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static func generateNavigationTitle(mainTitle: String, subTitle: String?) -> NSAttributedString? {
        var mainTitleAttribute: [NSAttributedString.Key:AnyObject]
        var subTitleAttribute: [NSAttributedString.Key:AnyObject]?
        var fullTitle: NSMutableAttributedString
        
        mainTitleAttribute = [
            NSAttributedString.Key.font: Constants.navigationBarTitleFont(),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        fullTitle = NSMutableAttributedString(string: mainTitle)
        fullTitle.addAttributes(mainTitleAttribute, range: NSMakeRange(0, mainTitle.count))
        
        if let theSubTitle: String = subTitle {
            subTitleAttribute = [
                NSAttributedString.Key.font: Constants.navigationBarSubTitleFont(),
                NSAttributedString.Key.foregroundColor: Constants.navigationBarSubTitleColor()
            ]
            fullTitle.append(NSAttributedString(string: "\n\(theSubTitle)"))
            fullTitle.addAttributes(subTitleAttribute!, range: NSMakeRange(mainTitle.count + 1, (subTitle?.count)!))
        }
        
        return fullTitle
    }
    
    static func sha256(string: String) -> String? {
        let sha256hash: NSMutableString = NSMutableString()
        guard let messageData = string.data(using:String.Encoding.utf8) else { return nil }
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        messageData.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(messageData.count), &hash)
        }

        for i in 0..<32 {
            sha256hash.appendFormat("%02x", hash[i])
        }
        
        return (sha256hash as String)
    }
    
    static func findBestViewController(vc: UIViewController) -> UIViewController? {
        if vc.presentedViewController != nil {
            return Utils.findBestViewController(vc: vc.presentedViewController!)
        }
        else if vc.isKind(of: UISplitViewController.self) {
            let svc = vc as! UISplitViewController
            if svc.viewControllers.count > 0 {
                return Utils.findBestViewController(vc: svc.viewControllers.last!)
            }
            else {
                return vc
            }
        }
        else if vc.isKind(of: UINavigationController.self) {
            let svc = vc as! UINavigationController
            if svc.viewControllers.count > 0 {
                return Utils.findBestViewController(vc: svc.topViewController!)
            }
            else {
                return vc
            }
        }
        else if vc.isKind(of: UITabBarController.self) {
            let svc = vc as! UITabBarController
            if (svc.viewControllers?.count)! > 0 {
                return Utils.findBestViewController(vc: svc.selectedViewController!)
            }
            else {
                return vc
            }
        }
        else {
            return vc
        }
    }
    
    static func isKindOfImage(mediaType: String) -> Bool {
        return (CFStringCompare(mediaType as CFString, kUTTypeImage, []) == CFComparisonResult.compareEqualTo)
    }
    
    static func isKindOfVideo(mediaType: String) -> Bool {
        return (CFStringCompare(mediaType as CFString, kUTTypeVideo, []) == CFComparisonResult.compareEqualTo)
    }
    
    static func infersMimeType(url: URL) -> String? {
        let ext: String = url.pathExtension
        let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)?.takeRetainedValue()
        let mimeType = UTTypeCopyPreferredTagWithClass(UTI!, kUTTagClassMIMEType)?.takeRetainedValue()
        
        if let mimeTypeString: NSString? = mimeType, let theMimeType: String = mimeTypeString as String? {
            return theMimeType
        } else {
            return nil
        }
    }
    
    static func isTopViewController(viewController: UIViewController) -> Bool {
        return (viewController === self.topViewController())
    }
    
    static func topViewController() -> UIViewController? {
        return self.topViewController(rootViewController: UIApplication.shared.keyWindow?.rootViewController)
    }
    
    static func topViewController(rootViewController: UIViewController?) -> UIViewController? {
        guard let theRootViewController: UIViewController = rootViewController,
            let presentedViewController: UIViewController = theRootViewController.presentedViewController,
            !presentedViewController.isBeingDismissed else {
            return rootViewController
        }
        
        if let navigationController: UINavigationController = presentedViewController as? UINavigationController {
            let lastViewController: UIViewController? = navigationController.viewControllers.last
            return self.topViewController(rootViewController:lastViewController)
        }
        else {
            return self.topViewController(rootViewController:presentedViewController)
        }
    }
}

extension Utils {
    static func indexes(messages: [SBDBaseMessage], inMessages: [SBDBaseMessage]) -> [SBSMIndex] {
        guard messages.count > 0 else {
            return []
        }
        
        let sortDescription: MessageComparison = {(message1, message2) -> Bool in
            return (message1.createdAt < message2.createdAt)
        }
        
        let sort: Bool = sortDescription(inMessages.first!, inMessages.last!)
        
        var index: Int = 0
        var indexes: [SBSMIndex] = []
        for message in messages {
            var found: Bool = false
            while (index < inMessages.count) {
                let baseMessage: SBDBaseMessage = inMessages[index]
                if baseMessage.messageId == message.messageId {
                    let previousIndex: Int = (index > 0) ? (index - 1) : NSNotFound
                    found = true
                    indexes.append(SBSMIndex.init(index: index, previousIndex: previousIndex))
                    break
                }
                
                if sort != sortDescription(message, baseMessage) {
                    let previousIndex: Int = (index > 0) ? (index - 1) : NSNotFound
                    found = true
                    indexes.append(SBSMIndex.init(index: NSNotFound, previousIndex: previousIndex))
                    break
                }
                
                index += 1
            }
            
            if !found {
                indexes.append(SBSMIndex.init(index: NSNotFound, previousIndex: index))
            }
            
            index += 1
        }
        
        return indexes
    }
    
    static func indexes(channels: [SBDGroupChannel], inChannels: [SBDGroupChannel], sortDescription: ChannelComparison) -> [SBSMIndex] {
        guard channels.count > 0 else {
            return []
        }
        
        let sort: Bool = sortDescription(inChannels.first!, inChannels.last!)
        
        var index: Int = 0
        var indexes: [SBSMIndex] = []
        for channel in channels {
            var found: Bool = false
            while (index < inChannels.count) {
                let baseChannel: SBDGroupChannel = inChannels[index]
                if baseChannel.channelUrl == channel.channelUrl {
                    let previousIndex: Int = (index > 0) ? (index - 1) : NSNotFound
                    found = true
                    indexes.append(SBSMIndex.init(index: index, previousIndex: previousIndex))
                    break
                }
                
                if sort != sortDescription(channel, baseChannel) {
                    let previousIndex: Int = (index > 0) ? (index - 1) : NSNotFound
                    found = true
                    indexes.append(SBSMIndex.init(index: NSNotFound, previousIndex: previousIndex))
                    break
                }
                
                index += 1
            }
            
            if !found {
                indexes.append(SBSMIndex.init(index: NSNotFound, previousIndex: index))
            }
            
            index += 1
        }
        
        return indexes
    }
    
    static func index(channel: SBDGroupChannel, inChannels: [SBDGroupChannel], sortDescription: ChannelComparison) -> SBSMIndex {
        let indexes: [SBSMIndex] = self.indexes(channels: [channel], inChannels: inChannels, sortDescription: sortDescription)
        let index: SBSMIndex? = indexes.first
        if (index != nil) {
            return index!
        }
        else {
            return SBSMIndex.init()
        }
    }
    
    static func index(messageId: Int64, ofMessages: [SBDBaseMessage]) -> SBSMIndex {
        guard ofMessages.count > 0 else {
            return SBSMIndex.init()
        }
        
        var index: Int = 0
        while index < ofMessages.count {
            let message: SBDBaseMessage = ofMessages[index]
            if message.messageId == messageId {
                let previousIndex: Int = (index > 0) ? (index - 1) : NSNotFound
                return SBSMIndex.init(index: index, previousIndex: previousIndex)
            }
            
            index += 1
        }
        
        return SBSMIndex.init()
    }
    
    static func index(channelUrl: String, ofChannels: [SBDGroupChannel]) -> SBSMIndex {
        guard ofChannels.count > 0 else {
            return SBSMIndex.init()
        }
        
        var index: Int = 0
        while index < ofChannels.count {
            let channel: SBDGroupChannel = ofChannels[index]
            if channel.channelUrl == channelUrl {
                let previousIndex: Int = (index > 0) ? (index - 1) : NSNotFound
                return SBSMIndex.init(index: index, previousIndex: previousIndex)
            }
            
            index += 1
        }
        
        return SBSMIndex.init()
    }
}

extension Utils {
    static func performBatchUpdate(tableView: UITableView, updateProcess: @escaping BatchTableviewProcess, completion completionHandler: @escaping BoolHandler ) -> Void {
        if #available(iOS 11.0, *) {
            DispatchQueue.main.async {
                tableView.performBatchUpdates({
                    updateProcess(tableView)
                }, completion: completionHandler)
            }
        }
        else {
            tableView.beginUpdates()
            updateProcess(tableView)
            tableView.endUpdates()
            
            completionHandler(true)
        }
    }
}
