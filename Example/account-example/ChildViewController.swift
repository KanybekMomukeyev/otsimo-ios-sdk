//
//  ChildViewController.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 02/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import UIKit
import OtsimoApiGrpc
import OtsimoSDK
import Kingfisher

class ChildViewController: UITableViewController {
    
    var childIdWillFetch: String = ""
    
    var infos: [String] = []
    var targetChild: OTSChild?
    var gameEntries: [ChildGame] = []
    var fetchedGames: [ChildGame] = []
    var selectedGameEntry: ChildGame?
    override func viewDidLoad() {
        super.viewDidLoad()
        otsimo.getChild(childIdWillFetch, handler: getChildHandler)
    }
    
    func getChildHandler(_ child: OTSChild?, err: OtsimoError) {
        infos.removeAll()
        targetChild = child
        if let child = child {
            infos.append("name: \(child.firstName) \(child.lastName)")
            infos.append("id: \(child.id_p)")
            infos.append("parent: \(child.parentId)")
            infos.append("language: \(child.language)")
            if child.gender == OTSGender.male {
                infos.append("gender: Male")
            } else if child.gender == OTSGender.female {
                infos.append("gender: Female")
            }
            infos.append("active: \(child.active)")
            
            tableView.reloadData()
            
            gameEntries = child.getGames()
            for e in gameEntries {
                print("getting the game", e.gameID)
                e.initialize(true, initKeyValueStorage: true, handler: getGameHandler)
            }
        }
    }
    
    func getGameHandler(_ game: ChildGame, error: OtsimoError) {
        switch (error) {
        case .none:
            fetchedGames.append(game)
            tableView.reloadData()
        default:
            print("failed to fetch \(game.gameID) error:\(error)")
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return infos.count
        } else {
            return fetchedGames.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "child_info_cell", for: indexPath)
            
            cell.textLabel?.text = infos[(indexPath as NSIndexPath).row]
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "child_game_cell", for: indexPath as IndexPath)
            cell.textLabel?.text = "loading..."
            let game = fetchedGames[indexPath.row]
            if let man = game.manifest {
                cell.textLabel?.text = man.localVisibleName
                if let url = URL(string: man.localIcon) {
                    cell.imageView!.kf_setImage(with: url)
                }
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 0 {
            return "info"
        } else {
            return "games"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            return
        }
        selectedGameEntry = fetchedGames[indexPath.row]
        performSegue(withIdentifier: "show_child_game_entry", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_child_game_entry" {
            let cgc = segue.destination as! ChildGameController
            cgc.childGame = selectedGameEntry
        }
    }
}
