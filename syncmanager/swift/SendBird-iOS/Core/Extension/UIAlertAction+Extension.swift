//
//  UIAlertAction+Extension.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2019/12/27.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit

extension UIAlertAction {
    
    static var cancelAction: UIAlertAction {
        return  UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    }
    static var closeAction: UIAlertAction {
        return  UIAlertAction(title: "Close", style: .cancel, handler: nil)
    }
}
