//
//  DownloadManager.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/22/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import UserNotifications

class DownloadManager: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    var filePath: [Int:String] = [:]
    var saveToLibrary: [Int:Bool] = [:]
    var mimeType: [Int:String] = [:]
    
    static let shared = DownloadManager()
    var session: URLSession?
    
    private override init() {
        
    }
    
    private func backgroundSession() -> URLSession {
        if DownloadManager.shared.session == nil {
            let configurationForFileDownload = URLSessionConfiguration.background(withIdentifier: "com.sendbird.sample.downloadsession")
            configurationForFileDownload.sessionSendsLaunchEvents = true
            configurationForFileDownload.isDiscretionary = false
            configurationForFileDownload.timeoutIntervalForResource = 300
            DownloadManager.shared.session = URLSession(configuration: configurationForFileDownload, delegate: DownloadManager.shared, delegateQueue: nil)
        }
        
        return DownloadManager.shared.session!
    }
    
    // MARK: URLSessionDataDelegate
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let filePath = DownloadManager.shared.filePath[dataTask.taskIdentifier]
        if filePath != nil {
            let handle = FileHandle(forUpdatingAtPath: filePath!)
            handle?.seekToEndOfFile()
            handle?.write(data)
            handle?.closeFile()
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if response is HTTPURLResponse {
            let statusCode = (response as! HTTPURLResponse).statusCode
            if statusCode >= 200 && statusCode < 300 {
                completionHandler(URLSession.ResponseDisposition.allow)
            }
        }
    }
    
    // MARK: - URLSessionTaskDelegate for file transfer progress
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            return
        }
        
        guard let currentRequest = task.currentRequest else { return }
        guard let url = currentRequest.url else { return }
        let urlAbsoluteString = url.absoluteString
        var saveToLibrary: Bool?
        var filePath: String?
        var mimeType: String?
        let taskIdentifier = task.taskIdentifier
        if DownloadManager.shared.saveToLibrary[taskIdentifier] != nil {
            saveToLibrary = DownloadManager.shared.saveToLibrary[taskIdentifier]!
            DownloadManager.shared.saveToLibrary.removeValue(forKey: taskIdentifier)
        }
        
        if DownloadManager.shared.filePath[taskIdentifier] != nil {
            filePath = DownloadManager.shared.filePath[taskIdentifier]!
            DownloadManager.shared.filePath.removeValue(forKey: taskIdentifier)
        }
        
        if DownloadManager.shared.mimeType[taskIdentifier] != nil {
            mimeType = DownloadManager.shared.mimeType[taskIdentifier]!
            DownloadManager.shared.mimeType.removeValue(forKey: taskIdentifier)
        }
        
        if saveToLibrary != nil && filePath != nil && mimeType != nil && task.response is HTTPURLResponse {
            let statusCode = (task.response as! HTTPURLResponse).statusCode
            if statusCode >= 200 && statusCode < 300 {
                let content = UNMutableNotificationContent()
                content.title = "File Downloaded."
                if saveToLibrary! {
                    content.body = "Run Photos app to open the file."
                }
                else {
                    content.body = "Run Files app to open the file."
                }
                
                let data = FileManager.default.contents(atPath: filePath!)
                if mimeType!.hasPrefix("image") {
                    let image = UIImage(data: data!)
                    UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                }
                else if mimeType!.hasPrefix("video") {
                    UISaveVideoAtPathToSavedPhotosAlbum(filePath!, nil, nil, nil)
                }
                
                let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: "com.sendbird.sample.local", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { (error) in
                    
                }
            }
        }
    }
    
    static func download(url: URL, filename: String, mimeType: String, addToMediaLibrary: Bool) {
        let request = URLRequest(url: url)
        let dataTask = DownloadManager.shared.backgroundSession().dataTask(with: request)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
        let filePath = documentsPath.appendingPathComponent(filename)
        let taskIdentifier = dataTask.taskIdentifier
        if DownloadManager.shared.filePath[taskIdentifier] == nil {
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
            DownloadManager.shared.filePath[taskIdentifier] = filePath
            DownloadManager.shared.saveToLibrary[taskIdentifier] = addToMediaLibrary
            DownloadManager.shared.mimeType[taskIdentifier] = mimeType
            dataTask.resume()
        }
    }
}
