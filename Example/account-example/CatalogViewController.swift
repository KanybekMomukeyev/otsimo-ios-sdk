//
//  CatalogViewController.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 25/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import UIKit
import OtsimoApiGrpc
import OtsimoSDK
import Kingfisher

class CatalogViewController: UITableViewController {

    var items: [OTSCatalogCategory: [OTSCatalogItem]] = [OTSCatalogCategory: [OTSCatalogItem]]()

    var catalog: OTSCatalog? {
        didSet {
            processItems()
        }
    }

    func processItems() {
        items.removeAll()
        if let cat = catalog {
            for i in 0 ..< Int(cat.itemsArray_Count) {
                let item = cat.itemsArray[i] as? OTSCatalogItem
                if let item = item {
                    if let _ = items[item.category] {
                        items[item.category]?.append(item)
                        items[item.category]?.sort(by: { $0.index < $1.index})
                    } else {
                        items[item.category] = [item]
                    }
                }
            }
        }
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        otsimo.getCatalog() { cat, error in
            switch (error) {
            case .none:
                if let c = cat {
                    self.catalog = c
                }
            default:
                print("error occured: \(error)")
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let index = items.index(items.startIndex, offsetBy: section) // index 1
        let key = items.keys[index]
        if let arr = items[key] {
            print("\(OTSCatalogCategory_EnumDescriptor().enumName(forValue: key.rawValue)!) has \(arr.count)")
            return arr.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let index = items.index(items.startIndex, offsetBy: section) // index 1
        let key = items.keys[index]
        return "\(OTSCatalogCategory_EnumDescriptor().enumName(forValue: key.rawValue)!)"
    }

    func updateCell(_ cell: GameTableCellView, ci: OTSCatalogItem?) {
        if let item = ci {
            otsimo.getGame(item.gameId) { g, e in
                if let game = g {
                    game.getManifest() { man, error in
                        if let m = man {
                            cell.titlLabel?.text = m.localVisibleName
                            cell.versionLabel?.text = m.version
                            let url = NSURL(string: m.localIcon)
                            cell.imageLabel.kf_setImage(with: url as? Resource,
                                                        placeholder: nil,
                                                        options: [.transition(.fade(1))],
                                                        progressBlock: nil,
                                                        completionHandler: nil)
                        } else {
                            print("failed to get manifes")
                        }
                    }
                } else {
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "game_table_reuse_identifier", for: indexPath as IndexPath) as! GameTableCellView

        let index = items.index(items.startIndex, offsetBy: (indexPath as NSIndexPath).section) // index 1
        let key = items.keys[index]
        var ci : OTSCatalogItem? = nil
        if let arr = items[key] {
            ci = arr[(indexPath as NSIndexPath).row]
        }
        updateCell(cell, ci: ci)
        return cell
    }

    fileprivate var selectedGame: Game?

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = items.index(items.startIndex, offsetBy: (indexPath as NSIndexPath).section) // index 1
        let key = items.keys[index]
        if let arr = items[key] {
            let ci = arr[(indexPath as NSIndexPath).row]
            selectedGame = Game(gameId: ci.gameId)
            performSegue(withIdentifier: "gameinfotest", sender: tableView)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let id = segue.identifier {
            if id != "gameinfotest" {
                return
            }
        } else {
            return
        }
        let gic = segue.destination as! GameInfoViewController
        gic.game = selectedGame
    }
}
