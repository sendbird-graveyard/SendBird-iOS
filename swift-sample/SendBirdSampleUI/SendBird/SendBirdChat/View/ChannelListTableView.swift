//
//  ChannelListTableView.swift
//  SendBirdSampleUI
//
//  Created by Jed Kyung on 2/2/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

import UIKit
import SendBirdSDK

class ChannelListTableView: UIView, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    var searchAreaView: UIView?
    var searchTextField: UITextField?
    var channelTableView: UITableView?
    var channels: NSMutableArray?
    var messagingChannels: Array<AnyObject>?
    var refreshControl: UIRefreshControl?
    var tableViewDataSource: UITableViewDataSource?
    var tableViewDelegate: UITableViewDelegate?
    var chattingTableViewController: ChattingTableViewController?

    private var channelListQuery: SendBirdChannelListQuery?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.backgroundColor = UIColor.whiteColor()
        self.searchAreaView = UIView()
        self.searchAreaView?.translatesAutoresizingMaskIntoConstraints = false
        self.searchAreaView?.backgroundColor = SendBirdUtils.UIColorFromRGB(0x2ac6b6)

        self.searchTextField = UITextField()
        self.searchTextField?.translatesAutoresizingMaskIntoConstraints = false
        self.searchTextField?.background = UIImage.init(named: "_box_white")
        self.searchTextField?.textColor = UIColor.blackColor()
        self.searchTextField?.font = UIFont.systemFontOfSize(13.0)
        let leftPaddingView = UIView.init(frame: CGRectMake(0, 0, 16, 8))
        let rightPaddingView = UIView.init(frame: CGRectMake(0, 0, 16, 8))
        self.searchTextField?.leftView = leftPaddingView
        self.searchTextField?.rightView = rightPaddingView
        self.searchTextField?.leftViewMode = UITextFieldViewMode.Always
        self.searchTextField?.rightViewMode = UITextFieldViewMode.Always
        self.searchTextField?.returnKeyType = UIReturnKeyType.Search
        self.searchTextField?.delegate = self
        self.searchTextField?.addTarget(self, action: "searchTextFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString.init(string: "  Search")
        let textAttachment: NSTextAttachment = NSTextAttachment()
        textAttachment.image = UIImage.init(named: "_icon_search")
        let attrStringWithImage: NSAttributedString = NSAttributedString.init(attachment: textAttachment)
        attributedString.replaceCharactersInRange(NSMakeRange(0, 1), withAttributedString: attrStringWithImage)
        self.searchTextField?.attributedPlaceholder = attributedString
        
        self.channelTableView = UITableView()
        self.channelTableView?.translatesAutoresizingMaskIntoConstraints = false
        self.channelTableView?.delegate = self
        self.channelTableView?.dataSource = self
        self.channelTableView?.separatorColor = UIColor.clearColor()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "reloadChannels", forControlEvents: UIControlEvents.ValueChanged)
        
        self.searchAreaView?.addSubview(self.searchTextField!)
        addSubview(self.searchAreaView!)
        
        self.channelTableView?.addSubview(self.refreshControl!)
        addSubview(self.channelTableView!)
        
        self.applyConstraints()
    }
    
    func viewDidLoad() {
        self.channelListQuery = SendBird.queryChannelList()
        self.channels = NSMutableArray()
        ImageCache.initImageCache()
    }
    
    private func applyConstraints() {
        self.addConstraint(NSLayoutConstraint.init(item: self.searchAreaView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.searchAreaView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.searchAreaView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.searchAreaView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 43))
        
        self.searchAreaView?.addConstraint(NSLayoutConstraint.init(item: self.searchTextField!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.searchAreaView!, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.searchAreaView?.addConstraint(NSLayoutConstraint.init(item: self.searchTextField!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.searchAreaView!, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 8))
        self.searchAreaView?.addConstraint(NSLayoutConstraint.init(item: self.searchTextField!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.searchAreaView!, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -8))
        self.addConstraint(NSLayoutConstraint.init(item: self.searchTextField!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 30))

        self.addConstraint(NSLayoutConstraint.init(item: self.searchAreaView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.channelTableView!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.channelTableView!, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.channelTableView!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.channelTableView!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
    }
    
    func loadChannels() {
        if self.channelListQuery?.isLoading() == true {
            return
        }
        
        if self.channelListQuery?.hasNext() == false {
            return
        }
        
        self.channelListQuery?.nextWithResultBlock({ (queryResult) -> Void in
                if self.channelListQuery?.page == 1 {
                    self.channels?.removeAllObjects()
                }
                self.channels?.addObjectsFromArray(queryResult as [AnyObject])
                self.channelTableView?.reloadData()
                self.refreshControl?.endRefreshing()
            }, endBlock: { (error) -> Void in
                NSLog("Error")
        })
    }

    func reloadChannels() {
        self.chattingTableViewController?.setIndicatorHidden(false)
        self.channelListQuery = SendBird.queryChannelList()
        self.channelListQuery?.nextWithResultBlock({ (queryResult) -> Void in
            if self.channelListQuery?.page == 1 {
                self.channels?.removeAllObjects()
            }
            self.channels?.addObjectsFromArray(queryResult as [AnyObject])
            
            self.channelTableView?.reloadData()
            self.refreshControl?.endRefreshing()
            
            self.chattingTableViewController?.setIndicatorHidden(true)
            }, endBlock: { (error) -> Void in
                NSLog("Error")
                self.chattingTableViewController?.setIndicatorHidden(true)
        })
    }
    
    func queryChannel(query: String) {
        self.chattingTableViewController?.setIndicatorHidden(false)
        self.channelListQuery = SendBird.queryChannelListWithKeyword(query)
        self.channelListQuery?.nextWithResultBlock({ (queryResult) -> Void in
            if self.channelListQuery?.page == 1 {
                self.channels?.removeAllObjects()
            }
            self.channels?.addObjectsFromArray(queryResult as [AnyObject])
            
            self.channelTableView?.reloadData()
            self.refreshControl?.endRefreshing()
            
            self.chattingTableViewController?.setIndicatorHidden(true)
            }, endBlock: { (error) -> Void in
                self.chattingTableViewController?.setIndicatorHidden(true)
        })
    }
    
    // MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.channels?.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier: String = "ChannelReuseIdentifier"
        
        var cell: ChannelTableViewCell? = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as? ChannelTableViewCell
        
        if cell == nil {
            cell = ChannelTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: CellIdentifier)
        }
        cell!.setModel(self.channels![indexPath.row] as? SendBirdChannel)
        
        if indexPath.row == (self.channels?.count)! - 1 && self.channelListQuery?.hasNext() == true {
            self.loadChannels()
        }
        
        return cell!;
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let channel: SendBirdChannel = self.channels![indexPath.row] as! SendBirdChannel
        self.chattingTableViewController!.channelUrl = channel.url
        self.chattingTableViewController!.initChannelTitle()
        self.chattingTableViewController!.setViewMode(kChattingViewMode)
        
        self.chattingTableViewController!.startChatting()
        self.hidden = true
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text?.characters.count > 0 {
            self.queryChannel(textField.text!)
        }
        return true
    }
}
