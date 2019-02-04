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
            print(goalId)
            self.database.getStateOfGoal(goalId: goalId!, callback: {(amount) -> Void in
                print("got goal amount")
                print(amount!)
                // TODO: make this what is displayed
            })
        })
    
    }
    
    
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        print("signout pressed")
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
