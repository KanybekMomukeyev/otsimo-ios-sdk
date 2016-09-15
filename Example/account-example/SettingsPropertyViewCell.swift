//
//  SettingsPropertyViewCell.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 06/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import UIKit
import OtsimoSDK
import OtsimoApiGrpc

public protocol SettingsPropertyDelegate {
    func propertyValueChanged(_ value: SettingsPropertyValue)
    func activationValueChanged(_ value: Bool)
}

final class SettingsPropertyViewCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var numberText: UITextField!
    @IBOutlet weak var stringText: UITextField!
    @IBOutlet weak var enumLabel: UITextField!
    @IBOutlet weak var booleanSwitch: UISwitch!

    var key: String!
    var game: ChildGame!
    var setProp: SettingsProperty!
    var delegate: SettingsPropertyDelegate!
    var enumValues: [String] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        let pickerView = UIPickerView()
        pickerView.delegate = self
        enumLabel.inputView = pickerView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    @IBAction func onNumberEditingEnded(_ sender: UITextField) {
        switch (setProp!) {
        case .integer(_, _):
            if let val = Int(sender.text!) {
                delegate.propertyValueChanged(.Integer(key: key, value: val))
            } else {
                print("wrong integer format")
            }
        case .float(_, _):
            if let val = Float64(sender.text!) {
                delegate.propertyValueChanged(.Float(key: key, value: val))
            } else {
                print("wrong integer format")
            }
        default:
            print("invalid property")
        }
    }

    @IBAction func booleanChanged(_ sender: UISwitch) {
        delegate.propertyValueChanged(.Boolean(key: key, value: sender.isOn))
    }

    @IBAction func onStringEditingEnded(_ sender: UITextField) {
        delegate.propertyValueChanged(.text(key: key, value: sender.text!))
    }
    // number of column
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // number of row
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return enumValues.count
    }

    // Title
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return game.keyvalue!.settingsTitle(key, enumKey: enumValues[row])
    }

    // update enum label when value changed
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        enumLabel.text = game.keyvalue!.settingsTitle(key, enumKey: enumValues[row])
        enumLabel.resignFirstResponder()
        delegate.propertyValueChanged(.text(key: key, value: enumValues[row]))
    }

    func initFromProperty(_ key: String, childGame: ChildGame, delegate: SettingsPropertyDelegate) {
        self.key = key
        self.game = childGame
        self.setProp = childGame.settings!.getFromKey(key)!
        self.delegate = delegate

        let vp = childGame.valueFor(key)

        self.booleanSwitch.isEnabled = false
        self.booleanSwitch.isHidden = true

        self.numberText.isEnabled = false
        self.numberText.isHidden = true

        self.stringText.isEnabled = false
        self.stringText.isHidden = true

        self.enumLabel.isEnabled = false
        self.enumLabel.isHidden = true

        self.titleLabel.text = childGame.keyvalue!.settingsTitle(key)
        self.descriptionText.text = childGame.keyvalue!.settingsDescription(key)

        switch (setProp!) {
        case .boolean(_, let defaultValue):
            self.booleanSwitch.isEnabled = true
            self.booleanSwitch.isHidden = false

            if let v = vp {
                booleanSwitch.isOn = v.boolean
            } else {
                booleanSwitch.isOn = defaultValue
            }
        case .integer(_, let defaultValue):
            self.numberText.isEnabled = true
            self.numberText.isHidden = false

            if let v = vp {
                numberText.text = "\(v.integer)"
            } else {
                numberText.text = "\(defaultValue)"
            }
        case .float(_, let defaultValue):
            self.numberText.isEnabled = true
            self.numberText.isHidden = false

            if let v = vp {
                numberText.text = "\(v.float)"
            } else {
                numberText.text = "\(defaultValue)"
            }
        case .text(_, let defaultValue):
            self.stringText.isEnabled = true
            self.stringText.isHidden = false

            if let v = vp {
                stringText.text = "\(v.string)"
            } else {
                stringText.text = "\(defaultValue)"
            }
        case .enum(_, let defaultValue, let values):
            self.enumLabel.isEnabled = true
            self.enumLabel.isHidden = false
            enumValues.removeAll()
            enumValues.append(contentsOf: values)
            if let v = vp {
                enumLabel.text = game.keyvalue!.settingsTitle(key, enumKey: v.string)
            } else {
                enumLabel.text = game.keyvalue!.settingsTitle(key, enumKey: defaultValue)
            }
        }
    }
}
