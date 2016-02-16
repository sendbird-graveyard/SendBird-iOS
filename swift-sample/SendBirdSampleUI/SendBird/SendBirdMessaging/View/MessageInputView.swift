//
//  MessageInputView.swift
//  SendBirdSampleUI
//
//  Created by Jed Kyung on 2/6/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

import UIKit
import SendBirdSDK

protocol MessageInputViewDelegate {
    func clickSendButton(message: String)
    func clickFileAttachButton()
    func clickChannelListButton()
}

class MessageInputView: UIView {
    let kMessageFontSize: CGFloat = 14.0
    let kMessageSendButtonFontSize: CGFloat = 11.0
    
    var topLineView: UIView?
    var messageTextField: UITextField?
    var sendButton: UIButton?
    var fileAttachButton: UIButton?
    var openChannelListButton: UIButton?
    
    var messageInputViewDelegate: MessageInputViewDelegate?
    var textFieldDelegate: UITextFieldDelegate?
    
    private var inputEnabled: Bool = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.inputEnabled = true
        
        self.backgroundColor = SendBirdUtils.UIColorFromRGB(0xffffff)
        
        self.topLineView = UIView()
        self.topLineView?.translatesAutoresizingMaskIntoConstraints = false
        self.topLineView?.backgroundColor = SendBirdUtils.UIColorFromRGB(0xbfbfbf)
        
        self.openChannelListButton = UIButton()
        self.openChannelListButton?.translatesAutoresizingMaskIntoConstraints = false
        self.openChannelListButton?.setImage(UIImage.init(named: "_btn_channel_list"), forState: UIControlState.Normal)
        self.openChannelListButton?.addTarget(nil, action: "clickChannelListButton", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.messageTextField = UITextField()
        self.messageTextField?.translatesAutoresizingMaskIntoConstraints = false
        self.messageTextField?.returnKeyType = UIReturnKeyType.Done
        self.messageTextField?.placeholder = "What\'s on your mind?"
        self.messageTextField?.textColor = SendBirdUtils.UIColorFromRGB(0x37434f)
        self.messageTextField?.attributedPlaceholder = NSAttributedString.init(string: "What\'s on your mind?", attributes: [NSForegroundColorAttributeName : SendBirdUtils.UIColorFromRGB(0xbbc3c9)])
        self.messageTextField?.font = UIFont.systemFontOfSize(kMessageFontSize)
        let paddingLeftView: UIView = UIView.init(frame: CGRectMake(0, 0, 8, 8))
        let paddingRightView: UIView = UIView.init(frame: CGRectMake(0, 0, 48, 8))
        self.messageTextField?.leftView = paddingLeftView
        self.messageTextField?.rightView = paddingRightView
        self.messageTextField?.leftViewMode = UITextFieldViewMode.Always
        self.messageTextField?.rightViewMode = UITextFieldViewMode.Always
        self.messageTextField?.layer.borderWidth = 1.0
        self.messageTextField?.layer.borderColor = SendBirdUtils.UIColorFromRGB(0xbbc3c9).CGColor
        self.messageTextField?.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        self.fileAttachButton = UIButton()
        self.fileAttachButton?.backgroundColor = UIColor.clearColor()
        self.fileAttachButton?.translatesAutoresizingMaskIntoConstraints = false
        self.fileAttachButton?.setImage(UIImage.init(named: "_sendbird_btn_upload_off"), forState: UIControlState.Normal)
        self.fileAttachButton?.setImage(UIImage.init(named: "_sendbird_btn_upload_on"), forState: UIControlState.Highlighted)
        self.fileAttachButton?.setImage(UIImage.init(named: "_sendbird_btn_upload_on"), forState: UIControlState.Selected)
        self.fileAttachButton?.addTarget(nil, action: "clickFileAttachButton", forControlEvents: UIControlEvents.TouchUpInside)
        self.fileAttachButton?.layer.borderWidth = 1.0
        self.fileAttachButton?.layer.borderColor = SendBirdUtils.UIColorFromRGB(0xbbc3c9).CGColor
        
        self.sendButton = UIButton()
        self.sendButton?.translatesAutoresizingMaskIntoConstraints = false
        self.sendButton?.setTitle("SEND", forState: UIControlState.Normal)
        self.sendButton?.titleLabel?.font = UIFont.boldSystemFontOfSize(kMessageSendButtonFontSize)
        self.sendButton?.setBackgroundImage(UIImage.init(named: "_btn_green"), forState: UIControlState.Normal)
        self.sendButton?.setBackgroundImage(UIImage.init(named: "_btn_green"), forState: UIControlState.Highlighted)
        self.sendButton?.setBackgroundImage(UIImage.init(named: "_btn_green"), forState: UIControlState.Selected)
        self.sendButton?.setBackgroundImage(UIImage.init(named: "_btn_white_line"), forState: UIControlState.Disabled)
        self.sendButton?.addTarget(self, action: "clickSendButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.sendButton?.alpha = 0
        self.sendButton?.enabled = false
        
        self.addSubview(self.openChannelListButton!)
        self.addSubview(self.messageTextField!)
        self.addSubview(self.fileAttachButton!)
        self.addSubview(self.sendButton!)
        self.addSubview(self.topLineView!)
        
        self.applyConstraints()
    }
    
    private func applyConstraints() {
        // Top Line View
        self.addConstraint(NSLayoutConstraint.init(item: self.topLineView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.topLineView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.topLineView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.topLineView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 1))
        
        // Channel List Button
        self.addConstraint(NSLayoutConstraint.init(item: self.openChannelListButton!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.openChannelListButton!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 10))
        self.addConstraint(NSLayoutConstraint.init(item: self.openChannelListButton!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.fileAttachButton!, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: -10))
        self.addConstraint(NSLayoutConstraint.init(item: self.openChannelListButton!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 15))
        
        // File Attach Button
        self.addConstraint(NSLayoutConstraint.init(item: self.fileAttachButton!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.fileAttachButton!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 28))
        self.addConstraint(NSLayoutConstraint.init(item: self.fileAttachButton!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 30))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageTextField!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.fileAttachButton!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -1))
        
        // Message TextField
        self.addConstraint(NSLayoutConstraint.init(item: self.messageTextField!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageTextField!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 30))
        self.addConstraint(NSLayoutConstraint.init(item: self.messageTextField!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -10))
        
        // Send Button
        self.addConstraint(NSLayoutConstraint.init(item: self.sendButton!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.sendButton!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -10))
        self.addConstraint(NSLayoutConstraint.init(item: self.sendButton!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        self.addConstraint(NSLayoutConstraint.init(item: self.sendButton!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 30))
    }
    
    func clickSendButton(sender: AnyObject) {
        if self.messageTextField?.text?.characters.count == 0 {
            return
        }
        self.messageInputViewDelegate?.clickSendButton((self.messageTextField?.text)!)
        SendBird.typeEnd()
    }
    
    func hideSendButton() {
        UILabel.beginAnimations(nil, context: nil)
        UILabel.setAnimationDuration(0.3)
        self.sendButton?.alpha = 0
        UILabel.commitAnimations()
        self.sendButton?.enabled = false
    }
    
    func showSendButton() {
        self.sendButton?.alpha = 1
        self.sendButton?.enabled = true
    }
    
    func clickFileAttachButton() {
        self.messageInputViewDelegate?.clickFileAttachButton()
    }
    
    func clickChannelListButton() {
        self.messageInputViewDelegate?.clickChannelListButton()
    }
    
    func hideKeyboard() {
        self.messageTextField?.endEditing(true)
    }
    
    func setDelegate(delegate: UITextFieldDelegate) {
        self.textFieldDelegate = delegate
        self.messageTextField?.delegate = delegate
    }
    
    func textFieldDidChange(textView: UITextView) {
        if textView.text.characters.count > 0 {
            if self.sendButton?.alpha == 0 {
                UILabel.beginAnimations(nil, context: nil)
                UILabel.setAnimationDuration(0.3)
                self.sendButton?.alpha = 1
                UILabel.commitAnimations()
                self.sendButton?.enabled = true
            }
            SendBird.typeStart()
        }
        else {
            UILabel.beginAnimations(nil, context: nil)
            UILabel.setAnimationDuration(0.3)
            self.sendButton?.alpha = 0
            UILabel.commitAnimations()
            self.sendButton?.enabled = false
            SendBird.typeEnd()
        }
    }
    
    func setInputEnable(enable: Bool) {
        self.fileAttachButton?.enabled = enable
        self.messageTextField?.enabled = enable
        self.sendButton?.enabled = enable
    }
    
    func isInputEnable() -> Bool {
        return self.inputEnabled
    }
}
