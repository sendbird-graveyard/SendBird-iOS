//
//  OpenChannelSettingsOperatorTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/1/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class OpenChannelSettingsOperatorTableViewCell: UITableViewCell {
    var user: SBDUser?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var bottomBorderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
