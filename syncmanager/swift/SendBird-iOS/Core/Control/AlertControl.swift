//
//  AlertControl.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2019/12/27.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
 

class AlertControl {
  
    static func show(parent: UIViewController, title: String, message: String? = nil, style: UIAlertController.Style = .alert, actionMessage: String, actionHandler: ((UIAlertAction) -> Void)? = nil) {
      
        self.showAlert(parent: parent, title: title, message: message, style: style,
                  actionMessage: actionMessage,
                  actionStyle: .default,
                  
                  cancelMessage: "cancel",
                  cancelStyle: .cancel,
                  
                  actionHandler: actionHandler,
                  cancelHandler: nil)
         
    }
      
    static func show(parent: UIViewController, actions: [UIAlertAction], title: String?, style: UIAlertController.Style) {
        
        weak var parent = parent
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: style)
        alert.modalPresentationStyle = .popover
         
        actions.forEach(alert.addAction)
        
        switch style {
        case .actionSheet:
            if let presenter = alert.popoverPresentationController, let bounds = parent?.view.bounds {
                presenter.sourceView = parent?.view
                presenter.sourceRect = CGRect(x: bounds.minX, y: bounds.maxY, width: 0, height: 0)
                presenter.permittedArrowDirections = []
            }
            
        case .alert:
            break
            
        @unknown default:
            fatalError()
        }
        
        parent?.view.endEditing(true)
        parent?.present(alert, animated: true, completion: {
            
        });
    }
    
    static func showError(parent: UIViewController, error: SBDError) {
        self.showWithClose(parent: parent, title: "Error", message: error.domain)
    }
    
    static func showWithClose(parent: UIViewController, title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(.closeAction)
        
        DispatchQueue.main.async {
            parent.present(alert, animated: true, completion: nil)
        }
    }
    
    static func showSimple(parent: UIViewController,
                           title: String? = "",
                           message: String? = "",
                           actionMessage: String? = "close",
                           style: UIAlertAction.Style = .default,
                           actionHandler: ((UIAlertAction) -> Void)? = nil) {
     
        weak var parent = parent
         
         let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: actionMessage, style: style, handler: actionHandler)
        
        alert.modalPresentationStyle = .popover
        alert.addAction(action)
  
        DispatchQueue.main.async {
            parent?.present(alert, animated: true, completion: nil)
        }
        
    }
    
    static private func showAlert(parent: UIViewController,
                          
                          title: String? = nil,
                          message: String? = nil,
                          style: UIAlertController.Style = .alert,
                          
                          actionMessage: String? = nil,
                          actionStyle: UIAlertAction.Style = .default,
                          
                          cancelMessage: String? = nil,
                          cancelStyle: UIAlertAction.Style = .default,
                          
                          actionHandler: ((UIAlertAction) -> Void)? = nil,
                          cancelHandler: ((UIAlertAction) -> Void)? = nil) {
        
        weak var parent = parent
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let actionMessage = actionMessage {
            let action = UIAlertAction(title: actionMessage, style: actionStyle, handler: actionHandler)
            alert.addAction(action)
        }
        if let cancelMessage = cancelMessage {
            let cancelAction = UIAlertAction(title: cancelMessage, style: cancelStyle, handler: cancelHandler)
            alert.addAction(cancelAction)
        }

        switch style {
        case .actionSheet:
            if let presenter = alert.popoverPresentationController, let bounds = parent?.view.bounds {
                presenter.sourceView = parent?.view
                presenter.sourceRect = CGRect(x: bounds.minX, y: bounds.maxY, width: 0, height: 0)
                presenter.permittedArrowDirections = []
            }
            
        case .alert:
            break
            
        @unknown default:
            fatalError()
        }
         
        parent?.present(alert, animated: true, completion: nil)
    }
    
}
