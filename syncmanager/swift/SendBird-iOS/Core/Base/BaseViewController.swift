//
//  BaseViewController.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2019/12/12.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import SendBirdSyncManager

class BaseViewController: UIViewController {
    
    let delegateIdentifier = NSUUID().uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(" 🔸 \(className).viewDidLoad()")
    }
    
    deinit {
        print(" 🔹 \(className).deinit()")
    }
}
