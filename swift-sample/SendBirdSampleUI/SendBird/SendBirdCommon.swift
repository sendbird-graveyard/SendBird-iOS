//
//  SendBirdCommon.swift
//  SendBirdSampleUI
//
//  Created by Jed Kyung on 1/30/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

import UIKit
import SendBirdSDK
import AFNetworking


let kChattingViewMode = 0
let kChannelListViewMode = 1

let kMessagingMemberViewMode = 0
let kMessagingChannelListViewMode = 1
let kMessagingViewMode = 2
let kMessagingChannelListEditViewMode = 3
let kMessagingMemberForGroupChatViewMode = 4

let kChatModeChatting = 0
let kChatModeMessaging = 1

let SENDBIRD_SAMPLE_UI_VER = "SendBird Sample UI v2.0.0"

/// Protocol for NSLocking objects that also provide tryLock()
public protocol TryLockable: NSLocking {
    func tryLock() -> Bool
}

// These Cocoa classes have tryLock()
extension NSLock: TryLockable {}
extension NSRecursiveLock: TryLockable {}
extension NSConditionLock: TryLockable {}


/// Protocol for NSLocking objects that also provide lockBeforeDate()
public protocol BeforeDateLockable: NSLocking {
    func lockBeforeDate(limit: NSDate) -> Bool
}

// These Cocoa classes have lockBeforeDate()
extension NSLock: BeforeDateLockable {}
extension NSRecursiveLock: BeforeDateLockable {}
extension NSConditionLock: BeforeDateLockable {}


/// Use an NSLocking object as a mutex for a critical section of code
public func synchronized<L: NSLocking>(lockable: L, criticalSection: () -> ()) {
    lockable.lock()
    criticalSection()
    lockable.unlock()
}

/// Use an NSLocking object as a mutex for a critical section of code that returns a result
public func synchronizedResult<L: NSLocking, T>(lockable: L, criticalSection: () -> T) -> T {
    lockable.lock()
    let result = criticalSection()
    lockable.unlock()
    return result
}

/// Use a TryLockable object as a mutex for a critical section of code
///
/// Return true if the critical section was executed, or false if tryLock() failed
public func trySynchronized<L: TryLockable>(lockable: L, criticalSection: () -> ()) -> Bool {
    if !lockable.tryLock() {
        return false
    }
    criticalSection()
    lockable.unlock()
    return true
}

/// Use a BeforeDateLockable object as a mutex for a critical section of code
///
/// Return true if the critical section was executed, or false if lockBeforeDate() failed
public func synchronizedBeforeDate<L: BeforeDateLockable>(limit: NSDate, lockable: L, criticalSection: () -> ()) -> Bool {
    if !lockable.lockBeforeDate(limit) {
        return false
    }
    criticalSection()
    lockable.unlock()
    return true
}

let lock = NSLock()

class ImageCache {
    static var cache: NSCache?
    static var _sharedInstance: ImageCache?

    static func initImageCache() {
        if _sharedInstance == nil {
            _sharedInstance = ImageCache()
        }
    }
    
    static func sharedInstance() -> ImageCache {
        synchronized(lock) {
            
        }
        return ImageCache._sharedInstance!
    }
    
    func initCache() {
        ImageCache.cache = NSCache()
    }

    func getImage(key: String) -> AnyObject? {
        if ImageCache.cache?.objectForKey(key) != nil && !(ImageCache.cache?.objectForKey(key) is NSNull) {
            return  ImageCache.cache?.objectForKey(key)
        }
        return nil
    }
    
    func setImage(image: UIImage?, key: AnyObject?) {
        if key == nil || image == nil {
            return
        }
        
        if ImageCache.cache?.objectForKey(key!) != nil && !(ImageCache.cache?.objectForKey(key!) is NSNull) {
            ImageCache.cache?.removeObjectForKey(key!)
        }
        
        ImageCache.cache?.setObject(image!, forKey: key!)
    }
}

class SendBirdUtils {
    
    static func deviceUniqueID() -> String {
        return SendBird.deviceUniqueID()
    }
    
    static func imageDownload(url: NSURL, onEnd: ((response: NSData!, error: NSError!) -> Void)!) {
        var request: NSMutableURLRequest
        
        request = NSMutableURLRequest()
        request.HTTPMethod = "GET"
        request.setValue(String.init(format: "Jios/%@", SendBird.VERSION()), forHTTPHeaderField: "User-Agent")
        request.URL = url

        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) -> Void in
            onEnd(response: data, error: error)
        }
    }
    
    static func getChannelNameFromUrl(channelUrl: String) -> String {
        var result: Array<String>?
        
        result = channelUrl.componentsSeparatedByCharactersInSet(NSCharacterSet.init(charactersInString: "."))
        
        if result?.count > 1 {
            return result![1]
        }
        
        return channelUrl
    }
    
    static func getUrlFromstring(bulk: String) -> String {
        var arrString: Array<String>?
        var url: String? = ""
        
        arrString = bulk.componentsSeparatedByString(" ")
        for var i = 0; i < arrString?.count; i++ {
            if (arrString![i].rangeOfString("http://", options: NSStringCompareOptions.CaseInsensitiveSearch)) != nil {
                url = arrString![i]
                break;
            }
            
            if (arrString![i].rangeOfString("https://", options: NSStringCompareOptions.CaseInsensitiveSearch)) != nil {
                url = arrString![i]
                break;
            }
        }
        
        return url!;
    }
    
    static func messageDateTime(interval: NSTimeInterval) -> String {
        let messageDate = NSDate.init(timeIntervalSince1970: interval)
        let today = NSDate.init()
        let formatter = NSDateFormatter()
        let todayCalendar = NSCalendar.currentCalendar()
        let todayComponents = todayCalendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month], fromDate: today)
        let messageDateComponents = todayCalendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month], fromDate: messageDate)

        let dayOfNow = todayComponents.day
        let monthOfNow = todayComponents.month
        let yearOfNow = todayComponents.year
        let dayOfMessage = messageDateComponents.day
        let monthOfMessage = messageDateComponents.month
        let yearOfMessage = messageDateComponents.year
        
        formatter.locale = NSLocale.currentLocale()
        
        if dayOfNow != dayOfMessage {
            formatter.dateFormat = "MM/dd/YY, HH:mm"
        }
        else {
            if monthOfNow != monthOfMessage || yearOfNow != yearOfMessage {
                formatter.dateFormat = "MM/dd/YY, HH:mm"
            }
            else {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            }
        }
        
        formatter.timeZone = NSTimeZone.localTimeZone()
        
        return formatter.stringFromDate(messageDate)
    }
    
    static func oldMessageDateTime(interval: NSTimeInterval) -> String {
        let date = NSDate.init(timeIntervalSince1970: interval)
        let formatter = NSDateFormatter()
        
        formatter.locale = NSLocale.currentLocale()
        formatter.dateFormat = "MM/dd/YY, HH:mm"
        formatter.timeZone = NSTimeZone.localTimeZone()
        
        return formatter.stringFromDate(date)
    }
    
    static func lastMessageDateTime(interval: NSTimeInterval) -> String {
        let date = NSDate.init(timeIntervalSince1970: interval)
        let formatter = NSDateFormatter()
        
        formatter.locale = NSLocale.currentLocale()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeZone = NSTimeZone.localTimeZone()
        
        return formatter.stringFromDate(date)
    }
    
    static func scaledImage(image: UIImage, width: CGFloat) -> UIImage {
        var newWidth: CGFloat
        var newHeight: CGFloat
        
        if image.size.width > image.size.height {
            newWidth = width * image.size.width / image.size.height
            newHeight = width
        }
        else {
            newHeight = width * image.size.width / image.size.height
            newWidth = width
        }
        
        let newSize = CGSizeMake(newWidth, newHeight)
        UIGraphicsBeginImageContextWithOptions(newSize, true, UIScreen.mainScreen().scale)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    static func getDisplayMemberNames(members: Array<SendBirdMember>) -> String {
        if members.count < 2 {
            return "No Members"
        }
        else if members.count == 2 {
            var names = String()
            for var i = 0; i < members.count; i++ {
                let member = members[i]
                if (member.guestId == SendBird.getUserId()) {
                    continue
                }
                
                names.appendContentsOf(", ")
                names.appendContentsOf(member.name)
            }
            
            names.removeRange(names.startIndex.advancedBy(0)..<names.startIndex.advancedBy(2))
            
            return names
        }
        else {
            return String.init(format: "Group %lu", members.count)
        }
    }
    
    static func getMessagingChannelNames(members: Array<SendBirdMemberInMessagingChannel>) -> String {
        if members.count > 1 {
            var names = String()
            for var i = 0; i < members.count; i++ {
                let member: SendBirdMemberInMessagingChannel = members[i]
                if (member.guestId == SendBird.getUserId()) {
                    continue
                }
                
                names.appendContentsOf(", ")
                names.appendContentsOf(member.name)
            }
            names.removeRange(names.startIndex.advancedBy(0)..<names.startIndex.advancedBy(2))
            
            return names
        }
        else {
            return ""
        }
    }
    
    static func getDisplayCoverImageUrl(members: Array<SendBirdMemberInMessagingChannel>) -> String {
        for member in members {
            if member.guestId == SendBird.getUserId() {
                continue
            }
            
            return member.imageUrl
        }
        
        return ""
    }
    
    static func setMessagingMaxMessageTs(messageTs: Int64) {
        let preferences: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        preferences.setObject(NSNumber.init(longLong: messageTs), forKey: "messaging_max_message_ts")
        preferences.synchronize()
    }
    
    static func getMessagingMaxMessageTs() -> Int64 {
        var maxMessageTs: Int64 = Int64.min
        let preferences: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if preferences.objectForKey("messaging_max_message_ts") != nil {
            maxMessageTs = (preferences.objectForKey("messaging_max_message_ts")?.longLongValue)!
        }
        
        return maxMessageTs
    }
    
    static func imageFromColor(color: UIColor) -> UIImage {
        let rect: CGRect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
    }
    
    static func UIColorFromRGB(rgbValue: Int32) -> UIColor {
        return UIColor.init(colorLiteralRed: ((Float)((rgbValue & 0xFF0000) >> 16))/255.0, green: ((Float)((rgbValue & 0x00FF00) >>  8))/255.0, blue: ((Float)((rgbValue & 0x0000FF) >>  0))/255.0, alpha: 1.0)
    }
    
    static func loadImage(imageUrl: String, imageView: UIImageView, width: CGFloat, height: CGFloat) {
        let iv: UIImageView = imageView
        let request: NSMutableURLRequest = NSMutableURLRequest()
        request.HTTPMethod = "GET"
        request.setValue(String.init(format: "Jios/%@", SendBird.VERSION()), forHTTPHeaderField: "User-Agent")
        request.URL = NSURL.init(string: imageUrl)
        
        iv.setImageWithURLRequest(request, placeholderImage: nil, success: { (request, response, image) -> Void in
            var newSize: CGSize = CGSizeMake(height * 2, width * 2)
            let widthRatio: CGFloat = newSize.width / image.size.width
            let heightRatio: CGFloat = newSize.height / image.size.height
            
            if widthRatio > heightRatio {
                newSize = CGSizeMake(image.size.width * heightRatio, image.size.height * heightRatio)
            }
            else {
                newSize = CGSizeMake(image.size.width * widthRatio, image.size.height * widthRatio)
            }
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
            image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
            let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            iv.image = newImage
            
            }, failure: nil)
    }
}

extension Array {
    mutating func addSendBirdMessage(message: SendBirdMessageModel, updateMessageTs: ((model: SendBirdMessageModel!) -> Void)!) {
        if message.isPast() {
            self.insert(message as! Element, atIndex: 0)
        }
        else {
            append(message as! Element)
        }
        
        updateMessageTs(model: message)
    }
}
