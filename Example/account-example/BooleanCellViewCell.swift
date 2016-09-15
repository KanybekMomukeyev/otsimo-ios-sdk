//
//  BooleanCellViewCell.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 08/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import UIKit

class BooleanCellViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var booleanSwitch: UISwitch!
    
    var delegate: SettingsPropertyDelegate!
    
    @IBAction func onBooleanValueChanged(_ sender: UISwitch) {
        delegate.activationValueChanged(sender.isOn)
    }
}





