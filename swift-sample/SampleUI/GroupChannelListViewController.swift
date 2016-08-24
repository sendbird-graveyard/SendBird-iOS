//
//  GroupChannelListViewController.swift
//  SampleUI
//
//  Created by Jed Kyung on 8/24/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class GroupChannelListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SBDConnectionDelegate, SBDChannelDelegate {
    @IBOutlet private weak var tableView: UITableView!
    private var channels: NSMutableArray?
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
        
        self.channels = NSMutableArray()
        
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
        // TODO:
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
            self.navigationItem.rightBarButtonItems = [self.createChannelButtomItem!, self.doneChannelListButtomItem!]
        }
    }
    
    func refreshChannelList() {
        if self.myGroupChannelListQuery != nil && self.myGroupChannelListQuery?.isLoading() == true {
            self.refreshControl?.endRefreshing()
            return
        }
        
        self.channels?.removeAllObjects()
        dispatch_async(dispatch_get_main_queue()) { 
            self.tableView.reloadData()
        }
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
                self.channels?.addObject(channel)
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
        let channel = self.channels![indexPath.row] as! SBDGroupChannel
        
        if self.editMode == true {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil)
            let leaveChannelAction = UIAlertAction(title: "Leave channel", style: UIAlertActionStyle.Default, handler: { (action) in
                channel.leaveChannelWithCompletionHandler({ (error) in
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.channels?.removeObject(channel)
                        self.tableView.reloadData()
                    })
                })
            })
            let hideChannelAction = UIAlertAction(title: "Hide channel", style: UIAlertActionStyle.Default, handler: { (action) in
                channel.hideChannelWithCompletionHandler({ (error) in
                    dispatch_async(dispatch_get_main_queue(), {
                        self.channels?.removeObject(channel)
                        self.tableView.reloadData()
                    })
                })
            })
        }
        else {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            // TODO:
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let channel = self.channels?.objectAtIndex(indexPath.row) as! SBDGroupChannel
        let cell = tableView.dequeueReusableCellWithIdentifier(GroupChannelListTableViewCell.cellReuseIdentifier()) as! GroupChannelListTableViewCell
        
        cell.setModel(channel)
        
        if self.channels!.count > 0 {
            if indexPath.row == self.channels!.count - 1 {
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
        if sender.isKindOfClass(SBDGroupChannel) == true {
            var isNewChannel = true
            (sender as! SBDGroupChannel).lastMessage = message
            for item in self.channels! {
                let channelInList = item as! SBDGroupChannel
                if sender.channelUrl == channelInList.channelUrl {
                    isNewChannel = false
                }
            }
            
            if isNewChannel == false {
                self.channels?.removeObject(sender)
            }
            
            self.channels?.insertObject(sender, atIndex: 0)
            
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
        var isNewChannel = true
        for item in self.channels! {
            if sender == item as! SBDGroupChannel {
                isNewChannel = false
                break
            }
        }
        
        if isNewChannel == true {
            self.channels?.insertObject(sender, atIndex: 0)
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
        var channelExist = false
        for item in self.channels! {
            if sender == item as! SBDGroupChannel {
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
        self.refreshChannelList()
    }
    
    func channel(sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {

    }
    
    // TODO:
}
