//
//  TableView+extension.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2019/11/29.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit

extension UITableView {
    open func register<T: UITableViewCell>(_ cell: T.Type) {
        let className = cell.className
        let nib = UINib(nibName: className, bundle: nil)
        register(nib, forCellReuseIdentifier: className)
    }
    
    open func dequeueReusableCell<T: UITableViewCell>(_ cell: T.Type) -> T {
        let className = cell.className
        guard let cell = dequeueReusableCell(withIdentifier: className) else {
            fatalError("tableView must be registered with the same identifier as the class name. \n ex) tableView.Register(SomeTableViewCell.self)")
        }
        guard let typeCell = cell as? T else {
            fatalError("This error occurs when the class name and identifier of the cell are different.")
        }
        return typeCell
    }
}
