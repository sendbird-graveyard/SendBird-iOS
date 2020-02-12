//
//  MessageOutgoingImageVideoFileCell.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 11/29/19.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK 
import FLAnimatedImage
import Kingfisher

class MessageOutgoingImageVideoFileCell: MessageOutgoingCell {
    
    private var hideReadCount = false

    @IBOutlet weak var placehloderImageView: UIImageView!
    
    @IBOutlet weak var imageFileMessageImageView: FLAnimatedImageView!
  
    @IBOutlet weak var fileTransferProgressViewContainerView: UIView!
    @IBOutlet weak var fileTransferProgressCircleView: CustomProgressCircle!
    @IBOutlet weak var fileTransferProgressLabel: UILabel!
  
    @IBOutlet weak var videoPlayIconImageView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.messageCellType = .imageVideo
        
        let clickMessageContainteGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(MessageOutgoingImageVideoFileCell.clickImageVideoFileMessage(_:)))
 
        let longClickMessageContainerGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(MessageOutgoingImageVideoFileCell.longClickImageVideoFileMessage(_:))
        )
        self.messageContainerView.addGestureRecognizer(clickMessageContainteGesture)
        self.messageContainerView.addGestureRecognizer(longClickMessageContainerGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
 
    override func configure(with model: MessageModel) {
        super.configure(with: model)
        
        
        self.resendButton.addTarget(self, action: #selector(MessageOutgoingImageVideoFileCell.clickResendImageVideoFileMessage(_:)), for: .touchUpInside)
        
        guard let fileMessage = self.message as? SBDFileMessage else {
            assertionFailure()
            return
        }
        
        switch fileMessage.fileType {
        case .image:
            self.setImage(isVideoImage: false)
        case .video:
            self.setImage(isVideoImage: true)
        default:
            assertionFailure()
        }
        
        
        
    }
 
    override func showProgress(_ progress: CGFloat) {
        DispatchQueue.main.async {
            self.fileTransferProgressViewContainerView.isHidden = false
            self.sendingFailureContainerView.isHidden = true
            self.readStatusContainerView.isHidden = true
            self.fileTransferProgressCircleView.drawCircle(progress: progress)
            self.fileTransferProgressLabel.text = String(format: "%.2lf%%", progress * 100.0)
        }
    }
    
    override func hideProgress() {
        self.fileTransferProgressViewContainerView.isHidden = true
        self.sendingFailureContainerView.isHidden = true
    }

    override func hideFailureElement() {
        self.fileTransferProgressViewContainerView.isHidden = true
        super.hideFailureElement()
    }
    
    override func showFailureElement(){
        self.fileTransferProgressViewContainerView.isHidden = false
        self.bringSubviewToFront(self.sendingFailureContainerView)
        self.messageDateLabel.isHidden = true
        super.showFailureElement()
    }
    
    override func showReadStatus(readCount: Int) {
        self.messageDateLabel.isHidden = false
        super.showReadStatus(readCount: readCount)
    }
    
    func showBottomMargin() {
        self.messageContainerViewBottomMargin.constant = Constants.messageContainerViewBottomMarginNormal
    }
    
    func hideBottomMargin() {
        self.messageContainerViewBottomMargin.constant = 0
    }
 
    @objc func clickImageVideoFileMessage(_ recognizer: UITapGestureRecognizer) {
        guard let message = self.message as? SBDFileMessage else { return }
        self.hero.isEnabled = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hero.isEnabled = false
        }
        
        delegate?.didClickImageVideoFileMessage?(message)
    }
    
    @objc func longClickImageVideoFileMessage(_ recognizer: UILongPressGestureRecognizer) {
        guard let message = self.message as? SBDFileMessage, recognizer.state == .began else { return }
        delegate?.didLongClickImageVideoFileMessage?(message)
    }
    
    @objc func clickResendImageVideoFileMessage(_ sender: AnyObject) {
        guard let message = self.message as? SBDFileMessage else { return }
        delegate?.didClickResendImageVideoFileMessage?(message)
    }
  
    func setImage(_ image: UIImage?) {
        guard let image = image, hash != 0 else {
            self.imageFileMessageImageView.image = nil
            return
            
        }
         
            self.imageFileMessageImageView.animatedImage = nil
            self.imageFileMessageImageView.image = image
    }
}
 
extension MessageOutgoingImageVideoFileCell {
 
    func updateImage(imageData: Data?, isGIF: Bool) {
        guard let imageData = imageData else { return }
        self.imageFileMessageImageView.image = nil
        if isGIF {
            self.imageFileMessageImageView.animatedImage = FLAnimatedImage(animatedGIFData: imageData)
        } else {
            self.imageFileMessageImageView.image = UIImage(data: imageData)
        }
    }
}


extension MessageOutgoingImageVideoFileCell {
    
    func setImage(isVideoImage: Bool) {
        if isVideoImage {
            self.placehloderImageView.image = UIImage(named: "img_icon_video_file_placeholder_outgoing")
        } else {
            self.placehloderImageView.image = UIImage(named: "img_icon_image_file_message_placeholder_outgoing")
        }

        guard let fileMessage = self.message as? SBDFileMessage else { return }
        let state = fileMessage.requestState()
        switch state {
        case .failed:

            self.hideReadStatus()
            self.hideProgress()
            self.showFailureElement()
            self.showBottomMargin()
            
            if let progress = model.progress {
                self.showProgress(progress)
            }
            guard
                let params = model.params as? SBDFileMessageParams,
                let fileType = params.mimeType
                else { return }
            
            DispatchQueue.main.async {
                self.updateImage(imageData: params.file, isGIF: fileType.hasPrefix("image/gif"))
            }
        case .pending:
            
            self.hideReadStatus()
            self.hideFailureElement()
            self.showBottomMargin()
            
            if isVideoImage {
                self.imageFileMessageImageView.image = nil
                self.imageFileMessageImageView.animatedImage = nil
            }
            
            guard
                let params = model.params as? SBDFileMessageParams,
                let fileType = params.mimeType
                else { assertionFailure(); return }
            
            DispatchQueue.main.async {
                self.updateImage(imageData: params.file, isGIF: fileType.hasPrefix("image/gif"))
            }
            
             
        case .succeeded:
             
            self.hideFailureElement()
            let url: URL?
             
            guard let thumbnails = fileMessage.thumbnails else { assertionFailure(); return }
            if let urlString = thumbnails.first?.url, let thumbnailURL = URL(string: urlString), !fileMessage.type.hasPrefix("image/gif") {
                url = thumbnailURL
            } else {
                url = URL(string: fileMessage.url)
            }

            guard let imageURL = url else { return }
            
            
            var placeholder: UIImage?
            
            if let params = model.params as? SBDFileMessageParams, let imageData = params.file {
                placeholder = UIImage(data: imageData)
            }
            self.videoPlayIconImageView.isHidden = true
            self.imageFileMessageImageView.kf.setImage(
                with: imageURL,
                placeholder: placeholder,
                options: [.transition(.fade(1))],
                progressBlock: nil)
            { result in
                switch result {
                case .success:
                    self.model.params = nil
                    if isVideoImage {
                        self.videoPlayIconImageView.isHidden = false
                    }
                case .failure:
                    if isVideoImage {
                        self.videoPlayIconImageView.isHidden = true
                    }
                }
            }
            
        case .none:
            assertionFailure()
            
        @unknown default:
            assertionFailure()
        }
    }
}
