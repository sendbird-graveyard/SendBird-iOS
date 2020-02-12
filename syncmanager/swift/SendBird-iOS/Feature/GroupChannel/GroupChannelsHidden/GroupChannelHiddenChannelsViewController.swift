//
//  GroupChannelHiddenChannelsViewController.swift
//  SendBird-iOS
//
//  Created by Minhyuk Kim on 01/08/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import AlamofireImage
class GroupChannelHiddenChannelsViewController: UIViewController {
    
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var toastView: UIView!
    @IBOutlet weak var toastMessageLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicatorView: CustomActivityIndicatorView!
    
    var refreshControl: UIRefreshControl?
    
    var channelListQuery: SBDGroupChannelListQuery?
    var channels: [SBDGroupChannel] = []
    var toastCompleted: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Hidden Channels"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshChannelList), for: .valueChanged)
        
        self.tableView.refreshControl = self.refreshControl
        
        self.hideLoadingIndicatorView()
        self.view.bringSubviewToFront(self.loadingIndicatorView)
        
        self.loadChannelListNextPage(true)
    }
    
    func showToast(message: String, completion: (() -> Void)?) {
        self.toastCompleted = false
        self.toastView.alpha = 1
        self.toastMessageLabel.text = message
        self.toastView.isHidden = false
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseIn, animations: {
            self.toastView.alpha = 0
        }) { (finished) in
            self.toastView.isHidden = true
            self.toastCompleted = true
            
            completion?()
        }
    }
    
    
    // MARK: - Load channels
    @objc func refreshChannelList() {
        self.loadChannelListNextPage(true)
    }
    
    func loadChannelListNextPage(_ refresh: Bool) {
        if refresh {
            self.channelListQuery = nil
        }
        
        if self.channelListQuery == nil {
            self.channelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
            self.channelListQuery?.order = .latestLastMessage
            self.channelListQuery?.limit = 20
            self.channelListQuery?.includeEmptyChannel = true
            self.channelListQuery?.channelHiddenStateFilter = .hiddenOnly
        }
        
        if self.channelListQuery?.hasNext == false {
            return
        }
        
        self.channelListQuery?.loadNextPage(completionHandler: { (channels, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                
                return
            }
            
            DispatchQueue.main.async {
                if refresh {
                    self.channels.removeAll()
                }
                
                self.channels.append(contentsOf: channels ?? [])
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        })
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

extension GroupChannelHiddenChannelsViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelTableViewCell") as! GroupChannelHiddenChannelTableViewCell
        let channel = self.channels[indexPath.row]
        
        cell.channelNameLabel.text = Utils.createGroupChannelName(channel: channel)
        
        let lastMessageDateFormatter = DateFormatter()
        var lastMessageDate: Date?
        
        if let lastUpdatedTimestamp = channel.lastMessage?.createdAt {
            if String(lastUpdatedTimestamp).count == 10 {
                lastMessageDate = Date(timeIntervalSince1970: Double(lastUpdatedTimestamp))
            }
            else {
                lastMessageDate = Date(timeIntervalSince1970: Double(lastUpdatedTimestamp) / 1000.0)
            }
            
            let currDate = Date()
            
            let lastMessageDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: lastMessageDate!)
            let currDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: currDate)
            
            if lastMessageDateComponents.year != currDateComponents.year || lastMessageDateComponents.month != currDateComponents.month || lastMessageDateComponents.day != currDateComponents.day {
                lastMessageDateFormatter.dateStyle = .short
                lastMessageDateFormatter.timeStyle = .none
                cell.lastUpdatedDateLabel.text = lastMessageDateFormatter.string(from: lastMessageDate!)
            }
            else {
                lastMessageDateFormatter.dateStyle = .none
                lastMessageDateFormatter.timeStyle = .short
                cell.lastUpdatedDateLabel.text = lastMessageDateFormatter.string(from: lastMessageDate!)
            }
        }
        
       
        
        cell.lastMessageLabel.isHidden = false
        
        if let lastMessage = channel.lastMessage as? SBDUserMessage {
            cell.lastMessageLabel.text = lastMessage.message
        }else if let lastMessage = channel.lastMessage as? SBDFileMessage {
            if lastMessage.type.hasPrefix("image") {
                cell.lastMessageLabel.text = "(Image)"
            }
            else if lastMessage.type.hasPrefix("video") {
                cell.lastMessageLabel.text = "(Video)"
            }
            else if lastMessage.type.hasPrefix("audio") {
                cell.lastMessageLabel.text = "(Audio)"
            }
            else {
                cell.lastMessageLabel.text = "(File)"
            }
        }
        else {
            cell.lastMessageLabel.text = ""
        }
        
        if channel.memberCount <= 2 {
            cell.memberCountContainerView.isHidden = true
        }
        else {
            cell.memberCountContainerView.isHidden = false
            cell.memberCountLabel.text = String(channel.memberCount)
        }
        
        DispatchQueue.main.async {
            if let updateCell = tableView.cellForRow(at: indexPath) as? GroupChannelHiddenChannelTableViewCell, let members = channel.members as? [SBDMember] {
                if let coverUrl = channel.coverUrl {
                    if coverUrl.count > 0 && !coverUrl.hasPrefix("https://sendbird.com/main/img/cover/") {
                        updateCell.profileImagView.setImage(withCoverUrl: coverUrl)
                    }
                    else {
                        updateCell.profileImagView.users = members
                        updateCell.profileImagView.makeCircularWithSpacing(spacing: 1)
                    }
                }
            }
        }
        
        if self.channels.count > 0 && indexPath.row == self.channels.count - 1 {
            self.loadChannelListNextPage(false)
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.channels.count == 0 && self.toastCompleted {
            self.emptyLabel.isHidden = false
        }
        else {
            self.emptyLabel.isHidden = true
        }
        
        return self.channels.count
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let unhideAction = UIAlertAction(title: "Unhide", style: .default) { (action) in
            self.channels[indexPath.row].unhideChannel(completionHandler: { (error) in
                if let error = error {
                    Utils.showAlertController(error: error, viewController: self)
                    return
                }
                DispatchQueue.main.async {
                    self.showToast(message: "Unhidden", completion: {
                        if self.channels.count == 0 && self.toastCompleted {
                            self.emptyLabel.isHidden = false
                        }
                        else {
                            self.emptyLabel.isHidden = true
                        }
                    })
                    
                    self.channels.remove(at: indexPath.row)
                    self.tableView.reloadData()
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let ac = Utils.createAlertController(title: "Unhide", message: "Unhide this channel?", actions: [unhideAction, cancelAction])
        
        self.present(ac, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let leaveAction: UIContextualAction = UIContextualAction.init(style: .destructive, title: "Leave") { (action, sourceView, completionHandler) in
            self.channels[indexPath.row].leave(completionHandler: { (error) in
                if let error = error {
                    Utils.showAlertController(error: error, viewController: self)
                    return
                }
                self.showToast(message: "Deleted", completion: nil)
            })
            
            completionHandler(true)
        }
        leaveAction.backgroundColor = UIColor(named: "color_leave_group_channel_bg")
        
        return UISwipeActionsConfiguration(actions: [leaveAction])
    }
    
}
