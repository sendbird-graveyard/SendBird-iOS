//
//  GroupChannelsNavigationController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/12/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit

class GroupChannelsNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationBar.prefersLargeTitles = true
        
        if self.responds(to: #selector(getter: GroupChannelsNavigationController.interactivePopGestureRecognizer)) {
            if let interactivePopGestureRecognizer = self.interactivePopGestureRecognizer {
                interactivePopGestureRecognizer.isEnabled = false
            }
        }
        
        let vc = GroupChannelsViewController.init(nibName: "GroupChannelsViewController", bundle: nil)
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
