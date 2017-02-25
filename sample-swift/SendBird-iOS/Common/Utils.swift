//
//  Utils.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/6/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit

class Utils: NSObject {
    static func imageFromColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static func generateNavigationTitle(mainTitle: String, subTitle: String?) -> NSAttributedString? {
        var mainTitleAttribute: [String:AnyObject]?
        var subTitleAttribute: [String:AnyObject]?
        
        if subTitle == nil || subTitle?.characters.count == 0 {
            mainTitleAttribute = [
                NSFontAttributeName: Constants.navigationBarTitleFont(),
                NSForegroundColorAttributeName: UIColor.black
            ]
        }
        else {
            mainTitleAttribute = [
                NSFontAttributeName: Constants.navigationBarTitleFont(),
                NSForegroundColorAttributeName: UIColor.black
            ]
            
            subTitleAttribute = [
                NSFontAttributeName: Constants.navigationBarSubTitleFont(),
                NSForegroundColorAttributeName: Constants.navigationBarSubTitleColor()
            ]
        }
        
        var fullTitle: NSMutableAttributedString?
        if subTitle == nil || subTitle?.characters.count == 0 {
            fullTitle = NSMutableAttributedString(string: mainTitle)
            fullTitle?.addAttributes(mainTitleAttribute!, range: NSMakeRange(0, mainTitle.characters.count))
        }
        else {
            fullTitle = NSMutableAttributedString(string: NSString(format: "%@\n%@", mainTitle, subTitle!) as String)
            
            fullTitle?.addAttributes(mainTitleAttribute!, range: NSMakeRange(0, mainTitle.characters.count))
            fullTitle?.addAttributes(subTitleAttribute!, range: NSMakeRange(mainTitle.characters.count + 1, (subTitle?.characters.count)!))
        }
        
        return fullTitle
    }
}
