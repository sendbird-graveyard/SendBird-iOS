//
//  CreateGroupChannelUserListTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/9/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import AlamofireImage

class CreateGroupChannelUserListTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    private var user: SBDUser!

    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    
    func setModel(aUser: SBDUser) {
        self.user = aUser
        self.profileImageView.af_setImage(withURL: URL(string: self.user.profileUrl!)!, placeholderImage:UIImage(named: "img_profile"))
        self.nicknameLabel.text = self.user.nickname
    }
    
    func setSelectedUser(selected: Bool) {
        if selected {
            self.checkImageView.image = UIImage(named: "btn_check_on")
        }
        else {
            self.checkImageView.image = UIImage(named: "btn_check_off")
        }
    }
}
