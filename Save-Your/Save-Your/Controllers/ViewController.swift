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
        
        // If screen tapped, dismiss keyboard
        self.hideKeyboardWhenTappedAround()
        
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        database.login(email: emailTextField.text!, password: passwordTextField.text!, view: self)
    }
    
    // Denote anchor for unwinding to upon logout
    @IBAction func unwindToLogout(segue:UIStoryboardSegue) { }
    

}

// Extension of View Controller to dismiss keyboard when screen is tapped
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

