//
//  AddGameToChildViewController.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 01/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import UIKit
import OtsimoSDK
import Kingfisher
import OtsimoApiGrpc

class AddGameToChildViewController: UIViewController {
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    internal var game: Game?
    internal var childList: [OTSChild] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        otsimo.getChildren() {cl, err in
            self.childList.append(contentsOf: cl)
            self.tableView.reloadData()
        }
        if let g = game {
            g.getManifest(initGame)
        }
    }
    
    func initGame(_ gm: GameManifest?, err: OtsimoError) -> Void {
        if let g = gm {
            iconImageView.kf_setImage(with: URL(string: g.localIcon))
            infoLabel.text = "\(g.localVisibleName)\nselect childs to add game"
        }
    }
    
    @IBAction func addPressed(_ sender: AnyObject) {
        for i in tableView.indexPathsForSelectedRows! {
            addGameToChild(childList[(i as NSIndexPath).row])
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelTouched(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func addGameToChild(_ child: OTSChild) {
        otsimo.addGameToChild(game!.id, childID: child.id_p,
            index: Int32(child.gamesArray.count),
            settings: game!.defaultSettings()) {res in
            print("add game finished with \(res)")
        }
    }
}

extension AddGameToChildViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return childList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "add_game_to_child_cell", for: indexPath)
        
        // Configure the cell...
        let c = childList[(indexPath as NSIndexPath).row]
        cell.textLabel!.text = "\(c.firstName) \(c.lastName)"
        cell.accessoryType = UITableViewCellAccessoryType.none;
        return cell
    }
}

extension AddGameToChildViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = UITableViewCellAccessoryType.checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = UITableViewCellAccessoryType.none
    }
}

