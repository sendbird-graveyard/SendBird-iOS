//
//  OpenChannelListViewController.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/13/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class OpenChannelListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CreateOpenChannelViewControllerDelegate {
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    private var refreshControl: UIRefreshControl?
    private var channels: [SBDOpenChannel] = []
    private var openChannelListQuery: SBDOpenChannelListQuery?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(OpenChannelListTableViewCell.nib(), forCellReuseIdentifier: OpenChannelListTableViewCell.cellReuseIdentifier())
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshChannelList), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(self.refreshControl!)
        
        let negativeLeftSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeLeftSpacer.width = -2
        let negativeRightSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeRightSpacer.width = -2
        
        let leftBackItem = UIBarButtonItem(image: UIImage(named: "btn_back"), style: UIBarButtonItemStyle.done, target: self, action: #selector(back))
        let rightCreateOpenChannelItem = UIBarButtonItem(image: UIImage(named: "btn_plus"), style: UIBarButtonItemStyle.done, target: self, action: #selector(createOpenChannel))
        
        self.navItem.leftBarButtonItems = [negativeLeftSpacer, leftBackItem]
        self.navItem.rightBarButtonItems = [negativeRightSpacer, rightCreateOpenChannelItem]
        
        self.refreshChannelList()
    }

    @objc private func refreshChannelList() {
        self.channels.removeAll()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        self.openChannelListQuery = SBDOpenChannel.createOpenChannelListQuery()
        self.openChannelListQuery?.limit = 20
        
        self.openChannelListQuery?.loadNextPage(completionHandler: { (channels, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                
                let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                vc.addAction(closeAction)
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: nil)
                }
                
                return
            }
            
            for channel in channels! {
                self.channels.append(channel)
            }
            
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        })
    }
    
    private func loadChannels() {
        if self.openChannelListQuery?.hasNext == false {
            return
        }
        
        self.openChannelListQuery?.loadNextPage(completionHandler: { (channels, error) in
            if error != nil {
                let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                vc.addAction(closeAction)
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: nil)
                }
                
                return
            }
            
            for channel in channels! {
                self.channels.append(channel)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    @objc private func back() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc private func createOpenChannel() {
        let vc = CreateOpenChannelViewController(nibName: "CreateOpenChannelViewController", bundle: Bundle.main)
        vc.delegate = self
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: CreateOpenChannelViewControllerDelegate
    func refreshView(vc: UIViewController) {
        self.refreshChannelList()
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.channels[indexPath.row].enter { (error) in
            if error != nil {
                let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                vc.addAction(closeAction)
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: nil)
                }
                
                return
            }
            
            let vc = OpenChannelChattingViewController(nibName: "OpenChannelChattingViewController", bundle: Bundle.main)
            vc.openChannel = self.channels[indexPath.row]
            DispatchQueue.main.async {
                self.present(vc, animated: false, completion: nil)
            }
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OpenChannelListTableViewCell.cellReuseIdentifier())
        
        (cell as! OpenChannelListTableViewCell).setModel(aChannel: self.channels[indexPath.row])
        (cell as! OpenChannelListTableViewCell).setRow(row: indexPath.row)
        
        if self.channels.count > 0 && indexPath.row + 1 == self.channels.count {
            self.loadChannels()
        }
        
        return cell!
    }
}
