//
//  ChangeGoalController.swift
//  senior_design_2019
//
//  Created by OIDUser on 2/15/19.
//  Copyright © 2019 Team 6. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ChangeGoalController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var goalField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    let database : DatabaseAccess = DatabaseAccess.getInstance()
    
    var goalIDs : [String]! = [String]()
    var goalNames : [String]! = [String]()
    var goalSelected : String = ""
    var goalSelectedRow : Int = 0
    var goalSelectedID : String = ""
    var picker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Picker set up
        picker.delegate = self
        picker.dataSource = self
        goalField.inputView = picker
        updatePickerView()
        populatePlaceholderText()
        
        // If screen tapped, dismiss picker
        self.hideKeyboardWhenTappedAround()
        
        // Pad and round the 'Save' Button
        saveButton.layer.cornerRadius = 5
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
        // Add logo to navigation bar
        let logo = UIImage(named: "saveyour logo-40.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return goalNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return goalNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        goalSelected = goalNames[row] as String
        goalSelectedRow = row
        goalSelectedID = goalIDs[row]
        
        // Set label text
        goalField.text = goalSelected
        
        self.view.endEditing(true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        self.database.editGoalInUser(userId: (Auth.auth().currentUser?.uid)!, goalId: goalIDs[goalSelectedRow])
        createAlert(title: "Current goal changed to '\(goalSelected)'")
    }
    
    func updatePickerView() {
        let goalsClosure = {(returnedGoalIDs: [String]?) -> Void in
            self.goalIDs = returnedGoalIDs
            let goalNameClosure = { (goalName : String?) -> Void in
                if goalName != nil {
                    self.goalNames.append(goalName!)
                    self.picker.reloadAllComponents()
                }
            }
            self.goalIDs = returnedGoalIDs ?? []
            for goalID in self.goalIDs {
                self.database.getStringGoalTitle(goalID: goalID, callback: goalNameClosure)
            }
        }
        self.database.getAllGoalsForUser(uid: (Auth.auth().currentUser?.uid)!, callback: goalsClosure)
    }
    
    /* Populates placeholder text in label to current user goal
     */
    func populatePlaceholderText() {
        let placeholderClosure = {(goalID: String?) -> Void in
            self.goalSelectedID = goalID ?? ""
            let goalNameClosure = { (goalName : String?) -> Void in
                if goalName != nil {
                    self.goalField.placeholder = goalName
                    self.goalSelected = goalName ?? ""
                }
            }
            self.database.getStringGoalTitle(goalID: goalID!, callback: goalNameClosure)
        }
        self.database.getUserCurrGoal(uid: (Auth.auth().currentUser?.uid)!, callback: placeholderClosure)
    }
    
    func createAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in self.performSegue(withIdentifier: "unwindSegueToAccountPage", sender: self)}))
        
        self.present(alert, animated: true, completion: nil)
    }

}
