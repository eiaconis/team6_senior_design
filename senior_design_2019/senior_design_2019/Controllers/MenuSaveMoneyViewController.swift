//
//  MenuSaveMoneyViewController.swift
//  spend_to_save
//
//  Created by OIDUser on 12/6/18.
//  Copyright © 2018 OIDUser. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseUI

class MenuSaveMoneyViewController: UIViewController {
    
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var database : DatabaseAccess = DatabaseAccess.getInstance()
    var currGoalId : String?
    var prevAmount : Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Pad and round the 'Save' Button
        saveButton.layer.cornerRadius = 5
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        self.database.getUserCurrGoal(uid: (Auth.auth().currentUser?.uid)!, callback: {(goalId) -> Void in
            print("got goalid")
            print(goalId)
            self.currGoalId = goalId
            self.database.getStateOfGoal(goalId: goalId!, callback: {(prev) -> Void in
                print("got prev")
                print(prev)
                self.prevAmount = prev
            })
        })
    }
    

    @IBAction func saveButtonPressed(_ sender: Any) {
        print("save pressed")
        print("save in menu pressed")
        // Get value from amount field
        var currAmount = Double(valueTextField.text!)
        // If amount field is blank or negative, popup error and stay
        if (currAmount == nil || currAmount! <= 0.0) {
            // TODO:
            return
        }
        
        // Create transaction-- TODO: make this menu item not
        var newTransaction = ManualEntryTransaction(category: "menu", userId: (Auth.auth().currentUser?.uid)!, amount: currAmount!, goalId: currGoalId!)
        currAmount! += self.prevAmount!
        // Add transaction to db
        var newTransactionId = self.database.addTransaction(transaction: newTransaction)
        // Add transaction to user
        self.database.addTransactionToUser(transactionId: newTransactionId!, userId: (Auth.auth().currentUser?.uid)!)
        // Add transaction to goal
        self.database.addTransactionToGoal(transactionId: newTransactionId!, goalId: self.currGoalId!)
        // Update goal--> Get current state, perform operations, update
        self.database.updateGoalAmountSaved(goalId: self.currGoalId!, newAmount: currAmount!)
        
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
