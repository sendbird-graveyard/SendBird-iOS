//
//  SelectedUserListCollectionViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/10/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import AlamofireImage

class SelectedUserListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    private var user: SBDUser!
    
    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    
    func setModel(aUser: SBDUser) {
        self.user = aUser
        
        if let url = self.user.profileUrl, !url.isEmpty {
            self.profileImageView.af_setImage(withURL: URL(string: self.user.profileUrl!)!, placeholderImage:UIImage(named: "img_profile"))
        }
        else {
            self.profileImageView.image = UIImage(named: "img_profile")
        }
        self.nicknameLabel.text = self.user.nickname
    }
}
