//
//  LoginSubscriber.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2019/12/11.
//  Copyright © 2019 SendBird. All rights reserved.
//

import SendBirdSDK
import SendBirdSyncManager

struct SBDLoginSubscriber {
    let userID: String?
    let nickname: String?
    
    func login(success: ((SBDUser) -> Void)? = nil,
               failure: ((SBDError) -> Void)? = nil) {
        
        login() { user, error in
            
            if let user = user {
                success?(user)
            }
            
            if let error = error {
                failure?(error)
            }
        }
        
    }
    
    func login(completionHandler: ((_ user: SBDUser?, _ error: SBDError?) -> Void)?) {
        guard let userID = userID, let nickname = nickname else {
            let userInfo = [ NSLocalizedDescriptionKey: "User id or user nickname is nil.", NSLocalizedFailureReasonErrorKey:"Saved user data does not exist." ]
            let error = SBDError(domain: ErrorDomainConnection, code: -1, userInfo: userInfo)
            completionHandler?(nil, error)
            return
        }
        
        SBSMSyncManager.setup(withUserId: userID)
        SBDMain.connect(withUserId: userID) { user, error in
            let userDefault = UserDefaults.standard
            if let error = error {
                if let handler = completionHandler {
                    handler(nil, error)
                }
                return
            }
            
            userDefault.setValue(SBDMain.getCurrentUser()?.userId, forKey: "sendbird_user_id")
            userDefault.setValue(true, forKey: "sendbird_auto_login")
            userDefault.synchronize()
            
            SBSMSyncManager.resumeSynchronize()
            
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
            
            ConnectionControl.sharedInstance.broadcastConnection(isReconnection: false)
            
            SBDMain.getDoNotDisturb { (isDoNotDisturbOn, startHour, startMin, endHour, endMin, timezone, error) in
                UserDefaults.standard.set(startHour, forKey: "sendbird_dnd_start_hour")
                UserDefaults.standard.set(startMin, forKey: "sendbird_dnd_start_min")
                UserDefaults.standard.set(endHour, forKey: "sendbird_dnd_end_hour")
                UserDefaults.standard.set(endMin, forKey: "sendbird_dnd_end_min")
                UserDefaults.standard.set(isDoNotDisturbOn, forKey: "sendbird_dnd_on")
                UserDefaults.standard.synchronize()
            }
            
            if nickname != SBDMain.getCurrentUser()?.nickname {
                SBDMain.updateCurrentUserInfo(withNickname: nickname, profileUrl: nil, completionHandler: { (error) in
                    userDefault.setValue(SBDMain.getCurrentUser()?.nickname, forKey: "sendbird_user_nickname")
                    userDefault.synchronize()
                    completionHandler?(user, nil)
                })
            } else {
                completionHandler?(user, nil)
            }
        }
    }
}

