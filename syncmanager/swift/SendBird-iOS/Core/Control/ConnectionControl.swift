//
//  ConnectionControl.swift
//  SendBird-iOS-LocalCache-Sample-swift
//
//  Created by sendbird-young on 2018. 4. 11..
//  Copyright © 2018년 SendBird. All rights reserved.
//
 
import UIKit
import SendBirdSDK
import SendBirdSyncManager

let ErrorDomainConnection = "com.sendbird.sample.connection"
let ErrorDomainUser = "com.sendbird.sample.user"

protocol ConnectionControlDelegate: NSObjectProtocol {
    func didConnect(isReconnection: Bool)
    func didDisconnect()
}
 
class ConnectionControl: NSObject, SBDConnectionDelegate {
    var observers: NSMapTable<NSString, AnyObject> = NSMapTable(keyOptions: .copyIn, valueOptions: .weakMemory)
    
    static let sharedInstance = ConnectionControl()
    static var stopConnectionRetry: Bool = false
    
    override init() {
        super.init()
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.description)
    }
    
    deinit {
        SBDMain.removeConnectionDelegate(forIdentifier: self.description)
    }
    
    static public func startLogin() {
        self.setLoginInfoByLastSuccess()
            .login(
                success: { user in
                    
                    guard let topVC = UIApplication.shared.keyWindow?.rootViewController else { return }
                    let presentedVC = topVC.presentedViewController ?? topVC
                    
                    AlertControl.show(parent: presentedVC, title: "Login Success", style: .actionSheet, actionMessage: "Okay")
                    
            },
                failure: { error in
                    if !stopConnectionRetry {
                        self.showAlert()
                    }
            })
    }
    
    static public func showAlert() {
        let alert = UIAlertController(title: "Login Failure", message: "Login Again?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (action) in
            self.startLogin()
        }))
        alert.addAction(UIAlertAction(title: "Retry in 5 sec", style: .default, handler: { (action) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                self.startLogin()
            })
        }))

        let topVC = UIApplication.shared.keyWindow?.rootViewController
        if topVC?.presentedViewController == nil {
            topVC?.present(alert, animated: true, completion: nil)
        } else {
            topVC?.presentedViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    static public func setLoginInfoByLastSuccess() -> SBDLoginSubscriber {
        let userDefault = UserDefaults.standard
        let userId = userDefault.value(forKey: "sendbird_user_id") as? String
        let userNickname = userDefault.value(forKey: "sendbird_user_nickname") as? String
        return .init(userID: userId, nickname: userNickname)
    }
    
    static public func setLoginInfo(userId: String, nickname: String) -> SBDLoginSubscriber {
        return .init(userID: userId, nickname: nickname)
    }
 
    static public func logout(completionHandler: (() -> Void)?) {
        self.sharedInstance.logout(completionHandler: completionHandler)
    }
    
    private func logout(completionHandler: (() -> Void)?) {
        SBDMain.disconnect {
            self.broadcastDisconnection()
            SBSMSyncManager.clearCache()
            let userDefault = UserDefaults.standard            
            userDefault.setValue(false, forKey: "sendbird_auto_login")
            userDefault.removeObject(forKey: "sendbird_dnd_start_hour")
            userDefault.removeObject(forKey: "sendbird_dnd_start_min")
            userDefault.removeObject(forKey: "sendbird_dnd_end_hour")
            userDefault.removeObject(forKey: "sendbird_dnd_end_min")
            userDefault.removeObject(forKey: "sendbird_dnd_on")
            userDefault.synchronize()
            
            UIApplication.shared.applicationIconBadgeNumber = 0
            
            if let handler: () -> Void = completionHandler {
                handler()
            }
        }
    }
    
    static public func add(connectionObserver: ConnectionControlDelegate) {
        self.sharedInstance.observers.setObject(connectionObserver as AnyObject, forKey:self.instanceIdentifier(instance: connectionObserver))
        if SBDMain.getConnectState() == .open {
            connectionObserver.didConnect(isReconnection: false)
        }
        else if SBDMain.getConnectState() == .closed {
            self.setLoginInfoByLastSuccess().login(completionHandler: nil)
        }
    }
    
    static public func remove(connectionObserver: ConnectionControlDelegate) {
        let observerIdentifier: NSString = self.instanceIdentifier(instance: connectionObserver)
        self.sharedInstance.observers.removeObject(forKey: observerIdentifier)
    }
    
    func broadcastConnection(isReconnection: Bool) {
        let enumerator: NSEnumerator? = self.observers.objectEnumerator()
        while let observer = enumerator?.nextObject() as! ConnectionControlDelegate? {
            observer.didConnect(isReconnection: isReconnection)
        }
    }
    
    private func broadcastDisconnection() {
        let enumerator: NSEnumerator? = self.observers.objectEnumerator()
        while let observer = enumerator?.nextObject() as! ConnectionControlDelegate? {
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
        SBSMSyncManager.resumeSynchronize()
    }
    
    func didFailReconnection() {
        //
    }
    
    func didCancelReconnection() {
        //
    }
}
