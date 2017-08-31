//
//  MemberListTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/10/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import AlamofireImage

class MemberListTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var onlineDateLabel: UILabel!
    
    private var user: SBDUser!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    
    func setModel(aUser: SBDUser) {
        self.user = aUser
        
        if self.user.profileUrl != nil {
            self.profileImageView.af_setImage(withURL: URL(string: self.user.profileUrl!)!, placeholderImage:UIImage(named: "img_profile"))
        }
        else {
            self.profileImageView.image = UIImage(named: "img_profile")
        }
        self.nicknameLabel.text = self.user.nickname
        
        if self.user.connectionStatus == SBDUserConnectionStatus.online {
            self.onlineDateLabel.text = "Online"
            self.onlineDateLabel.textColor = Constants.memberOnlineTextColor()
        }
        else {
            // Last seen at
            let lastMessageDateFormatter = DateFormatter()
            var lastMessageDate: Date?
            if String(format: "%lld", self.user.lastSeenAt).characters.count == 10 {
                lastMessageDate = Date(timeIntervalSince1970: Double(self.user.lastSeenAt))
            }
            else {
                lastMessageDate = Date(timeIntervalSince1970: Double(self.user.lastSeenAt) / 1000.0)
            }
            let currDate = Date()
            
            let lastMessageDateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: lastMessageDate! as Date)
            let currDateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: currDate as Date)
            
            if lastMessageDateComponents.year != currDateComponents.year || lastMessageDateComponents.month != currDateComponents.month || lastMessageDateComponents.day != currDateComponents.day {
                lastMessageDateFormatter.dateStyle = DateFormatter.Style.short
                lastMessageDateFormatter.timeStyle = DateFormatter.Style.none
                self.onlineDateLabel.text = lastMessageDateFormatter.string(from: lastMessageDate!)
            }
            else {
                lastMessageDateFormatter.dateStyle = DateFormatter.Style.none
                lastMessageDateFormatter.timeStyle = DateFormatter.Style.medium
                self.onlineDateLabel.text = lastMessageDateFormatter.string(from: lastMessageDate!)
            }
            
            self.onlineDateLabel.textColor = Constants.memberOfflineDateTextColor()
        }
    }
}
