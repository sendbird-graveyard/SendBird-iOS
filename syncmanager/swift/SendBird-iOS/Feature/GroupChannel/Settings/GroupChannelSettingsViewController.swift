//
//  GroupChannelSettingsViewController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/9/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import Photos 
import MobileCoreServices

class GroupChannelSettingsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, GroupChannelInviteMemberDelegate, GroupChannelSettingsTableViewCellDelegate, GroupChannelCoverImageNameSettingDelegate, NotificationDelegate, SBDChannelDelegate {

    weak var delegate: GroupChannelSettingsDelegate?
    var channel: SBDGroupChannel?
    var members: [SBDMember] = []
    var selectedUsers: [String:SBDUser] = [:]
    
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var loadingIndicatorView: CustomActivityIndicatorView!
    
    static let REGULAR_MEMBER_MENU_COUNT = 7
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Group Channel Settings"
        
        self.settingsTableView.delegate = self
        self.settingsTableView.dataSource = self
        
        /*
         * When use delegate, must remove the delete in deinit.
         * Please check the BaseViewController.swift
         */
        SBDMain.add(self as SBDChannelDelegate, identifier: self.delegateIdentifier)
        
        self.loadingIndicatorView.isHidden = true
        self.view.bringSubviewToFront(self.loadingIndicatorView)
        
        self.rearrangeMembers()
        
        self.settingsTableView.reloadData()
    }
    
    deinit {
        
        SBDMain.removeChannelDelegate(forIdentifier: self.delegateIdentifier)
    }
    
    private func rearrangeMembers() {
        guard let channel = self.channel else { return }
        guard let members = channel.members as? [SBDMember] else { return }
        guard let currentUser = SBDMain.getCurrentUser() else { return }
        self.members = members.sorted { member, _ in member.userId == currentUser.userId }
    }
    
    func openChat(_ channelURL: String) {
        self.navigationController?.popViewController(animated: false)
        
        if
            let currentVC = UIViewController.currentViewController(),
            let delegate = currentVC as? NotificationDelegate
        {
            delegate.openChat(channelURL)
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 2) ? "Members" : nil
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return self.members.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let channel = self.channel, let currentUser = SBDMain.getCurrentUser() else { return UITableViewCell() }
       
        switch indexPath.section {
        case 0:
            let channelCoverNameCell = tableView.dequeueReusableCell(GroupChannelSettingsChannelCoverNameTableViewCell.self)
            channelCoverNameCell.channelNameTextField.placeholder = Utils.createGroupChannelNameFromMembers(channel: channel)
            channelCoverNameCell.channelNameTextField.text = channel.name
            channelCoverNameCell.delegate = self
            
            var currentMembers: [SBDMember] = []
            var count = 0
            if let members = channel.members as? [SBDMember] {
                for member in members {
                    if member.userId == currentUser.userId {
                        continue
                    }
                    currentMembers.append(member)
                    count += 1
                    if count == 4 {
                        break
                    }
                }
            }
            
            if let url = channel.coverUrl, url.count > 0 && !url.hasPrefix("https://sendbird.com/main/img/cover/") {
                channelCoverNameCell.profileImageView.setImage(withCoverUrl: url)
            }
            else {
                channelCoverNameCell.profileImageView.users = members
            }
            channelCoverNameCell.profileImageView.makeCircularWithSpacing(spacing: 1)
            
            return channelCoverNameCell
        case 1:
            
            let notiCell = tableView.dequeueReusableCell(GroupChannelSettingsNotificationsTableViewCell.self)
            notiCell.notificationSwitch.isOn = self.channel?.myPushTriggerOption == .off ? false : true
            notiCell.delegate = self
            
            return notiCell
        case 2:
            if indexPath.row == 0 {
                return tableView.dequeueReusableCell(withIdentifier: "GroupChannelSettingsInviteMemberTableViewCell", for: indexPath)
            } else {

                let memberCell = tableView.dequeueReusableCell(GroupChannelSettingsMemberTableViewCell.self)
                let member = self.members[indexPath.row - 1]
                
                let isCurrentUser = member.userId == currentUser.userId
                memberCell.nicknameLabel.text = member.nickname
                
                if member.isBlockedByMe {
                    memberCell.blockedUserCoverImageView.isHidden = false
                    memberCell.statusLabel.isHidden = false
                    memberCell.statusLabel.text = "Blocked"
                } else {
                    memberCell.blockedUserCoverImageView.isHidden = true
                    memberCell.statusLabel.isHidden = true
                    memberCell.statusLabel.text = ""
                }
                 
                memberCell.accessoryType = isCurrentUser ? .none : .disclosureIndicator
                
                DispatchQueue.main.async {
                    guard let updateCell = tableView.cellForRow(at: indexPath) as? GroupChannelSettingsMemberTableViewCell else { return }
                    
                    updateCell.profileImageView.setProfileImageView(for: member)
                    updateCell.myProfileImageCoverView.isHidden = !isCurrentUser
                }
                
                return memberCell
            }
        case 3:
            return tableView.dequeueReusableCell(withIdentifier: "GroupChannelSettingsLeaveChatTableViewCell", for: indexPath)
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
            
        case 0:
            return 121
            
        case 1:
            return 48
            
        default:
            return 48
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath.section {
        case 2:
            if indexPath.row == 0 {
                // Invite member
                
                let vc = GroupChannelInviteMemberViewController.initiate()
                vc.channel = self.channel
                vc.delegate = self
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                let vc = UserProfileViewController.initiate()
                vc.user = self.members[indexPath.row - 1]
                self.show(vc, sender: nil)
            }
            
        case 3:
            // Leave channel
            self.channel?.leave { error in
                guard error == nil else { return }
                
                DispatchQueue.main.async {
                    if self.splitViewController?.displayMode == .allVisible {
                        if let delegate = self.delegate {
                            delegate.didLeaveChannel()
                        }
                    } else {
                        self.dismiss(animated: true) {
                            if let delegate = self.delegate {
                                delegate.didLeaveChannel()
                            }
                        }
                    }
                }
            }
            
        default:
            return
        }

    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section != 2 || indexPath.row == 0 { return nil }
        let currentMember = self.members[indexPath.row - 1]
        if !currentMember.isBlockedByMe { return nil }
        
        let unblockAction = UIContextualAction(style: .normal, title: "Unblock") { (action, sourceView, completionHandler) in
            SBDMain.unblockUserId(currentMember.userId, completionHandler: { error in })
            let currentCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelSettingsMemberTableViewCell", for: indexPath) as! GroupChannelSettingsMemberTableViewCell
            currentCell.blockedUserCoverImageView.isHidden = true
            currentCell.statusLabel.isHidden = true
            currentCell.statusLabel.text = ""
            tableView.reloadData()
        }
        
        unblockAction.backgroundColor = UIColor(named: "color_leave_group_channel_bg")
        return UISwipeActionsConfiguration(actions: [unblockAction])
    }
    
    // MARK: - GroupChannelInviteMemberDelegate
    func didInviteMembers() {
        self.rearrangeMembers()
        self.settingsTableView.reloadData()
    }
    
    // MARK: - GroupChannelSettingsTableViewCellDelegate
    func willUpdateChannelNameAndCoverImage() {
        let vc = GroupChannelCoverImageNameSettingViewController.initiate()
        vc.channel = self.channel
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didChangeNotificationSwitchButton(isOn: Bool) {
        guard let channel = self.channel else { return }
        self.loadingIndicatorView.superViewSize = self.view.frame.size
        self.loadingIndicatorView.updateFrame()
        
        DispatchQueue.main.async {
            self.loadingIndicatorView.isHidden = false
            self.loadingIndicatorView.startAnimating()
        }
        
        let pushOption:SBDGroupChannelPushTriggerOption = isOn ? .all : .off
        channel.setMyPushTriggerOption(pushOption) { error in
            DispatchQueue.main.async {
                self.loadingIndicatorView.isHidden = true
                self.loadingIndicatorView.stopAnimating()
            }
        }
    }
    
    // MARK: - GroupChannelCoverImageNameSettingDelegate
    func didUpdateGroupChannel() {
        DispatchQueue.main.async {
            self.settingsTableView.reloadData()
        }
    }
    
    // MARK: - SBDChannelDelegate
    func channelWasChanged(_ sender: SBDBaseChannel) {
        guard let channel = self.channel else { return }
        if sender.channelUrl == channel.channelUrl {
            DispatchQueue.main.async {
                self.rearrangeMembers()
                self.settingsTableView.reloadData()
            }
        }
    }
    
    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        guard let channel = self.channel else { return }
        if sender.channelUrl == channel.channelUrl {
            DispatchQueue.main.async {
                self.rearrangeMembers()
                self.settingsTableView.reloadData()
            }
        }
    }
    
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        guard let channel = self.channel else { return }
        if sender.channelUrl == channel.channelUrl {
            DispatchQueue.main.async {
                self.rearrangeMembers()
                self.settingsTableView.reloadData()
            }
        }
    }
    
    // MARK: - Utilities
    private func showLoadingIndicatorView() {
        self.loadingIndicatorView.superViewSize = self.view.frame.size
        self.loadingIndicatorView.updateFrame()
        
        DispatchQueue.main.async {
            self.loadingIndicatorView.isHidden = false
            self.loadingIndicatorView.startAnimating()
        }
    }
    
    private func hideLoadingIndicatorView() {
        DispatchQueue.main.async {
            self.loadingIndicatorView.isHidden = true
            self.loadingIndicatorView.stopAnimating()
        }
    }
}

extension GroupChannelSettingsViewController {
    static func initiate() -> GroupChannelSettingsViewController {
        let vc = GroupChannelSettingsViewController.withStoryboard(storyboard: .groupChannel)
        return vc
    }
}
