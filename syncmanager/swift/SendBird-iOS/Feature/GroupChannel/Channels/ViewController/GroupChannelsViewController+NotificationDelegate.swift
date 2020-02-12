//
//  GroupChannelsViewController+NotificationDelegate.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2019/12/12.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
 
extension GroupChannelsViewController: NotificationDelegate {
    func openChat(_ channelURL: String) {
        SBDGroupChannel.getWithUrl(channelURL) { channel, error in
            if error != nil { return }
            
            DispatchQueue.main.async {
                (UIApplication.shared.delegate as? AppDelegate)?.pushReceivedGroupChannel = nil
                
                let vc = GroupChannelChatViewController.initiate()
                vc.channel = channel
                vc.delegate = self
                let naviVC = UINavigationController(rootViewController: vc)
                naviVC.modalPresentationStyle = .overCurrentContext
                self.present(naviVC, animated: true)
            }
        }
    }
}
