//
//  OpenChannelListViewController.swift
//  SampleUI
//
//  Created by Jed Kyung on 8/19/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class OpenChannelListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    var channels: [SBDOpenChannel] = []
    var channelListQuery: SBDOpenChannelListQuery?
    var refreshControl: UIRefreshControl?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Open Channels"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(OpenChannelListViewController.createOpenChannel))
        
        self.loadingActivityIndicator.hidesWhenStopped = true;
        self.loadingActivityIndicator.stopAnimating()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(OpenChannelListTableViewCell.nib(), forCellReuseIdentifier: OpenChannelListTableViewCell.cellReuseIdentifier())
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(OpenChannelListViewController.refreshChannelList), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(self.refreshControl!)
        
        self.channelListQuery = SBDOpenChannel.createOpenChannelListQuery()
        
        self.loadChannels()
    }

    func createOpenChannel() {
        let alert = UIAlertController(title: "Create Open Channel", message: "Create open channel with name.", preferredStyle: UIAlertControllerStyle.alert)
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (action) in
            
        }
        let createAction = UIAlertAction(title: "Create", style: UIAlertActionStyle.default) { (action) in
            let nameTextField = alert.textFields![0]
            
            if nameTextField.text?.characters.count > 0 {
                DispatchQueue.main.async(execute: {
                    self.loadingActivityIndicator.isHidden = false
                    self.loadingActivityIndicator.startAnimating()
                })
                
                SBDOpenChannel.createChannel(withName: nameTextField.text, coverUrl: nil, data: nil, operatorUsers: [SBDMain.getCurrentUser()!], completionHandler: { (channel, error) in
                    if error != nil {
                        let alert = UIAlertController(title: "Error", message: String(format: "%lld: %@", error!.code, (error?.domain)!), preferredStyle: UIAlertControllerStyle.alert)
                        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(closeAction)
                        DispatchQueue.main.async(execute: {
                            self.present(alert, animated: true, completion: nil)
                            self.loadingActivityIndicator.stopAnimating()
                        })

                        return
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.channels.removeAll()
                        self.channelListQuery = SBDOpenChannel.createOpenChannelListQuery()
                        self.loadChannels()
                        self.loadingActivityIndicator.stopAnimating()
                    })
                })
            }
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter a channel name."
        }
        
        alert.addAction(closeAction)
        alert.addAction(createAction)
        
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    func refreshChannelList() {
        if self.channelListQuery != nil && self.channelListQuery?.isLoading() == true {
            self.refreshControl?.endRefreshing()
            return
        }
        
        self.channels.removeAll()
        self.tableView.reloadData()
        self.channelListQuery = SBDOpenChannel.createOpenChannelListQuery()
        self.loadChannels()
    }
    
    func loadChannels() {
        if self.channelListQuery?.isLoading() == true {
            return
        }
        
        if self.channelListQuery?.hasNext == false {
            return
        }
        
        self.channelListQuery?.loadNextPage(completionHandler: { (channels, error) in
            if error != nil {
                print("Channel list loading error: %@", error)
                if self.refreshControl?.isRefreshing == true {
                    self.refreshControl?.endRefreshing()
                }
                
                return
            }
            
            if channels == nil || channels!.count == 0 {
                return
            }
            
            for channel in channels! {
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
        tableView.deselectRow(at: indexPath, animated: false)
        let vc = OpenChannelViewController()
        vc.title = self.channels[(indexPath as NSIndexPath).row].name
        vc.senderId = SBDMain.getCurrentUser()?.userId
        vc.senderDisplayName = SBDMain.getCurrentUser()?.nickname
        vc.channel = self.channels[(indexPath as NSIndexPath).row]
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let channel = self.channels[(indexPath as NSIndexPath).row]
        let cell: OpenChannelListTableViewCell = (tableView.dequeueReusableCell(withIdentifier: OpenChannelListTableViewCell.cellReuseIdentifier()) as? OpenChannelListTableViewCell)!
        cell.setModel(channel)
        
        if self.channels.count > 0 {
            if (indexPath as NSIndexPath).row == self.channels.count - 1 {
                self.loadChannels()
            }
        }
        
        return cell
    }
}
