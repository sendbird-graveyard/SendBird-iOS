//
//  CreateOpenChannelNavigationController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/16/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class CreateOpenChannelNavigationController: UINavigationController {
    weak var createChannelDelegate: CreateOpenChannelDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationBar.prefersLargeTitles = false
        
        let vc = CreateOpenChannelViewControllerA.init(nibName: "CreateOpenChannelViewControllerA", bundle: nil)
        self.pushViewController(vc, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
