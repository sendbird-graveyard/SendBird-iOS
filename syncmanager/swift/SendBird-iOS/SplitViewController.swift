//
//  SplitViewController.swift
//  SendBird-iOS
//
//  Created by Jaesung Lee on 09/08/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.preferredDisplayMode = .allVisible
        self.modalPresentationStyle = .fullScreen
        // Do any additional setup after loading the view.
    }

}
