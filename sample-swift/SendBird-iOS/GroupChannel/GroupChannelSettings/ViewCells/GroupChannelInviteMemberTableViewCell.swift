//
//  GroupChannelInviteMemberTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/16/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class GroupChannelInviteMemberTableViewCell: UITableViewCell {
    var user: SBDUser?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    var selectedUser: Bool = false {
        didSet {
            if selectedUser {
                self.checkImageView.image = UIImage(named: "img_list_checked")
            }
            else {
                self.checkImageView.image = UIImage(named: "img_list_unchecked")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
