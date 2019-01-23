//
//  SelectGroupChannelMemberTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/15/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class SelectGroupChannelMemberTableViewCell: UITableViewCell {
    var user: SBDUser?
    var selectedUser: Bool = false {
        didSet {
            if self.selectedUser {
                self.checkImageView.image = UIImage(named: "img_list_checked")
            }
            else {
                self.checkImageView.image = UIImage(named: "img_list_unchecked")
            }
        }
    }
    
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
