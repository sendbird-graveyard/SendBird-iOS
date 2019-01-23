//
//  OpenChannelSettingsMenuTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/1/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit

class OpenChannelSettingsMenuTableViewCell: UITableViewCell {
    @IBOutlet weak var settingMenuIconImageView: UIImageView!
    @IBOutlet weak var settingMenuLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
