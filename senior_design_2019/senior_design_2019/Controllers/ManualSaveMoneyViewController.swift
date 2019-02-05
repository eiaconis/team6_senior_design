//
//  ManualSaveMoneyViewController.swift
//  spend_to_save
//
//  Created by OIDUser on 12/6/18.
//  Copyright © 2018 OIDUser. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseUI

class ManualSaveMoneyViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var categoryLabel: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    let database: DatabaseAccess = DatabaseAccess.getInstance()
    var currGoalId : String?
    var prevAmount : Double?
    
    var categories = ["Food", "Transportation", "Entertainment", "Rent", "Shopping"]
    var picker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.dataSource = self
        categoryLabel.inputView = picker
        
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryLabel.text = categories[row]
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        print("save in manual pressed")
        // Get value from amount field
        var currAmount = Double(amountTextField.text!)
        // If amount field is blank or negative, popup error and stay
        if (currAmount == nil || currAmount! <= 0.0) {
            // TODO:
        }
        currAmount! += self.prevAmount!
        // Else get category
        let currCategory = categoryLabel.text!
        
        // Create transaction
        var newTransaction = ManualEntryTransaction(category: currCategory, userId: (Auth.auth().currentUser?.uid)!, amount: currAmount!, goalId: self.currGoalId!)
        // Add transaction to db
        var newTransactionId = self.database.addTransaction(transaction: newTransaction)
        // Add transaction to user
        self.database.addTransactionToUser(transactionId: newTransactionId!, userId: (Auth.auth().currentUser?.uid)!)
        // Add transaction to goal
        self.database.addTransactionToGoal(transactionId: newTransactionId!, goalId: self.currGoalId!)
        // Update goal--> Get current state, perform operations, update
        self.database.updateGoalAmountSaved(goalId: self.currGoalId!, newAmount: currAmount!)
        
    }
}
