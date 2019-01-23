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
import AlamofireImage
import MobileCoreServices

class GroupChannelSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GroupChannelInviteMemberDelegate, GroupChannelSettingsTableViewCellDelegate, GroupChannelCoverImageNameSettingDelegate, NotificationDelegate, SBDChannelDelegate {

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
        
        let barButtomItemBack = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        guard let navigationController = self.navigationController else { return }
        let prevVC = navigationController.viewControllers[navigationController.viewControllers.count - 2]
        prevVC.navigationItem.backBarButtonItem = barButtomItemBack
        
        self.settingsTableView.delegate = self
        self.settingsTableView.dataSource = self
        
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
        self.settingsTableView.register(UINib(nibName: "GroupChannelSettingsChannelCoverNameTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupChannelSettingsChannelCoverNameTableViewCell")
        self.settingsTableView.register(UINib(nibName: "GroupChannelSettingsBlankTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupChannelSettingsBlankTableViewCell")
        self.settingsTableView.register(UINib(nibName: "GroupChannelSettingsNotificationsTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupChannelSettingsNotificationsTableViewCell")
        self.settingsTableView.register(UINib(nibName: "GroupChannelSettingsInviteMemberTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupChannelSettingsInviteMemberTableViewCell")
        self.settingsTableView.register(UINib(nibName: "GroupChannelSettingsMemberTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupChannelSettingsMemberTableViewCell")
        self.settingsTableView.register(UINib(nibName: "GroupChannelSettingsLeaveChatTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupChannelSettingsLeaveChatTableViewCell")
        self.settingsTableView.register(UINib(nibName: "GroupChannelSettingsSectionTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupChannelSettingsSectionTableViewCell")
        
        self.loadingIndicatorView.isHidden = true
        self.view.bringSubviewToFront(self.loadingIndicatorView)
        
        self.rearrangeMembers()
        
        self.settingsTableView.reloadData()
    }
    
    private func rearrangeMembers() {
        self.members.removeAll()
        guard let channel = self.channel else { return }
        guard let members = channel.members else { return }
        guard let currentUser = SBDMain.getCurrentUser() else { return }
        
        for member in members as! [SBDMember] {
            if member.userId == currentUser.userId {
                self.members.insert(member, at: 0)
            }
            else {
                self.members.append(member)
            }
        }
    }
    
    func openChat(_ channelUrl: String) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: false)
        }
        
        guard let cvc = UIViewController.currentViewController() else { return }
        if cvc is GroupChannelChatViewController {
            (cvc as! GroupChannelChatViewController).openChat(channelUrl)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.members.count + GroupChannelSettingsViewController.REGULAR_MEMBER_MENU_COUNT
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        guard let channel = self.channel else { return cell }
        guard let currentUser = SBDMain.getCurrentUser() else { return cell }
        
        if indexPath.row == 0 {
            guard let channelCoverNameCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelSettingsChannelCoverNameTableViewCell", for: indexPath) as? GroupChannelSettingsChannelCoverNameTableViewCell else { return cell }
            channelCoverNameCell.channelNameTextField.placeholder = Utils.createGroupChannelNameFromMembers(channel: channel)
            channelCoverNameCell.channelNameTextField.text = channel.name
            channelCoverNameCell.delegate = self
            
            channelCoverNameCell.singleCoverImageContainerView.isHidden = true
            channelCoverNameCell.doubleCoverImageContainerView.isHidden = true
            channelCoverNameCell.tripleCoverImageContainerView.isHidden = true
            channelCoverNameCell.quadrupleCoverImageContainerView.isHidden = true
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
            
            guard let profileImagePlaceholder1 = UIImage(named: "img_default_profile_image_1") else { return cell }
            guard let profileImagePlaceholder2 = UIImage(named: "img_default_profile_image_2") else { return cell }
            guard let profileImagePlaceholder3 = UIImage(named: "img_default_profile_image_3") else { return cell }
            guard let profileImagePlaceholder4 = UIImage(named: "img_default_profile_image_4") else { return cell }
            
            if (channel.coverUrl?.count)! > 0 && !(channel.coverUrl?.hasPrefix("https://sendbird.com/main/img/cover/"))! {
                if let url = URL(string: channel.coverUrl!) {
                    channelCoverNameCell.singleCoverImageContainerView.isHidden = false
                    channelCoverNameCell.singleCoverImageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "img_cover_image_placeholder_1"))
                }
                else {
                    channelCoverNameCell.singleCoverImageView.image = UIImage(named: "img_cover_image_placeholder_1")
                }
            }
            else {
                if currentMembers.count == 0 {
                    channelCoverNameCell.singleCoverImageContainerView.isHidden = false
                    channelCoverNameCell.singleCoverImageView.image = profileImagePlaceholder1
                }
                else if currentMembers.count == 1 {
                    channelCoverNameCell.singleCoverImageContainerView.isHidden = false
                    Utils.setProfileImage(imageView: channelCoverNameCell.singleCoverImageView, user: currentMembers[0])
                }
                else if currentMembers.count == 2 {
                    channelCoverNameCell.doubleCoverImageContainerView.isHidden = false
                    Utils.setProfileImage(imageView: channelCoverNameCell.doubleCoverImageView1, user: currentMembers[0])
                    Utils.setProfileImage(imageView: channelCoverNameCell.doubleCoverImageView2, user: currentMembers[1])
                }
                else if currentMembers.count == 3 {
                    channelCoverNameCell.tripleCoverImageContainerView.isHidden = false
                    Utils.setProfileImage(imageView: channelCoverNameCell.tripleCoverImageView1, user: currentMembers[0])
                    Utils.setProfileImage(imageView: channelCoverNameCell.tripleCoverImageView2, user: currentMembers[1])
                    Utils.setProfileImage(imageView: channelCoverNameCell.tripleCoverImageView3, user: currentMembers[2])
                }
                else if currentMembers.count >= 4 {
                    channelCoverNameCell.quadrupleCoverImageContainerView.isHidden = false
                    Utils.setProfileImage(imageView: channelCoverNameCell.quadrupleCoverImageView1, user: currentMembers[0])
                    Utils.setProfileImage(imageView: channelCoverNameCell.quadrupleCoverImageView2, user: currentMembers[1])
                    Utils.setProfileImage(imageView: channelCoverNameCell.quadrupleCoverImageView3, user: currentMembers[2])
                    Utils.setProfileImage(imageView: channelCoverNameCell.quadrupleCoverImageView4, user: currentMembers[3])
                }
            }
            
            cell = channelCoverNameCell
        }
        else if indexPath.row == 1 {
            guard let blankCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelSettingsBlankTableViewCell", for: indexPath) as? GroupChannelSettingsBlankTableViewCell else { return cell }
            cell = blankCell
        }
        else if indexPath.row == 2 {
            guard let notiCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelSettingsNotificationsTableViewCell", for: indexPath) as? GroupChannelSettingsNotificationsTableViewCell else { return cell }
            notiCell.notificationSwitch.isOn = channel.isPushEnabled
            notiCell.delegate = self
            cell = notiCell
        }
        else if indexPath.row == 3 {
            guard let memberSectionCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelSettingsSectionTableViewCell", for: indexPath) as? GroupChannelSettingsSectionTableViewCell else { return cell }
            cell = memberSectionCell
        }
        else if indexPath.row == 4 {
            guard let inviteCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelSettingsInviteMemberTableViewCell", for: indexPath) as? GroupChannelSettingsInviteMemberTableViewCell else { return cell }
            cell = inviteCell
        }
        else if indexPath.row >= 5 {
            if self.members.count > 0 {
                if indexPath.row > 4 && indexPath.row < self.members.count + 5 {
                    guard let memberCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelSettingsMemberTableViewCell", for: indexPath) as? GroupChannelSettingsMemberTableViewCell else { return cell }
                    
                    let member = self.members[indexPath.row - 5]
                    memberCell.nicknameLabel.text = member.nickname
                    if member.isBlockedByMe {
                        memberCell.blockedUserCoverImageView.isHidden = false
                        memberCell.statusLabel.isHidden = false
                        memberCell.statusLabel.text = "Blocked"
                    }
                    else {
                        memberCell.blockedUserCoverImageView.isHidden = true
                        memberCell.statusLabel.isHidden = true
                        memberCell.statusLabel.text = ""
                    }
                    
                    if member.userId == currentUser.userId {
                        memberCell.accessoryType = .none
                    }
                    else {
                        memberCell.accessoryType = .disclosureIndicator
                    }
                    
                    DispatchQueue.main.async {
                        guard let updateCell = tableView.cellForRow(at: indexPath) as? GroupChannelSettingsMemberTableViewCell else { return }
                        
                        if let url = URL(string: Utils.transformUserProfileImage(user: member)) {
                            updateCell.profileImageView.af_setImage(withURL: url, placeholderImage: Utils.getDefaultUserProfileImage(user: member))
                        }
                        else {
                            updateCell.profileImageView.image = Utils.getDefaultUserProfileImage(user: member)
                        }
                        
                        if member.userId == currentUser.userId {
                            updateCell.myProfileImageCoverView.isHidden = false
                            updateCell.topBorderView.isHidden = false
                        }
                        else {
                            updateCell.myProfileImageCoverView.isHidden = true
                            updateCell.topBorderView.isHidden = true
                        }
                    }
                    
                    cell = memberCell
                }
                else if indexPath.row == self.members.count + 5 {
                    guard let blankCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelSettingsBlankTableViewCell", for: indexPath) as? GroupChannelSettingsBlankTableViewCell else { return cell }
                    cell = blankCell
                }
                else if indexPath.row == self.members.count + 6 {
                    guard let leaveChannelCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelSettingsLeaveChatTableViewCell", for: indexPath) as? GroupChannelSettingsLeaveChatTableViewCell else { return cell }
                    cell = leaveChannelCell
                }
            }
            else {
                if indexPath.row == 5 {
                    guard let blankCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelSettingsBlankTableViewCell", for: indexPath) as? GroupChannelSettingsBlankTableViewCell else { return cell }
                    cell = blankCell
                }
                else if indexPath.row == 6 {
                    guard let leaveChannelCell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelSettingsLeaveChatTableViewCell", for: indexPath) as? GroupChannelSettingsLeaveChatTableViewCell else { return cell }
                    cell = leaveChannelCell
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 121
        }
        else if indexPath.row == 1 {
            return 34
        }
        else if indexPath.row == 2 {
            return 44
        }
        else if indexPath.row == 3 {
            return 56
        }
        else if indexPath.row == 4 {
            return 44
        }
        else if indexPath.row >= 5 {
            if self.members.count > 0 {
                if indexPath.row > 4 && indexPath.row < self.members.count + 5 {
                    return 48
                }
                else if indexPath.row == self.members.count + 5 {
                    return 34
                }
                else if indexPath.row == self.members.count + 6 {
                    return 44
                }
            }
            else {
                if indexPath.row == 5 {
                    return 34
                }
                else if indexPath.row == 6 {
                    return 44
                }
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.row == 4 {
            // Invite member
            let vc = GroupChannelInviteMemberViewController.init(nibName: "GroupChannelInviteMemberViewController", bundle: nil)
            vc.channel = self.channel
            vc.delegate = self
            if let navigationController = self.navigationController {
                navigationController.pushViewController(vc, animated: true)
            }
        }
        else if indexPath.row >= 5 {
            if self.members.count > 0 {
                if indexPath.row >= 6 && indexPath.row < self.members.count + 5 {
                    // User Profile
                    let vc = UserProfileViewController.init(nibName: "UserProfileViewController", bundle: nil)
                    vc.user = self.members[indexPath.row - 5]
                    if let navigationController = self.navigationController {
                        navigationController.pushViewController(vc, animated: true)
                    }
                }
                else if indexPath.row == self.members.count + 6 {
                    // Leave channel
                    guard let channel = self.channel else { return }
                    channel.leave { (error) in
                        if error != nil {
                            return
                        }
                        
                        DispatchQueue.main.async {
                            if let navigationController = self.navigationController {
                                navigationController.popViewController(animated: false)
                                if let delegate = self.delegate {
                                    if delegate.responds(to: #selector(GroupChannelSettingsDelegate.didLeaveChannel)) {
                                        delegate.didLeaveChannel!()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else {
                // Leave channel
                guard let channel = self.channel else { return }
                channel.leave { (error) in
                    if error != nil {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        if let navigationController = self.navigationController {
                            navigationController.popViewController(animated: false)
                            if let delegate = self.delegate {
                                if delegate.responds(to: #selector(GroupChannelSettingsDelegate.didLeaveChannel)) {
                                    delegate.didLeaveChannel!()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - GroupChannelInviteMemberDelegate
    func didInviteMembers() {
        self.rearrangeMembers()
        self.settingsTableView.reloadData()
    }
    
    // MARK: - GroupChannelSettingsTableViewCellDelegate
    func willUpdateChannelNameAndCoverImage() {
        let vc = GroupChannelCoverImageNameSettingViewController.init(nibName: "GroupChannelCoverImageNameSettingViewController", bundle: nil)
        
        vc.channel = self.channel
        vc.delegate = self
        
        guard let navigationController = self.navigationController else { return }
        navigationController.pushViewController(vc, animated: true)
    }
    
    func didChangeNotificationSwitchButton(isOn: Bool) {
        guard let channel = self.channel else { return }
        
        DispatchQueue.main.async {
            self.loadingIndicatorView.isHidden = false
            self.loadingIndicatorView.startAnimating()
        }
        
        channel.setPushPreferenceWithPushOn(isOn) { (error) in
            DispatchQueue.main.async {
                self.loadingIndicatorView.isHidden = true
                self.loadingIndicatorView.stopAnimating()
                
                self.settingsTableView.reloadData()
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
