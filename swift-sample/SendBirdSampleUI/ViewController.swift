//
//  ViewController.swift
//  SendBirdSampleUI
//
//  Created by Jed Kyung on 1/30/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

import UIKit
import SendBirdSDK

class ViewController: UIViewController, UITextFieldDelegate {
    var sendbirdLogoImageView: UIImageView?
    var sendbirdLabel: UILabel?
    var backgroundImageView: UIImageView?
    var sendbirdStartOpenChatButton: UIButton?
    var sendbirdStartMessaging: UIButton?
    var sendbirdMemberListButton: UIButton?
    var sendbirdMessagingChannelList: UIButton?
    var sendbirdBackFromMessaging: UIButton?
    var sendbirdChannelListButton: UIButton?
    var sendbirdLobbyMemberListButton: UIButton?
    var sendbirdMessagingChannelListButton: UIButton?
    var sendbirdUserNicknameLabel: UILabel?
    var sendbirdUserNicknameTextField: UITextField?
    
    private var messagingUserName: NSString?
    private var messagingUserId: NSString?
    private var messagingTargetUserId: NSString?
    private var startMessagingFromOpenChat: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initView() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.backgroundImageView = UIImageView(image: UIImage(named: "_sendbird_img_bg_default.jpg"))
        self.backgroundImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        self.backgroundImageView?.clipsToBounds = true
        self.view.addSubview(self.backgroundImageView!)
        
        // SendBird Logo
        self.sendbirdLogoImageView = UIImageView(image: UIImage(named: "_logo"))
        self.sendbirdLogoImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.sendbirdLogoImageView!)

        NSLog("Version: %@", SendBird.VERSION())
        self.sendbirdLabel = UILabel()
        self.sendbirdLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.sendbirdLabel?.text = NSString.init(format: "SendBird v%@", SendBird.VERSION()) as String
        self.sendbirdLabel?.textColor = UIColor.whiteColor()
        self.sendbirdLabel?.font = UIFont.init(name: "AmericanTypewriter-Bold", size: 28.0)
        self.sendbirdLabel?.hidden = true
        self.view.addSubview(self.sendbirdLabel!)
        
        // SendBird User Nickname Label
        self.sendbirdUserNicknameLabel = UILabel()
        self.sendbirdUserNicknameLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.sendbirdUserNicknameLabel?.text = "Enter your nickname."
        self.sendbirdUserNicknameLabel?.textColor = UIColor.whiteColor()
        self.sendbirdUserNicknameLabel?.font = UIFont.boldSystemFontOfSize(16.0)
        self.view.addSubview(self.sendbirdUserNicknameLabel!)
        
        // SendBird User Nickname
        self.sendbirdUserNicknameTextField = UITextField()
        self.sendbirdUserNicknameTextField?.translatesAutoresizingMaskIntoConstraints = false
        self.sendbirdUserNicknameTextField?.background = SendBirdUtils.imageFromColor(SendBirdUtils.UIColorFromRGB(0xE8EAF6))
        self.sendbirdUserNicknameTextField?.clipsToBounds = true
        self.sendbirdUserNicknameTextField?.layer.cornerRadius = 4.0
        var leftPaddingView: UIView?
        var rightPaddingView: UIView?
        leftPaddingView = UIView.init(frame: CGRectMake(0, 0, 12, 0))
        rightPaddingView = UIView.init(frame: CGRectMake(0, 0, 12, 0))
        self.sendbirdUserNicknameTextField?.leftView = leftPaddingView
        self.sendbirdUserNicknameTextField?.leftViewMode = UITextFieldViewMode.Always
        self.sendbirdUserNicknameTextField?.rightView = rightPaddingView
        self.sendbirdUserNicknameTextField?.rightViewMode = UITextFieldViewMode.Always
        self.sendbirdUserNicknameTextField?.placeholder = "Nickname"
        self.sendbirdUserNicknameTextField?.font = UIFont.systemFontOfSize(16.0)
        self.sendbirdUserNicknameTextField?.returnKeyType = UIReturnKeyType.Done
        self.sendbirdUserNicknameTextField?.delegate = self
        
        // Set Default User Nickname
        var USER_ID: NSString?
        var USER_NAME: NSString?
        
        USER_ID = SendBird.deviceUniqueID()
        USER_NAME = NSString.init(format: "User-%@", (USER_ID?.substringToIndex(5))!)
        self.sendbirdUserNicknameTextField?.text = USER_NAME as? String
        self.view.addSubview(self.sendbirdUserNicknameTextField!)
        
        // Start Open Chat Button
        self.sendbirdStartOpenChatButton = UIButton()
        self.sendbirdStartOpenChatButton?.translatesAutoresizingMaskIntoConstraints = false
        self.sendbirdStartOpenChatButton?.setBackgroundImage(SendBirdUtils.imageFromColor(SendBirdUtils.UIColorFromRGB(0xAB47BC)), forState: UIControlState.Normal)
        self.sendbirdStartOpenChatButton?.clipsToBounds = true
        self.sendbirdStartOpenChatButton?.layer.cornerRadius = 4.0
        self.sendbirdStartOpenChatButton?.addTarget(self, action:"clickSendBirdStartOpenChatButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.sendbirdStartOpenChatButton?.setTitle("OpenChat", forState: UIControlState.Normal)
        self.sendbirdStartOpenChatButton?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.sendbirdStartOpenChatButton?.titleLabel?.font = UIFont.boldSystemFontOfSize(16.0)
        self.view.addSubview(self.sendbirdStartOpenChatButton!)

        // Start Messaging Button
        self.sendbirdStartMessaging = UIButton()
        self.sendbirdStartMessaging?.translatesAutoresizingMaskIntoConstraints = false
        self.sendbirdStartMessaging?.setBackgroundImage(SendBirdUtils.imageFromColor(SendBirdUtils.UIColorFromRGB(0xAB47BC)), forState: UIControlState.Normal)
        self.sendbirdStartMessaging?.clipsToBounds = true
        self.sendbirdStartMessaging?.layer.cornerRadius = 4.0
        self.sendbirdStartMessaging?.addTarget(self, action:"clickSendBirdStartMessagingButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.sendbirdStartMessaging?.setTitle("Messaging", forState: UIControlState.Normal)
        self.sendbirdStartMessaging?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.sendbirdStartMessaging?.titleLabel?.font = UIFont.boldSystemFontOfSize(16.0)
        self.view.addSubview(self.sendbirdStartMessaging!)

        // Member List Button
        self.sendbirdMemberListButton = UIButton()
        self.sendbirdMemberListButton?.translatesAutoresizingMaskIntoConstraints = false
        self.sendbirdMemberListButton?.setBackgroundImage(SendBirdUtils.imageFromColor(SendBirdUtils.UIColorFromRGB(0xAB47BC)), forState: UIControlState.Normal)
        self.sendbirdMemberListButton?.clipsToBounds = true
        self.sendbirdMemberListButton?.layer.cornerRadius = 4.0
        self.sendbirdMemberListButton?.addTarget(self, action:"clickSendBirdMemberListButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.sendbirdMemberListButton?.setTitle("Member List", forState: UIControlState.Normal)
        self.sendbirdMemberListButton?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.sendbirdMemberListButton?.titleLabel?.font = UIFont.boldSystemFontOfSize(16.0)
        self.sendbirdMemberListButton?.hidden = true
        self.view.addSubview(self.sendbirdMemberListButton!)
        
        // Messaging Channel List Button
        self.sendbirdMessagingChannelListButton = UIButton()
        self.sendbirdMessagingChannelListButton?.translatesAutoresizingMaskIntoConstraints = false
        self.sendbirdMessagingChannelListButton?.setBackgroundImage(SendBirdUtils.imageFromColor(SendBirdUtils.UIColorFromRGB(0xAB47BC)), forState: UIControlState.Normal)
        self.sendbirdMessagingChannelListButton?.clipsToBounds = true
        self.sendbirdMessagingChannelListButton?.layer.cornerRadius = 4.0
        self.sendbirdMessagingChannelListButton?.addTarget(self, action:"clickSendBirdMessagingChannelListButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.sendbirdMessagingChannelListButton?.setTitle("Messaging Channel List", forState: UIControlState.Normal)
        self.sendbirdMessagingChannelListButton?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.sendbirdMessagingChannelListButton?.titleLabel?.font = UIFont.boldSystemFontOfSize(16.0)
        self.sendbirdMessagingChannelListButton?.hidden = true
        self.view.addSubview(self.sendbirdMessagingChannelListButton!)
        
        // Back From Messaging Button
        self.sendbirdBackFromMessaging = UIButton()
        self.sendbirdBackFromMessaging?.translatesAutoresizingMaskIntoConstraints = false
        self.sendbirdBackFromMessaging?.setBackgroundImage(SendBirdUtils.imageFromColor(SendBirdUtils.UIColorFromRGB(0x43A047)), forState: UIControlState.Normal)
        self.sendbirdBackFromMessaging?.clipsToBounds = true
        self.sendbirdBackFromMessaging?.layer.cornerRadius = 4.0
        self.sendbirdBackFromMessaging?.addTarget(self, action:"clickSendBirdBackFromMessaging:", forControlEvents: UIControlEvents.TouchUpInside)
        self.sendbirdBackFromMessaging?.setTitle("Back", forState: UIControlState.Normal)
        self.sendbirdBackFromMessaging?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.sendbirdBackFromMessaging?.titleLabel?.font = UIFont.boldSystemFontOfSize(16.0)
        self.sendbirdBackFromMessaging?.hidden = true
        self.view.addSubview(sendbirdBackFromMessaging!)
        
        self.setConstraints()
    }
    
    func setConstraints() {
        // Background Image
        self.view.addConstraint(NSLayoutConstraint.init(item: self.backgroundImageView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.backgroundImageView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.backgroundImageView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.backgroundImageView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        
        // SendBird Logo
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdLogoImageView!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdLogoImageView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 48))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdLogoImageView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 80))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdLogoImageView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 76.4))
        
        // SendBird Label
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdLabel!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.sendbirdLogoImageView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 8))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdLabel!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.sendbirdLogoImageView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        
        // SendBird User Nickname Label
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdUserNicknameLabel!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdUserNicknameLabel!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.sendbirdLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 20))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdUserNicknameLabel!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 220))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdUserNicknameLabel!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 36))
        
        // SendBird User Nickname TextField
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdUserNicknameTextField!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdUserNicknameTextField!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.sendbirdUserNicknameLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 4))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdUserNicknameTextField!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 220))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdUserNicknameTextField!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 36))
        
        // SendBird Start Open Chat Button
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdStartOpenChatButton!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdStartOpenChatButton!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.sendbirdUserNicknameTextField, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 40))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdStartOpenChatButton!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 220))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdStartOpenChatButton!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 36))
        
        // SendBird Start Messaging Button.
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdStartMessaging!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdStartMessaging!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.sendbirdStartOpenChatButton, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 12))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdStartMessaging!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 220))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdStartMessaging!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 36))
        
        // SendBird Member List Button
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdMemberListButton!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdMemberListButton!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.sendbirdUserNicknameTextField, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 40))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdMemberListButton!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 220))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdMemberListButton!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 36))

        // SendBird Messaging Channel List.
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdMessagingChannelListButton!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdMessagingChannelListButton!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.sendbirdMemberListButton, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 12))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdMessagingChannelListButton!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 220))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdMessagingChannelListButton!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 36))

        // Back From Messaging Button
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdBackFromMessaging!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdBackFromMessaging!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.sendbirdMessagingChannelListButton, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 12))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdBackFromMessaging!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 220))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.sendbirdBackFromMessaging!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 36))
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startMessagingWithUser:", name: "open_messaging", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.startMessagingFromOpenChat == true {
            let viewController: MessagingTableViewController = MessagingTableViewController()
            viewController.setViewMode(kMessagingViewMode)
            viewController.initChannelTitle()
            viewController.channelUrl = ""
            viewController.userName = self.messagingUserName
            viewController.userId = self.messagingUserId
            viewController.targetUserId = self.messagingTargetUserId

            let navigationController: UINavigationController = UINavigationController.init(rootViewController: viewController)
            self.presentViewController(navigationController, animated: true, completion: nil)
        }
        
        self.startMessagingFromOpenChat = false
    }
    
    private func startMessagingWithUser(obj: NSNotification) {
        self.messagingTargetUserId = obj.object as! String
        self.startMessagingFromOpenChat = true
    }
    
    func clickSendBirdStartOpenChatButton(sender: AnyObject) {
        NSLog("clickSendBirdStartOpenChatButton")
        if self.sendbirdUserNicknameTextField?.text?.characters.count > 0 {
            self.startSendBird((self.sendbirdUserNicknameTextField?.text)!, chatMode: kChatModeChatting, viewMode: kChannelListViewMode)
        }
    }
    
    func clickSendBirdStartMessagingButton(sender: AnyObject) {
        NSLog("clickSendBirdStartMessagingButton")
        self.sendbirdStartOpenChatButton?.hidden = true
        self.sendbirdStartMessaging?.hidden = true
        self.sendbirdMemberListButton?.hidden = false
        self.sendbirdMessagingChannelListButton?.hidden = false
        self.sendbirdBackFromMessaging?.hidden = false
    }
    
    func clickSendBirdMemberListButton(sender: AnyObject) {
        NSLog("clickSendBirdMemberListButton")
        if self.sendbirdUserNicknameTextField?.text?.characters.count > 0 {
            self.startSendBird((self.sendbirdUserNicknameTextField?.text)!, chatMode: kChatModeMessaging, viewMode: kMessagingMemberViewMode)
        }
    }
    
    func clickSendBirdMessagingChannelListButton(sender: AnyObject) {
        NSLog("clickSendBirdMessagingChannelListButton")
        if self.sendbirdUserNicknameTextField?.text?.characters.count > 0 {
            self.startSendBird((self.sendbirdUserNicknameTextField?.text)!, chatMode: kChatModeMessaging, viewMode: kMessagingChannelListViewMode)
        }
    }
    
    func clickSendBirdBackFromMessaging(sender: AnyObject) {
        NSLog("clickSendBirdBackFromMessaging")
        self.sendbirdStartOpenChatButton?.hidden = false
        self.sendbirdStartMessaging?.hidden = false
        self.sendbirdMemberListButton?.hidden = true
        self.sendbirdMessagingChannelListButton?.hidden = true
        self.sendbirdBackFromMessaging?.hidden = true
    }
    
    private func startSendBird(userName: String, chatMode: Int, viewMode: Int) {
        let USER_ID: String = SendBird.deviceUniqueID()
        let USER_NAME: String = userName
        
        self.messagingUserName = USER_NAME
        self.messagingUserId = USER_ID
        
        if chatMode == kChatModeChatting {
            let viewController: ChattingTableViewController = ChattingTableViewController()
            
            viewController.setViewMode(viewMode)
            viewController.initChannelTitle()
            viewController.userName = USER_NAME
            viewController.userId = USER_ID
            
            self.navigationController?.pushViewController(viewController, animated: false)
        }
        else {
            let viewController: MessagingTableViewController = MessagingTableViewController()
            
            viewController.setViewMode(viewMode)
            viewController.initChannelTitle()
            viewController.userName = USER_NAME
            viewController.userId = USER_ID
            
            self.navigationController?.pushViewController(viewController, animated: false)
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

