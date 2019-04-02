//
//  SaveMoneyController.swift
//  spend_to_save
//
//  Created by OIDUser on 11/6/18.
//  Copyright © 2018 OIDUser. All rights reserved.
//

import UIKit

class SaveMoneyController: UIViewController {

    @IBOutlet weak var menuEntryButton: UIButton!
    @IBOutlet weak var manualEntryButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add logo to navigation bar
        let logo = UIImage(named: "saveyour logo-40.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    

    @IBAction func menuEntryButtonPressed(_ sender: Any) {
        print("menu entry pressed")
    }
    
    @IBAction func manualEntryButtonPressed(_ sender: Any) {
        print("manual entry pressed")
    }

}
