//
//  CreateOpenChannelViewControllerB.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/16/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import AlamofireImage

class CreateOpenChannelViewControllerB: UIViewController, SelectOperatorsDelegate, UITableViewDelegate, UITableViewDataSource, NotificationDelegate {
    var channelName: String?
    var coverImageData: Data?
    var channelUrl: String?
    var doneButtonItem: UIBarButtonItem?
    var selectedUsers: [String:SBDUser] = [:]
    
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorView: CustomActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Create Open Channel"
        self.navigationItem.largeTitleDisplayMode = .never
        let barButtonItemBack = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        let prevVC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2]
        prevVC?.navigationItem.backBarButtonItem = barButtonItemBack
        
        self.doneButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(CreateOpenChannelViewControllerB.clickDoneButton(_:)))
        self.navigationItem.rightBarButtonItem = self.doneButtonItem
        
        self.channelUrl = String(UUID().uuidString[..<String.Index(encodedOffset: 8)])
        
        self.activityIndicatorView.isHidden = true
        self.view.bringSubviewToFront(self.activityIndicatorView)
        
        self.tableView.register(UINib(nibName: "CreateOpenChannelChannelUrlTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateOpenChannelChannelUrlTableViewCell")
        self.tableView.register(UINib(nibName: "CreateOpenChannelOperatorSectionTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateOpenChannelOperatorSectionTableViewCell")
        self.tableView.register(UINib(nibName: "CreateOpenChannelAddOperatorTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateOpenChannelAddOperatorTableViewCell")
        self.tableView.register(UINib(nibName: "CreateOpenChannelCurrentUserTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateOpenChannelCurrentUserTableViewCell")
        self.tableView.register(UINib(nibName: "CreateOpenChannelOperatorTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateOpenChannelOperatorTableViewCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(CreateOpenChannelViewControllerB.keyboardWillShow(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CreateOpenChannelViewControllerB.keyboardDidHide(_:)), name: UIWindow.keyboardDidHideNotification, object: nil)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    @objc func clickDoneButton(_ sender: AnyObject) {
        self.activityIndicatorView.isHidden = false
        self.activityIndicatorView.startAnimating()
        var operatorIds: [String] = []
        operatorIds += self.selectedUsers.keys
        operatorIds.append((SBDMain.getCurrentUser()?.userId)!)
        let channelUrl = self.channelUrl
        SBDOpenChannel.createChannel(withName: self.channelName, channelUrl: channelUrl, coverImage: self.coverImageData!, coverImageName: "cover_image.jpg", data: nil, operatorUserIds: operatorIds, customType: nil, progressHandler: nil) { (channel, error) in
            if error != nil {
                self.activityIndicatorView.isHidden = true
                self.activityIndicatorView.stopAnimating()
                
                Utils.showAlertController(error: error!, viewController: self)
                
                return
            }
            
            if self.navigationController is CreateOpenChannelNavigationController {
                let nc = self.navigationController as! CreateOpenChannelNavigationController
                
                if let delegate = nc.createChannelDelegate {
                    delegate.didCreate!(channel!)
                }
            }
            
            channel?.enter(completionHandler: { (error) in
                self.activityIndicatorView.isHidden = true
                self.activityIndicatorView.stopAnimating()
                
                if error != nil {
                    Utils.showAlertController(error: error!, viewController: self)
                    
                    return
                }
                
                let vc = OpenChannelChatViewController.init(nibName: "OpenChannelChatViewController", bundle: nil) as OpenChannelChatViewController
                vc.channel = channel
                vc.hidesBottomBarWhenPushed = true
                guard let navigationController = self.navigationController else { return }
                vc.createChannelDelegate = (navigationController as! CreateOpenChannelNavigationController).createChannelDelegate
                navigationController.pushViewController(vc, animated: true)
            })
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrameBegin: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrameBeginRect = keyboardFrameBegin.cgRectValue
            DispatchQueue.main.async {
                self.bottomMargin.constant = keyboardFrameBeginRect.size.height - self.view.safeAreaInsets.bottom
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        DispatchQueue.main.async {
            self.bottomMargin.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - NotificationDelegate
    func openChat(_ channelUrl: String) {
        self.navigationController?.popViewController(animated: false)
        let cvc = UIViewController.currentViewController()
        if cvc is CreateOpenChannelViewControllerA {
            (cvc as! CreateOpenChannelViewControllerA).openChat(channelUrl)
        }
    }
    
    // MARK: - SelectOperatorsDelegate
    func didSelectUsers(_ users: [String : SBDUser]) {
        self.selectedUsers = users
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableView.automaticDimension
        }
        else if indexPath.row == 1 {
            return UITableView.automaticDimension
        }
        else {
            return 48
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row == 2 {
            let vc = SelectOperatorsViewController.init(nibName: "SelectOperatorsViewController", bundle: nil)
            vc.title = "Select an operator"
            vc.delegate = self
            vc.selectedUsers = self.selectedUsers
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedUsers.count + 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        if indexPath.row == 0 {
            if let channelUrlCell = tableView.dequeueReusableCell(withIdentifier: "CreateOpenChannelChannelUrlTableViewCell") as? CreateOpenChannelChannelUrlTableViewCell {
                channelUrlCell.channelUrlTextField.text = self.channelUrl
                channelUrlCell.channelUrlTextField.addTarget(self, action: #selector(CreateOpenChannelViewControllerB.channelUrlChanged(_:)), for: .editingChanged)
                
                cell = channelUrlCell
            }
        }
        else if indexPath.row == 1 {
            if let operatorSectionCell = tableView.dequeueReusableCell(withIdentifier: "CreateOpenChannelOperatorSectionTableViewCell") as? CreateOpenChannelOperatorSectionTableViewCell {
                cell = operatorSectionCell
            }
        }
        else if indexPath.row == 2 {
            if let addOperatorCell = tableView.dequeueReusableCell(withIdentifier: "CreateOpenChannelAddOperatorTableViewCell") as? CreateOpenChannelAddOperatorTableViewCell {
                cell = addOperatorCell
            }
        }
        else if indexPath.row == 3 {
            if let currentUserCell = tableView.dequeueReusableCell(withIdentifier: "CreateOpenChannelCurrentUserTableViewCell") as? CreateOpenChannelCurrentUserTableViewCell {
                currentUserCell.nicknameLabel.text = SBDMain.getCurrentUser()?.nickname
                DispatchQueue.main.async {
                    if let updateCell = tableView.cellForRow(at: indexPath) {
                        if updateCell is CreateOpenChannelCurrentUserTableViewCell {
                            if let url = URL(string: Utils.transformUserProfileImage(user: SBDMain.getCurrentUser()!)) {
                                (updateCell as! CreateOpenChannelCurrentUserTableViewCell).profileImageView.af_setImage(withURL: url, placeholderImage: Utils.getDefaultUserProfileImage(user: SBDMain.getCurrentUser()!))
                            }
                            else {
                                (updateCell as! CreateOpenChannelCurrentUserTableViewCell).profileImageView.image = Utils.getDefaultUserProfileImage(user: SBDMain.getCurrentUser()!)
                            }
                        }
                    }
                }
                
                if selectedUsers.count == 0 {
                    currentUserCell.bottomBorderView.isHidden = false
                }
                else {
                    currentUserCell.bottomBorderView.isHidden = true
                }
                
                cell = currentUserCell
            }
        }
        else {
            if let operatorCell = tableView.dequeueReusableCell(withIdentifier: "CreateOpenChannelOperatorTableViewCell") as? CreateOpenChannelOperatorTableViewCell {
                let op = Array(self.selectedUsers.values)[indexPath.row - 4]
                operatorCell.op = op
                operatorCell.nicknameLabel.text = op.nickname
                DispatchQueue.main.async {
                    if let updateCell = tableView.cellForRow(at: indexPath) {
                        if updateCell is CreateOpenChannelOperatorTableViewCell {
                            if let url = URL(string: Utils.transformUserProfileImage(user: op)) {
                                (updateCell as! CreateOpenChannelOperatorTableViewCell).profileImageView.af_setImage(withURL: url, placeholderImage: Utils.getDefaultUserProfileImage(user: op))
                            }
                            else {
                                (updateCell as! CreateOpenChannelOperatorTableViewCell).profileImageView.image = Utils.getDefaultUserProfileImage(user: op)
                            }
                        }
                    }
                }
                
                if self.selectedUsers.count - 1 == indexPath.row - 4 {
                    operatorCell.bottomBorderView.isHidden = false
                }
                else {
                    operatorCell.bottomBorderView.isHidden = true
                }
                
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(CreateOpenChannelViewControllerB.openOperatorActionSheet(_:)))
                operatorCell.addGestureRecognizer(longPress)
                
                cell = operatorCell
            }
        }
        
        return cell
    }
    
    @objc func channelUrlChanged(_ sender: AnyObject) {
        if sender is UITextField {
            let textField = sender as! UITextField
            self.channelUrl = textField.text
        }
    }
    
    @objc func openOperatorActionSheet(_ sender: UILongPressGestureRecognizer) {
        if sender.view is CreateOpenChannelOperatorTableViewCell {
            if let op = (sender.view as? CreateOpenChannelOperatorTableViewCell)!.op {
                let ac = UIAlertController(title: op.nickname, message: nil, preferredStyle: .actionSheet)
                let removeFromOperatorsAction = UIAlertAction(title: "Remove from operators", style: .destructive) { (action) in
                    DispatchQueue.main.async {
                        if let op = (sender.view as? CreateOpenChannelOperatorTableViewCell)!.op {
                            self.selectedUsers.removeValue(forKey: op.userId)
                            self.tableView.reloadData()
                        }
                    }
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                ac.addAction(removeFromOperatorsAction)
                ac.addAction(cancelAction)
                self.present(ac, animated: true, completion: nil)
            }
            
        }
    }
}
