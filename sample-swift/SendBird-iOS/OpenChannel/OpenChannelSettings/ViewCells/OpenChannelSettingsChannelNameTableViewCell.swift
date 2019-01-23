//
//  OpenChannelSettingsChannelNameTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/1/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit

class OpenChannelSettingsChannelNameTableViewCell: UITableViewCell {
    weak var delegate: OpenChannelSettingsChannelNameTableViewCellDelegate?
    
    @IBOutlet weak var channelCoverImageView: UIImageView!
    @IBOutlet weak var channelNameTextField: UITextField!
    @IBOutlet weak var enableEditButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.channelCoverImageView.isUserInteractionEnabled = false
        self.channelNameTextField.isEnabled = false
        self.enableEditButton.addTarget(self, action: #selector(OpenChannelSettingsChannelNameTableViewCell.clickEnableEditButton), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func clickEnableEditButton() {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(OpenChannelSettingsChannelNameTableViewCellDelegate.didClickChannelCoverImageNameEdit)) {
                delegate.didClickChannelCoverImageNameEdit!()
            }
        }
    }
    
    func setEnableEditing(_ enable: Bool) {
        if enable {
            self.enableEditButton.isHidden = false
            self.enableEditButton.isEnabled = true
        }
        else {
            self.enableEditButton.isHidden = true
            self.enableEditButton.isEnabled = false
        }
    }
}
