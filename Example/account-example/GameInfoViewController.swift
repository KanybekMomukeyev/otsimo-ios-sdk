//
//  GameInfoViewController.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 28/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import UIKit
import OtsimoSDK
import Haneke

class GameInfoViewController: UIViewController {
    
    @IBOutlet weak var languagesSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var iconImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var summaryLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    internal var game: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selectedLang = languagesSegmentedControl.titleForSegmentAtIndex(languagesSegmentedControl.selectedSegmentIndex) {
            renderForLanguage(selectedLang)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func languageChanged(sender: UISegmentedControl) {
        if let selectedLang = languagesSegmentedControl.titleForSegmentAtIndex(languagesSegmentedControl.selectedSegmentIndex) {
            renderForLanguage(selectedLang)
        }
    }
    
    func renderForLanguage(lang: String) {
        game?.getManifest() {manifest, error in
            if let man = manifest {
                self.renderForLanguageAndManifest(lang, man: man)
            } else {
                print("Unable to get GameManifest:\(error)")
            }
        }
    }
    
    func renderForLanguageAndManifest(lang: String, man: GameManifest) {
        navigationItem.title = man.localVisibleName
        for md in man.metadatas {
            if md.language == lang {
                nameLabel.text = md.visibleName
                summaryLabel.text = md.summary
                descriptionLabel.text = md.description_p
                let url = otsimo.fixGameAssetUrl(man.gameId, version: man.version, rawUrl: md.icon)
                iconImage.hnk_setImageFromURL(NSURL(string: url)!)
            }
        }
    }
}
