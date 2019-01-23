//
//  OpenChannelsNavigationController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/16/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit

class OpenChannelsNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationBar.prefersLargeTitles = true
        
        if self.responds(to: #selector(getter: OpenChannelsNavigationController.interactivePopGestureRecognizer)) {
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        let vc = OpenChannelsViewController.init(nibName: "OpenChannelsViewController", bundle: nil)
        self.pushViewController(vc, animated: false)
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
