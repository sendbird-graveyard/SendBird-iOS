//
//  ConnectionManager.swift
//  SendBird-iOS-LocalCache-Sample-swift
//
//  Created by sendbird-young on 2018. 4. 11..
//  Copyright © 2018년 SendBird. All rights reserved.
//

import Foundation
import SendBirdSDK
import SendBirdSyncManager

let ErrorDomainConnection = "com.sendbird.sample.connection"
let ErrorDomainUser = "com.sendbird.sample.user"

protocol ConnectionManagerDelegate: NSObjectProtocol {
    func didConnect(isReconnection: Bool)
    func didDisconnect()
}

class ConnectionManager: NSObject, SBDConnectionDelegate {
    var observers: NSMapTable<NSString, AnyObject> = NSMapTable(keyOptions: .copyIn, valueOptions: .weakMemory)
    
    static let sharedInstance = ConnectionManager()
    
    override init() {
        super.init()
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.description)
    }
    
    deinit {
        SBDMain.removeConnectionDelegate(forIdentifier: self.description)
    }
    
    static public func login(completionHandler: ((_ user: SBDUser?, _ error: NSError?) -> Void)?) {
        let userId: String? = UserDefaults.standard.string(forKey: "sendbird_user_id")
        let userNickname: String? = UserDefaults.standard.string(forKey: "sendbird_user_nickname")
        
        guard let theUserId: String = userId, let theNickname: String = userNickname else {
            if let handler: ((_ :SBDUser?, _ :NSError?) -> ()) = completionHandler {
                let error: NSError = NSError(domain: ErrorDomainConnection, code: -1, userInfo: [NSLocalizedDescriptionKey:"User id or user nickname is nil.",NSLocalizedFailureReasonErrorKey:"Saved user data does not exist."])
                handler(nil, error)
            }
            return
        }
        
        self.login(userId: theUserId, nickname: theNickname, completionHandler: completionHandler)
    }
    
    static public func login(userId: String, nickname: String, completionHandler: ((_ user: SBDUser?, _ error: NSError?) -> Void)?) {
        self.sharedInstance.login(userId: userId, nickname: nickname, completionHandler: completionHandler)
    }
    
    private func login(userId: String, nickname: String, completionHandler: ((_ user: SBDUser?, _ error: NSError?) -> Void)?) {
        SBSMSyncManager.setup(withUserId: userId)
        
        SBDMain.connect(withUserId: userId) { (user, error) in
            if let theError: NSError = error {
                self.removeUserInfo()
                if let handler = completionHandler {
                    var userInfo: [String: Any] = Dictionary()
                    if let reason: String = theError.localizedFailureReason {
                        userInfo[NSLocalizedFailureReasonErrorKey] = reason
                    }
                    userInfo[NSLocalizedDescriptionKey] = theError.localizedDescription
                    userInfo[NSUnderlyingErrorKey] = theError
                    let connectionError: NSError = NSError.init(domain: ErrorDomainConnection, code: theError.code, userInfo: userInfo)
                    handler(nil, connectionError)
                }
                return
            }
            
            let manager: SBSMSyncManager = SBSMSyncManager()
            manager.resumeSynchronize()
            
            if let pushToken: Data = SBDMain.getPendingPushToken() {
                SBDMain.registerDevicePushToken(pushToken, unique: true, completionHandler: { (status, error) in
                    guard let _: SBDError = error else {
                        print("APNS registration failed.")
                        return
                    }
                    
                    if status == .pending {
                        print("Push registration is pending.")
                    }
                    else {
                        print("APNS Token is registered.")
                    }
                })
            }
            
            self.broadcastConnection(isReconnection: false)
            
            let userDefault: UserDefaults = UserDefaults.standard
            userDefault.set(SBDMain.getCurrentUser()?.userId, forKey: "sendbird_user_id")
            userDefault.set(SBDMain.getCurrentUser()?.nickname, forKey: "sendbird_user_nickname")
            userDefault.synchronize()
            
            SBDMain.updateCurrentUserInfo(withNickname: nickname, profileUrl: nil, completionHandler: { (error) in
                if let handler = completionHandler {
                    handler(user, nil)
                }
            })
        }
    }
    
    private func removeUserInfo() {
        let userDefault: UserDefaults = UserDefaults.standard
        userDefault.removeObject(forKey: "sendbird_user_id")
        userDefault.removeObject(forKey: "sendbird_user_nickname")
        userDefault.synchronize()
    }
    
    static public func logout(completionHandler: (() -> Void)?) {
        self.sharedInstance.logout(completionHandler: completionHandler)
    }
    
    private func logout(completionHandler: (() -> Void)?) {
        SBDMain.disconnect {
            self.broadcastDisconnection()
            SBSMSyncManager.clearCache()
            self.removeUserInfo()
            
            if let handler: () -> Void = completionHandler {
                handler()
            }
        }
    }
    
    static public func add(connectionObserver: ConnectionManagerDelegate) {
        self.sharedInstance.observers.setObject(connectionObserver as AnyObject, forKey:self.instanceIdentifier(instance: connectionObserver))
        if SBDMain.getConnectState() == .open {
            connectionObserver.didConnect(isReconnection: false)
        }
        else if SBDMain.getConnectState() == .closed {
            self.login(completionHandler: nil)
        }
    }
    
    static public func remove(connectionObserver: ConnectionManagerDelegate) {
        let observerIdentifier: NSString = self.instanceIdentifier(instance: connectionObserver)
        self.sharedInstance.observers.removeObject(forKey: observerIdentifier)
    }
    
    private func broadcastConnection(isReconnection: Bool) {
        let enumerator: NSEnumerator? = self.observers.objectEnumerator()
        while let observer = enumerator?.nextObject() as! ConnectionManagerDelegate? {
            observer.didConnect(isReconnection: isReconnection)
        }
    }
    
    private func broadcastDisconnection() {
        let enumerator: NSEnumerator? = self.observers.objectEnumerator()
        while let observer = enumerator?.nextObject() as! ConnectionManagerDelegate? {
            observer.didDisconnect()
        }
    }
    
    static private func instanceIdentifier(instance: Any) -> NSString {
        return NSString(format: "%zd", self.hash())
    }
    
    func didStartReconnection() {
        self.broadcastDisconnection()
    }
    
    func didSucceedReconnection() {
        self.broadcastConnection(isReconnection: true)
    }
    
    func didFailReconnection() {
        //
    }
    
    func didCancelReconnection() {
        //
    }
}
