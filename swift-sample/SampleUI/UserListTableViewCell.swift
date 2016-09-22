//
//  UserListTableViewCell.swift
//  SampleUI
//
//  Created by Jed Kyung on 8/24/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class UserListTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var profileImageView: UIImageView!
    @IBOutlet fileprivate weak var usernameLabel: UILabel!
    @IBOutlet fileprivate weak var onlineStatusLabel: UILabel!
    @IBOutlet fileprivate weak var lastSeenAtLabel: UILabel!
    
    fileprivate var user: SBDUser?

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
    
    func setModel(_ aUser: SBDUser) {
        self.user = aUser
        
        self.profileImageView.af_setImage(withURL: URL(string: (self.user?.profileUrl)!)!)
        self.usernameLabel.text = self.user?.nickname
        
        if self.user?.connectionStatus == SBDUserConnectionStatus.online {
            self.onlineStatusLabel.text = "Online"
            self.onlineStatusLabel.textColor = UIColor.green
        }
        else {
            self.onlineStatusLabel.text = "Offline"
            self.onlineStatusLabel.textColor = UIColor.gray
        }
        
        let date = Date(timeIntervalSince1970: Double((self.user?.lastSeenAt)!) / 1000)
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeStyle = DateFormatter.Style.short
        formatter.dateStyle = DateFormatter.Style.short
        formatter.timeZone = TimeZone.autoupdatingCurrent
        
        self.lastSeenAtLabel.text = formatter.string(from: date)
    }
    
    func setOnlineStatusVisiblility(_ visibility: Bool) {
        self.onlineStatusLabel.isHidden = !visibility
        self.lastSeenAtLabel.isHidden = !visibility
    }
    
    override func draw(_ rect: CGRect) {
        self.profileImageView.layer.cornerRadius = 16
        self.profileImageView.clipsToBounds = true
    }
}
