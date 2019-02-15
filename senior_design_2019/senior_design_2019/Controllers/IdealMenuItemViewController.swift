//
//  IdealMenuItemViewController.swift
//  spend_to_save
//
//  Created by OIDUser on 12/6/18.
//  Copyright © 2018 OIDUser. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class IdealMenuItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let database : DatabaseAccess = DatabaseAccess.getInstance()
    
    let menu = ["Small Coffee", "Medium Coffee", "Large Coffee"]
    let menuPrice = [1.00, 2.00, 3.00]
    var itemPurchasedPrice : Double = 0.0
    var currGoalId : String?
    var prevAmount : Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get user's current goal
        self.database.getUserCurrGoal(uid: (Auth.auth().currentUser?.uid)!, callback: {(goalId) -> Void in
            self.currGoalId = goalId
            self.database.getStateOfGoal(goalId: goalId!, callback: {(prev) -> Void in
                self.prevAmount = prev
            })
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = menu[indexPath.row]
        cell.textLabel?.font = UIFont(name:"DIN Condensed", size:20)
        print(menu[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Calculate saving.  If item purchased is same as item wanted, don't log a saving.
        var itemWantedPrice = menuPrice[indexPath.row]
        var saving = 0.0
        if itemWantedPrice > itemPurchasedPrice {
            saving = itemWantedPrice - itemPurchasedPrice
            print("purchased item = \(itemPurchasedPrice)")
            print("saving = \(saving)")
        
            // Create transaction
            var newTransaction = ManualEntryTransaction(category: "menu", userId: (Auth.auth().currentUser?.uid)!, amount: saving, goalId: currGoalId!)
            saving += self.prevAmount!
            // Add transaction to db
            var newTransactionId = self.database.addTransaction(transaction: newTransaction)
            // Add transaction to user
            self.database.addTransactionToUser(transactionId: newTransactionId!, userId: (Auth.auth().currentUser?.uid)!)
            // Add transaction to goal
            self.database.addTransactionToGoal(transactionId: newTransactionId!, goalId: self.currGoalId!)
            // Update goal--> Get current state, perform operations, update
            self.database.updateGoalAmountSaved(goalId: self.currGoalId!, newAmount: saving)
        }
        // Go back to homepage
        self.performSegue(withIdentifier: "backToMain", sender: self)
    }

}
