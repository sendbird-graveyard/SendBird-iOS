//
//  ParticipantListViewController.swift
//  SampleUI
//
//  Created by Jed Kyung on 8/24/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class ParticipantListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var currentChannel: SBDOpenChannel?

    @IBOutlet fileprivate weak var tableView: UITableView!
    fileprivate var participants: [SBDUser] = []
    fileprivate var query: SBDUserListQuery?
    fileprivate var refreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Participants"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UserListTableViewCell.nib(), forCellReuseIdentifier: UserListTableViewCell.cellReuseIdentifier())
        
        self.query = self.currentChannel?.createParticipantListQuery()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(ParticipantListViewController.refreshParticipantList), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(self.refreshControl!)
        
        self.loadParticipants()
    }

    func refreshParticipantList() {
        if self.query != nil && self.query?.isLoading() == true {
            self.refreshControl?.endRefreshing()
            return
        }
        
        self.participants.removeAll()
        self.query = self.currentChannel?.createParticipantListQuery()
        self.loadParticipants()
    }
    
    func loadParticipants() {
        if self.query?.isLoading() == true {
            return
        }
        
        if self.query?.hasNext == false {
            return
        }
        
        self.query?.loadNextPage(completionHandler: { (participants, error) in
            if error != nil {
                if self.refreshControl?.isRefreshing == true {
                    self.refreshControl?.endRefreshing()
                }
                
                return
            }
            
            if participants == nil || participants!.count == 0 {
                if self.refreshControl?.isRefreshing == true {
                    self.refreshControl?.endRefreshing()
                }
                
                return
            }

            for user in participants! {
                self.participants.append(user)
            }
            
            DispatchQueue.main.async(execute: { 
                self.tableView.reloadData()
                if self.refreshControl?.isRefreshing == true {
                    self.refreshControl?.endRefreshing()
                }
            })
        })
        
        self.currentChannel?.refresh(completionHandler: { (error) in
            DispatchQueue.main.async(execute: { 
                self.title = String(format: "Participants(%lu)", (self.currentChannel?.participantCount)!)
            })
        })
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
        let user = self.participants[(indexPath as NSIndexPath).row]
        
        if user.userId == SBDMain.getCurrentUser()!.userId {
            return
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
        let blockUserAction = UIAlertAction(title: "Block user", style: UIAlertActionStyle.destructive) { (action) in
            SBDMain.blockUser(user, completionHandler: { (blockedUser, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(closeAction)
                    DispatchQueue.main.async(execute: { 
                        self.present(alert, animated: true, completion: nil)
                    })
                }
                else {
                    let alert = UIAlertController(title: "User Blocked", message: String(format: "%@ is blocked", blockedUser!.nickname!), preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(closeAction)
                    DispatchQueue.main.async(execute: {
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            })
        }
        
        alert.addAction(closeAction)
        alert.addAction(blockUserAction)
        
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = self.participants[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UserListTableViewCell.cellReuseIdentifier()) as! UserListTableViewCell
        
        cell.setModel(user)
        cell.setOnlineStatusVisiblility(false)
        
        if self.participants.count > 0 {
            if (indexPath as NSIndexPath).row == self.participants.count - 1 {
                self.loadParticipants()
            }
        }
        
        return cell
    }
}
