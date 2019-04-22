//
//  UserPreferences.swift
//  Sample-SyncManager-iOS-swift
//
//  Created by sendbird-young on 22/04/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

import Foundation
import SendBirdSyncManager

class UserPreferences: NSObject {
    static private let prefix: String = "com.sendbird.sample.syncmanager"
    
    // MARK: User info
    static private var kUserId: String {
        get {
            let key: String = "\(prefix).user.userId"
            return key
        }
    }
    
    static private var kUserNickname: String {
        get {
            let key: String = "\(prefix).user.nickname"
            return key
        }
    }
    
    static var userId: String? {
        get {
            return UserDefaults.standard.string(forKey: kUserId)
        }
        set(newValue) {
            let userDefaults: UserDefaults = UserDefaults.standard
            if let theNewValue: String = newValue {
                userDefaults.set(theNewValue, forKey: kUserId)
            }
            else {
                userDefaults.removeObject(forKey: kUserId)
            }
            userDefaults.synchronize()
        }
    }
    
    static var userNickname: String? {
        get {
            return UserDefaults.standard.string(forKey: kUserNickname)
        }
        set(newValue) {
            let userDefaults: UserDefaults = UserDefaults.standard
            if let theNewValue: String = newValue {
                userDefaults.set(theNewValue, forKey: kUserNickname)
            }
            else {
                userDefaults.removeObject(forKey: kUserNickname)
            }
            userDefaults.synchronize()
        }
    }
    
    static func removeUserInfo() {
        let userDefaults: UserDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: kUserId)
        userDefaults.removeObject(forKey: kUserNickname)
        userDefaults.synchronize()
    }
    
    // MARK: Last seen at in channel
    static private var kLastSeenAts: String? {
        guard let theUserId: String = userId else { return nil }
        return "\(UserPreferences.prefix).\(theUserId).channel.lastSeenAts"
    }
    
    static private var lastSeenAts: [String:Int64] {
        get {
            guard let keyLastSeenAts: String = kLastSeenAts else {return [String:Int64]()}
            if let lastSeenAts:[String:Int64] = UserDefaults.standard.dictionary(forKey: keyLastSeenAts) as? [String : Int64] {
                return lastSeenAts
            }
            else {
                return [String:Int64]()
            }
        }
        set(newValue) {
            guard let keyLastSeenAts: String = kLastSeenAts else {return}
            
            let userDefaults: UserDefaults = UserDefaults.standard
            userDefaults.set(newValue, forKey: keyLastSeenAts)
            userDefaults.synchronize()
        }
    }
    
    static func lastSeenAt(channelUrl: String?) -> Int64? {
        guard let theChannelUrl: String = channelUrl else { return nil }
        
        return self.lastSeenAts[theChannelUrl]
    }
    
    static func setLastSeenAt(channelUrl: String?, lastSeenAt: Int64) {
        guard let theChannelUrl: String = channelUrl else { return }
        
        var lastSeenAts: [String:Int64] = self.lastSeenAts
        if lastSeenAt > 0  {
            lastSeenAts[theChannelUrl] = lastSeenAt
        }
        else {
            lastSeenAts.removeValue(forKey: theChannelUrl)
        }
        self.lastSeenAts = lastSeenAts
    }
}
