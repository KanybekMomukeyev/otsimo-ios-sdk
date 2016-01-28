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
import Haneke

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
            for i in 0..<Int(cat.itemsArray_Count) {
                let item = cat.itemsArray[i] as? OTSCatalogItem
                if let item = item {
                    if let _ = items[item.category] {
                        items[item.category]?.append(item)
                        items[item.category]?.sortInPlace({$0.index < $1.index})
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
        
        otsimo.getCatalog() {cat, error in
            switch (error) {
            case .None:
                if let c = cat {
                    self.catalog = c
                }
            default:
                print("error occured: \(error)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let index = items.startIndex.advancedBy(section) // index 1
        let key = items.keys[index]
        if let arr = items[key] {
            print("\(OTSCatalogCategory_EnumDescriptor().enumNameForValue(key.rawValue)!) has \(arr.count)")
            return arr.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let index = items.startIndex.advancedBy(section) // index 1
        let key = items.keys[index]
        return "\(OTSCatalogCategory_EnumDescriptor().enumNameForValue(key.rawValue)!)"
    }
    
    func updateCell(cell: GameTableCellView, ci: OTSCatalogItem?) {
        if let item = ci {
            let game: Game = item.getGame()
            game.getManifest() {man, error in
                if let m = man {
                    cell.titlLabel?.text = m.localVisibleName
                    cell.versionLabel?.text = m.version
                    cell.imageLabel.hnk_setImageFromURL(NSURL(string: m.localIcon)!)
                } else {
                    print("failed to get manifes")
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("game_table_reuse_identifier", forIndexPath: indexPath) as! GameTableCellView
        
        let index = items.startIndex.advancedBy(indexPath.section) // index 1
        let key = items.keys[index]
        var ci : OTSCatalogItem? = nil
        if let arr = items[key] {
            ci = arr[indexPath.row]
        }
        updateCell(cell, ci: ci)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /*   let child = childList[indexPath.row]
         selectedChildId = child.id_p
         print("clicked on '\(selectedChildId)'")
         performSegueWithIdentifier("getchildtest", sender: tableView)
         */
    }
}

