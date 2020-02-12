//
//  ImageUtil.swift
//  SendBird-iOS
//
//  Created by Minhyuk Kim on 23/07/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import Kingfisher

class ImageUtil {
    static func transformUserProfileImage(user: SBDUser) -> String {
        if let profileUrl = user.profileUrl {
            if profileUrl.hasPrefix("https://sendbird.com/main/img/profiles") {
                return ""
            }
            else {
                return profileUrl
            }
        }
        
        return ""
    }
    
    static func getDefaultUserProfileImage(user: SBDUser) -> UIImage? {
        if let nickname = user.nickname, let image = UIImage(named: "img_default_profile_image_\(nickname.count % 4)") {
            return image
        }
        
        return UIImage(named: "img_default_profile_image_1")
    }
}

extension UIImageView {
    convenience init(withUser user: SBDUser) {
        self.init()
        setProfileImageView(for: user)
    }
    
    func setProfileImageView(for user: SBDUser) {
        let defaultImage = ImageUtil.getDefaultUserProfileImage(user: user)
        guard let url = URL(string: ImageUtil.transformUserProfileImage(user: user)) else {
            self.image = defaultImage
            return
        }
        self.kf.setImage(with: url, placeholder: defaultImage)
        
    }
}

class ProfileImageView: UIView {
    
    var users: [SBDUser] = [] {
        didSet {
            let index = (users.count > 3) ? 4 : users.count
            users = Array(users[0..<index])
            setUpImageStack()
        }
    }
    
    var spacing: CGFloat = 0 {
        didSet {
            for subView in self.subviews{
                if let stack = subView as? UIStackView{
                    for subStack in stack.arrangedSubviews{
                        (subStack as? UIStackView)?.spacing = spacing
                    }
                }
                (subView as? UIStackView)?.spacing = spacing
            }
        }
    }
    
    func makeCircularWithSpacing(spacing: CGFloat){
        self.layer.cornerRadius = self.frame.height/2
        self.spacing = spacing
    }
    
    private func setUpImageStack() {
        for subView in self.subviews{
            subView.removeFromSuperview()
        }
        
        let mainStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        mainStackView.axis = .horizontal
        mainStackView.spacing = spacing
        mainStackView.distribution = .fillEqually
        self.addSubview(mainStackView)
        
        if users.isEmpty {
            let imageContainerView = UIView(frame: self.frame)
            let imageView = UIImageView(image: UIImage(named: "img_default_profile_image_1"))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageContainerView.translatesAutoresizingMaskIntoConstraints = false
            
            imageContainerView.addSubview(imageView)
            mainStackView.addArrangedSubview(imageContainerView)
            
            imageView.heightAnchor.constraint(equalTo: imageContainerView.heightAnchor).isActive = true
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
            
            imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor).isActive = true
            imageContainerView.clipsToBounds = true
            
            
        }
        
        for user in users{
            let imageContainerView = UIView(frame: self.frame)
            let imageView = UIImageView(withUser: user)
            imageContainerView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageContainerView.translatesAutoresizingMaskIntoConstraints = false
            if users.count == 1 {
                mainStackView.addArrangedSubview(imageContainerView)
            }
            else {
                
                let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
                stackView.addArrangedSubview(imageContainerView)
                stackView.axis = .vertical
                stackView.distribution = .fillEqually
                stackView.spacing = spacing
                
                imageView.heightAnchor.constraint(equalToConstant: imageContainerView.frame.height).isActive = true
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
                
                if mainStackView.arrangedSubviews.count < 2 {
                    mainStackView.addArrangedSubview(stackView)
                }
                else {
                    for subView in mainStackView.arrangedSubviews {
                        if (subView as? UIStackView)?.arrangedSubviews.count == 1 {
                            (subView as? UIStackView)?.addArrangedSubview(imageContainerView)
                        }
                    }
                }
            }
            
            imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor).isActive = true
            imageContainerView.clipsToBounds = true
        }
    }
    
    
    init(users: [SBDUser], frame: CGRect){
        super.init(frame: frame)
        self.setUser(newUsers: users)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setUser(newUsers: [SBDUser]) {
        self.users = newUsers
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setImage(withCoverUrl coverUrl: String){
        
        let placeholderImage = UIImage(named: "img_cover_image_placeholder_1")
        
        let imageView = UIImageView()
        if let url = URL(string: coverUrl){
            imageView.kf.setImage(with: url, placeholder: placeholderImage)
        } else {
            imageView.image = placeholderImage
        }
        
        
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        stackView.addArrangedSubview(imageView)
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        self.addSubview(stackView)
        makeCircularWithSpacing(spacing: 0)
    }
    
    func setImage(withImage image: UIImage){
        let imageView = UIImageView(image: image)
        
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        stackView.addArrangedSubview(imageView)
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        self.addSubview(stackView)
        makeCircularWithSpacing(spacing: 0)
    }
    
}
