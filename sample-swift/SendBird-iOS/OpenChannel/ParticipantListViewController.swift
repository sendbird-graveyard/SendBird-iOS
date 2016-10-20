//
//  ParticipantListViewController.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/13/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class ParticipantListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var channel: SBDOpenChannel!
    
    private var query: SBDUserListQuery?
    private var participants: [SBDUser] = []
    private var refreshControl: UIRefreshControl?
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(ParticipantListTableViewCell.nib(), forCellReuseIdentifier: ParticipantListTableViewCell.cellReuseIdentifier())
        
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
            self.participants.removeAll()
            self.query = self.channel.createParticipantListQuery()
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
            
            for participant in users! {
                self.participants.append(participant)
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
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ParticipantListTableViewCell = tableView.dequeueReusableCell(withIdentifier: ParticipantListTableViewCell.cellReuseIdentifier()) as! ParticipantListTableViewCell
        
        cell.setModel(aUser: self.participants[indexPath.row])
        
        if self.participants.count > 0 && indexPath.row + 1 == self.participants.count {
            self.loadList(initial: false)
        }
        
        return cell
    }
}
