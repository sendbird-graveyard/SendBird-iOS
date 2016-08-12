//
//  MessagingFileMessageTableViewCell.swift
//  SendBirdSampleUI
//
//  Created by Jed Kyung on 2/7/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

import UIKit
import SendBirdSDK

class MessagingFileMessageTableViewCell: UITableViewCell {
    let kFileMessageTopMargin: CGFloat = 6.0
    let kFileMessageBottomMargin: CGFloat = 6.0
    let kFileMessageLeftMargin: CGFloat = 16.0
    let kFileMessageRightMargin: CGFloat = 16.0
    let kFileMessageMarginBetweenNameAndMessage: CGFloat = 8
    let kFileMessageNameWidth: CGFloat = 80.0
    let kFileMessageNameFontSize: CGFloat = 14.0
    let kFileMessageFileNameFontSize: CGFloat = 11.0
    let kFileMessageFileSizeFontSize: CGFloat = 11.0
    let kFileMessageMessageFontSize: CGFloat = 14.0
    let kFileMessageImageWidth: CGFloat = 31.5
    let kFileMessageImageHeight: CGFloat = 39.0
    
    var nicknameLabel: UILabel?
    var messageLabel: UILabel?
    var fileImageView: UIImageView?
    var filenameLabel: UILabel?
    var filesizeLabel: UILabel?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UIColor.clearColor()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        self.nicknameLabel = UILabel()
        self.nicknameLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.nicknameLabel?.font = UIFont.boldSystemFontOfSize(kFileMessageNameFontSize)
        self.nicknameLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.nicknameLabel?.numberOfLines = 0
        
        self.fileImageView = UIImageView.init(image: UIImage.init(named: "_icon_file"))
        self.fileImageView?.translatesAutoresizingMaskIntoConstraints = false
        
        self.filenameLabel = UILabel()
        self.filenameLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.filenameLabel?.font = UIFont.boldSystemFontOfSize(kFileMessageFileNameFontSize)
        self.filenameLabel?.textColor = SendBirdUtils.UIColorFromRGB(0x824096)
        
        self.filesizeLabel = UILabel()
        self.filesizeLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.filesizeLabel?.font = UIFont.systemFontOfSize(kFileMessageFileSizeFontSize)
        self.filesizeLabel?.textColor = SendBirdUtils.UIColorFromRGB(0x824096)
        
        self.contentView.addSubview(self.nicknameLabel!)
        self.contentView.addSubview(self.fileImageView!)
        self.contentView.addSubview(self.filenameLabel!)
        self.contentView.addSubview(self.filesizeLabel!)
        
        // Nickname Label
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.nicknameLabel!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: kFileMessageTopMargin))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.nicknameLabel!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kFileMessageNameWidth))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.nicknameLabel!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: kFileMessageLeftMargin))
        
        // File Icon
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.fileImageView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: kFileMessageTopMargin))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.fileImageView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.nicknameLabel!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: kFileMessageMarginBetweenNameAndMessage))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.fileImageView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kFileMessageImageWidth))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.fileImageView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kFileMessageImageHeight))
        
        // File Name
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.filenameLabel!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: kFileMessageTopMargin))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.filenameLabel!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.fileImageView!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: kFileMessageMarginBetweenNameAndMessage))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.filenameLabel!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -kFileMessageRightMargin))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.filenameLabel!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kFileMessageFileNameFontSize + 2))
        
        // File Size
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.filenameLabel!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.filesizeLabel!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.filesizeLabel!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.fileImageView!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: kFileMessageMarginBetweenNameAndMessage))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.filesizeLabel!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.filesizeLabel!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kFileMessageFileNameFontSize + 2))
        
        // Content View
        self.addConstraint(NSLayoutConstraint.init(item: self.contentView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
    }

    func setModel(model: SendBirdFileLink) {
        let fileSize: CGFloat = CGFloat((model.fileInfo?.size)!)
        let underlineAttribute: [String: AnyObject] = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        let nickname: NSAttributedString = NSAttributedString.init(string: model.sender!.name, attributes: underlineAttribute)
        self.nicknameLabel?.attributedText = nickname
        self.filenameLabel?.text = model.fileInfo.name
        self.filesizeLabel?.text = String.init(format: "%.2fMB", fileSize / 1024.0 / 1024.0)
    }
    
    func getHeightOfViewCell(totalWidth: CGFloat) -> CGFloat {
        var nameRect: CGRect?

        nameRect = self.nicknameLabel?.attributedText?.boundingRectWithSize(CGSizeMake(kFileMessageNameWidth, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        return max(kFileMessageImageHeight, nameRect!.size.height) + kFileMessageTopMargin + kFileMessageBottomMargin
    }
}
