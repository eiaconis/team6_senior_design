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
        let currAmount = Double(amountTextField.text!)
        // If amount field is blank or negative, popup error and stay
        if (currAmount == nil || currAmount! <= 0.0) {
            // TODO:
        }
        // Else get category
        let currCategory = categoryLabel.text!
        //Get current user's goal
        var currGoalId : String? = nil
        self.database.getUserCurrGoal(uid: (Auth.auth().currentUser?.uid)!, callback: {(goalId) -> Void in
                    print("got goalid")
                    print(goalId)
                    currGoalId = goalId
                    // Create transaction
                    var newTransaction = ManualEntryTransaction(category: currCategory, userId: (Auth.auth().currentUser?.uid)!, amount: currAmount!, goalId: currGoalId!)
                    // Add transaction to db
                    self.database.addTransaction(transaction: newTransaction)
                })

        
        // Add transaction to user
        // Add transaction to goal
        // Update goal
    }
}
