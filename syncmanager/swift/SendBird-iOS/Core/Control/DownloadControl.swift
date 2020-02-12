//
//  DownloadControl.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/22/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import UserNotifications

class DownloadControl: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    var filePath: [Int:String] = [:]
    var saveToLibrary: [Int:Bool] = [:]
    var mimeType: [Int:String] = [:]
    
    static let shared = DownloadControl()
    var session: URLSession?
    
    private override init() {
        
    }
    
    private func backgroundSession() -> URLSession {
        if let session = DownloadControl.shared.session { return session }
        
        let configurationForFileDownload = URLSessionConfiguration.background(withIdentifier: "com.sendbird.sample.downloadsession")
        configurationForFileDownload.sessionSendsLaunchEvents = true
        configurationForFileDownload.isDiscretionary = false
        configurationForFileDownload.timeoutIntervalForResource = 300
        let session = URLSession(configuration: configurationForFileDownload, delegate: DownloadControl.shared, delegateQueue: nil)
        DownloadControl.shared.session = session
        
        return session
    }
    
    // MARK: URLSessionDataDelegate
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let filePath = DownloadControl.shared.filePath[dataTask.taskIdentifier], let handle = FileHandle(forUpdatingAtPath: filePath) else { return }
            handle.seekToEndOfFile()
            handle.write(data)
            handle.closeFile()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> ()) {
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { return }
        
        switch statusCode {
        case 200..<300: completionHandler(URLSession.ResponseDisposition.allow)
        default: break
        }
        
    }
    
    // MARK: - URLSessionTaskDelegate for file transfer progress
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if error != nil { return }
        
        guard let currentRequest = task.currentRequest, let _ = currentRequest.url else { return }
        let taskIdentifier = task.taskIdentifier
        
        if task.response is HTTPURLResponse,
            let saveToLibrary = DownloadControl.shared.saveToLibrary[taskIdentifier],
            let filePath = DownloadControl.shared.filePath[taskIdentifier],
            let mimeType = DownloadControl.shared.mimeType[taskIdentifier] {
            
            let statusCode = (task.response as! HTTPURLResponse).statusCode
             
            switch statusCode {
                
            case 200..<300:
                
                let content = UNMutableNotificationContent()
                content.title = "File Downloaded."
                content.body = saveToLibrary ? "Run Photos app to open the file." : "Run Files app to open the file."
                
                if mimeType.hasPrefix("image"),
                    let data = FileManager.default.contents(atPath: filePath),
                    let image = UIImage(data: data) {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    
                } else if mimeType.hasPrefix("video") {
                    
                    UISaveVideoAtPathToSavedPhotosAlbum(filePath, nil, nil, nil)
                    
                }
                
                let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: "com.sendbird.sample.local", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { _ in
                    // Handle Callback
                }
                
            default:
                break
                
            }
            
        }
        
        DownloadControl.shared.saveToLibrary.removeValue(forKey: taskIdentifier)
        DownloadControl.shared.filePath.removeValue(forKey: taskIdentifier)
        DownloadControl.shared.mimeType.removeValue(forKey: taskIdentifier)
    }
    
    static func download(url: URL, filename: String, mimeType: String, addToMediaLibrary: Bool) {
        guard let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first as NSString? else { return }
        
        let request = URLRequest(url: url)
        let dataTask = DownloadControl.shared.backgroundSession().dataTask(with: request)
        let filePath = documentsPath.appendingPathComponent(filename)
        let taskIdentifier = dataTask.taskIdentifier
        
        if DownloadControl.shared.filePath[taskIdentifier] == nil {
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
            DownloadControl.shared.filePath[taskIdentifier] = filePath
            DownloadControl.shared.saveToLibrary[taskIdentifier] = addToMediaLibrary
            DownloadControl.shared.mimeType[taskIdentifier] = mimeType
            dataTask.resume()
        }
    }
}
