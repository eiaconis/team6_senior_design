//
//  ViewController.swift
//  spend_to_save
//
//  Created by OIDUser on 11/6/18.
//  Copyright © 2018 OIDUser. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {
    
    let database: DatabaseAccess = DatabaseAccess.getInstance()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        print("login button pressed")

    }
    
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        print("create account button pressed")

    }

}

