//
//  Utils.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/12/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import MobileCoreServices

class Utils: NSObject {
    //    static let imageLoaderQueue = DispatchQueue.init(label: "com.sendbird.imageloader", qos: DispatchQoS.background, attributes: DispatchQueue.Attributes., autoreleaseFrequency: <#T##DispatchQueue.AutoreleaseFrequency#>, target: <#T##DispatchQueue?#>)
    static func getMessageDateStringFromTimestamp(_ timestamp: Int64) -> String? {
        var messageDateString: String = ""
        let messageDateFormatter: DateFormatter = DateFormatter()
        var messageDate: Date?
        if String(format: "%lld", timestamp).count == 10 {
            messageDate = Date.init(timeIntervalSince1970: TimeInterval(timestamp))
        }
        else {
            messageDate = Date.init(timeIntervalSince1970: TimeInterval(Double(timestamp) / 1000.0))
        }
        
        messageDateFormatter.dateStyle = .none
        messageDateFormatter.timeStyle = .short
        messageDateString = messageDateFormatter.string(from: messageDate!)
        
        return messageDateString
    }
    
    static func getDateStringForDateSeperatorFromTimestamp(_ timestamp: Int64) -> String {
        var messageDateString: String = ""
        let messageDateFormatter: DateFormatter = DateFormatter()
        var messageDate: Date?
        if String(format: "%lld", timestamp).count == 10 {
            messageDate = Date.init(timeIntervalSince1970: TimeInterval(timestamp))
        }
        else {
            messageDate = Date.init(timeIntervalSince1970: TimeInterval(Double(timestamp) / 1000.0))
        }
        
        messageDateFormatter.dateStyle = .long
        messageDateFormatter.timeStyle = .none
        messageDateString = messageDateFormatter.string(from: messageDate!)
        
        return messageDateString
    }
    
    static func checkDayChangeDayBetweenOldTimestamp(oldTimestamp: Int64, newTimestamp: Int64) -> Bool {
        var oldMessageDate: Date?
        var newMessageDate: Date?
        
        if String(format: "%lld", oldTimestamp).count == 10 {
            oldMessageDate = Date.init(timeIntervalSince1970: TimeInterval(oldTimestamp))
        }
        else {
            oldMessageDate = Date.init(timeIntervalSince1970: TimeInterval(Double(oldTimestamp) / 1000.0))
        }
        
        if String(format: "%lld", newTimestamp).count == 10 {
            newMessageDate = Date.init(timeIntervalSince1970: TimeInterval(newTimestamp))
        }
        else {
            newMessageDate = Date.init(timeIntervalSince1970: TimeInterval(Double(newTimestamp) / 1000.0))
        }
        
        let oldMessageDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: oldMessageDate!)
        let newMessageDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: newMessageDate!)
        
        if oldMessageDateComponents.year != newMessageDateComponents.year || oldMessageDateComponents.month != newMessageDateComponents.month || oldMessageDateComponents.day != newMessageDateComponents.day {
            return true
        }
        else {
            return false
        }
    }
    
    static func createGroupChannelName(channel: SBDGroupChannel) -> String {
        if channel.name.count > 0 {
            return channel.name
        }
        else {
            return self.createGroupChannelNameFromMembers(channel: channel)
        }
    }
    
    static func createGroupChannelNameFromMembers(channel: SBDGroupChannel) -> String {
        var memberNicknames: [String] = []
        var count: Int = 0
        for member in channel.members as! [SBDUser] {
            if member.userId == SBDMain.getCurrentUser()?.userId {
                continue
            }
            
            memberNicknames.append(member.nickname!)
            count += 1
            if count == 4 {
                break
            }
        }
        
        if count == 0 {
            return "NO MEMBERS"
        }
        else {
            return memberNicknames.joined(separator: ", ")
        }
    }
     
    static func buildTypingIndicatorLabel(channel: SBDGroupChannel) -> String {
        if let typingMembers = channel.getTypingMembers() {
            if typingMembers.count == 0 {
                return ""
            }
            else {
                if typingMembers.count == 1 {
                    return String(format: "%@ is typing.", typingMembers[0].nickname!)
                }
                else if typingMembers.count == 2 {
                    return String(format: "@% and %@ are typing.", typingMembers[0].nickname!, typingMembers[1].nickname!)
                }
                else {
                    return "Several people are typing."
                }
            }
        }
        else {
            return ""
        }
    }
    
    static func getKeyboardAnimationOptions(notification: Notification) -> (height: CGFloat?, duration: Double?, curve: UIView.AnimationOptions) {
        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        
        let animationCurveRawNSN = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = (animationCurveRawNSN?.uintValue) ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        let keyboardFrameBegin = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height
        
        return (height: keyboardFrameBegin, duration: duration, curve: animationCurve)
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (exists index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

//Random String Generator for Channel Url
extension String {
    static func randomUUIDString() -> String{
        return String(UUID().uuidString[..<String.Index(utf16Offset: 8, in: UUID().uuidString)])
    }
}
