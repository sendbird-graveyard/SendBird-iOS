//
//  OpenChannelParticipantListViewController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/2/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import AlamofireImage

class OpenChannelParticipantListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NotificationDelegate {
    var channel: SBDOpenChannel?
    
    var participantListQuery: SBDUserListQuery?
    private var participants: [SBDUser] = []
    private var refreshControl: UIRefreshControl?
    
    @IBOutlet weak var participantsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Participants"
        self.navigationItem.largeTitleDisplayMode = .automatic
        let barButtonItemBack = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        guard let navigationController = self.navigationController else { return }
        let prevVC = navigationController.viewControllers[navigationController.viewControllers.count - 2]
        prevVC.navigationItem.backBarButtonItem = barButtonItemBack
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(OpenChannelParticipantListViewController.refreshParticipantList), for: .valueChanged)
        
        self.participantsTableView.register(UINib(nibName: "OpenChannelSettingsUserTableViewCell", bundle: nil), forCellReuseIdentifier: "OpenChannelSettingsUserTableViewCell")
        self.participantsTableView.refreshControl = self.refreshControl
        
        self.participantsTableView.delegate = self
        self.participantsTableView.dataSource = self
        
        self.loadParticipantListNextPage(refresh: true)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func refreshParticipantList() {
        self.loadParticipantListNextPage(refresh: true)
    }

    func loadParticipantListNextPage(refresh: Bool) {
        if refresh {
            self.participantListQuery = nil
        }
        
        guard let channel = self.channel else { return }
        if self.participantListQuery == nil {
            self.participantListQuery = channel.createParticipantListQuery()
            self.participantListQuery?.limit = 20
        }
        
        if self.participantListQuery?.hasNext == false {
            return
        }
        
        self.participantListQuery?.loadNextPage(completionHandler: { (users, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                return
            }
            
            DispatchQueue.main.async {
                if refresh {
                    self.participants.removeAll()
                }
                
                self.participants += users!
                self.participantsTableView.reloadData()
                
                self.refreshControl?.endRefreshing()
            }
        })
    }
    
    // MARK: - NotificationDelegate
    func openChat(_ channelUrl: String) {
        guard let navigationController = self.navigationController else { return }
        navigationController.popViewController(animated: false)
        if let cvc = UIViewController.currentViewController() {
            if cvc is OpenChannelSettingsViewController {
                (cvc as! OpenChannelSettingsViewController).openChat(channelUrl)
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if let userCell = tableView.dequeueReusableCell(withIdentifier: "OpenChannelSettingsUserTableViewCell") as? OpenChannelSettingsUserTableViewCell {
            let participant = self.participants[indexPath.row]
            userCell.nicknameLabel.text = participant.nickname
            userCell.user = participant
            
            cell = userCell
            
            DispatchQueue.main.async {
                if let updateCell = tableView.cellForRow(at: indexPath) as? OpenChannelSettingsUserTableViewCell {
                    if let url = URL(string: Utils.transformUserProfileImage(user: self.participants[indexPath.row])) {
                        updateCell.profileImageView.af_setImage(withURL: url, placeholderImage: Utils.getDefaultUserProfileImage(user: self.participants[indexPath.row]))
                    }
                    else {
                        updateCell.profileImageView.image = Utils.getDefaultUserProfileImage(user: self.participants[indexPath.row])
                    }
                }
            }
        }
        
        if self.participants.count > 0 && indexPath.row == self.participants.count - 1 {
            self.loadParticipantListNextPage(refresh: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.participants.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let participant = self.participants[indexPath.row]
        let vc = UserProfileViewController.init(nibName: "UserProfileViewController", bundle: nil)
        vc.user = participant
        DispatchQueue.main.async {
            guard let navigationController = self.navigationController else { return }
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}
