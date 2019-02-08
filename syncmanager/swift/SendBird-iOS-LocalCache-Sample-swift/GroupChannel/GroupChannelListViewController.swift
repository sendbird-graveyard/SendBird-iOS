//
//  GroupChannelListViewController.swift
//  SendBird-iOS-LocalCache-Sample-swift
//
//  Created by Jed Kyung on 10/10/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import SendBirdSDK
import SendBirdSyncManager

class GroupChannelListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate, CreateGroupChannelUserListViewControllerDelegate, SBSMChannelCollectionDelegate {
    @IBOutlet weak var navItem: UINavigationItem?
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var noChannelLabel: UILabel?
    
    private var channels: Array<SBDGroupChannel> = Array()
    
    private var query: SBDGroupChannelListQuery? {
        get {
            let theQuery: SBDGroupChannelListQuery? = SBDGroupChannel.createMyGroupChannelListQuery()
            theQuery?.limit = 10
            theQuery?.order = SBDGroupChannelListOrder.latestLastMessage
            return theQuery
        }
    }
    
    private var collection: SBSMChannelCollection?
    private var channelCollection: SBSMChannelCollection? {
        if self.collection == nil, let query: SBDGroupChannelListQuery = self.query {
            self.collection = SBSMChannelCollection.init(query: query)
        }
        return self.collection
    }
    private func resetChannelCollection() {
        self.channelCollection?.remove()
        self.collection = nil
    }
    
    private var typingAnimationChannels: Array<String> = Array()

    private var refreshControl: UIRefreshControl = UIRefreshControl()
    private var editableChannel: Bool = false
    
    lazy private var tableViewQueue: SBSMOperationQueue = SBSMOperationQueue.init()
    
    deinit {
        if let collection: SBSMChannelCollection = self.channelCollection {
            collection.delegate = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
        
        self.channelCollection?.delegate = self
        self.channelCollection?.fetch(completionHandler: { (error) in
        })
    }
    
    private func configureView() -> Void {
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.isEditing = false
        self.tableView?.register(GroupChannelListTableViewCell.nib(), forCellReuseIdentifier: GroupChannelListTableViewCell.cellReuseIdentifier())
        self.tableView?.register(GroupChannelListEditableTableViewCell.nib(), forCellReuseIdentifier: GroupChannelListEditableTableViewCell.cellReuseIdentifier())
        
        self.refreshControl.addTarget(self, action: #selector(refreshChannels), for: UIControl.Event.valueChanged)
        self.tableView?.addSubview(self.refreshControl)
        
        self.noChannelLabel?.isHidden = true
        
        self.configureDefaultNavigationItems()
    }
    
    private func configureDefaultNavigationItems() {
        let negativeLeftSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        negativeLeftSpacer.width = -2
        let negativeRightSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        negativeRightSpacer.width = -2
        let leftBackItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_back"), style: UIBarButtonItem.Style.done, target: self, action: #selector(back))
        self.navItem?.leftBarButtonItems = [negativeLeftSpacer, leftBackItem]
        
        let rightCreateGroupChannelItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_plus"), style: UIBarButtonItem.Style.done, target: self, action: #selector(createGroupChannel))
        let rightEditItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn_edit"), style: UIBarButtonItem.Style.done, target: self, action: #selector(editGroupChannel))
        rightEditItem.imageInsets = UIEdgeInsets.init(top: 0, left: 14, bottom: 0, right: -14)
        self.navItem?.rightBarButtonItems = [negativeRightSpacer, rightCreateGroupChannelItem, rightEditItem]
    }
    
    // MARK: UI Action methods
    @objc private func refreshChannels() {
        DispatchQueue.main.async {
            self.refreshControl.beginRefreshing()
        }
        
        
        self.resetChannelCollection()
        self.channelCollection?.fetch(completionHandler: { (error) in
            // end load progress
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    @objc private func back() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc private func createGroupChannel() {
        let vc: CreateGroupChannelUserListViewController = CreateGroupChannelUserListViewController(nibName: "CreateGroupChannelUserListViewController", bundle: Bundle.main)
        vc.delegate = self
        vc.userSelectionMode = 0
        self.present(vc, animated: false, completion: nil)
    }
    
    @objc private func editGroupChannel() {
        self.editableChannel = true
        
        let negativeLeftSpacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        negativeLeftSpacer.width = -2
        
        let leftBackItem: UIBarButtonItem = UIBarButtonItem(title: Bundle.sbLocalizedStringForKey(key: "DoneButton"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(done))
        leftBackItem.setTitleTextAttributes([NSAttributedString.Key.font: Constants.navigationBarButtonItemFont()], for: UIControl.State.normal)
        
        self.navItem?.leftBarButtonItems = [negativeLeftSpacer, leftBackItem]
        self.navItem?.rightBarButtonItems = []
        
        self.tableView?.reloadData()
    }
    
    @objc func done() {
        self.editableChannel = false
        self.configureDefaultNavigationItems()
        self.tableView?.reloadData()
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
            let channel: SBDGroupChannel = self.channels[indexPath.row]
            let vc: GroupChannelChattingViewController = GroupChannelChattingViewController.init(channel: channel)
            
            self.present(vc, animated: false, completion: nil)
        }
        else {
            if let cell: MGSwipeTableCell = tableView.cellForRow(at: indexPath) as? MGSwipeTableCell {
                cell.showSwipe(MGSwipeDirection.rightToLeft, animated: true)
            }
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
                if self.typingAnimationChannels.index(of: self.channels[indexPath.row].channelUrl) == nil {
                    self.typingAnimationChannels.append(self.channels[indexPath.row].channelUrl)
                }
            }
            else {
                if self.typingAnimationChannels.index(of: self.channels[indexPath.row].channelUrl) != nil {
                    self.typingAnimationChannels.remove(at: self.typingAnimationChannels.index(of: self.channels[indexPath.row].channelUrl)!)
                }
            }
            
            (cell as! GroupChannelListTableViewCell).setModel(aChannel: self.channels[indexPath.row])
        }
        
        if self.channels.count > 0 && indexPath.row + 1 == self.channels.count {
            self.channelCollection?.fetch(completionHandler: nil)
        }
        
        return cell!
    }
    
    // MARK: MGSwipeTableCellDelegate
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        // 0: right, 1: left
        let row = self.tableView?.indexPath(for: cell)?.row
        let selectedChannel: SBDGroupChannel = self.channels[row!] as SBDGroupChannel
        let handler = {(error: SBDError?) -> Void in
            guard let _: SBDError = error else {
            let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertController.Style.alert)
            let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertAction.Style.cancel, handler: nil)
            vc.addAction(closeAction)
            DispatchQueue.main.async {
                self.present(vc, animated: true, completion: nil)
            }
            
            return
            }
        }
        
        if index == 0 {
            // Hide
            selectedChannel.hide(withHidePreviousMessages: false, completionHandler: handler)
        }
        else {
            // Leave
            selectedChannel.leave(completionHandler: handler)
        }
        
        return true
    }
    
    // MARK: CreateGroupChannelUserListViewControllerDelegate
    func presentGroupChannel(channel: SBDGroupChannel, parentViewController: UIViewController) {
        DispatchQueue.main.async {
            let vc: GroupChannelChattingViewController = GroupChannelChattingViewController.init(channel: channel)
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    // MARK: SendBird Manager Delegate
    func collection(_ collection: SBSMChannelCollection, didReceiveEvent action: SBSMChannelEventAction, channels: [SBDGroupChannel]) {
        guard self.channelCollection == collection, channels.count > 0 else {
            return
        }
        
        var operation: SBSMOperation?
        operation = self.tableViewQueue.enqueue({
            let handler = {() -> Void in
                operation?.complete()
            }
            
            switch (action) {
            case SBSMChannelEventAction.insert:
                self.insert(channels: channels, completionHandler: handler)
                break
            case SBSMChannelEventAction.update:
                self.update(channels: channels, completionHandler: handler)
                break
            case SBSMChannelEventAction.remove:
                self.remove(channels: channels, completionHandler: handler)
                break
            case SBSMChannelEventAction.move:
                self.move(channel: channels.first!, completionHandler: handler)
                break
            case SBSMChannelEventAction.clear:
                self.clearAllChannels(completionHandler: handler)
                break
            case SBSMChannelEventAction.none:
                handler()
                break
            default:
                handler()
                break
            }
        })
    }
    
    // MARK: UI update
    func insert(channels: [SBDGroupChannel], completionHandler: SBSMVoidHandler?) -> Void {
        guard channels.count > 0, let tableView: UITableView = self.tableView else {
            return
        }
        
        var indexPathes: [IndexPath] = [IndexPath]()
        let indexes: [SBSMIndex] = Utils.indexes(channels: channels, inChannels: self.channels) { (channel1, channel2) -> Bool in
            return (self.channelCollection!.orderAscendingBetweenObject(channel1, andObject: channel2) == ComparisonResult.orderedAscending)
        }
        
        for indexObject in indexes {
            var index: Int = indexObject.indexOfPreviousObject
            index += 1
            let channel: SBDGroupChannel = self.channels[index]
            self.channels.insert(channel, at: index)
            indexPathes.append(IndexPath.init(row: index, section: 0))
        }
        
        Utils.performBatchUpdate(tableView: tableView, updateProcess: { (tableView) in
            tableView.insertRows(at: indexPathes, with: UITableView.RowAnimation.automatic)
        }) { (finished) in
            if (completionHandler != nil) {
                completionHandler?()
            }
        }
    }
    
    func update(channels: [SBDGroupChannel], completionHandler: SBSMVoidHandler?) -> Void {
        guard channels.count > 0, let tableView: UITableView = self.tableView else {
            return
        }
        
        var indexPathes: [IndexPath] = [IndexPath]()
        let indexes: [SBSMIndex] = Utils.indexes(channels: channels, inChannels: self.channels) { (channel1, channel2) -> Bool in
            return (self.channelCollection!.orderAscendingBetweenObject(channel1, andObject: channel2) == ComparisonResult.orderedAscending)
        }
        
        for (index, indexObject) in indexes.enumerated() {
            let indexOfChannel: Int = indexObject.indexOfObject
            let channel: SBDGroupChannel = channels[index]
            self.channels[indexOfChannel] = channel
            indexPathes.append(IndexPath.init(row: indexOfChannel, section: 0))
        }
        
        Utils.performBatchUpdate(tableView: tableView, updateProcess: { (tableView) in
            tableView.reloadRows(at: indexPathes, with: UITableView.RowAnimation.none)
        }) { (finished) in
            if (completionHandler != nil) {
                completionHandler?()
            }
        }
    }
    
    func remove(channels: [SBDGroupChannel], completionHandler: SBSMVoidHandler?) -> Void {
        guard channels.count > 0, let tableView: UITableView = self.tableView else {
            return
        }
        
        var indexPathes: [IndexPath] = [IndexPath]()
        let indexes: [SBSMIndex] = Utils.indexes(channels: channels, inChannels: self.channels) { (channel1, channel2) -> Bool in
            return (self.channelCollection!.orderAscendingBetweenObject(channel1, andObject: channel2) == ComparisonResult.orderedAscending)
        }
        
        for indexObject in indexes {
            let index: Int = indexObject.indexOfObject
            self.channels.remove(at: index)
            indexPathes.append(IndexPath.init(row: index, section: 0))
        }
        
        Utils.performBatchUpdate(tableView: tableView, updateProcess: { (tableView) in
            tableView.deleteRows(at: indexPathes, with: UITableView.RowAnimation.automatic)
        }) { (finished) in
            if (completionHandler != nil) {
                completionHandler?()
            }
        }
    }
    
    func move(channel: SBDGroupChannel, completionHandler: SBSMVoidHandler?) -> Void {
        guard let tableView: UITableView = self.tableView else {
            return
        }
        
        let atIndex: SBSMIndex = Utils.index(channelUrl: channel.channelUrl, ofChannels: self.channels)
        let atIndexPath: IndexPath = IndexPath.init(item: atIndex.indexOfObject, section: 0)
        self.channels.remove(at: atIndex.indexOfObject)
        let toIndex: SBSMIndex = Utils.index(channel: channel, inChannels: self.channels) { (channel1, channel2) -> Bool in
            return (self.channelCollection?.orderAscendingBetweenObject(channel1, andObject: channel2) == ComparisonResult.orderedAscending)
        }
        let toIndexPath: IndexPath = IndexPath.init(item: toIndex.indexOfObject, section: 0)
        self.channels.insert(channel, at: toIndex.indexOfObject)
        
        Utils.performBatchUpdate(tableView: tableView, updateProcess: { (tableView) in
            tableView.reloadRows(at: [atIndexPath], with: UITableView.RowAnimation.none)
            tableView.moveRow(at: atIndexPath, to: toIndexPath)
        }) { (finished) in
            if (completionHandler != nil) {
                completionHandler?()
            }
        }
    }
    
    func clearAllChannels(completionHandler: SBSMVoidHandler?) -> Void {
        guard let tableView: UITableView = self.tableView else {
            return
        }
        
        Utils.performBatchUpdate(tableView: tableView, updateProcess: { (tableView) in
            self.channels.removeAll()
            tableView.reloadData()
        }) { (finished) in
            if (completionHandler != nil) {
                completionHandler?()
            }
        }
    }
    
    // MARK: SendBird SDK Channel Delegate
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        if self.editableChannel == true {
            return
        }
        
        let row = self.channels.index(of: sender)
        if row != nil {
            let cell = self.tableView?.cellForRow(at: IndexPath(row: row!, section: 0)) as! GroupChannelListTableViewCell
            
            cell.startTypingAnimation()
        }
    }
}
