//
//  NewDefaultGoalController.swift
//  Save-Your
//
//  Created by OIDUser on 4/15/19.
//

import UIKit
import FirebaseAuth

class NewDefaultGoalController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Variables
    let database: DatabaseAccess = DatabaseAccess.getInstance()
    var picker = UIPickerView()
    var goalNames : [String] = [String]()
    var goalNameToID : [String: String] = [:]
    var goalSelected : String = ""
    var goalSelectedID : String = ""
    var oldCurrGoalID : String = ""
    var accessedThruGoalPage : Bool = false
    
    // Fields
    @IBOutlet weak var goalField: UITextField!
    
    // Buttons
    @IBOutlet weak var confirmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If screen tapped, dismiss picker
        self.hideKeyboardWhenTappedAround()
        
        // Picker set up
        picker.delegate = self
        picker.dataSource = self
        goalField.inputView = picker
        updatePickerView()
        
        // Pad and round the 'Save' Button
        confirmButton.layer.cornerRadius = 5
        confirmButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
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
        goalSelectedID = goalNameToID[goalSelected]!
        
        // Set label text
        goalField.text = goalSelected
        
        self.view.endEditing(true)
    }
    
    // Function to load picker view with goal names for user
    func updatePickerView() {
        let goalsClosure = {(returnedGoalIDs: [String]?) -> Void in
            let goalIDs = returnedGoalIDs ?? []
            for goalID in goalIDs {
                let goalNameClosure = { (goalName : String?) -> Void in
                    if goalName != nil {
                        self.goalNames.append(goalName!)
                        self.goalNameToID[goalName!] = goalID
                        self.picker.reloadAllComponents()
                    }
                }
                if goalID != self.oldCurrGoalID {
                    self.database.getStringGoalTitle(goalID: goalID, callback: goalNameClosure)
                }
            }
        }
        self.database.getAllGoalsForUser(uid: (Auth.auth().currentUser?.uid)!, callback: goalsClosure)
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        self.database.editGoalInUser(userId: (Auth.auth().currentUser?.uid)!, goalId: goalSelectedID)
        createAlert(title: "Default goal changed to '\(goalSelected)'")
    }
    
    func createAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in self.properSegue()}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Determines proper segue based on how storyboard was accessed
    func properSegue() {
        if accessedThruGoalPage {
            performSegue(withIdentifier: "unwindSegueToGoalFeed", sender: self)
        } else {
            performSegue(withIdentifier: "unwindSegueToHome", sender: self)
        }
    }
    

}
