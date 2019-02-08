//
//  ConnectionManager.swift
//  SendBird-iOS
//
//  Created by sendbird-young on 2018. 4. 11..
//  Copyright © 2018년 SendBird. All rights reserved.
//

import Foundation
import SendBirdSDK

let ErrorDomainConnection = "com.sendbird.sample.connection"
let ErrorDomainUser = "com.sendbird.sample.user"

protocol ConnectionManagerDelegate: NSObjectProtocol {
    func didConnect(isReconnection: Bool)
    func didDisconnect();
}

class ConnectionManager: NSObject, SBDConnectionDelegate {
    var observers: NSMapTable<NSString, AnyObject> = NSMapTable(keyOptions: .copyIn, valueOptions: .weakMemory)
    
    static let sharedInstance = ConnectionManager();
    
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
        
        if let theUserId: String = userId, let theNickname: String = userNickname {
            self.login(userId: theUserId, nickname: theNickname, completionHandler: completionHandler)
        }
        else {
            if let handler: ((_ :SBDUser?, _ :NSError?) -> ()) = completionHandler {
                let error: NSError = NSError(domain: ErrorDomainConnection, code: -1, userInfo: [NSLocalizedDescriptionKey:"User id or user nickname is nil.",NSLocalizedFailureReasonErrorKey:"Saved user data does not exist."])
                handler(nil, error);
            }
            return;
        }
    }
    
    static public func login(userId: String, nickname: String, completionHandler: ((_ user: SBDUser?, _ error: NSError?) -> Void)?) {
        self.sharedInstance.login(userId: userId, nickname: nickname, completionHandler: completionHandler)
    }
    
    private func login(userId: String, nickname: String, completionHandler: ((_ user: SBDUser?, _ error: NSError?) -> Void)?) {
        SBDMain.connect(withUserId: userId) { (user, error) in
            guard error == nil else {
                self.removeUserInfo()
                if let handler = completionHandler {
                    var userInfo: [String: Any]?
                    if let reason: String = error?.localizedFailureReason {
                        userInfo?[NSLocalizedFailureReasonErrorKey] = reason
                    }
                    userInfo?[NSLocalizedDescriptionKey] = error?.localizedDescription
                    userInfo?[NSUnderlyingErrorKey] = error;
                    let connectionError: NSError = NSError.init(domain: ErrorDomainConnection, code: error!.code, userInfo: userInfo)
                    handler(nil, connectionError)
                }
                return;
            }
            
            if let pushToken: Data = SBDMain.getPendingPushToken() {
                SBDMain.registerDevicePushToken(pushToken, unique: true, completionHandler: { (status, error) in
                    guard error == nil else {
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
            
            SBDMain.updateCurrentUserInfo(withNickname: nickname, profileUrl: nil, completionHandler: { (error) in
                guard error == nil else {
                    self.logout(completionHandler: {
                        if let handler = completionHandler {
                            var userInfo: [String: Any]?
                            if let reason: String = error?.localizedFailureReason {
                                userInfo?[NSLocalizedFailureReasonErrorKey] = reason
                            }
                            userInfo?[NSLocalizedDescriptionKey] = error?.localizedDescription
                            userInfo?[NSUnderlyingErrorKey] = error;
                            let connectionError: NSError = NSError.init(domain: ErrorDomainUser, code: error!.code, userInfo: userInfo)
                            handler(nil, connectionError)
                        }
                    })
                    return;
                }
                
                let userDefault: UserDefaults = UserDefaults.standard
                userDefault.set(SBDMain.getCurrentUser()?.userId, forKey: "sendbird_user_id")
                userDefault.set(SBDMain.getCurrentUser()?.nickname, forKey: "sendbird_user_nickname")
                userDefault.synchronize()
                
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
