//
//  FLAnimatedImageView+ImageLoader.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/19/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import Foundation
import FLAnimatedImage

extension FLAnimatedImageView {
    static let shared = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: nil)
    static var assignedCache: Bool?
    
    static func imageCache() -> URLCache {
        if assignedCache == nil {
            assignedCache = true
            URLCache.shared = shared
        }
        
        return shared
    }
    
    func setAnimatedImage(url: URL, success: ((_ image: FLAnimatedImage, _ hash: Int) -> Void)?, failure: ((_ error: NSError?) -> Void)?) {
        let request = URLRequest(url: url)
        if let cachedResponse = FLAnimatedImageView.imageCache().cachedResponse(for: request) {
            if success != nil {
                let animatedImage = FLAnimatedImage.init(animatedGIFData: cachedResponse.data)
                success!(animatedImage!, cachedResponse.data.hashValue)
            }
            
            return
        }
        
        let session = URLSession.init(configuration: URLSessionConfiguration.default)
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                if failure != nil {
                    failure!(error! as NSError)
                }
                
                session.invalidateAndCancel()
                
                return
            }
            
            let resp = response as! HTTPURLResponse
            if resp.statusCode >= 200 && resp.statusCode < 300 {
                let animatedImage = FLAnimatedImage.init(animatedGIFData: data)
                if animatedImage != nil {
                    if success != nil {
                        success!(animatedImage!, data.hashValue)
                    }
                }
                else {
                    if failure != nil {
                        failure!(nil)
                    }
                }
            }
            else {
                if failure != nil {
                    failure!(nil)
                }
            }
            
            session.invalidateAndCancel()
        }
        
        dataTask.resume()
    }
}
