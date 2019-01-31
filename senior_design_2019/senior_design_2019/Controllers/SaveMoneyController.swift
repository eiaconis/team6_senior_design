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

        // Do any additional setup after loading the view.
    }
    

    @IBAction func menuEntryButtonPressed(_ sender: Any) {
        print("menu entry pressed")
    }
    
    @IBAction func manualEntryButtonPressed(_ sender: Any) {
         print("manual entry pressed")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
