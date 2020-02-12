//
//  UIViewController+Extension.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2019/12/26.
//  Copyright © 2019 SendBird. All rights reserved.
//
 
import UIKit

extension UIViewController {
    private class func fromStoryboard<T>(storyboard: String, className: String, as type: T.Type) -> T {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: className)
        
        guard let rusult = viewController as? T else {
            fatalError("View Controller Couldn't find.")
        }
        
        return rusult
    }
    
    class func withStoryboard(storyboard: StoryboardType) -> Self {
        
        fromStoryboard(storyboard: storyboard.fileName, className: className, as: self)
    }
    
}
