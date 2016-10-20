//
//  ReusableViewFromXib.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/7/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit

class ReusableViewFromXib: UIView {
    var customView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let className = String(describing: type(of: self))

        self.customView = Bundle.main.loadNibNamed(className, owner: self, options: nil)!.first as? UIView
        self.customView?.frame = self.bounds
        
        if frame.isEmpty == true {
            self.bounds = (self.customView?.bounds)!
        }
        
        self.addSubview(self.customView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let className = String(describing: type(of: self))
        
        self.customView = Bundle.main.loadNibNamed(className, owner: self, options: nil)!.first as? UIView
        self.customView?.frame = self.bounds
        
        self.addSubview(self.customView!)
    }
}
