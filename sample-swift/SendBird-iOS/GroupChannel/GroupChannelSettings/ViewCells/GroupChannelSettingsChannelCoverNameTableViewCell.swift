//
//  GroupChannelSettingsChannelCoverNameTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/16/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class GroupChannelSettingsChannelCoverNameTableViewCell: UITableViewCell {

    weak var delegate: GroupChannelSettingsTableViewCellDelegate?
    
    @IBOutlet weak var coverImageContainerView: UIView!
    @IBOutlet weak var channelNameTextField: UITextField!
    
    @IBOutlet weak var singleCoverImageContainerView: UIView!
    @IBOutlet weak var singleCoverImageView: UIImageView!
    
    @IBOutlet weak var doubleCoverImageContainerView: UIView!
    @IBOutlet weak var doubleCoverImageView1: UIImageView!
    @IBOutlet weak var doubleCoverImageView2: UIImageView!
    
    @IBOutlet weak var tripleCoverImageContainerView: UIView!
    @IBOutlet weak var tripleCoverImageView1: UIImageView!
    @IBOutlet weak var tripleCoverImageView2: UIImageView!
    @IBOutlet weak var tripleCoverImageView3: UIImageView!
    
    @IBOutlet weak var quadrupleCoverImageContainerView: UIView!
    @IBOutlet weak var quadrupleCoverImageView1: UIImageView!
    @IBOutlet weak var quadrupleCoverImageView2: UIImageView!
    @IBOutlet weak var quadrupleCoverImageView3: UIImageView!
    @IBOutlet weak var quadrupleCoverImageView4: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func clickEnableEditButton(_ sender: Any) {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(GroupChannelSettingsTableViewCellDelegate.willUpdateChannelNameAndCoverImage)) {
                delegate.willUpdateChannelNameAndCoverImage!()
            }
        }
    }
}
