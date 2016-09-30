//
//  GroupChannelListViewController.swift
//  SampleUI
//
//  Created by Jed Kyung on 8/24/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class GroupChannelListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SBDConnectionDelegate, SBDChannelDelegate, UserListViewControllerDelegate, GroupChannelViewControllerDelegate {
    @IBOutlet fileprivate weak var tableView: UITableView!
    fileprivate var channels: [SBDGroupChannel] = []
    fileprivate var userID: String?
    fileprivate var userName: String?
    fileprivate var myGroupChannelListQuery: SBDGroupChannelListQuery?
    fileprivate var delegateIndetifier: String?
    fileprivate var refreshControl: UIRefreshControl?
    fileprivate var editMode: Bool?
    fileprivate var editChannelListButtomItem: UIBarButtonItem?
    fileprivate var doneChannelListButtomItem: UIBarButtonItem?
    fileprivate var createChannelButtomItem: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Group Channel List"
        self.editMode = false
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(GroupChannelListTableViewCell.nib(), forCellReuseIdentifier: GroupChannelListTableViewCell.cellReuseIdentifier())
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(GroupChannelListViewController.refreshChannelList), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(self.refreshControl!)
        
        self.myGroupChannelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        self.myGroupChannelListQuery?.limit = 10
        
        self.delegateIndetifier = self.description
        
        self.editChannelListButtomItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(GroupChannelListViewController.editGroupChannelList))
        self.doneChannelListButtomItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(GroupChannelListViewController.editGroupChannelList))
        self.createChannelButtomItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(GroupChannelListViewController.createGroupChannel))
        
        self.navigationItem.rightBarButtonItems = [self.createChannelButtomItem!, self.editChannelListButtomItem!]
        
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.delegateIndetifier!)
        SBDMain.add(self as SBDChannelDelegate, identifier: self.delegateIndetifier!)
        
        self.loadChannels()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.navigationController?.viewControllers.index(of: self) == nil {
            SBDMain.removeChannelDelegate(forIdentifier: self.delegateIndetifier!)
            SBDMain.removeConnectionDelegate(forIdentifier: self.delegateIndetifier!)
        }
        
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createGroupChannel() {
        let vc = UserListViewController()
        vc.invitationMode = 0
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func editGroupChannelList() {
        if self.editMode == true {
            self.title = "Group Channels"
            self.editMode = false
            self.createChannelButtomItem?.isEnabled = true
            self.navigationItem.rightBarButtonItems = [self.createChannelButtomItem!, self.editChannelListButtomItem!]
        }
        else {
            self.title = "Edit Group Channels"
            self.editMode = true
            self.createChannelButtomItem?.isEnabled = false
            self.navigationItem.rightBarButtonItems = [self.createChannelButtomItem!, self.doneChannelListButtomItem!]
        }
    }
    
    func refreshChannelList() {
        if self.myGroupChannelListQuery != nil && self.myGroupChannelListQuery?.isLoading() == true {
            self.refreshControl?.endRefreshing()
            return
        }
        
        self.channels.removeAll()
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })

        self.myGroupChannelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        self.myGroupChannelListQuery!.limit = 10
        self.loadChannels()
    }
    
    fileprivate func loadChannels() {
        if self.myGroupChannelListQuery?.isLoading() == true {
            return
        }
        
        if self.myGroupChannelListQuery?.hasNext == false {
            return
        }
        
        self.myGroupChannelListQuery?.loadNextPage(completionHandler: { (channels, error) in
            if error != nil {
                if self.refreshControl?.isRefreshing == true {
                    self.refreshControl?.endRefreshing()
                }
                
                return
            }
            
            if channels == nil || channels!.count == 0 {
                return
            }
            
            for item in channels! {
                let channel = item as SBDGroupChannel
                self.channels.append(channel)
            }

            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                
                if self.refreshControl?.isRefreshing == true {
                    self.refreshControl?.endRefreshing()
                }
            })
        })
    }
    
    func setUser(_ aUserId: String, aUserName: String) {
        self.userID = aUserId
        self.userName = aUserName
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = self.channels[(indexPath as NSIndexPath).row]
        
        if self.editMode == true {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
            let leaveChannelAction = UIAlertAction(title: "Leave channel", style: UIAlertActionStyle.default, handler: { (action) in
                channel.leave(completionHandler: { (error) in
                    DispatchQueue.main.async(execute: {
                        if let index = self.channels.index(of: channel) {
                            self.channels.remove(at: index)
                        }
                        self.tableView.reloadData()
                    })
                })
            })
            let hideChannelAction = UIAlertAction(title: "Hide channel", style: UIAlertActionStyle.default, handler: { (action) in
                channel.hide(completionHandler: { (error) in
                    DispatchQueue.main.async(execute: {
                        if let index = self.channels.index(of: channel) {
                            self.channels.remove(at: index)
                        }
                        self.tableView.reloadData()
                    })
                })
            })
            
            alert.addAction(closeAction)
            alert.addAction(leaveChannelAction)
            alert.addAction(hideChannelAction)
            
            DispatchQueue.main.async(execute: { 
                self.present(alert, animated: true, completion: nil)
            })
        }
        else {
            tableView.deselectRow(at: indexPath, animated: false)
            let vc = GroupChannelViewController()
            vc.title = "Group Channel"
            vc.senderId = SBDMain.getCurrentUser()?.userId
            vc.senderDisplayName = SBDMain.getCurrentUser()?.nickname
            vc.setGroupChannel(self.channels[(indexPath as NSIndexPath).row])
            vc.delegate = self
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let channel = self.channels[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupChannelListTableViewCell.cellReuseIdentifier()) as! GroupChannelListTableViewCell
        
        cell.setModel(channel)
        
        if self.channels.count > 0 {
            if (indexPath as NSIndexPath).row == self.channels.count - 1 {
                self.loadChannels()
            }
        }
        
        return cell
    }
    
    // MARK: SBDConnectionDelegate
    func didStartReconnection() {

    }
    
    func didSucceedReconnection() {

    }
    
    func didFailReconnection() {

    }
    
    // MARK: SBDBaseChannelDelegate
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        print("channel(sender: didReceiveMessage user:)")
        
        if sender.isKind(of: SBDGroupChannel.self) == true {
            var isNewChannel = true
            (sender as! SBDGroupChannel).lastMessage = message
            for channelInList in self.channels {
                if sender.channelUrl == channelInList.channelUrl {
                    isNewChannel = false
                }
            }
            
            if isNewChannel == false {
                if let index = self.channels.index(of: (sender as! SBDGroupChannel)) {
                    self.channels.remove(at: index)
                }
            }
            
            self.channels.insert((sender as! SBDGroupChannel), at: 0)
            
            DispatchQueue.main.async(execute: { 
                self.tableView.reloadData()
            })
        }
    }
    
    func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
        
    }
    
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        
    }
    
    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        print("channel(sender: userDidJoin user:)")
        var isNewChannel = true
        for channel in self.channels {
            if sender == channel {
                isNewChannel = false
                break
            }
        }
        
        if isNewChannel == true {
            self.channels.insert(sender as SBDGroupChannel, at: 0)
            DispatchQueue.main.async(execute: { 
                self.tableView.reloadData()
            })
        }
    }
    
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        
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
        print("channelWasChanged(sender:)")
        var channelExist = false
        for channel in self.channels {
            if sender == channel {
                channelExist = true
                break
            }
        }
        
        if channelExist == true {
            DispatchQueue.main.async(execute: { 
                self.tableView.reloadData()
            })
        }
    }
    
    func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        print("channelWasDeleted(channelUrl:, channelType:)")
        self.refreshChannelList()
    }
    
    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        print("channel(sender:, messageWasDeleted messageId:)")
    }
    
    // MARK: GroupChannelViewControllerDelegate
    func didCloseGroupChannelViewController(_ vc: UIViewController) {
        self.refreshChannelList()
    }
    
    // MARK: UserListViewControllerDelegate
    func didCloseUserListViewController(_ vc: UIViewController, groupChannel: SBDGroupChannel) {
        print("didCloseUserListViewController(vc:, groupChannel:)")
        self.refreshChannelList()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(500 * NSEC_PER_USEC)) / Double(NSEC_PER_SEC)) {
            let gvc = GroupChannelViewController()
            gvc.title = "Group Channel"
            gvc.senderId = SBDMain.getCurrentUser()?.userId
            gvc.senderDisplayName = SBDMain.getCurrentUser()?.nickname
            gvc.setGroupChannel(groupChannel)
            gvc.delegate = self
            
            self.navigationController?.pushViewController(gvc, animated: false)
        }
    }
}
