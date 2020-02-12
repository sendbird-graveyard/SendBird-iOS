//
//  SelectedUserCollectioViewCell.swift
//  SendBird-iOS
//
//  Created by Jaesung Lee on 27/08/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import Kingfisher

class SelectedUserCollectionViewCell: UICollectionViewCell {
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
        let placeholderImage = UIImage(named: "img_profile")
        if let urlString = self.user.profileUrl, let url = URL(string: urlString) {
            self.profileImageView.kf.setImage(with: url, placeholder: placeholderImage)
        } else {
            self.profileImageView.image = placeholderImage
        }
        
        self.nicknameLabel.text = self.user.nickname
    }
}
