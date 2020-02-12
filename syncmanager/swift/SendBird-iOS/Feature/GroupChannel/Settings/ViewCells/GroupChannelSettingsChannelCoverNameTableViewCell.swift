//
//  GroupChannelSettingsChannelCoverNameTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/16/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class GroupChannelSettingsChannelCoverNameTableViewCell: UITableViewCell {

    weak var delegate: GroupChannelSettingsTableViewCellDelegate?
    
    
    @IBOutlet weak var channelNameTextField: UITextField!
    
    @IBOutlet weak var profileImageView: ProfileImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func clickEnableEditButton(_ sender: Any) {
        self.delegate?.willUpdateChannelNameAndCoverImage()
        
    }
}
