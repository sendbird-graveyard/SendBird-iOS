//
//  CustomPhotosViewController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/31/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import NYTPhotoViewer

class CustomPhotosViewController: NYTPhotosViewController {
    private var previousNavigationBackgroundColor: UIColor?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.rightBarButtonItems = nil
        self.rightBarButtonItem = nil
        
        if let closeButtonImage = UIImage(named: "img_btn_close_white") {
            closeButtonImage.withRenderingMode(.alwaysOriginal)
            let closeButtonItem = UIBarButtonItem(image: closeButtonImage, style: .plain, target: self, action: #selector(CustomPhotosViewController.closeViewer(_:)))
            self.leftBarButtonItem = closeButtonItem
        }
        
    }
    
    @objc func closeViewer(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
