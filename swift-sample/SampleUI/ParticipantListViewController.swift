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

    @IBOutlet private weak var tableView: UITableView!
    private var participants: [SBDUser] = []
    private var query: SBDUserListQuery?
    private var refreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Participants"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerNib(UserListTableViewCell.nib(), forCellReuseIdentifier: UserListTableViewCell.cellReuseIdentifier())
        
        self.query = self.currentChannel?.createParticipantListQuery()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(ParticipantListViewController.refreshParticipantList), forControlEvents: UIControlEvents.ValueChanged)
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
        
        self.query?.loadNextPageWithCompletionHandler({ (participants, error) in
            if error != nil {
                if self.refreshControl?.refreshing == true {
                    self.refreshControl?.endRefreshing()
                }
                
                return
            }
            
            if participants == nil || participants!.count == 0 {
                if self.refreshControl?.refreshing == true {
                    self.refreshControl?.endRefreshing()
                }
                
                return
            }

            for user in participants! {
                self.participants.append(user)
            }
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.tableView.reloadData()
                if self.refreshControl?.refreshing == true {
                    self.refreshControl?.endRefreshing()
                }
            })
        })
        
        self.currentChannel?.refreshWithCompletionHandler({ (error) in
            dispatch_async(dispatch_get_main_queue(), { 
                self.title = String(format: "Participants(%lu)", (self.currentChannel?.participantCount)!)
            })
        })
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
        let user = self.participants[indexPath.row]
        
        if user.userId == SBDMain.getCurrentUser()!.userId {
            return
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil)
        let blockUserAction = UIAlertAction(title: "Block user", style: UIAlertActionStyle.Destructive) { (action) in
            SBDMain.blockUser(user, completionHandler: { (blockedUser, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.Alert)
                    let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil)
                    alert.addAction(closeAction)
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
                else {
                    let alert = UIAlertController(title: "User Blocked", message: String(format: "%@ is blocked", blockedUser!.nickname!), preferredStyle: UIAlertControllerStyle.Alert)
                    let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil)
                    alert.addAction(closeAction)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
            })
        }
        
        alert.addAction(closeAction)
        alert.addAction(blockUserAction)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.participants.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let user = self.participants[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(UserListTableViewCell.cellReuseIdentifier()) as! UserListTableViewCell
        
        cell.setModel(user)
        cell.setOnlineStatusVisiblility(false)
        
        if self.participants.count > 0 {
            if indexPath.row == self.participants.count - 1 {
                self.loadParticipants()
            }
        }
        
        return cell
    }
}
