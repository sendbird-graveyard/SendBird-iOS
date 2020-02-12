//
//  SelectableUserTableViewCell.swift
//  SendBird-iOS
//
//  Created by Minhyuk Kim on 18/07/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class SelectableUserTableViewCell: UITableViewCell {

    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    var user: SBDUser?
    
    var selectedUser: Bool = false {
        didSet {
            let imageName = self.selectedUser ? "img_list_checked" : "img_list_unchecked"
            self.checkImageView.image = UIImage(named: imageName)
        }
    }
    
    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
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
