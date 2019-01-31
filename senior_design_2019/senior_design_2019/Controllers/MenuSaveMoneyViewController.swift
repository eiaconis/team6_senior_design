//
//  MenuSaveMoneyViewController.swift
//  spend_to_save
//
//  Created by OIDUser on 12/6/18.
//  Copyright © 2018 OIDUser. All rights reserved.
//

import UIKit

class MenuSaveMoneyViewController: UIViewController {
    
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Pad and round the 'Save' Button
        saveButton.layer.cornerRadius = 5
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
    }
    

    @IBAction func saveButtonPressed(_ sender: Any) {
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
