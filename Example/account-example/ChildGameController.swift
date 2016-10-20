//
//  ChildGameController.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 04/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import UIKit
import OtsimoSDK
import OtsimoApiGrpc

class ChildGameController: UITableViewController, SettingsPropertyDelegate {
    var childGame: ChildGame!

    override func viewDidLoad() {
        super.viewDidLoad()
        initInfo(childGame.manifest!)
    }

    func initInfo(_ gm: GameManifest) {
        navigationItem.title = childGame.manifest!.localVisibleName
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if let gs = self.childGame.settings {
            return gs.properties.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "child_game_info_cell", for: indexPath)
                cell.textLabel?.text = "\(childGame.manifest!.manifest.uniqueName)"
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "child_game_info_cell", for: indexPath)
                cell.textLabel?.text = "Index: \(childGame.index)"
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "child_game_info_boolean_cell", for: indexPath) as! BooleanCellViewCell
                cell.titleLabel!.text = "Active"
                cell.booleanSwitch.isOn = childGame.isActive
                cell.delegate = self
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "child_game_info_cell", for: indexPath)
                cell.textLabel?.text = "unknown"
                return cell
            }
        } else {

            return createSettingsCell(tableView, index: indexPath)
        }
    }

    func createSettingsCell(_ tableView: UITableView, index: IndexPath) -> UITableViewCell {
        let prop = childGame.settings!.properties[index.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "settings_property_cell", for: index) as!SettingsPropertyViewCell

        cell.initFromProperty(prop.key, childGame: self.childGame, delegate: self)

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "info"
        } else {
            return "settings"
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            return
        }
//        print(games[indexPath.row].uniqueName, "pressed")
    }

    func propertyValueChanged(_ value: SettingsPropertyValue) {
        childGame.updateValue(value)
        childGame.saveSettings { e in
            switch (e) {
            case .none:
                print("saved")
            default:
                print("failed to save error:\(e)")
            }
        }
    }

    func activationValueChanged(_ value: Bool) {
        childGame.isActive = value
    }
}
