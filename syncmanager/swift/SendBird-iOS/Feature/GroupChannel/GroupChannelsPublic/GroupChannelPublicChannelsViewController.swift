//
//  GroupChannelPublicChannelsViewController.swift
//  SendBird-iOS
//
//  Created by Minhyuk Kim on 01/08/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

//TODO: Merge with GroupChannelHiddenChannelsViewController
class GroupChannelPublicChannelsViewController: UIViewController {
    
    @IBOutlet weak var loadingIndicatorView: CustomActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var refreshControl: UIRefreshControl?
    
    var channelListQuery: SBDPublicGroupChannelListQuery?
    var channels: [SBDGroupChannel] = []
    
    var password: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Public Channels"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshChannelList), for: .valueChanged)
        
        self.tableView.refreshControl = self.refreshControl
        
        self.hideLoadingIndicatorView()
        self.view.bringSubviewToFront(self.loadingIndicatorView)
        
        self.loadChannelListNextPage(true)
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
            self.channelListQuery = SBDGroupChannel.createPublicGroupChannelListQuery()
            self.channelListQuery?.order = .chronological
            self.channelListQuery?.limit = 20
            self.channelListQuery?.includeEmptyChannel = true
            self.channelListQuery?.publicMembershipFilter = .all
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
            let filteredChannels = channels?.filter({
                if let userId = SBDMain.getCurrentUser()?.userId, $0.hasMember(userId) {
                    return false
                }
                return true
            })
            
            DispatchQueue.main.async {
                if refresh {
                    self.channels.removeAll()
                }
                
                self.channels.append(contentsOf: filteredChannels ?? [])
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

extension GroupChannelPublicChannelsViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelTableViewCell") as! GroupChannelPublicChannelTableViewCell
        
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
            if let updateCell = tableView.cellForRow(at: indexPath) as? GroupChannelPublicChannelTableViewCell, let members = channel.members as? [SBDMember] {
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
        self.emptyLabel.isHighlighted = !(self.channels.count == 0)
        
        return self.channels.count
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let ac = Utils.createAlertController(title: "Join", message: "Join this channel?", actions: [])
        
        let joinAction = UIAlertAction(title: "Join", style: .default) { (action) in
            if let password = ac.textFields?.first?.text, self.channels[indexPath.row].isAccessCodeRequired {
                self.channels[indexPath.row].join(withAccessCode: password, completionHandler: { (error) in
                    if let error = error {
                        Utils.showAlertController(error: error, viewController: self)
                        return
                    }
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            } else {
                self.channels[indexPath.row].join(completionHandler: { (error) in
                    if let error = error {
                        Utils.showAlertController(error: error, viewController: self)
                        return
                    }
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        ac.addAction(joinAction)
        ac.addAction(cancelAction)
        
        if channels[indexPath.row].isAccessCodeRequired {
            let passwordTextField: (UITextField)->Void = { textField in
                textField.placeholder = "Enter password..."
            }
            ac.addTextField(configurationHandler: passwordTextField)
        }
        
        self.present(ac, animated: true, completion: nil)
    }
}
