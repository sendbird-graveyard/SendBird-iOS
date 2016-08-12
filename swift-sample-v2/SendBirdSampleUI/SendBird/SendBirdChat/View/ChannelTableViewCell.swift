//
//  ChannelTableViewCell.swift
//  SendBirdSampleUI
//
//  Created by Jed Kyung on 2/2/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

import UIKit
import SendBirdSDK

let kChannelUrlFontSize: CGFloat = 14.0
let kChannelMembersFontSize: CGFloat = 11.0
let kChannelCoverRadius: CGFloat = 19.0

class ChannelTableViewCell: UITableViewCell {
    var channelUrlLabel: UILabel?
    var memberCountLabel: UILabel?
    var coverImageView: UIImageView?
    var checkImageView: UIImageView?
    var bottomLineView: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.coverImageView = UIImageView()
        self.coverImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.coverImageView?.layer.cornerRadius = kChannelCoverRadius
        self.coverImageView?.clipsToBounds = true
        self.coverImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        self.addSubview(self.coverImageView!)
        
        self.channelUrlLabel = UILabel()
        self.channelUrlLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.channelUrlLabel?.font = UIFont.boldSystemFontOfSize(kChannelUrlFontSize)
        self.channelUrlLabel?.textColor = SendBirdUtils.UIColorFromRGB(0x414858)
        self.addSubview(self.channelUrlLabel!)
        
        self.memberCountLabel = UILabel()
        self.memberCountLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.memberCountLabel?.font = UIFont.systemFontOfSize(kChannelMembersFontSize)
        self.memberCountLabel?.textColor = SendBirdUtils.UIColorFromRGB(0xa6b0ba)
        self.addSubview(self.memberCountLabel!)
        
        self.checkImageView = UIImageView.init(image: UIImage.init(named: "_icon_check"))
        self.checkImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.checkImageView?.hidden = true
        self.addSubview(self.checkImageView!)
        
        self.bottomLineView = UIView()
        self.bottomLineView?.translatesAutoresizingMaskIntoConstraints = false
        self.bottomLineView?.backgroundColor = SendBirdUtils.UIColorFromRGB(0xd9d9d9)
        self.addSubview(self.bottomLineView!)
        
        // Cover Image View
        self.addConstraint(NSLayoutConstraint.init(item: self.coverImageView!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.coverImageView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 15))
        self.addConstraint(NSLayoutConstraint.init(item: self.coverImageView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 38))
        self.addConstraint(NSLayoutConstraint.init(item: self.coverImageView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 38))

        // Channel URL Label
        self.addConstraint(NSLayoutConstraint.init(item: self.channelUrlLabel!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 6))
        self.addConstraint(NSLayoutConstraint.init(item: self.channelUrlLabel!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.coverImageView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 15))
        self.addConstraint(NSLayoutConstraint.init(item: self.channelUrlLabel!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -46))
        
        // Member Count Label
        self.addConstraint(NSLayoutConstraint.init(item: self.memberCountLabel!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -6))
        self.addConstraint(NSLayoutConstraint.init(item: self.memberCountLabel!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.coverImageView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 15))
        self.addConstraint(NSLayoutConstraint.init(item: self.memberCountLabel!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -46))
        
        // Check Image View
        self.addConstraint(NSLayoutConstraint.init(item: self.checkImageView!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.checkImageView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -15))
        self.addConstraint(NSLayoutConstraint.init(item: self.checkImageView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 22))
        self.addConstraint(NSLayoutConstraint.init(item: self.checkImageView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 22))

        // Bottom Line View
        self.addConstraint(NSLayoutConstraint.init(item: self.bottomLineView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.bottomLineView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.coverImageView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 15))
        self.addConstraint(NSLayoutConstraint.init(item: self.bottomLineView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.bottomLineView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 1))

    }
    
    func setModel(model: SendBirdChannel?) {
        if model == nil {
            return
        }
        
        self.channelUrlLabel?.text = String.init(format: "#%@", SendBirdUtils.getChannelNameFromUrl((model?.url)!))
        if model?.memberCount <= 1 {
            self.memberCountLabel?.text = String.init(format: "%d MEMBER", (model?.memberCount)!)
        }
        else {
            self.memberCountLabel?.text = String.init(format: "%d MEMBERS", (model?.memberCount)!)
        }
        
        if SendBird.getCurrentChannel() != nil && SendBird.getCurrentChannel().channelId == model?.channelId {
            backgroundColor = SendBirdUtils.UIColorFromRGB(0xffffe2)
            self.checkImageView?.hidden = false
        }
        else {
            backgroundColor = UIColor.clearColor()
            self.checkImageView?.hidden = true
        }
        
        SendBirdUtils.loadImage((model?.coverUrl)!, imageView: self.coverImageView!, width: 38, height: 38)
    }
}
