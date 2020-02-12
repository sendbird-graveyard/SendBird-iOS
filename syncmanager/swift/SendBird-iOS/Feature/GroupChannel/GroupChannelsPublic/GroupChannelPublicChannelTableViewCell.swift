//
//  GroupChannelPublicChannelTableViewCell.swift
//  SendBird-iOS
//
//  Created by Minhyuk Kim on 01/08/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import FLAnimatedImage
import SendBirdSDK

class GroupChannelPublicChannelTableViewCell: UITableViewCell {
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var memberCountContainerView: UIView!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var lastUpdatedDateLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var profileImagView: ProfileImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
