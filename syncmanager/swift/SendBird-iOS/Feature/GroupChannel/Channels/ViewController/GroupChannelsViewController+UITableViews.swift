//
//  GroupChannelsViewController+UITableViews.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2019/12/12.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

// MARK: - UITableViewDataSource
extension GroupChannelsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let channel = channels[indexPath.row]
        let timer = self.trypingIndicatorTimer[channel.channelUrl]
        let cell = tableView.dequeueReusableCell(GroupChannelTableViewCell.self)
        
        cell.set(by: channel, timer: timer)
 
        if channels.count > 0 && indexPath.row == channels.count - 1 {
            self.loadChannelListNextPage(false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        emptyLabel.isHidden = !(channels.isEmpty && toastCompleted)
        return self.channels.count
    }
}

// MARK: - UITableViewDelegate
extension GroupChannelsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        let channels = collection?.channels ?? []
        let channel = channels[indexPath.row]
        let vc = GroupChannelChatViewController.initiate()
        
        vc.channel = channel
        vc.delegate = self

        let naviVC = UINavigationController(rootViewController: vc)
        naviVC.modalPresentationStyle = .overCurrentContext
        self.tabBarController?.present(naviVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let leaveAction = UIContextualAction(style: .destructive, title: "Leave") { action, sourceView, completionHandler in
            let channel = self.channels[indexPath.row]

            channel.leave { error in
                if let error = error {
                    AlertControl.showError(parent: self, error: error)
                    return
                }
            }
        }
        
        leaveAction.backgroundColor = UIColor(named: "color_leave_group_channel_bg")
        return UISwipeActionsConfiguration(actions: [leaveAction])
    }
}
