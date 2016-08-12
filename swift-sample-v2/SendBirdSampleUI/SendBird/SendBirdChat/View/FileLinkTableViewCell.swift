//
//  FileLinkTableViewCell.swift
//  SendBirdSampleUI
//
//  Created by Jed Kyung on 2/3/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

import UIKit
import SendBirdSDK
import AFNetworking

class FileLinkTableViewCell: UITableViewCell {
    let kFileLinkTopMargin: CGFloat = 4.0
    let kFileLinkBottomMargin: CGFloat = 4.0
    let kFileLinkLeftMargin: CGFloat = 15.0
    let kFileLinkRightMargin: CGFloat = 15.0
    let kFileLinkFileNameFontSize: CGFloat = 10.0
    let kFileLinkMessageFontSize: CGFloat = 14.0
    let kFileLinkImageWidth: CGFloat = 180.0
    let kFileLinkImageHeight: CGFloat = 140.0
    let kFileLinkLeftBarWidth: CGFloat = 3
    let kFileLinkLMarginBetweenMessageAndImageInfo: CGFloat = 4
    let kFileLinkMarginBetweenLeftBarAndImage: CGFloat = 6.0
    let kFileLinkMarginBetweenFilenameAndImage: CGFloat = 6.0
    
    var fileLink: SendBirdFileLink?
    var messageLabel: UILabel?
    var fileImageView: UIImageView?
    var filenameLabel: UILabel?
    var filesizeLabel: UILabel?
    var leftBarView: UIView?

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
        
        self.messageLabel = UILabel()
        self.messageLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.messageLabel?.font = UIFont.systemFontOfSize(kFileLinkMessageFontSize)
        self.messageLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.messageLabel?.numberOfLines = 0
        
        self.fileImageView = UIImageView.init(image: UIImage.init(named: "_icon_file"))
        self.fileImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.fileImageView?.contentMode = UIViewContentMode.ScaleAspectFit
        
        self.filenameLabel = UILabel()
        self.filenameLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.filenameLabel?.font = UIFont.systemFontOfSize(kFileLinkFileNameFontSize)
        self.filenameLabel?.textColor = SendBirdUtils.UIColorFromRGB(0x595959)
        
        self.leftBarView = UIView()
        self.leftBarView?.translatesAutoresizingMaskIntoConstraints = false
        self.leftBarView?.backgroundColor = SendBirdUtils.UIColorFromRGB(0x000000)
        self.leftBarView?.alpha = 0.15
        
        self.contentView.addSubview(self.messageLabel!)
        self.contentView.addSubview(self.fileImageView!)
        self.contentView.addSubview(self.filenameLabel!)
        self.contentView.addSubview(self.leftBarView!)
        
        // Message Label
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: kFileLinkTopMargin))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: kFileLinkLeftMargin))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -kFileLinkRightMargin))
        
        // Left Bar View
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.leftBarView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: kFileLinkLeftMargin))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.leftBarView!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: -kFileLinkLMarginBetweenMessageAndImageInfo))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: leftBarView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kFileLinkLeftBarWidth))

        // File Name
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.messageLabel!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.filenameLabel!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: -kFileLinkLMarginBetweenMessageAndImageInfo))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.filenameLabel!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.leftBarView!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: kFileLinkMarginBetweenLeftBarAndImage))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.filenameLabel!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: kFileLinkRightMargin))
        
        // Image
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.fileImageView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.filenameLabel!, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: kFileLinkMarginBetweenFilenameAndImage))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.fileImageView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.leftBarView!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: kFileLinkMarginBetweenLeftBarAndImage))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.fileImageView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kFileLinkImageWidth))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.fileImageView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: kFileLinkImageHeight))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: self.fileImageView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.leftBarView!, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        
        // Content View
        self.addConstraint(NSLayoutConstraint.init(item: self.contentView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
    }
    
    func setModel(model: SendBirdFileLink) {
        self.fileLink = model
        self.messageLabel?.attributedText = self.buildMessage()
        self.filenameLabel?.text = self.fileLink?.fileInfo.name
        if ((self.fileLink?.fileInfo.type.hasPrefix("image")) != nil) {
            SendBirdUtils.loadImage(model.fileInfo.url, imageView: self.fileImageView!, width: kFileLinkImageWidth, height: kFileLinkImageHeight)
        }
    }
    
    func buildMessage() -> NSAttributedString {
        var fileLinkUrl: String = (self.fileLink?.fileInfo.url)!
        
        if (self.fileLink?.fileInfo.type.hasPrefix("image")) != nil {
            fileLinkUrl = ""
        }
        
        var message: String = String.init(format: "%@: %@", (self.fileLink?.sender.name)!, fileLinkUrl.stringByReplacingOccurrencesOfString(" ", withString: "\u{00A0}"))
        message = message.stringByReplacingOccurrencesOfString(" ", withString: "\u{00A0}")
        message = message.stringByReplacingOccurrencesOfString("-", withString: "\u{2011}")
        message = message.stringByReplacingOccurrencesOfString("/", withString: "\u{2215}")
        
        var badge: Int = 0
        if self.fileLink?.isOpMessage == true {
            message = String.init(format: "\u{00A0}\u{00A0}%@", message)
            badge = 2
        }
        
        let attributedMessage: NSMutableAttributedString = NSMutableAttributedString.init(string: message)
        let nameRange: NSRange = NSMakeRange(badge, (self.fileLink?.sender.name.characters.count)!)
        let messageRange: NSRange = NSMakeRange((self.fileLink?.sender.name.characters.count)! + badge, fileLinkUrl.characters.count + 2)
        
        attributedMessage.beginEditing()
        attributedMessage.setAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(kFileLinkMessageFontSize), NSForegroundColorAttributeName: SendBirdUtils.UIColorFromRGB(0x824096)], range: nameRange)
        attributedMessage.setAttributes([NSFontAttributeName: UIFont.systemFontOfSize(kFileLinkMessageFontSize), NSForegroundColorAttributeName: SendBirdUtils.UIColorFromRGB(0x595959)], range: messageRange)
        attributedMessage.endEditing()
        
        return attributedMessage
    }
    
    func getHeightOfViewCell(totalWidth: CGFloat) -> CGFloat {
        var messageWidth: CGFloat
        var filenameWidth: CGFloat
        var messageRect: CGRect
        var filenameRect: CGRect
        
        let attributedMessage: NSAttributedString = self.buildMessage()
        
        messageWidth = totalWidth - (kFileLinkLeftMargin + kFileLinkRightMargin)
        messageRect = attributedMessage.boundingRectWithSize(CGSizeMake(messageWidth, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)

        filenameWidth = totalWidth - (kFileLinkLeftMargin + kFileLinkRightMargin + kFileLinkLeftBarWidth)
        filenameRect = (self.filenameLabel?.attributedText?.boundingRectWithSize(CGSizeMake(filenameWidth, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil))!

        return messageRect.size.height + filenameRect.size.height + kFileLinkImageHeight + kFileLinkMarginBetweenFilenameAndImage + kFileLinkTopMargin + kFileLinkBottomMargin + kFileLinkLMarginBetweenMessageAndImageInfo
    }
}
