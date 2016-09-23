//
//  OpenChannelListTableViewCell.swift
//  SampleUI
//
//  Created by Jed Kyung on 8/19/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import AlamofireImage

class OpenChannelListTableViewCell: UITableViewCell {
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var channelNameLabel: UILabel!
    
    var channel: SBDOpenChannel?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
        return UINib.init(nibName: NSStringFromClass(self).components(separatedBy: ".").last!, bundle: Bundle(for: self));
    }

    static func cellReuseIdentifier() -> String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    func setModel(_ aChannel: SBDOpenChannel) {
        self.channel = aChannel
        self.coverImageView.af_setImage(withURL: URL.init(string: self.channel!.coverUrl!)!)
        self.channelNameLabel.text = self.channel!.name
    }
    
    override func draw(_ rect: CGRect) {
        self.coverImageView.layer.cornerRadius = 16
        self.coverImageView.clipsToBounds = true
    }
}
