//
//  CreateGroupChannelSelectOptionViewController.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/10/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

protocol CreateGroupChannelSelectOptionViewControllerDelegate: class {
    func didFinishCreating(channel: SBDGroupChannel, vc: UIViewController)
}

class CreateGroupChannelSelectOptionViewController: UIViewController {
    weak var delegate: CreateGroupChannelSelectOptionViewControllerDelegate?
    
    var selectedUser: [SBDUser] = []
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var distinctButton: UIButton!
    @IBOutlet weak var nonDistinctButton: UIButton!
    @IBOutlet weak var distinctTextButton: UIButton!
    @IBOutlet weak var nonDistinctTextButton: UIButton!
    
    private var isDistinct: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let negativeLeftSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        negativeLeftSpacer.width = -2
        let negativeRightSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        negativeRightSpacer.width = -2
        
        let leftBackItem = UIBarButtonItem(image: UIImage(named: "btn_back"), style: UIBarButtonItem.Style.done, target: self, action: #selector(back))
        let rightCreateItem = UIBarButtonItem(title: Bundle.sbLocalizedStringForKey(key: "CreateButton"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(createChannel))
        
        self.navItem.leftBarButtonItems = [negativeLeftSpacer, leftBackItem]
        self.navItem.rightBarButtonItems = [negativeRightSpacer, rightCreateItem]
        
        self.activityIndicator.isHidden = true
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.stopAnimating()
        
        self.distinctTextButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        self.nonDistinctTextButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        
        self.selectDictinctOption()
        
        self.isDistinct = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc private func back() {
        self.dismiss(animated: false) { 
            
        }
    }
    
    @objc private func createChannel() {
        SBDGroupChannel.createChannel(with: self.selectedUser, isDistinct: self.isDistinct) { (channel, error) in
            if error != nil {
                let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertController.Style.alert)
                let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertAction.Style.cancel, handler: { (action) in
                    
                })
                vc.addAction(closeAction)
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: nil)
                }
                
                self.activityIndicator.stopAnimating()
                
                return
            }

            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            
            self.dismiss(animated: false, completion: { 
                if self.delegate != nil {
                    self.delegate?.didFinishCreating(channel: channel!, vc: self)
                }
            })
        }
    }
    
    private func selectDictinctOption() {
        self.isDistinct = true
        
        self.distinctButton.setBackgroundImage(UIImage(named: "btn_selected"), for: UIControl.State.normal)
        self.distinctButton.setBackgroundImage(UIImage(named: "btn_check_off"), for: UIControl.State.highlighted)
        self.nonDistinctButton.setBackgroundImage(UIImage(named: "btn_check_off"), for: UIControl.State.normal)
        self.nonDistinctButton.setBackgroundImage(UIImage(named: "btn_selected"), for: UIControl.State.highlighted)
        
        self.distinctTextButton.titleLabel?.font = Constants.distinctButtonSelected()
        self.nonDistinctTextButton.titleLabel?.font = Constants.distinctButtonNormal()
    }
    
    private func selectNonDistinctOption() {
        self.isDistinct = false
        
        self.distinctButton.setBackgroundImage(UIImage(named: "btn_check_off"), for: UIControl.State.normal)
        self.distinctButton.setBackgroundImage(UIImage(named: "btn_selected"), for: UIControl.State.highlighted)
        self.nonDistinctButton.setBackgroundImage(UIImage(named: "btn_selected"), for: UIControl.State.normal)
        self.nonDistinctButton.setBackgroundImage(UIImage(named: "btn_check_off"), for: UIControl.State.highlighted)
        
        self.distinctTextButton.titleLabel?.font = Constants.distinctButtonNormal()
        self.nonDistinctTextButton.titleLabel?.font = Constants.distinctButtonSelected()
    }
    
    @IBAction func clickDistinctButton(_ sender: AnyObject) {
        self.selectDictinctOption()
    }
    
    @IBAction func clickDistinctTextButton(_ sender: AnyObject) {
        self.selectDictinctOption()
    }
    
    @IBAction func clickNondistinctButton(_ sender: AnyObject) {
        self.selectNonDistinctOption()
    }
    
    @IBAction func clickNonDistinctTextButton(_ sender: AnyObject) {
        self.selectNonDistinctOption()
    }
}
