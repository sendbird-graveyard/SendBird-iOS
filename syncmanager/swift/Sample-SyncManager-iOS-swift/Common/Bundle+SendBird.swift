//
//  Bundle+SendBird.swift
//  SendBird-iOS-LocalCache-Sample-swift
//
//  Created by Jed Kyung on 10/18/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import Foundation

extension Bundle {
    static func sbBundle() -> Bundle {
        return Bundle(for: ViewController.self)
    }
    
    static func sbResourceBundle() -> Bundle {
        let bundleResourcePath = Bundle.sbBundle().resourcePath
        let projectName: String = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let assetPath = bundleResourcePath?.appending("/\(projectName).bundle")
        return Bundle(path: assetPath!)!
    }
    
    static func sbLocalizedStringForKey(key: String) -> String {
        return NSLocalizedString(key, tableName: "Localizable", bundle: Bundle.sbResourceBundle(), comment: "")
    }
}
