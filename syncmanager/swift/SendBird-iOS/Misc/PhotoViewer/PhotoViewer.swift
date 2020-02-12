//
//  PhotoViewer.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/31/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import NYTPhotoViewer

class PhotoViewer: NSObject, NYTPhoto {
    var image: UIImage?
    var imageData: Data?
    var placeholderImage: UIImage?
    var attributedCaptionTitle: NSAttributedString?
    var attributedCaptionCredit: NSAttributedString?
    var attributedCaptionSummary: NSAttributedString?
}
