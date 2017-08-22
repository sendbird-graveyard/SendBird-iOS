//
//  GroupChannelListViewController.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/10/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import SendBirdSDK

class GroupChannelListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate, CreateGroupChannelUserListViewControllerDelegate, SBDChannelDelegate, SBDConnectionDelegate {
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noChannelLabel: UILabel!
    
    private var refreshControl: UIRefreshControl?
    private var channels: [SBDGroupChannel] = []
    private var editableChannel: Bool = false
    private var groupChannelListQuery: SBDGroupChannelListQuery?
    private var typingAnimationChannelList: [String] = []

    private var cachedChannels: Bool = true
    
    private var firstLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isEditing = false
        self.tableView.register(GroupChannelListTableViewCell.nib(), forCellReuseIdentifier: GroupChannelListTableViewCell.cellReuseIdentifier())
        self.tableView.register(GroupChannelListEditableTableViewCell.nib(), forCellReuseIdentifier: GroupChannelListEditableTableViewCell.cellReuseIdentifier())
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshChannelList), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(self.refreshControl!)
        
        self.setDefaultNavigationItems()
        
        self.noChannelLabel.isHidden = true
        
        let dumpLoadQueue: DispatchQueue = DispatchQueue(label: "com.sendbird.dumploadqueue", attributes: .concurrent)
        dumpLoadQueue.async {
            self.channels = Utils.loadGroupChannels()
            if self.channels.count > 0 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(150), execute: { 
                        self.refreshChannelList()
                    })
                }
            }
            else {
                self.cachedChannels = false
                self.refreshChannelList()
            }
        }
        
        self.firstLoading = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Utils.dumpChannels(channels: self.channels)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.firstLoading == false {
            self.refreshChannelList()
        }
        
        self.firstLoading = false
    }

    func addDelegates() {
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.description)
    }

    private func setDefaultNavigationItems() {
        let negativeLeftSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeLeftSpacer.width = -2
        let negativeRightSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeRightSpacer.width = -2
        
        let leftBackItem = UIBarButtonItem(image: UIImage(named: "btn_back"), style: UIBarButtonItemStyle.done, target: self, action: #selector(back))
        let rightCreateGroupChannelItem = UIBarButtonItem(image: UIImage(named: "btn_plus"), style: UIBarButtonItemStyle.done, target: self, action: #selector(createGroupChannel))
        let rightEditItem = UIBarButtonItem(image: UIImage(named: "btn_edit"), style: UIBarButtonItemStyle.done, target: self, action: #selector(editGroupChannel))
        rightEditItem.imageInsets = UIEdgeInsetsMake(0, 14, 0, -14)
        
        self.navItem.leftBarButtonItems = [negativeLeftSpacer, leftBackItem]
        self.navItem.rightBarButtonItems = [negativeRightSpacer, rightCreateGroupChannelItem, rightEditItem]
    }
    
    private func setEditableNavigationItems() {
        let negativeLeftSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeLeftSpacer.width = -2
        
        let leftBackItem = UIBarButtonItem(title: Bundle.sbLocalizedStringForKey(key: "DoneButton"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(done))
        leftBackItem.setTitleTextAttributes([NSFontAttributeName: Constants.navigationBarButtonItemFont()], for: UIControlState.normal)
        
        self.navItem.leftBarButtonItems = [negativeLeftSpacer, leftBackItem]
        self.navItem.rightBarButtonItems = []
    }
    
    @objc private func refreshChannelList() {
        self.groupChannelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        self.groupChannelListQuery?.limit = 20
        self.groupChannelListQuery?.order = SBDGroupChannelListOrder.latestLastMessage
        
        self.groupChannelListQuery?.loadNextPage(completionHandler: { (channels, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                
                return
            }
            
            self.channels.removeAll()
            self.cachedChannels = false
            
            for channel in channels! {
                self.channels.append(channel)
            }
            
            DispatchQueue.main.async {
                if self.channels.count == 0 {
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
                    self.noChannelLabel.isHidden = false
                }
                else {
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                    self.noChannelLabel.isHidden = true
                }
                
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        })
    }
    
    private func loadChannels() {
        if self.cachedChannels == true {
            return
        }
        
        if self.groupChannelListQuery != nil {
            if self.groupChannelListQuery?.hasNext == false {
                return
            }
            
            self.groupChannelListQuery?.loadNextPage(completionHandler: { (channels, error) in
                if error != nil {
                    if error?.code != 800170 {
                        DispatchQueue.main.async {
                            self.refreshControl?.endRefreshing()
                        }
                        
                        let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                        let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                        vc.addAction(closeAction)
                        DispatchQueue.main.async {
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                    
                    return
                }
                
                for channel in channels! {
                    self.channels.append(channel)
                }
                
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    @objc private func back() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc private func createGroupChannel() {
        let vc = CreateGroupChannelUserListViewController(nibName: "CreateGroupChannelUserListViewController", bundle: Bundle.main)
        vc.delegate = self
        vc.userSelectionMode = 0
        self.present(vc, animated: false, completion: nil)
    }
    
    @objc private func editGroupChannel() {
        self.editableChannel = true
        self.setEditableNavigationItems()
        self.tableView.reloadData()
    }
    
    func done() {
        self.editableChannel = false
        self.setDefaultNavigationItems()
        self.tableView.reloadData()
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if self.editableChannel == false {
            let vc = GroupChannelChattingViewController(nibName: "GroupChannelChattingViewController", bundle: Bundle.main)
            vc.groupChannel = self.channels[indexPath.row]
            
            self.present(vc, animated: false, completion: nil)
        }
        else {
            let cell = tableView.cellForRow(at: indexPath) as! MGSwipeTableCell
            cell.showSwipe(MGSwipeDirection.rightToLeft, animated: true)
        }
    }

    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if self.editableChannel == true {
            cell = tableView.dequeueReusableCell(withIdentifier: GroupChannelListEditableTableViewCell.cellReuseIdentifier()) as! GroupChannelListEditableTableViewCell?
            let leaveButton = MGSwipeButton(title: Bundle.sbLocalizedStringForKey(key: "LeaveButton"), backgroundColor: Constants.leaveButtonColor())
            let hideButton = MGSwipeButton(title: Bundle.sbLocalizedStringForKey(key: "HideButton"), backgroundColor: Constants.hideButtonColor())
            
            hideButton.titleLabel?.font = Constants.hideButtonFont()
            leaveButton.titleLabel?.font = Constants.leaveButtonFont()
            
            (cell as! GroupChannelListEditableTableViewCell).rightButtons = [hideButton, leaveButton]
            (cell as! GroupChannelListEditableTableViewCell).setModel(aChannel: self.channels[indexPath.row])
            (cell as! GroupChannelListEditableTableViewCell).delegate = self
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: GroupChannelListTableViewCell.cellReuseIdentifier()) as! GroupChannelListTableViewCell?
            if self.channels[indexPath.row].isTyping() == true {
                if self.typingAnimationChannelList.index(of: self.channels[indexPath.row].channelUrl) == nil {
                    self.typingAnimationChannelList.append(self.channels[indexPath.row].channelUrl)
                }
            }
            else {
                if self.typingAnimationChannelList.index(of: self.channels[indexPath.row].channelUrl) != nil {
                    self.typingAnimationChannelList.remove(at: self.typingAnimationChannelList.index(of: self.channels[indexPath.row].channelUrl)!)
                }
            }
            
            (cell as! GroupChannelListTableViewCell).setModel(aChannel: self.channels[indexPath.row])
        }
        
        if self.channels.count > 0 && indexPath.row + 1 == self.channels.count {
            self.loadChannels()
        }
        
        return cell!
    }
    
    // MARK: MGSwipeTableCellDelegate
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        // 0: right, 1: left
        let row = self.tableView.indexPath(for: cell)?.row
        let selectedChannel: SBDGroupChannel = self.channels[row!] as SBDGroupChannel
        if index == 0 {
            // Hide
            selectedChannel.hide(completionHandler: { (error) in
                if error != nil {
                    let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                    vc.addAction(closeAction)
                    DispatchQueue.main.async {
                        self.present(vc, animated: true, completion: nil)
                    }
                    
                    return
                }
                
                if let index = self.channels.index(of: selectedChannel) {
                    self.channels.remove(at: index)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
        else {
            // Leave
            selectedChannel.leave(completionHandler: { (error) in
                if error != nil {
                    let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                    vc.addAction(closeAction)
                    DispatchQueue.main.async {
                        self.present(vc, animated: true, completion: nil)
                    }
                    
                    return
                }
                
                if let index = self.channels.index(of: selectedChannel) {
                    self.channels.remove(at: index)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
        
        return true
    }
    
    // MARK: CreateGroupChannelUserListViewControllerDelegate
    func openGroupChannel(channel: SBDGroupChannel, vc: UIViewController) {
        DispatchQueue.main.async {
            let vc = GroupChannelChattingViewController(nibName: "GroupChannelChattingViewController", bundle: Bundle.main)
            vc.groupChannel = channel
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    // MARK: GroupChannelChattingViewController
    func didStartReconnection() {
        
    }
    
    func didSucceedReconnection() {
        let vc = UIApplication.shared.keyWindow?.rootViewController
        let bestVC = Utils.findBestViewController(vc: vc!)
        
        if bestVC == self {
            let query = SBDGroupChannel.createMyGroupChannelListQuery()
            query?.limit = 20
            query?.order = SBDGroupChannelListOrder.latestLastMessage
            query?.loadNextPage(completionHandler: { (channels, error) in
                if error != nil {
                    return
                }
                
                self.channels.removeAll()
                self.channels.append(contentsOf: channels!)
                DispatchQueue.main.async {
                    self.groupChannelListQuery = query
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func didFailReconnection() {
        
    }
    
    // MARK: SBDChannelDelegate
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        if sender is SBDGroupChannel {
            let messageReceivedChannel = sender as! SBDGroupChannel
            if self.channels.index(of: messageReceivedChannel) != nil {
                self.channels.remove(at: self.channels.index(of: messageReceivedChannel)!)
            }
            self.channels.insert(messageReceivedChannel, at: 0)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
        
    }
    
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        if self.editableChannel == true {
            return
        }
        
        let row = self.channels.index(of: sender)
        if row != nil {
            let cell = self.tableView.cellForRow(at: IndexPath(row: row!, section: 0)) as! GroupChannelListTableViewCell
            
            cell.startTypingAnimation()
        }
    }
    
    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        DispatchQueue.main.async {
            if self.channels.index(of: sender) == nil {
                self.channels.append(sender)
            }
            self.tableView.reloadData()
        }
    }
    
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        if user.userId == SBDMain.getCurrentUser()?.userId {
            if let index = self.channels.index(of: sender) {
                self.channels.remove(at: index)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDOpenChannel, userWasMuted user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDOpenChannel, userWasUnmuted user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDOpenChannel, userWasBanned user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDOpenChannel, userWasUnbanned user: SBDUser) {
        
    }
    
    func channelWasFrozen(_ sender: SBDOpenChannel) {
        
    }
    
    func channelWasUnfrozen(_ sender: SBDOpenChannel) {
        
    }
    
    func channelWasChanged(_ sender: SBDBaseChannel) {
        if sender is SBDGroupChannel {
            let messageReceivedChannel = sender as! SBDGroupChannel
            if self.channels.index(of: messageReceivedChannel) != nil {
                self.channels.remove(at: self.channels.index(of: messageReceivedChannel)!)
            }
            self.channels.insert(messageReceivedChannel, at: 0)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        
    }
    
    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        
    }
}
