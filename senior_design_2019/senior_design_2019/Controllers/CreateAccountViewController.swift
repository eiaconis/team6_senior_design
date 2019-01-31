//
//  CreateAccountViewController.swift
//  spend_to_save
//
//  Created by Elena Iaconis on 12/6/18.
//  Copyright © 2018 OIDUser. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController {
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Pad and round the 'Continue' Button
        continueButton.layer.cornerRadius = 5
        continueButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        print("continueButton pressed")
    }
    
}

