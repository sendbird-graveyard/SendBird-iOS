//
//  UIImageView+SyncManager.swift
//  Sample-SyncManager-iOS-swift
//
//  Created by sendbird-young on 08/05/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit

extension UIImageView {
    func sbsm_setProfileImage(profileUrl: String?) {
        let defaultImage: UIImage? = UIImage(named: "img_profile")
        if let theProfileUrl: String = profileUrl, let url: URL = URL(string: theProfileUrl) {
            self.af_setImage(withURL: url, placeholderImage: defaultImage)
        }
        else {
            self.image = defaultImage
        }
    }
}
