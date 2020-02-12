//
//  GroupChannelsViewController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/12/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import SendBirdSyncManager

// TODO: Seperate Logic & UI & SDK
class GroupChannelsViewController: BaseViewController, SBDConnectionDelegate {
    @IBOutlet weak var loadingIndicatorView: CustomActivityIndicatorView!
    @IBOutlet weak var toastView: UIView!
    @IBOutlet weak var toastMessageLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self

            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(GroupChannelsViewController.longPressChannel(_:)))
            longPressGesture.minimumPressDuration = 1.0
            self.tableView.addGestureRecognizer(longPressGesture)
            
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self, action: #selector(GroupChannelsViewController.refreshChannelList), for: .valueChanged)
            self.tableView.refreshControl = self.refreshControl
        }
    }
    
    var channels: [SBDGroupChannel] = []

    var query: SBDGroupChannelListQuery?
    var collection: SBSMChannelCollection?
     
    var refreshControl: UIRefreshControl?
    var trypingIndicatorTimer: [String : Timer] = [:]
    var toastCompleted: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Group Channels"
        self.navigationController?.title = "Group"
        self.navigationItem.largeTitleDisplayMode = .automatic
        
        let createChannelBarButton = UIBarButtonItem(image: UIImage(named: "img_btn_create_group_channel_blue"),
                                                     style: .plain, target: self,
                                                     action: #selector(GroupChannelsViewController.clickCreateGroupChannel(_:)))
        
        self.navigationItem.rightBarButtonItem = createChannelBarButton
 
        self.hideLoadingIndicatorView()
        self.view.bringSubviewToFront(self.loadingIndicatorView)
        
        self.updateTotalUnreadMessageCountBadge()
        self.initGroupChannelListQuery()
        self.initChannelCollection();
        self.collection?.delegate = self
        self.collection?.fetch() { error in
            if let error = error {
                if error.code != SBSMErrorCode.duplicatedFetch.rawValue {
                    AlertControl.showError(parent: self, error: error)
                }
                return
            }
        }
        
        /*
         * When use delegate, must remove the delete in deinit.
         * Please check the BaseViewController.swift
         */
        SBDMain.add(self as SBDChannelDelegate, identifier: self.delegateIdentifier)
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.delegateIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.layoutIfNeeded()
        self.tabBarController?.hidesBottomBarWhenPushed = true
    }
    
    deinit { 
        SBDMain.removeConnectionDelegate(forIdentifier: self.delegateIdentifier)
        SBDMain.removeChannelDelegate(forIdentifier: self.delegateIdentifier)
    }
    
    func showToast(message: String, completion: (() -> Void)?) {
        self.toastCompleted = false
        self.toastView.alpha = 1
        self.toastMessageLabel.text = message
        self.toastView.isHidden = false
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.5,
                       options: .curveEaseIn,
                       animations: {
                        self.toastView.alpha = 0
        }) { finished in
            self.toastView.isHidden = true
            self.toastCompleted = true
            
            completion?()
        }
    }
    
    func initGroupChannelListQuery() {
        self.query = SBDGroupChannel.createMyGroupChannelListQuery()
        self.query!.order = .latestLastMessage
        self.query!.limit = 30
    }
    
    func initChannelCollection() {
        if let query = self.query {
            self.collection = SBSMChannelCollection(query: query)
            self.collection?.delegate = self
        }
    }
 
    @objc func clickCreateGroupChannel(_ sender: Any) {
        let vc = CreateGroupChannelNavigationController.initiate()
        vc.channelCreationDelegate = self
        vc.modalPresentationStyle = .overCurrentContext
        self.tabBarController?.present(vc, animated: true, completion: nil)
    }
    
    @objc func longPressChannel(_ recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: self.tableView)
        guard let indexPath = self.tableView.indexPathForRow(at: point) else { return }
        
        guard recognizer.state == .began else { return }
        let channel = self.channels[indexPath.row]
        
        let title = Utils.createGroupChannelName(channel: channel)

        AlertControl.show(parent: self, title: title, actionMessage: "Leave Channel") { _ in
            channel.leave { error in
                if let error = error {
                    AlertControl.showError(parent: self, error: error)
                    return
                }
            }
        }
    }
    
    func updateTotalUnreadMessageCountBadge() {
        func update() {
            SBDMain.getTotalUnreadMessageCount { unreadCount, error in
                guard let navigationController = self.navigationController else { return }
                guard error == nil, unreadCount > 0 else {
                    navigationController.tabBarItem.badgeValue = nil
                    return
                }
                navigationController.tabBarItem.badgeValue = String(unreadCount)
            }
        }
        
        update()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: update)
    }
    
    func getTypingIndicatorText(channel: SBDGroupChannel) -> String {
        guard let typingMembers = channel.getTypingMembers() else { return "" }
        
        switch typingMembers.count {
            
        case 0: return ""
        case 1: return typingMembers[0].nickname! + " is typing."
        case 2: return typingMembers[0].nickname! + " and " + typingMembers[1].nickname! + " are typing."
        
        default:
            return "Several people are typing."
        }
    }
    
    @objc func typingIndicatorTimeout(_ timer: Timer) {
        guard let channelUrl = timer.userInfo as? String else { return }
        self.trypingIndicatorTimer[channelUrl]?.invalidate()
        self.trypingIndicatorTimer.removeValue(forKey: channelUrl)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Load channels
    @objc func refreshChannelList() {
        self.initGroupChannelListQuery()
        self.initChannelCollection();
        
        DispatchQueue.main.async {
            self.channels = []
            self.tableView.reloadData()
        }
        
        self.loadChannelListNextPage(true)
    }
    
    func loadChannelListNextPage(_ refresh: Bool) {
        DispatchQueue.main.async {
            self.collection?.fetch() { error in
                if let error = error {
                    if error.code != SBSMErrorCode.duplicatedFetch.rawValue {
                        AlertControl.showError(parent: self, error: error)
                    }
                    return
                }
            }
            
            if (refresh) {
                self.refreshControl?.endRefreshing()
            }
        }
    }
     
    func insertChannels(_ channels: [SBDGroupChannel]) {
        DispatchQueue.main.async {
            if self.channels.count == 0 {
                self.channels.insert(channels[0], at: 0)
            }
            
            for insertedChannel in channels {
                var foundPosition = -1
                var replace = false
                for existChannel in self.channels {
                    if insertedChannel == existChannel {
                        foundPosition = self.channels.firstIndex(of: existChannel)!
                        replace = true
                        break
                    }
                    
                    let order = self.query?.order
                    if order == SBDGroupChannelListOrder.latestLastMessage {
                        var timestampOfInsertedChannel = Int64(insertedChannel.createdAt)
                        var timestampOfExistChannel = Int64(existChannel.createdAt)
                        
                        if let lastMessageOfInsertedChannel = insertedChannel.lastMessage {
                            timestampOfInsertedChannel = Int64(lastMessageOfInsertedChannel.createdAt)
                        }
                        
                        if let lastMessageOfExistChannel = existChannel.lastMessage {
                            timestampOfExistChannel = Int64(lastMessageOfExistChannel.createdAt)
                        }
                        
                        if (timestampOfExistChannel <= timestampOfInsertedChannel) {
                            foundPosition = self.channels.firstIndex(of: existChannel)!
                            break;
                        }
                    }
                    else if order == SBDGroupChannelListOrder.channelMetaDataValueAlphabetical {
                        // TODO:
                    }
                    else if order == SBDGroupChannelListOrder.channelNameAlphabetical {
                        // TODO:
                    }
                    else {
                        // SBDGroupChannelListOrder.chronological
                        // TODO:
                    }
                }
                
                if foundPosition > -1 {
                    if replace {
                        self.channels[foundPosition] = insertedChannel
                    }
                    else {
                        self.channels.insert(insertedChannel, at: foundPosition)
                    }
                }
                else {
                    self.channels.append(insertedChannel)
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    func reloadChannel(_ channel: SBDGroupChannel) {
        DispatchQueue.main.async {
            guard let index = self.channels.firstIndex(of: channel) else { return }
            guard let cell = self.tableView.cellForRow(at: .init(row: index, section: 0)) as? GroupChannelTableViewCell else { return }

            let timer = self.trypingIndicatorTimer[channel.channelUrl]
            cell.set(by: channel, timer: timer)
        }
    }
    
    func updateChannels(_ channels: [SBDGroupChannel]) {
        if self.channels.count == 0 {
            return
        }
        
        for updatedChannel in channels {
            DispatchQueue.main.async {
                guard let index = self.channels.firstIndex(of: updatedChannel) else { return }
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }

    func moveChannels(_ channels: [SBDGroupChannel]) {
        for movedChannel in channels {
            DispatchQueue.main.async {
                guard let index = self.channels.firstIndex(of: movedChannel) else { return }
                self.channels.remove(at: index)
                
                var foundPosition = -1
                
                for existChannel in self.channels {
                    let order = self.query?.order
                    if order == SBDGroupChannelListOrder.latestLastMessage {
                        var timestampOfInsertedChannel = Int64(movedChannel.createdAt)
                        var timestampOfExistChannel = Int64(existChannel.createdAt)
                        
                        if let lastMessageOfInsertedChannel = movedChannel.lastMessage {
                            timestampOfInsertedChannel = Int64(lastMessageOfInsertedChannel.createdAt)
                        }
                        
                        if let lastMessageOfExistChannel = existChannel.lastMessage {
                            timestampOfExistChannel = Int64(lastMessageOfExistChannel.createdAt)
                        }
                        
                        if (timestampOfExistChannel <= timestampOfInsertedChannel) {
                            foundPosition = self.channels.firstIndex(of: existChannel)!
                            break;
                        }
                    }
                    else if order == SBDGroupChannelListOrder.channelMetaDataValueAlphabetical {
                        // TODO:
                    }
                    else if order == SBDGroupChannelListOrder.channelNameAlphabetical {
                        // TODO:
                    }
                    else {
                        // SBDGroupChannelListOrder.chronological
                        // TODO:
                    }
                }
                
                if foundPosition > -1 {
                    self.channels.insert(movedChannel, at: foundPosition)
                    self.tableView.moveRow(at: IndexPath(row: index, section: 0), to: IndexPath(row: foundPosition, section: 0))
                }
            }
        }
    }

    func deleteChannels(_ channels: [SBDGroupChannel]) {
        DispatchQueue.main.async {
            var deletedIndex: [IndexPath] = []
            for deletedChannel in channels {
                if let row = self.channels.firstIndex(of: deletedChannel) {
                    let indexPath = IndexPath(row: row, section: 0)
                    deletedIndex.append(indexPath)
                    self.channels.removeObject(deletedChannel)
                }
            }
            self.tableView.deleteRows(at: deletedIndex, with: .automatic)
        }
    }
}

// MARK: - Utilities
extension GroupChannelsViewController {
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

extension GroupChannelsViewController {
    static func initiate() -> GroupChannelsViewController {
        let vc = GroupChannelsViewController.withStoryboard(storyboard: .groupChannel)
        return vc
    }
}

// MARK: - SBSMChannelCollectionDelegate
extension GroupChannelsViewController: SBSMChannelCollectionDelegate {
    func collection(_ collection: SBSMChannelCollection, didReceiveEvent action: SBSMChannelEventAction, channels: [SBDGroupChannel]) {
        switch action {
            
        case .insert:
            self.insertChannels(channels)
            
        case .update:
            self.updateChannels(channels)
            
        case .remove:
            self.deleteChannels(channels)
            
        case .move:
            self.moveChannels(channels)

        case .clear:
            DispatchQueue.main.async {
                self.channels = []
                self.tableView.reloadData()
            }
            
        case .none:
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        default:
            assertionFailure("Undefine action")

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - CreateGroupChannelViewControllerDelegate
extension GroupChannelsViewController: CreateGroupChannelViewControllerDelegate {
    func didCreateGroupChannel(_ channel: SBDGroupChannel) {
        let vc = GroupChannelChatViewController.initiate()
        vc.channel = channel
        vc.delegate = self

        let naviVC = UINavigationController(rootViewController: vc)
        naviVC.modalPresentationStyle = .overCurrentContext
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 3000)) {
            naviVC.modalPresentationStyle = .overCurrentContext
            self.tabBarController?.present(naviVC, animated: true, completion: nil)
        }
    }
}
