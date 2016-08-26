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
    @IBOutlet private weak var tableView: UITableView!
    private var channels: [SBDGroupChannel] = []
    private var userID: String?
    private var userName: String?
    private var myGroupChannelListQuery: SBDGroupChannelListQuery?
    private var delegateIndetifier: String?
    private var refreshControl: UIRefreshControl?
    private var editMode: Bool?
    private var editChannelListButtomItem: UIBarButtonItem?
    private var doneChannelListButtomItem: UIBarButtonItem?
    private var createChannelButtomItem: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Group Channel List"
        self.editMode = false
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerNib(GroupChannelListTableViewCell.nib(), forCellReuseIdentifier: GroupChannelListTableViewCell.cellReuseIdentifier())
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(GroupChannelListViewController.refreshChannelList), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl!)
        
        self.myGroupChannelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        self.myGroupChannelListQuery?.limit = 10
        
        self.delegateIndetifier = self.description
        
        self.editChannelListButtomItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: #selector(GroupChannelListViewController.editGroupChannelList))
        self.doneChannelListButtomItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(GroupChannelListViewController.editGroupChannelList))
        self.createChannelButtomItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(GroupChannelListViewController.createGroupChannel))
        
        self.navigationItem.rightBarButtonItems = [self.createChannelButtomItem!, self.editChannelListButtomItem!]
        
        SBDMain.addChannelDelegate(self, identifier: self.delegateIndetifier!)
        SBDMain.addConnectionDelegate(self, identifier: self.delegateIndetifier!)
        
        self.loadChannels()
    }
    
    override func viewWillDisappear(animated: Bool) {
        if self.navigationController?.viewControllers.indexOf(self) == nil {
            SBDMain.removeChannelDelegateForIdentifier(self.delegateIndetifier!)
            SBDMain.removeConnectionDelegateForIdentifier(self.delegateIndetifier!)
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
            self.createChannelButtomItem?.enabled = true
            self.navigationItem.rightBarButtonItems = [self.createChannelButtomItem!, self.editChannelListButtomItem!]
        }
        else {
            self.title = "Edit Group Channels"
            self.editMode = true
            self.createChannelButtomItem?.enabled = false
            self.navigationItem.rightBarButtonItems = [self.createChannelButtomItem!, self.doneChannelListButtomItem!]
        }
    }
    
    func refreshChannelList() {
        if self.myGroupChannelListQuery != nil && self.myGroupChannelListQuery?.isLoading() == true {
            self.refreshControl?.endRefreshing()
            return
        }
        
        self.channels.removeAll()
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })

        self.myGroupChannelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        self.myGroupChannelListQuery!.limit = 10
        self.loadChannels()
    }
    
    private func loadChannels() {
        if self.myGroupChannelListQuery?.isLoading() == true {
            return
        }
        
        if self.myGroupChannelListQuery?.hasNext == false {
            return
        }
        
        self.myGroupChannelListQuery?.loadNextPageWithCompletionHandler({ (channels, error) in
            if error != nil {
                if self.refreshControl?.refreshing == true {
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

            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                
                if self.refreshControl?.refreshing == true {
                    self.refreshControl?.endRefreshing()
                }
            })
        })
    }
    
    func setUser(aUserId: String, aUserName: String) {
        self.userID = aUserId
        self.userName = aUserName
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let channel = self.channels[indexPath.row]
        
        if self.editMode == true {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil)
            let leaveChannelAction = UIAlertAction(title: "Leave channel", style: UIAlertActionStyle.Default, handler: { (action) in
                channel.leaveChannelWithCompletionHandler({ (error) in
                    dispatch_async(dispatch_get_main_queue(), {
                        if let index = self.channels.indexOf(channel) {
                            self.channels.removeAtIndex(index)
                        }
                        self.tableView.reloadData()
                    })
                })
            })
            let hideChannelAction = UIAlertAction(title: "Hide channel", style: UIAlertActionStyle.Default, handler: { (action) in
                channel.hideChannelWithCompletionHandler({ (error) in
                    dispatch_async(dispatch_get_main_queue(), {
                        if let index = self.channels.indexOf(channel) {
                            self.channels.removeAtIndex(index)
                        }
                        self.tableView.reloadData()
                    })
                })
            })
            
            alert.addAction(closeAction)
            alert.addAction(leaveChannelAction)
            alert.addAction(hideChannelAction)
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
        else {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            let vc = GroupChannelViewController()
            vc.title = "Group Channel"
            vc.senderId = SBDMain.getCurrentUser()?.userId
            vc.senderDisplayName = SBDMain.getCurrentUser()?.nickname
            vc.setGroupChannel(self.channels[indexPath.row])
            vc.delegate = self
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let channel = self.channels[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(GroupChannelListTableViewCell.cellReuseIdentifier()) as! GroupChannelListTableViewCell
        
        cell.setModel(channel)
        
        if self.channels.count > 0 {
            if indexPath.row == self.channels.count - 1 {
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
    func channel(sender: SBDBaseChannel, didReceiveMessage message: SBDBaseMessage) {
        print("channel(sender: didReceiveMessage user:)")
        
        if sender.isKindOfClass(SBDGroupChannel) == true {
            var isNewChannel = true
            (sender as! SBDGroupChannel).lastMessage = message
            for channelInList in self.channels {
                if sender.channelUrl == channelInList.channelUrl {
                    isNewChannel = false
                }
            }
            
            if isNewChannel == false {
                if let index = self.channels.indexOf((sender as! SBDGroupChannel)) {
                    self.channels.removeAtIndex(index)
                }
            }
            
            self.channels.insert((sender as! SBDGroupChannel), atIndex: 0)
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.tableView.reloadData()
            })
        }
    }
    
    func channelDidUpdateReadReceipt(sender: SBDGroupChannel) {
        
    }
    
    func channelDidUpdateTypingStatus(sender: SBDGroupChannel) {
        
    }
    
    func channel(sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        print("channel(sender: userDidJoin user:)")
        var isNewChannel = true
        for channel in self.channels {
            if sender == channel {
                isNewChannel = false
                break
            }
        }
        
        if isNewChannel == true {
            self.channels.insert(sender as SBDGroupChannel, atIndex: 0)
            dispatch_async(dispatch_get_main_queue(), { 
                self.tableView.reloadData()
            })
        }
    }
    
    func channel(sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        
    }
    
    func channel(sender: SBDOpenChannel, userDidEnter user: SBDUser) {
        
    }
    
    func channel(sender: SBDOpenChannel, userDidExit user: SBDUser) {
        
    }
    
    func channel(sender: SBDOpenChannel, userWasMuted user: SBDUser) {
        
    }
    
    func channel(sender: SBDOpenChannel, userWasUnmuted user: SBDUser) {
        
    }
    
    func channel(sender: SBDOpenChannel, userWasBanned user: SBDUser) {
        
    }
    
    func channel(sender: SBDOpenChannel, userWasUnbanned user: SBDUser) {
        
    }
    
    func channelWasFrozen(sender: SBDOpenChannel) {
        
    }
    
    func channelWasUnfrozen(sender: SBDOpenChannel) {
        
    }
    
    func channelWasChanged(sender: SBDBaseChannel) {
        print("channelWasChanged(sender:)")
        var channelExist = false
        for channel in self.channels {
            if sender == channel {
                channelExist = true
                break
            }
        }
        
        if channelExist == true {
            dispatch_async(dispatch_get_main_queue(), { 
                self.tableView.reloadData()
            })
        }
    }
    
    func channelWasDeleted(channelUrl: String, channelType: SBDChannelType) {
        print("channelWasDeleted(channelUrl:, channelType:)")
        self.refreshChannelList()
    }
    
    func channel(sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        print("channel(sender:, messageWasDeleted messageId:)")
    }
    
    // MARK: GroupChannelViewControllerDelegate
    func didCloseGroupChannelViewController(vc: UIViewController) {
        self.refreshChannelList()
    }
    
    // MARK: UserListViewControllerDelegate
    func didCloseUserListViewController(vc: UIViewController, groupChannel: SBDGroupChannel) {
        print("didCloseUserListViewController(vc:, groupChannel:)")
        self.refreshChannelList()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(500 * NSEC_PER_USEC)), dispatch_get_main_queue()) {
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
