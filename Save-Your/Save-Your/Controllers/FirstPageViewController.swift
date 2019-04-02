//
//  FirstPageViewController.swift
//  senior_design_2019
//
//  Created by OIDUser on 1/31/19.
//  Copyright © 2019 Team 6. All rights reserved.
//

import UIKit

class FirstPageViewController: UIViewController {

    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Pad and round the 'Create Account' Button
        createAccountButton.layer.cornerRadius = 5
        createAccountButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
        // Pad and round the 'Sign In' Button
        signInButton.layer.cornerRadius = 5
        signInButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
    }

}
