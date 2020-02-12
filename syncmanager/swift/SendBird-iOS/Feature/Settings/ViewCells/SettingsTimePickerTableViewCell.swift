//
//  SettingsTimePickerTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/17/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit

class SettingsTimePickerTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    weak var delegate: SettingsTimePickerDelegate?
    var identifier: String?
    let hours: [String] = (0...11).map(String.init)
    var mins: [String] = (0...59).map(String.init)
    var ampm: [String] = ["AM", "PM"]
    
    @IBOutlet weak var timerPicker: UIPickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.timerPicker.delegate = self
        self.timerPicker.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 5
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch component {
            
        case 1: return 12
        case 2: return 60
        case 3: return 2
            
        default:
            return 0
        }
 
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch component {
            
        case 1: return self.hours[row]
        case 2: return self.mins[row]
        case 3: return self.ampm[row]
            
        default:
            return ""
        }
         
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        guard let identifier = self.identifier else { return }
        
        switch component {
            
        case 1: self.delegate?.didSetTime(timeValue: self.hours[row], component: component, identifier: identifier)
        case 2: self.delegate?.didSetTime(timeValue: self.mins[row], component: component, identifier: identifier)
        case 3: self.delegate?.didSetTime(timeValue: self.ampm[row], component: component, identifier: identifier)
            
        default:
            return
        }
    }
}
