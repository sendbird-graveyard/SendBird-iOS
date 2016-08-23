//
//  OpenChannelListViewController.swift
//  SampleUI
//
//  Created by Jed Kyung on 8/19/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class OpenChannelListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var channels: NSMutableArray?
    var channelListQuery: SBDOpenChannelListQuery?
    var refreshControl: UIRefreshControl?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Open Channels"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(OpenChannelListViewController.createOpenChannel))
        
        self.channels = NSMutableArray()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerNib(OpenChannelListTableViewCell.nib(), forCellReuseIdentifier: OpenChannelListTableViewCell.cellReuseIdentifier())
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(OpenChannelListViewController.refreshChannelList), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl!)
        
        self.channelListQuery = SBDOpenChannel.createOpenChannelListQuery()
        
        self.loadChannels()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createOpenChannel() {
        let alert = UIAlertController(title: "Create Open Channel", message: "Create open channel with name.", preferredStyle: UIAlertControllerStyle.Alert)
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (action) in
            
        }
        let createAction = UIAlertAction(title: "Create", style: UIAlertActionStyle.Default) { (action) in
            let nameTextField = alert.textFields![0]
            
            if nameTextField.text?.characters.count > 0 {
                dispatch_async(dispatch_get_main_queue(), { 
                    // TODO:
                })
                
                SBDOpenChannel.createChannelWithName(nameTextField.text, coverUrl: nil, data: nil, operatorUsers: [SBDMain.getCurrentUser()!], completionHandler: { (channel, error) in
                    if error != nil {
                        print("Error")
                        
                        dispatch_async(dispatch_get_main_queue(), { 
                            // TODO:
                        })
                        
                        return
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.channels?.removeAllObjects()
                        self.channelListQuery = SBDOpenChannel.createOpenChannelListQuery()
                        self.loadChannels()
                        // TODO:
                    })
                })
            }
        }
        
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Enter a channel name."
        }
        
        alert.addAction(closeAction)
        alert.addAction(createAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func refreshChannelList() {
        if self.channelListQuery != nil && self.channelListQuery?.isLoading() == true {
            self.refreshControl?.endRefreshing()
            return
        }
        
        self.channels?.removeAllObjects()
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
        
        self.channelListQuery?.loadNextPageWithCompletionHandler({ (channels, error) in
            if error != nil {
                print("Channel list loading error: %@", error)
                if self.refreshControl?.refreshing == true {
                    self.refreshControl?.endRefreshing()
                }
                
                return
            }
            
            if channels == nil || channels!.count == 0 {
                return
            }
            
            for channel in channels! {
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
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let vc = OpenChannelViewController()
        vc.title = self.channels?.objectAtIndex(indexPath.row).name
        vc.senderId = SBDMain.getCurrentUser()?.userId
        vc.senderDisplayName = SBDMain.getCurrentUser()?.nickname
        vc.channel = self.channels?.objectAtIndex(indexPath.row) as? SBDOpenChannel
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let channel = self.channels![indexPath.row]
        print(OpenChannelListTableViewCell.cellReuseIdentifier())
        let cell: OpenChannelListTableViewCell = (tableView.dequeueReusableCellWithIdentifier(OpenChannelListTableViewCell.cellReuseIdentifier()) as? OpenChannelListTableViewCell)!
        cell.setModel(channel as! SBDOpenChannel)
        
        return cell
    }
}
