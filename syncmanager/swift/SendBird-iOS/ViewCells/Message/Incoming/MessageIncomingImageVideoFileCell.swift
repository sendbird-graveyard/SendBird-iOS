//
//  MessageIncomingImageVideoFileCell.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 11/29/19.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import FLAnimatedImage

class MessageIncomingImageVideoFileCell: MessageIncomingCell {
    
    @IBOutlet weak var imageFileMessageImageView: FLAnimatedImageView!
    @IBOutlet weak var videoPlayIconImageView: UIImageView!
    @IBOutlet weak var imageMessagePlaceholderImageView: UIImageView!
    @IBOutlet weak var videoMessagePlaceholderImageView: UIImageView!
    
    override func awakeFromNib() {
        self.messageCellType = .imageVideo
        
        super.awakeFromNib()
        
        let clickMessageContainteGesture = UITapGestureRecognizer(target: self, action: #selector(MessageIncomingImageVideoFileCell.clickImageVideoFileMessage(_:)))
        self.messageContainerView.addGestureRecognizer(clickMessageContainteGesture)
        
        let longClickMessageContainerGesture = UILongPressGestureRecognizer(target: self, action: #selector(MessageIncomingImageVideoFileCell.longClickImageVideoFileMessage(_:)))
        self.messageContainerView.addGestureRecognizer(longClickMessageContainerGesture)
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func hideAllPlaceholders() {
        self.videoPlayIconImageView.isHidden = true
        self.imageMessagePlaceholderImageView.isHidden = true
        self.videoMessagePlaceholderImageView.isHidden = true
    }
    
    override func configure(with model: MessageModel) {
        super.configure(with: model)
        
        self.videoMessagePlaceholderImageView.isHidden = false
        self.hideAllPlaceholders()
        
        
        self.imageMessagePlaceholderImageView.isHidden = false
        self.setImage(nil)
        self.setAnimatedImage(nil, hash: 0)
        
        guard let fileMessage = message as? SBDFileMessage else { return }
        let isImage = fileMessage.fileType == .image
        
        if fileMessage.type == "image/gif" {
            guard let url = URL(string: fileMessage.url) else { return }
            self.imageFileMessageImageView.setAnimatedImage(url: url, success: { (image, hash) in
                DispatchQueue.main.async {
                    self.hideAllPlaceholders()
                    self.setAnimatedImage(image, hash: hash)
                }
            }) { error in
                DispatchQueue.main.async {
                    self.hideAllPlaceholders()
                    self.imageMessagePlaceholderImageView.isHidden = false
                    self.setImage(nil)
                    self.setAnimatedImage(nil, hash: 0)
                }
            }
            return
        }
        
        var url: URL? = nil
        
        if let thumbnails = fileMessage.thumbnails, thumbnails.count > 0 {
            url = URL(string: thumbnails[0].url)
        } else {
            url = URL(string: fileMessage.url)
        }
        
        
        guard let imageURL = url else {
            self.hideAllPlaceholders()
            self.videoMessagePlaceholderImageView.isHidden = false
            self.setAnimatedImage(nil, hash: 0)
            self.setImage(nil)
            return
            
        }
        
        self.imageFileMessageImageView.kf.setImage(with: imageURL) { result in
            
            self.hideAllPlaceholders()
            
            switch result {
            case .success:
                
                if isImage {
                    self.videoPlayIconImageView.isHidden = true
                } else {
                    self.videoPlayIconImageView.isHidden = false
                }
                 
                self.videoMessagePlaceholderImageView.isHidden = true
                
            case .failure:
                
                if isImage {
                    self.videoMessagePlaceholderImageView.isHidden = true
                    self.imageMessagePlaceholderImageView.isHidden = false
                    self.videoPlayIconImageView.isHidden = true
                } else {
                    self.videoMessagePlaceholderImageView.isHidden = false
                    self.imageMessagePlaceholderImageView.isHidden = true
                    self.videoPlayIconImageView.isHidden = false
                    
                }
                
                
                self.setImage(nil)
                self.setAnimatedImage(nil, hash: 0)
                
            }
        }
         
    }
    
    func setAnimatedImage(_ image: FLAnimatedImage?, hash: Int) {
        if image == nil || hash == 0 {
            self.imageFileMessageImageView.animatedImage = nil
        }
        else {
            self.imageFileMessageImageView.image = nil
            self.imageFileMessageImageView.animatedImage = image
        }
    }
    
    func setImage(_ image: UIImage?) {
        guard let image = image else {
            self.imageFileMessageImageView.image = nil
            return
            
        }
        self.imageFileMessageImageView.animatedImage = nil
        self.imageFileMessageImageView.image = image
    }
    
    @objc func clickImageVideoFileMessage(_ recognizer: UITapGestureRecognizer) {
        guard let message = self.message as? SBDFileMessage else { return }
        self.hero.isEnabled = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hero.isEnabled = false
        }
        
        self.delegate?.didClickImageVideoFileMessage?(message)
        
    }
    
    @objc func longClickImageVideoFileMessage(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            if let fileMessage = self.message as? SBDFileMessage {
                self.delegate?.didLongClickImageVideoFileMessage?(fileMessage)
            }
        }
    }
}
 
