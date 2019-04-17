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
    
    var menu : [Any] = []
    var totalMenu : NSDictionary = [:]
    var itemPurchasedPrice : Double = 0.0
    var currGoalId : String = ""
    var currGoalName : String = ""
    var currGoalAmount : Double = 0.0
    var currGoalTarget : Double = 0.0
    var totalUserSavings : Double = 0.0
    var savingAmountRemaining : Double = 0.0
    var sizeVal = "venti_price"
    
    @IBOutlet weak var size2: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add logo to navigation bar
        let logo = UIImage(named: "saveyour logo-40.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        // Get user's current goal
        self.database.getUserCurrGoal(uid: (Auth.auth().currentUser?.uid)!, callback: {(goalId) -> Void in
            self.currGoalId = goalId ?? ""
            self.database.getStateOfGoal(goalId: self.currGoalId, callback: {(amount) -> Void in
                self.currGoalAmount = amount ?? 0.0
                self.database.getTargetOfGoal(goalId: self.currGoalId, callback: {(target) -> Void in
                    self.currGoalTarget = target ?? 0.0
                })
            })
            self.database.getStringGoalTitle(goalID: self.currGoalId, callback: { (goalName) in
                self.currGoalName = goalName ?? ""
            })
        })
        self.database.getUserTotalSavings(uid: (Auth.auth().currentUser?.uid)!, callback: {(totalSav) -> Void in
            self.totalUserSavings = totalSav ?? 0.0
        })
        self.database.getMenu(callback: {(men) -> Void in
            self.totalMenu = men
            self.menu = men.allKeys
            self.tableView.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = (menu[indexPath.row]) as! String
        cell.textLabel?.font = UIFont(name:"DIN Condensed", size:20)
        return cell
    }
    
    
    @IBAction func sizeChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            sizeVal = "tall_price"
        case 1:
            sizeVal = "grande_price"
        case 2:
            sizeVal = "venti_price"
        default:
            break;
        }  //Switch
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Calculate saving.  If item purchased is same as item wanted, don't log a saving.
        var prices : NSDictionary = totalMenu[menu[indexPath.row]]! as! NSDictionary
        var itemWantedPrice = (prices[sizeVal]! as! NSString).doubleValue
        var saving = 0.0
        if itemWantedPrice > itemPurchasedPrice {
            saving = itemWantedPrice - itemPurchasedPrice
            logSaving(saving: saving)
        
            // Update total savings for user
            let newTotalUserSavings = totalUserSavings + saving
            self.database.updateUserTotalSavings(uid: (Auth.auth().currentUser?.uid)!, newAmount: newTotalUserSavings)
            
            // Check if goal is completed
            let newGoalAmount = saving + currGoalAmount
            if newGoalAmount < currGoalTarget {
                logSaving(saving: saving)
                performSegue(withIdentifier: "unwindSegueToHome", sender: self)
            } else {
                if (currGoalName != "First Time Saver") {
                    self.database.setGoalCompleted(goalID: currGoalId )
                }
                self.savingAmountRemaining = saving - (currGoalTarget - currGoalAmount)
                logSaving(saving: currGoalTarget - currGoalAmount)
                if newGoalAmount == currGoalTarget {
                    // Create completion alert
                    createCompletionAlert()
                } else {
                    // Create exceeds alert
                    createExceedAlert()
                }
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "menuToAddBalance") {
            let viewController = segue.destination as! CompleteAndTransferController
            viewController.savingAmountRemaining = savingAmountRemaining
            viewController.deletedGoalID = currGoalId
        } else if (segue.identifier == "newDefaultGoalSegueFromMenu") {
            let viewController = segue.destination as! NewDefaultGoalController
            viewController.oldCurrGoalID = currGoalId
        }
    }
    
    // Handles logging a saving given the amount
    func logSaving(saving: Double) {
        // Create transaction
        var newTransaction = ManualEntryTransaction(category: "menu", userId: (Auth.auth().currentUser?.uid)!, amount: saving, goalId: currGoalId)
        let newGoalAmount = saving + currGoalAmount
        // Add transaction to db
        var newTransactionId = self.database.addTransaction(transaction: newTransaction)
        // Add transaction to user
        self.database.addTransactionToUser(transactionId: newTransactionId!, userId: (Auth.auth().currentUser?.uid)!)
        // Add transaction to goal
        self.database.addTransactionToGoal(transactionId: newTransactionId!, goalId: self.currGoalId)
        // Update goal--> Get current state, perform operations, update
        self.database.updateGoalAmountSaved(goalId: currGoalId, newAmount: newGoalAmount)
    }
    
    func createCompletionAlert() {
        let alert = UIAlertController(title: "Congratulations!  You reached your goal of '\(self.currGoalName)'!", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: {(action) in self.deleteGoalAndSegueToNewDefault(goalID: self.currGoalId)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func createExceedAlert() {
        let alert = UIAlertController(title: "Congratulations!  You have exceeded your goal of '\(self.currGoalName)'!  Please allocate rest of saving to another goal", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: {(action) in self.deleteGoalAndSegueToSavingAllocation(goalID: self.currGoalId)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Deletes goal and segues to new default goal storyboard
    func deleteGoalAndSegueToNewDefault(goalID: String) {
//        self.database.deleteGoal(goalID: goalID)
        print("deleting goal - not really right now")
        performSegue(withIdentifier: "newDefaultGoalSegueFromMenu", sender: self)
    }
    
    // Deletes goal and segues to allocating extra savings
    func deleteGoalAndSegueToSavingAllocation(goalID: String) {
//        self.database.deleteGoal(goalID: goalID)
        print("deleting goal - not really right now")
        performSegue(withIdentifier: "menuToAddBalance", sender: self)
    }

}
