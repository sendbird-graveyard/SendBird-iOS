//
//  GroupChannelTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/12/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import FLAnimatedImage

class GroupChannelTableViewCell: UITableViewCell {
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
    
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var memberCountContainerView: UIView!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var lastUpdatedDateLabel: UILabel!
    @IBOutlet weak var notiOffIconImageView: UIImageView!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var unreadMessageCountContainerView: UIView!
    @IBOutlet weak var unreadMessageCountLabel: UILabel!
    @IBOutlet weak var typingIndicatorContainerView: UIView!
    @IBOutlet weak var typingIndicatorImageView: FLAnimatedImageView!
    @IBOutlet weak var typingIndicatorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        do {
            let path = Bundle.main.path(forResource: "loading_typing", ofType: "gif")!
            let gifData = try NSData(contentsOfFile: path) as Data
            let image = FLAnimatedImage(animatedGIFData: gifData)
            self.typingIndicatorImageView.animatedImage = image
            self.typingIndicatorContainerView.isHidden = true
            self.lastMessageLabel.isHidden = false
        }
        catch {
            
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
