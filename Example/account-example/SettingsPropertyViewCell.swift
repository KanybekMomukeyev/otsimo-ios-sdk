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
    func propertyValueChanged(value: SettingsPropertyValue)
    func activationValueChanged(value: Bool)
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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    @IBAction func onNumberEditingEnded(sender: UITextField) {
        switch (setProp!) {
        case .Integer(_, _):
            if let val = Int(sender.text!) {
                delegate.propertyValueChanged(.Integer(key: key, value: val))
            } else {
                print("wrong integer format")
            }
        case .Float(_, _):
            if let val = Float64(sender.text!) {
                delegate.propertyValueChanged(.Float(key: key, value: val))
            } else {
                print("wrong integer format")
            }
        default:
            print("invalid property")
        }
    }

    @IBAction func booleanChanged(sender: UISwitch) {
        delegate.propertyValueChanged(.Boolean(key: key, value: sender.on))
    }

    @IBAction func onStringEditingEnded(sender: UITextField) {
        delegate.propertyValueChanged(.Text(key: key, value: sender.text!))
    }
    // number of column
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    // number of row
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return enumValues.count
    }

    // Title
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return game.keyvalue!.settingsTitle(key, enumKey: enumValues[row])
    }

    // update enum label when value changed
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        enumLabel.text = game.keyvalue!.settingsTitle(key, enumKey: enumValues[row])
        enumLabel.resignFirstResponder()
        delegate.propertyValueChanged(.Text(key: key, value: enumValues[row]))
    }

    func initFromProperty(key: String, childGame: ChildGame, delegate: SettingsPropertyDelegate) {
        self.key = key
        self.game = childGame
        self.setProp = childGame.settings!.getFromKey(key)!
        self.delegate = delegate

        let vp = childGame.valueFor(key)

        self.booleanSwitch.enabled = false
        self.booleanSwitch.hidden = true

        self.numberText.enabled = false
        self.numberText.hidden = true

        self.stringText.enabled = false
        self.stringText.hidden = true

        self.enumLabel.enabled = false
        self.enumLabel.hidden = true

        self.titleLabel.text = childGame.keyvalue!.settingsTitle(key)
        self.descriptionText.text = childGame.keyvalue!.settingsDescription(key)

        switch (setProp!) {
        case .Boolean(_, let defaultValue):
            self.booleanSwitch.enabled = true
            self.booleanSwitch.hidden = false

            if let v = vp {
                booleanSwitch.on = v.boolean
            } else {
                booleanSwitch.on = defaultValue
            }
        case .Integer(_, let defaultValue):
            self.numberText.enabled = true
            self.numberText.hidden = false

            if let v = vp {
                numberText.text = "\(v.integer)"
            } else {
                numberText.text = "\(defaultValue)"
            }
        case .Float(_, let defaultValue):
            self.numberText.enabled = true
            self.numberText.hidden = false

            if let v = vp {
                numberText.text = "\(v.float)"
            } else {
                numberText.text = "\(defaultValue)"
            }
        case .Text(_, let defaultValue):
            self.stringText.enabled = true
            self.stringText.hidden = false

            if let v = vp {
                stringText.text = "\(v.string)"
            } else {
                stringText.text = "\(defaultValue)"
            }
        case .Enum(_, let defaultValue, let values):
            self.enumLabel.enabled = true
            self.enumLabel.hidden = false
            enumValues.removeAll()
            enumValues.appendContentsOf(values)
            if let v = vp {
                enumLabel.text = game.keyvalue!.settingsTitle(key, enumKey: v.string)
            } else {
                enumLabel.text = game.keyvalue!.settingsTitle(key, enumKey: defaultValue)
            }
        }
    }
}
