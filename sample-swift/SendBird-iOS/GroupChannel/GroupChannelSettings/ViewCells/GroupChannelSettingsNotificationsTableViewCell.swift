//
//  GroupChannelSettingsNotificationsTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/16/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit

class GroupChannelSettingsNotificationsTableViewCell: UITableViewCell {
    weak var delegate: GroupChannelSettingsTableViewCellDelegate?
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func clickSwitch(_ sender: Any) {
        guard let sw = sender as? UISwitch else { return }
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(GroupChannelSettingsTableViewCellDelegate.didChangeNotificationSwitchButton(isOn:))) {
                delegate.didChangeNotificationSwitchButton!(isOn: sw.isOn)
            }
        }
    }
}
