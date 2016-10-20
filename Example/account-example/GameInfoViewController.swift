//
//  GameInfoViewController.swift
//  OtsimoSDK_Example
//
//  Created by Sercan Değirmenci on 28/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import UIKit
import OtsimoSDK
import Kingfisher

class GameInfoViewController: UIViewController {

    @IBOutlet weak var languagesSegmentedControl: UISegmentedControl!

    @IBOutlet weak var iconImage: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var summaryLabel: UILabel!

    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var imageCollectionView: UICollectionView!
    internal var game: Game?

    internal var language: String = ""
    internal var images: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollectionView.dataSource = self
        if let selectedLang = languagesSegmentedControl.titleForSegment(at: languagesSegmentedControl.selectedSegmentIndex) {
            renderForLanguage(selectedLang)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func languageChanged(_ sender: UISegmentedControl) {
        if let selectedLang = languagesSegmentedControl.titleForSegment(at: languagesSegmentedControl.selectedSegmentIndex) {
            renderForLanguage(selectedLang)
        }
    }

    func renderForLanguage(_ lang: String) {
        language = lang
        game?.getManifest() { manifest, error in
            if let man = manifest {
                self.renderForLanguageAndManifest(lang, man: man)
            } else {
                print("Unable to get GameManifest:\(error)")
            }
        }
    }

    func renderForLanguageAndManifest(_ lang: String, man: GameManifest) {
        navigationItem.title = man.localVisibleName
        for md in man.metadatas {
            if md.language == lang {
                nameLabel.text = md.visibleName
                summaryLabel.text = md.summary
                descriptionLabel.text = md.description_p
                let url = otsimo.fixGameAssetUrl(man.gameId, version: man.version, rawUrl: md.icon)
                iconImage.kf_setImage(with:NSURL(string: url) as! Resource?)
                images = md.imagesArray as AnyObject as![String]
                images.removeAll()
                for i in md.imagesArray {
                    if let im = i as? String {
                        let u = otsimo.fixGameAssetUrl(man.gameId, version: man.version, rawUrl: im)
                        images.append(u)
                    }
                }
                imageCollectionView.reloadData()
            }
        }
    }

    @IBAction func addTouched(_ sender: UIButton) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddGameToChildViewController") as! AddGameToChildViewController
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        vc.game = self.game
        vc.preferredContentSize = CGSize(width: 300, height: 300)

        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.sourceView = sender
        popover.delegate = self
        popover.sourceRect = CGRect(x: 0, y: 0, width: sender.frame.size.width, height: sender.frame.size.height)

        present(vc, animated: true, completion: nil)
    }
}

extension GameInfoViewController: UICollectionViewDataSource {
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count;
    }

    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }

    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.imageCollectionView.dequeueReusableCell(withReuseIdentifier: "game_image_cell", for: indexPath) as! GameImageViewCell
        cell.image.kf_setImage(with: URL(string: images[indexPath.row])!)
        return cell
    }
}

extension GameInfoViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(
        for controller: UIPresentationController) -> UIModalPresentationStyle {
            return UIModalPresentationStyle.none
    }
}
