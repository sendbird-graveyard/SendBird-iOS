//
//  MemberTableViewCell.swift
//  SendBirdSampleUI
//
//  Created by Jed Kyung on 2/6/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

import UIKit
import SendBirdSDK

class MemberTableViewCell: UITableViewCell {
    
    var profileImageView: UIImageView?
    var nicknameLabel: UILabel?
    var seperateLineView: UIView?
    var checkImageView: UIImageView?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        self.profileImageView = UIImageView()
        self.profileImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.profileImageView?.clipsToBounds = true
        self.profileImageView?.layer.cornerRadius = 20
        self.profileImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        self.contentView.addSubview(self.profileImageView!)
        
        self.nicknameLabel = UILabel()
        self.nicknameLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.nicknameLabel?.font = UIFont.systemFontOfSize(14.0)
        self.nicknameLabel?.textColor = SendBirdUtils.UIColorFromRGB(0x3d3d3d)
        self.contentView.addSubview(self.nicknameLabel!)
        
        self.checkImageView = UIImageView()
        self.checkImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.checkImageView?.image = UIImage.init(named: "_check_member_off")
        self.addSubview(self.checkImageView!)
        
        self.seperateLineView = UIView()
        self.seperateLineView?.translatesAutoresizingMaskIntoConstraints = false
        self.seperateLineView?.backgroundColor = SendBirdUtils.UIColorFromRGB(0xc8c8c8)
        self.contentView.addSubview(self.seperateLineView!)
        
        self.applyConstraints()
    }
    
    private func applyConstraints() {
        // Profile ImageView
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.profileImageView!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.profileImageView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 12))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.profileImageView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.profileImageView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        
        // Nickname Label
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.nicknameLabel!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.nicknameLabel!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.profileImageView!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 14))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.nicknameLabel!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -12))
        
        // Check Image View
        self.addConstraint(NSLayoutConstraint.init(item: self.checkImageView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -12))
        self.addConstraint(NSLayoutConstraint.init(item: self.checkImageView!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        // Seperator Line View
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.seperateLineView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.seperateLineView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 66))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.seperateLineView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.seperateLineView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 0.5))
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.checkImageView?.image = UIImage.init(named: "_check_member_on")
        }
        else {
            self.checkImageView?.image = UIImage.init(named: "_check_member_off")
        }
    }
    
    func setModel(model: SendBirdAppUser, check: Bool) {
        if check {
            self.checkImageView?.hidden = false
        }
        else {
            self.checkImageView?.hidden = true
        }
        
        self.nicknameLabel?.text = model.nickname
        
        SendBirdUtils.loadImage(model.picture, imageView: self.profileImageView!, width: 40, height: 40)
    }
}
