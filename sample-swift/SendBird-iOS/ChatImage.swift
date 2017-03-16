//
//  ChatImage.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 3/15/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

import UIKit
import NYTPhotoViewer

class ChatImage: NSObject, NYTPhoto {

    var image: UIImage?
    var imageData: Data?
    var placeholderImage: UIImage?
    var attributedCaptionTitle: NSAttributedString?
    var attributedCaptionSummary: NSAttributedString?
    var attributedCaptionCredit: NSAttributedString?
    
    init(image: UIImage? = nil, imageData: NSData? = nil) {
        super.init()
        
        self.image = image
        self.imageData = imageData as Data?
    }
    
}
