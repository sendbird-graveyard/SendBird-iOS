//
//  SettingsViewController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/17/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import Photos
import AlamofireImage
import MobileCoreServices

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SettingsTableViewCellDelegate, SettingsTimePickerDelegate, UserProfileImageNameSettingDelegate, NotificationDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicatorView: CustomActivityIndicatorView!
    @IBOutlet weak var tableViewBottomMargin: NSLayoutConstraint!
    
    var isDoNotDisturbOn: Bool = true
    
    var startHour: Int32 = 0
    var startMin: Int32 = 0
    var startAmPm: String = "AM"
    var endHour: Int32 = 0
    var endMin: Int32 = 0
    var endAmPm: String = "PM"
    var startTimeShown: Bool = false
    var endTimeShown: Bool = false
    var showPreview: Bool = false
    var createDistinctChannel: Bool = true
    var showFromTimePicker: Bool = false
    var showToTimePicker: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Settings"
        self.navigationItem.largeTitleDisplayMode = .automatic
        
        self.tableView.register(UINib(nibName: "SettingsSectionTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsSectionTableViewCell")
        self.tableView.register(UINib(nibName: "SettingsProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsProfileTableViewCell")
        self.tableView.register(UINib(nibName: "SettingsSwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsSwitchTableViewCell")
        self.tableView.register(UINib(nibName: "SettingsTimeTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsTimeTableViewCell")
        self.tableView.register(UINib(nibName: "SettingsGeneralTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsGeneralTableViewCell")
        self.tableView.register(UINib(nibName: "SettingsSignOutTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsSignOutTableViewCell")
        self.tableView.register(UINib(nibName: "SettingsVersionTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsVersionTableViewCell")
        self.tableView.register(UINib(nibName: "SettingsDescriptionTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsDescriptionTableViewCell")
        self.tableView.register(UINib(nibName: "SettingsTimePickerTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsTimePickerTableViewCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 14, right: 0)
        
        if let value = UserDefaults.standard.object(forKey: Constants.ID_SHOW_PREVIEWS) {
            self.showPreview = value as! Bool
        }
        
        if let value = UserDefaults.standard.object(forKey: Constants.ID_CREATE_DISTINCT_CHANNEL) {
            self.createDistinctChannel = value as! Bool
        }
        
        self.view.bringSubviewToFront(self.loadingIndicatorView)
        self.loadingIndicatorView.isHidden = false
        self.loadingIndicatorView.startAnimating()
        
        SBDMain.getDoNotDisturb { (isDoNotDisturbOn, startHour, startMin, endHour, endMin, timezone, error) in
            DispatchQueue.main.async {
                self.loadingIndicatorView.isHidden = true
                self.loadingIndicatorView.stopAnimating()
            }
            
            UserDefaults.standard.set(startHour, forKey: "sendbird_dnd_start_hour")
            UserDefaults.standard.set(startMin, forKey: "sendbird_dnd_start_min")
            UserDefaults.standard.set(endHour, forKey: "sendbird_dnd_end_hour")
            UserDefaults.standard.set(endMin, forKey: "sendbird_dnd_end_min")
            UserDefaults.standard.set(isDoNotDisturbOn, forKey: "sendbird_dnd_on")
            UserDefaults.standard.synchronize()
            
            if error != nil {
                return
            }
            
            self.isDoNotDisturbOn = isDoNotDisturbOn
            if startHour < 12 {
                self.startHour = startHour
                self.startAmPm = "AM"
            }
            else {
                self.startHour = startHour - 12
                self.startAmPm = "PM"
            }
            
            self.startMin = startMin
            
            if endHour < 12 {
                self.endHour = endHour
                self.endAmPm = "AM"
            }
            else {
                self.endHour = endHour - 12
                self.endAmPm = "PM"
            }
            
            self.endMin = endMin
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                if let switchViewCell = self.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) {
                    (switchViewCell as! SettingsSwitchTableViewCell).switchButton.isOn = isDoNotDisturbOn
                }
            }
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

    // MARK: - NotificationDelegate
    func openChat(_ channelUrl: String) {
        (self.navigationController?.parent as! MainTabBarController).selectedIndex = 0
        if let cvc = UIViewController.currentViewController() {
            (cvc as! GroupChannelsViewController).openChat(channelUrl)
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 16
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        switch indexPath.row {
        case 0:
            let viewCell0 = tableView.dequeueReusableCell(withIdentifier: "SettingsSectionTableViewCell") as! SettingsSectionTableViewCell
            viewCell0.sectionLabel.text = ""
            viewCell0.topBorderView.isHidden = true
            viewCell0.bottomBorderView.isHidden = false
            cell = viewCell0
            break
        case 1:
            let viewCell1 = tableView.dequeueReusableCell(withIdentifier: "SettingsProfileTableViewCell") as! SettingsProfileTableViewCell
            viewCell1.nicknameLabel.text = SBDMain.getCurrentUser()?.nickname
            if SBDMain.getCurrentUser()?.nickname!.count == 0 {
                viewCell1.nicknameLabel.attributedText = NSAttributedString(string: "Please write your nickname", attributes: [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0, weight: .regular),
                    NSAttributedString.Key.foregroundColor: UIColor.gray as Any
                    ])
            }
            viewCell1.userIdLabel.text = SBDMain.getCurrentUser()?.userId
            DispatchQueue.main.async {
                if let updateCell = tableView.cellForRow(at: indexPath) {
                    if let url = URL(string: Utils.transformUserProfileImage(user: SBDMain.getCurrentUser()!)) {
                        (updateCell as! SettingsProfileTableViewCell).profileImageView.af_setImage(withURL: url, placeholderImage: Utils.getDefaultUserProfileImage(user: SBDMain.getCurrentUser()!))
                    }
                    else {
                        (updateCell as! SettingsProfileTableViewCell).profileImageView.image = Utils.getDefaultUserProfileImage(user: SBDMain.getCurrentUser()!)
                    }
                }
            }
            
            cell = viewCell1
            break
        case 2:
            let viewCell2 = tableView.dequeueReusableCell(withIdentifier: "SettingsSectionTableViewCell") as! SettingsSectionTableViewCell
            viewCell2.sectionLabel.text = "GROUP CHANNEL NOTIFICATIONS"
            viewCell2.topBorderView.isHidden = false
            viewCell2.bottomBorderView.isHidden = false
            
            cell = viewCell2
            break
        case 3:
            let viewCell3 = tableView.dequeueReusableCell(withIdentifier: "SettingsSwitchTableViewCell") as! SettingsSwitchTableViewCell
            viewCell3.settingsLabel.text = "Do Not Disturb"
            if self.isDoNotDisturbOn {
                viewCell3.bottomBorderView.isHidden = false
            }
            else {
                viewCell3.bottomBorderView.isHidden = true
            }
            
            viewCell3.switchIdentifier = Constants.ID_DO_NOT_DISTURB
            viewCell3.delegate = self
            
            cell = viewCell3
            break
        case 4:
            let viewCell4 = tableView.dequeueReusableCell(withIdentifier: "SettingsTimeTableViewCell") as! SettingsTimeTableViewCell
            viewCell4.settingLabel.text = "From"
            viewCell4.expandedTopBorderView.isHidden = true
            viewCell4.timeLabel.text = String(format: "%02d:%02d %@", self.startHour, self.startMin, self.startAmPm)
            if self.startTimeShown {
                viewCell4.bottomBorderView.isHidden = true
                viewCell4.expandedBottomBorderView.isHidden = false
                viewCell4.timeLabel.textColor = UIColor(named: "color_settings_time_label_highlighted")
            }
            else {
                viewCell4.bottomBorderView.isHidden = false
                viewCell4.expandedBottomBorderView.isHidden = true
                viewCell4.timeLabel.textColor = UIColor(named: "color_settings_time_label_normal")
            }
            
            if self.isDoNotDisturbOn {
                viewCell4.isHidden = false
            }
            else {
                viewCell4.isHidden = true
            }
            
            cell = viewCell4
        case 5:
            let viewCell5 = tableView.dequeueReusableCell(withIdentifier: "SettingsTimePickerTableViewCell") as! SettingsTimePickerTableViewCell
            viewCell5.delegate = self
            viewCell5.identifier = "START"
            viewCell5.timerPicker.selectRow(Int(self.startHour), inComponent: 1, animated: false)
            viewCell5.timerPicker.selectRow(Int(self.startMin), inComponent: 2, animated: false)
            if self.startAmPm == "AM" {
                viewCell5.timerPicker.selectRow(0, inComponent: 3, animated: false)
            }
            else {
                viewCell5.timerPicker.selectRow(1, inComponent: 3, animated: false)
            }
            
            cell = viewCell5
        case 6:
            let viewCell6 = tableView.dequeueReusableCell(withIdentifier: "SettingsTimeTableViewCell") as! SettingsTimeTableViewCell
            viewCell6.settingLabel.text = "To"
            viewCell6.bottomBorderView.isHidden = true
            viewCell6.timeLabel.text = String(format: "%02d:%02d %@", self.endHour, self.endMin, self.endAmPm)
            
            if self.startTimeShown {
                viewCell6.expandedTopBorderView.isHidden = false
            }
            else {
                viewCell6.expandedTopBorderView.isHidden = true
            }
            
            if self.endTimeShown {
                viewCell6.expandedBottomBorderView.isHidden = false
                viewCell6.timeLabel.textColor = UIColor(named: "color_settings_time_label_highlighted")
            }
            else {
                viewCell6.expandedBottomBorderView.isHidden = true
                viewCell6.timeLabel.textColor = UIColor(named: "color_settings_time_label_normal")
            }
            
            if self.isDoNotDisturbOn {
                viewCell6.isHidden = false
            }
            else {
                viewCell6.isHidden = true
            }
            
            cell = viewCell6
            
            break
        case 7:
            let viewCell7 = tableView.dequeueReusableCell(withIdentifier: "SettingsTimePickerTableViewCell") as! SettingsTimePickerTableViewCell
            viewCell7.delegate = self
            viewCell7.identifier = "END"
            viewCell7.timerPicker.selectRow(Int(self.endHour), inComponent: 1, animated: false)
            viewCell7.timerPicker.selectRow(Int(self.endMin), inComponent: 2, animated: false)
            if self.endAmPm == "AM" {
                viewCell7.timerPicker.selectRow(0, inComponent: 3, animated: false)
            }
            else {
                viewCell7.timerPicker.selectRow(1, inComponent: 3, animated: false)
            }
            
            cell = viewCell7
            
            break
        case 8:
            let viewCell8 = tableView.dequeueReusableCell(withIdentifier: "SettingsSectionTableViewCell") as! SettingsSectionTableViewCell
            viewCell8.sectionLabel.text = "DISTINCT GROUP CHANNEL"
            viewCell8.topBorderView.isHidden = false
            viewCell8.bottomBorderView.isHidden = false
            
            cell = viewCell8
            
            break
        case 9:
            let viewCell9 = tableView.dequeueReusableCell(withIdentifier: "SettingsSwitchTableViewCell") as! SettingsSwitchTableViewCell
            viewCell9.settingsLabel.text = "Create Distinct Channel"
            viewCell9.bottomBorderView.isHidden = true
            viewCell9.switchIdentifier = Constants.ID_CREATE_DISTINCT_CHANNEL
            viewCell9.switchButton.isOn = self.createDistinctChannel
            viewCell9.delegate = self
            
            cell = viewCell9
            
            break
        case 10:
            let viewCell10 = tableView.dequeueReusableCell(withIdentifier: "SettingsDescriptionTableViewCell") as! SettingsDescriptionTableViewCell
            
            cell = viewCell10
            
            break
        case 11:
            let viewCell11 = tableView.dequeueReusableCell(withIdentifier: "SettingsSectionTableViewCell") as! SettingsSectionTableViewCell
            viewCell11.sectionLabel.text = "BLOCKED USER LIST"
            viewCell11.topBorderView.isHidden = true
            viewCell11.bottomBorderView.isHidden = false
            
            cell = viewCell11
            
            break
        case 12:
            let viewCell12 = tableView.dequeueReusableCell(withIdentifier: "SettingsGeneralTableViewCell") as! SettingsGeneralTableViewCell
            viewCell12.settingLabel.text = "Blocked Users"
            
            cell = viewCell12
            
            break
        case 13:
            let viewCell13 = tableView.dequeueReusableCell(withIdentifier: "SettingsSectionTableViewCell") as! SettingsSectionTableViewCell
            viewCell13.sectionLabel.text = ""
            viewCell13.topBorderView.isHidden = false
            
            cell = viewCell13
            
            break
        case 14:
            let viewCell14 = tableView.dequeueReusableCell(withIdentifier: "SettingsSignOutTableViewCell") as! SettingsSignOutTableViewCell
            
            cell = viewCell14
            
            break
        case 15:
            let viewCell15 = tableView.dequeueReusableCell(withIdentifier: "SettingsVersionTableViewCell") as! SettingsVersionTableViewCell
            let path = Bundle.main.path(forResource: "Info", ofType: "plist")
            if path != nil {
                let infoDict = NSDictionary.init(contentsOfFile: path!)
                let sampleUIVersion = infoDict!["CFBundleShortVersionString"] as! String
                let version = String(format: "Sample UI v%@ / SDK v%@", sampleUIVersion, SBDMain.getSDKVersion())
                viewCell15.versionLabel.text = version
            }
            else {
                viewCell15.versionLabel.text = ""
            }
            
            cell = viewCell15
            
            break
        default:
            
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 20
        case 1:
            return 81
        case 2:
            return 56
        case 3:
            return 44
        case 4:
            if self.isDoNotDisturbOn {
                return 44
            }
            else {
                return 0
            }
        case 5:
            if self.isDoNotDisturbOn && self.startTimeShown {
                return 217
            }
            else {
                return 0
            }
        case 6:
            if self.isDoNotDisturbOn {
                return 44
            }
            else {
                return 0
            }
        case 7:
            if self.isDoNotDisturbOn && self.endTimeShown {
                return 217
            }
            else {
                return 0
            }
        case 8:
            return 50
        case 9:
            return 44
        case 10:
            return UITableView.automaticDimension
        case 11:
            return 50
        case 12:
            return 44
        case 13:
            return 36
        case 14:
            return 44
        case 15:
            return 44
        default:
            return UITableView.automaticDimension
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let vc = UpdateUserProfileViewController.init(nibName: "UpdateUserProfileViewController", bundle: nil)
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath.row == 4 {
            self.startTimeShown = !self.startTimeShown
            self.endTimeShown = false
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            if self.startTimeShown == false {
                self.setDoNotDisturbTime()
            }
        }
        else if indexPath.row == 6 {
            self.startTimeShown = false
            self.endTimeShown = !self.endTimeShown
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            if self.endTimeShown == false {
                self.setDoNotDisturbTime()
            }
        }
        else if indexPath.row == 12 {
            let vc = SettingsBlockedUserListViewController.init(nibName: "SettingsBlockedUserListViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath.row == 14 {
            let ac = UIAlertController(title: "Sign Out", message: "Do you want to sign out?", preferredStyle: .alert)
            let actionConfirmSignOut = UIAlertAction(title: "OK", style: .default) { (action) in
                SBDMain.unregisterPushToken(SBDMain.getPendingPushToken()!, completionHandler: { (response, error) in
                    
                })
                
                SBDMain.disconnect(completionHandler: {
                    self.dismiss(animated: true, completion: {
                        UserDefaults.standard.setValue(false, forKey: "sendbird_auto_login")
                        UserDefaults.standard.removeObject(forKey: "sendbird_dnd_start_hour")
                        UserDefaults.standard.removeObject(forKey: "sendbird_dnd_start_min")
                        UserDefaults.standard.removeObject(forKey: "sendbird_dnd_end_hour")
                        UserDefaults.standard.removeObject(forKey: "sendbird_dnd_end_min")
                        UserDefaults.standard.removeObject(forKey: "sendbird_dnd_on")
                        UserDefaults.standard.synchronize()
                        
                        UIApplication.shared.applicationIconBadgeNumber = 0
                    })
                })
            }
            let actionCancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            ac.addAction(actionConfirmSignOut)
            ac.addAction(actionCancelAction)
            
            self.present(ac, animated: true, completion: nil)
        }
    }
    
    // MARK: - SettingsTableViewCellDelegate
    func didChangeSwitchButton(isOn: Bool, identifier: String) {
        if identifier == Constants.ID_DO_NOT_DISTURB {
            self.isDoNotDisturbOn = isOn
            DispatchQueue.main.async {
                self.loadingIndicatorView.isHidden = false
                self.loadingIndicatorView.startAnimating()
                
                self.tableView.reloadData()
                
                let startHour24 = self.startAmPm == "AM" ? self.startHour : self.startHour + 12
                let endHour24 = self.endAmPm == "AM" ? self.endHour : self.endHour + 12
                
                UserDefaults.standard.set(startHour24, forKey: "sendbird_dnd_start_hour")
                UserDefaults.standard.set(self.startMin, forKey: "sendbird_dnd_start_min")
                UserDefaults.standard.set(endHour24, forKey: "sendbird_dnd_end_hour")
                UserDefaults.standard.set(self.endMin, forKey: "sendbird_dnd_end_min")
                UserDefaults.standard.set(self.isDoNotDisturbOn, forKey: "sendbird_dnd_on")
                UserDefaults.standard.synchronize()
                
                SBDMain.setDoNotDisturbWithEnable(isOn, startHour: startHour24, startMin: self.startMin, endHour: endHour24, endMin: self.endMin, timezone: TimeZone.current.identifier, completionHandler: { (error) in
                    DispatchQueue.main.async {
                        self.loadingIndicatorView.isHidden = true
                        self.loadingIndicatorView.stopAnimating()
                    }
                    
                    if error != nil {
                        return
                    }
                })
            }
        }
        else if identifier == Constants.ID_SHOW_PREVIEWS {
            UserDefaults.standard.set(isOn, forKey: Constants.ID_SHOW_PREVIEWS)
            UserDefaults.standard.synchronize()
            self.showPreview = isOn
        }
        else if identifier == Constants.ID_CREATE_DISTINCT_CHANNEL {
            UserDefaults.standard.set(isOn, forKey: Constants.ID_CREATE_DISTINCT_CHANNEL)
            UserDefaults.standard.synchronize()
            
            self.createDistinctChannel = isOn
        }
    }
    
    func setDoNotDisturbTime() {
        DispatchQueue.main.async {
            self.loadingIndicatorView.isHidden = false
            self.loadingIndicatorView.startAnimating()
            
            let startHour24 = self.startAmPm == "AM" ? self.startHour : self.startHour + 12
            let endHour24 = self.endAmPm == "AM" ? self.endHour : self.endHour + 12
            
            SBDMain.setDoNotDisturbWithEnable(true, startHour: startHour24, startMin: self.startMin, endHour: endHour24, endMin: self.endMin, timezone: TimeZone.current.identifier, completionHandler: { (error) in
                DispatchQueue.main.async {
                    self.loadingIndicatorView.isHidden = true
                    self.loadingIndicatorView.stopAnimating()
                }
                
                if error != nil {
                    return
                }
                
                UserDefaults.standard.set(startHour24, forKey: "sendbird_dnd_start_hour")
                UserDefaults.standard.set(self.startMin, forKey: "sendbird_dnd_start_min")
                UserDefaults.standard.set(endHour24, forKey: "sendbird_dnd_end_hour")
                UserDefaults.standard.set(self.endMin, forKey: "sendbird_dnd_end_min")
                UserDefaults.standard.set(true, forKey: "sendbird_dnd_on")
                UserDefaults.standard.synchronize()
            })
        }
    }
    
    // MARK: - SettingsTimePickerDelegate
    func didSetTime(timeValue: String, component: Int, identifier: String) {
        if identifier == "START" {
            if component == 1 {
                self.startHour = Int32(timeValue)!
            }
            else if component == 2 {
                self.startMin = Int32(timeValue)!
            }
            else if component == 3 {
                self.startAmPm = timeValue
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .none)
            }
        }
        else if identifier == "END" {
            if component == 1 {
                self.endHour = Int32(timeValue)!
            }
            else if component == 2 {
                self.endMin = Int32(timeValue)!
            }
            else if component == 3 {
                self.endAmPm = timeValue
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: 6, section: 0)], with: .none)
            }
        }
    }
    
    // MARK: - UserProfileImageNameSettingDelegate
    func didUpdateUserProfile() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
