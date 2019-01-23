//
//  SettingsSectionTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/17/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit

class SettingsSectionTableViewCell: UITableViewCell {
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var topBorderView: UIView!
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
