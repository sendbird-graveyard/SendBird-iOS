//
//  WebViewController.swift
//  SendBird-iOS
//
//  Created by Minhyuk Kim on 17/10/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    var webView: WKWebView!
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = url {
            let request = URLRequest(url: url)
            
            webView = WKWebView(frame: self.view.frame)
            webView.load(request)
            
            self.view.addSubview(webView)
        }
    }

    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        print(error.localizedDescription)
    }
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Strat to load")
    }
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        print("finish to load")
    }
}
