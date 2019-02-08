//
//  CreateOpenChannelViewController.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/13/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

protocol CreateOpenChannelViewControllerDelegate: class {
    func refreshView(vc: UIViewController)
}

class CreateOpenChannelViewController: UIViewController, UITextFieldDelegate {
    weak var delegate: CreateOpenChannelViewControllerDelegate?
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var openChannelNameTextField: UITextField!
    @IBOutlet weak var channelNameLabelBottomMargin: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let legativeLeftSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        legativeLeftSpacer.width = -2
        let legativeRightSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        legativeRightSpacer.width = -2
        
        let leftItem = UIBarButtonItem(image: UIImage(named: "btn_close"), style: UIBarButtonItem.Style.done, target: self, action: #selector(closeViewController))
        let rightItem = UIBarButtonItem(title: Bundle.sbLocalizedStringForKey(key: "CreateButton"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(createOpenChannel))
        rightItem.setTitleTextAttributes([NSAttributedString.Key.font: Constants.navigationBarButtonItemFont()], for: UIControl.State.normal)
        
        self.navItem.leftBarButtonItems = [legativeLeftSpacer, leftItem]
        self.navItem.rightBarButtonItems = [legativeRightSpacer, rightItem]
        
        self.channelNameLabel.alpha = 0
        self.openChannelNameTextField.delegate = self
        self.openChannelNameTextField.addTarget(self, action: #selector(channelNameTextFieldDidChange(sender:)), for: UIControl.Event.editingChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func closeViewController() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc private func createOpenChannel() {
        if self.openChannelNameTextField.text?.count == 0 {
            return
        }
        
        SBDOpenChannel.createChannel(withName: self.openChannelNameTextField.text, channelUrl: nil, coverUrl: nil, data: nil, operatorUserIds: nil, customType: nil) { (channel, error) in
            if error != nil {
                let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertController.Style.alert)
                let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertAction.Style.cancel, handler: nil)
                vc.addAction(closeAction)
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: nil)
                }
                
                return
            }
            
            self.delegate?.refreshView(vc: self)
            let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "OpenChannelCreatedTitle"), message: Bundle.sbLocalizedStringForKey(key: "OpenChannelCreatedMessage"), preferredStyle: UIAlertController.Style.alert)
            let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertAction.Style.cancel, handler: { (action) in
                self.dismiss(animated: false, completion: nil)
            })
            vc.addAction(closeAction)
            DispatchQueue.main.async {
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @objc func channelNameTextFieldDidChange(sender: UITextField) {
        if sender.text?.count == 0 {
            self.channelNameLabelBottomMargin.constant = -12
            self.view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.1, animations: {
                self.channelNameLabel.alpha = 0
                self.view.layoutIfNeeded()
            })
        }
        else {
            self.channelNameLabelBottomMargin.constant = 0
            self.view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.2, animations: {
                self.channelNameLabel.alpha = 1
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.openChannelNameTextField {
            self.lineView.backgroundColor = Constants.textFieldLineColorSelected()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.openChannelNameTextField {
            self.lineView.backgroundColor = Constants.textFieldLineColorNormal()
        }
    }
}
