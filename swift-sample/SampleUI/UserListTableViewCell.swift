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
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var onlineStatusLabel: UILabel!
    @IBOutlet private weak var lastSeenAtLabel: UILabel!
    
    private var user: SBDUser?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
        return UINib.init(nibName: NSStringFromClass(self).componentsSeparatedByString(".").last!, bundle: NSBundle(forClass: self));
    }
    
    static func cellReuseIdentifier() -> String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    func setModel(aUser: SBDUser) {
        self.user = aUser
        
        self.profileImageView.af_setImageWithURL(NSURL(string: (self.user?.profileUrl)!)!)
        self.usernameLabel.text = self.user?.nickname
        
        if self.user?.connectionStatus == SBDUserConnectionStatus.Online {
            self.onlineStatusLabel.text = "Online"
            self.onlineStatusLabel.textColor = UIColor.greenColor()
        }
        else {
            self.onlineStatusLabel.text = "Offline"
            self.onlineStatusLabel.textColor = UIColor.grayColor()
        }
        
        let date = NSDate(timeIntervalSince1970: Double((self.user?.lastSeenAt)!) / 1000)
        
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale.currentLocale()
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeZone = NSTimeZone.localTimeZone()
        
        self.lastSeenAtLabel.text = formatter.stringFromDate(date)
    }
    
    func setOnlineStatusVisiblility(visibility: Bool) {
        self.onlineStatusLabel.hidden = !visibility
        self.lastSeenAtLabel.hidden = !visibility
    }
    
    override func drawRect(rect: CGRect) {
        self.profileImageView.layer.cornerRadius = 16
        self.profileImageView.clipsToBounds = true
    }
}
