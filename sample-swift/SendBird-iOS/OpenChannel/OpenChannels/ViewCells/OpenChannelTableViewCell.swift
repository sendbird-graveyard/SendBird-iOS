//
//  OpenChannelTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/16/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit

class OpenChannelTableViewCell: UITableViewCell {
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var participantCountLabel: UILabel!
    @IBOutlet weak var operatorMarkImageView: UIImageView!
    
    var asOperator: Bool = false {
        didSet {
            if self.asOperator {
                self.operatorMarkImageView.image = UIImage(named: "img_icon_operator")
            }
            else {
                self.operatorMarkImageView.image = nil
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
