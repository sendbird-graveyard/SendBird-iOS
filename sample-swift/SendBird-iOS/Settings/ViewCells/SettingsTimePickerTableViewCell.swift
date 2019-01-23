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
    var hours: [String] = []
    var mins: [String] = []
    var ampm: [String] = []
    
    @IBOutlet weak var timerPicker: UIPickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        for i in 0...11 {
            self.hours.append(String(i))
        }
        
        for j in 0...59 {
            self.mins.append(String(j))
        }
        
        self.ampm.append("AM")
        self.ampm.append("PM")
        
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
        if component == 1 {
            return 12
        }
        else if component == 2 {
            return 60
        }
        else if component == 3 {
            return 2
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 1 {
            return self.hours[row]
        }
        else if component == 2 {
            return self.mins[row]
        }
        else if component == 3 {
            return self.ampm[row]
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let delegate = self.delegate {
            if component == 1 {
                delegate.didSetTime(timeValue: self.hours[row], component: component, identifier: self.identifier!)
            }
            else if component == 2 {
                delegate.didSetTime(timeValue: self.mins[row], component: component, identifier: self.identifier!)
            }
            else if component == 3 {
                delegate.didSetTime(timeValue: self.ampm[row], component: component, identifier: self.identifier!)
            }
        }
    }
}
