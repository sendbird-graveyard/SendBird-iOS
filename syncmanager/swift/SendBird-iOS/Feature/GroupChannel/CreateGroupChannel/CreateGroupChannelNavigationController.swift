//
//  CreateGroupChannelNavigationController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/15/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit

class CreateGroupChannelNavigationController: UINavigationController {
    weak var channelCreationDelegate: CreateGroupChannelViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.prefersLargeTitles = false
    }
}

extension CreateGroupChannelNavigationController {
    static func initiate() -> CreateGroupChannelNavigationController {
        let vc = CreateGroupChannelNavigationController.withStoryboard(storyboard: .groupChannel)
        return vc
    }
}
