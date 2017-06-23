//
//  BlockedUserListViewController.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/13/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class BlockedUserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var baseChannel: SBDBaseChannel?
    
    private var query: SBDUserListQuery?
    private var blockedUsers: [SBDUser] = []
    private var refreshControl: UIRefreshControl?
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(BlockedUserListTableViewCell.nib(), forCellReuseIdentifier: BlockedUserListTableViewCell.cellReuseIdentifier())
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshList), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(self.refreshControl!)
        
        let negativeLeftSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeLeftSpacer.width = -2
        let leftCloseItem = UIBarButtonItem(image: UIImage(named: "btn_close"), style: UIBarButtonItemStyle.done, target: self, action: #selector(close))
        self.navItem.leftBarButtonItems = [negativeLeftSpacer, leftCloseItem]
        
        self.loadList(initial: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func refreshList() {
        self.loadList(initial: true)
    }
    
    private func loadList(initial: Bool) {
        if initial {
            self.blockedUsers.removeAll()
            self.query = SBDMain.createBlockedUserListQuery()
        }
        
        if self.query?.hasNext == false {
            return
        }
        
        self.query?.loadNextPage(completionHandler: { (users, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                
                return
            }
            
            for blockedUser in users! {
                self.blockedUsers.append(blockedUser)
            }
            
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
            
        })
    }
    
    @objc private func close() {
        self.dismiss(animated: false, completion: nil)
    }
    
    private func unblockUser(user: SBDUser) {
        let vc = UIAlertController(title: user.nickname, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let unblockUserAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "UnblockUserButton"), style: UIAlertActionStyle.default) { (action) in
            SBDMain.unblockUser(user, completionHandler: { (error) in
                if error != nil {
                    let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                    vc.addAction(closeAction)
                    DispatchQueue.main.async {
                        self.present(vc, animated: true, completion: nil)
                    }
                    
                    return
                }
                
                DispatchQueue.main.async {
                    self.refreshList()
                }
            })
        }
        let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
        vc.addAction(unblockUserAction)
        vc.addAction(closeAction)
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.unblockUser(user: self.blockedUsers[indexPath.row])
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.blockedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BlockedUserListTableViewCell = tableView.dequeueReusableCell(withIdentifier: BlockedUserListTableViewCell.cellReuseIdentifier()) as! BlockedUserListTableViewCell
        
        cell.setModel(aUser: self.blockedUsers[indexPath.row])
        
        if self.blockedUsers.count > 0 && indexPath.row + 1 == self.blockedUsers.count {
            self.loadList(initial: false)
        }
        
        return cell
    }
}
