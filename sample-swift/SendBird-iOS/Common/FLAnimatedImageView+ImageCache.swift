//
//  FLAnimatedImageView+ImageCache.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 6/7/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

import Foundation
import FLAnimatedImage

class CustomURLCache: URLCache {
    static let sharedInstance: CustomURLCache = {
        let instance = CustomURLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: nil)
        
        URLCache.shared = instance
        
        return instance
    }()
}

extension FLAnimatedImageView {
    func setAnimatedImageWithURL(url: URL, success: ((FLAnimatedImage) -> Void)?, failure: ((Error?) -> Void)?) -> Void {
        let request = URLRequest.init(url: url)
        let session = URLSession.init(configuration: URLSessionConfiguration.default)
        (session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                if failure != nil {
                    failure!(error!)
                }
                
                session.invalidateAndCancel()
                
                return
            }
            
            let resp: HTTPURLResponse = response as! HTTPURLResponse
            if resp.statusCode >= 200 && resp.statusCode < 300 {
                let cachedResponse = CachedURLResponse(response: response!, data: data!)
                CustomURLCache.sharedInstance.storeCachedResponse(cachedResponse, for: request)
                let animatedImage = FLAnimatedImage(animatedGIFData: data)
                
                if success != nil {
                    success!(animatedImage!)
                }
            }
            else {
                if failure != nil {
                    failure!(nil)
                }
            }
            
            session.invalidateAndCancel()
        }).resume()
    }
    
    static func cachedImageForURL(url: URL) -> Data? {
        let request = URLRequest(url: url)
        let cachedResponse: CachedURLResponse? = CustomURLCache.sharedInstance.cachedResponse(for: request)
        if cachedResponse != nil {
            return cachedResponse?.data
        }
        else {
            return nil
        }
    }
}
