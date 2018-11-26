//
//  MemberListViewController.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/13/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK


class MemberListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SBDChannelDelegate, SBDConnectionDelegate {
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    var channel: SBDGroupChannel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(MemberListTableViewCell.nib(), forCellReuseIdentifier: MemberListTableViewCell.cellReuseIdentifier())
        
        let negativeLeftSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeLeftSpacer.width = -2
        let leftCloseItem = UIBarButtonItem(image: UIImage(named: "btn_close"), style: UIBarButtonItemStyle.done, target: self, action: #selector(close))
        self.navItem.leftBarButtonItems = [negativeLeftSpacer, leftCloseItem]
        
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.channel.refresh { (error) in
            if error != nil {
                let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                vc.addAction(closeAction)
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: nil)
                }
                
                return
            }
        }
        
        DispatchQueue.main.async {
            self.navItem.title = String(format: Bundle.sbLocalizedStringForKey(key: "MemberListTitle"), Int(self.channel.memberCount))
            self.tableView.reloadData()
        }
    }
    
    @objc private func close() {
        self.dismiss(animated: false, completion: nil)
    }
    
    // MARK: GroupChannelChattingViewController
    func didStartReconnection() {
        
    }
    
    func didSucceedReconnection() {
        self.channel .refresh { (error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.navItem.title = String(format: Bundle.sbLocalizedStringForKey(key: "MemberListTitle"), Int(self.channel.memberCount))
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func didFailReconnection() {
        
    }
    
    // MARK: SBDChannelDelegate
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {

    }
    
    func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
        
    }
    
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {

    }
    
    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        DispatchQueue.main.async {
            self.navItem.title = String(format: Bundle.sbLocalizedStringForKey(key: "MemberListTitle"), Int(self.channel.memberCount))
            self.tableView.reloadData()
        }
    }
    
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        DispatchQueue.main.async {
            self.navItem.title = String(format: Bundle.sbLocalizedStringForKey(key: "MemberListTitle"), Int(self.channel.memberCount))
            self.tableView.reloadData()
        }
    }
    
    func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDBaseChannel, userWasMuted user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDBaseChannel, userWasUnmuted user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDBaseChannel, userWasBanned user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDBaseChannel, userWasUnbanned user: SBDUser) {
        
    }
    
    func channelWasFrozen(_ sender: SBDBaseChannel) {
        
    }
    
    func channelWasUnfrozen(_ sender: SBDBaseChannel) {
        
    }
    
    func channelWasChanged(_ sender: SBDBaseChannel) {
        DispatchQueue.main.async {
            self.navItem.title = String(format: Bundle.sbLocalizedStringForKey(key: "MemberListTitle"), Int(self.channel.memberCount))
            self.tableView.reloadData()
        }
    }
    
    func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        
    }
    
    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        
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
        return (self.channel.members?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: MemberListTableViewCell?

        cell = tableView.dequeueReusableCell(withIdentifier: MemberListTableViewCell.cellReuseIdentifier()) as! MemberListTableViewCell?
        cell?.setModel(aUser: self.channel.members![indexPath.row] as! SBDUser)
        
        return cell!
    }

}
