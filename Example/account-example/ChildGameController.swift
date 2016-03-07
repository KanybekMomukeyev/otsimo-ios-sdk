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

    func initInfo(gm: GameManifest) {
        navigationItem.title = childGame.manifest!.localVisibleName
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if let gs = self.childGame.settings {
            return gs.properties.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch (indexPath.row) {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("child_game_info_cell", forIndexPath: indexPath)
                cell.textLabel?.text = "\(childGame.manifest!.manifest.uniqueName)"
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("child_game_info_cell", forIndexPath: indexPath)
                cell.textLabel?.text = "Index: \(childGame.index)"
                return cell
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier("child_game_info_boolean_cell", forIndexPath: indexPath) as! BooleanCellViewCell
                cell.titleLabel!.text = "Active"
                cell.booleanSwitch.on = childGame.isActive
                cell.delegate = self
                return cell
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier("child_game_info_cell", forIndexPath: indexPath)
                cell.textLabel?.text = "unknown"
                return cell
            }
        } else {

            return createSettingsCell(tableView, index: indexPath)
        }
    }

    func createSettingsCell(tableView: UITableView, index: NSIndexPath) -> UITableViewCell {
        let prop = childGame.settings!.properties[index.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("settings_property_cell", forIndexPath: index) as!SettingsPropertyViewCell

        cell.initFromProperty(prop.key, childGame: self.childGame, delegate: self)

        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "info"
        } else {
            return "settings"
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            return
        }
//        print(games[indexPath.row].uniqueName, "pressed")
    }

    func propertyValueChanged(value: SettingsPropertyValue) {
        childGame.updateValue(value)
        childGame.saveSettings { e in
            switch (e) {
            case .None:
                print("saved")
            default:
                print("failed to save error:\(e)")
            }
        }
    }

    func activationValueChanged(value: Bool) {
        childGame.isActive = value
    }
}
