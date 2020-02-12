//
//  UIViewController+Utils.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/12/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit

extension UIViewController {
    public static func findBestViewController(_ vc: UIViewController) -> UIViewController {
        
        if let presentedVC = vc.presentedViewController {
            // Return presented view controller
            return UIViewController.findBestViewController(presentedVC)
        }
        else if let splitVC = vc as? UISplitViewController {
            // Return right hand side
            guard splitVC.viewControllers.count > 0 else { return vc }
            return UIViewController.findBestViewController(splitVC.viewControllers.last!)
        }
        else if let naviVC = vc as? UINavigationController {
            // Return top view
            // TODO: Need to compare with ObjC ver.
            guard let topVC = naviVC.topViewController else { return vc }
            return UIViewController.findBestViewController(topVC)
            
        }
        else if let tabVC = vc as? UITabBarController {
            // Return visible view
            guard (tabVC.viewControllers?.count ?? 0) > 0 else { return vc }
            return UIViewController.findBestViewController(tabVC.selectedViewController!)
            
        }
        else {
            // Unknown view controller type, return last child view controller
            return vc
        }
    }
    
    public static func currentViewController() -> UIViewController? {
        guard let viewController = UIApplication.shared.keyWindow?.rootViewController else { return nil }
        return UIViewController.findBestViewController(viewController)
    }
}
