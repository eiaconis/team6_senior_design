//
//  MoneyValueViewController.swift
//  spend_to_save
//
//  Created by OIDUser on 1/25/19.
//  Copyright © 2019 OIDUser. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase



class MoneyValueViewController: UIViewController {

    var database : DatabaseAccess = DatabaseAccess.getInstance()
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var currentAmountLabel: UILabel!
    @IBOutlet weak var progressPercentageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pad and round the 'Logout' Button
        logoutButton.layer.cornerRadius = 5
        logoutButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
        // Pad and round the '+' Button
        plusButton.layer.cornerRadius = 5
        plusButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
        // Read data from db for appropriate text rendering
        var currAmount = 0.0
        self.database.getUserCurrGoal(uid: Auth.auth().currentUser!.uid, callback: {(goalId) -> Void in
            print("got goal id")
            print(goalId ?? "Something went wrong getting goal id.")
            self.database.getStateOfGoal(goalId: goalId!, callback: {(amount) -> Void in
                print("got goal amount")
                print(amount!)
                currAmount = amount!
                // TODO: make this what is displayed
                self.currentAmountLabel.text = "\(amount!)"
            })
            self.database.getTargetOfGoal(goalId: goalId!, callback: {(target) -> Void in
                print("got target amount")
                print(target!)
                let percentage = (currAmount / target!)*100
                // TODO: make this what is displayed
//                self.progressPercentageLabel.text = "\(percentage)"
                self.progressPercentageLabel.text = "\(currAmount) %"

            })
        })
    
    }

}
