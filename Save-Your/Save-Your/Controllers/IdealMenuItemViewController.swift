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
    var currGoalId : String?
    var prevAmount : Double?
    var currTotal : Double?
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
            self.currGoalId = goalId
            self.database.getStateOfGoal(goalId: goalId!, callback: {(prev) -> Void in
                self.prevAmount = prev
            })
        })
        self.database.getUserTotalSavings(uid: (Auth.auth().currentUser?.uid)!, callback: {(totalSav) -> Void in
            self.currTotal = totalSav
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
        print(menu[indexPath.row])
        return cell
    }
    
    
    @IBAction func sizeChange(_ sender: UISegmentedControl) {
        print("# of Segments = \(sender.numberOfSegments)")
        
        switch sender.selectedSegmentIndex {
        case 0:
            print("first segement clicked")
            sizeVal = "tall_price"
        case 1:
            print("second segment clicked")
            sizeVal = "grande_price"
        case 2:
            print("third segemnet clicked")
            sizeVal = "venti_price"
        default:
            break;
        }  //Switch
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Calculate saving.  If item purchased is same as item wanted, don't log a saving.
        var prices : NSDictionary = totalMenu[menu[indexPath.row]]! as! NSDictionary
        var itemWantedPrice = (prices[sizeVal]! as! NSString).doubleValue
        print("price wanted \(itemWantedPrice)")
        var saving = 0.0
        if itemWantedPrice > itemPurchasedPrice {
            saving = itemWantedPrice - itemPurchasedPrice
            print("purchased item = \(itemPurchasedPrice)")
            print("saving = \(saving)")
        
            // Create transaction
            var newTransaction = ManualEntryTransaction(category: "menu", userId: (Auth.auth().currentUser?.uid)!, amount: saving, goalId: currGoalId!)
            var newTotal = self.currTotal! + saving
            saving += self.prevAmount!
            // Add transaction to db
            var newTransactionId = self.database.addTransaction(transaction: newTransaction)
            // Add transaction to user
            self.database.addTransactionToUser(transactionId: newTransactionId!, userId: (Auth.auth().currentUser?.uid)!)
            // Add transaction to goal
            self.database.addTransactionToGoal(transactionId: newTransactionId!, goalId: self.currGoalId!)
            // Update goal--> Get current state, perform operations, update
            self.database.updateGoalAmountSaved(goalId: self.currGoalId!, newAmount: saving)
            self.database.updateUserTotalSavings(uid: (Auth.auth().currentUser?.uid)!, newAmount: newTotal)
        }
        // Go back to homepage
        performSegue(withIdentifier: "unwindSegueToHome", sender: self)
    }

}
