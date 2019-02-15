//
//  ChangeGoalController.swift
//  senior_design_2019
//
//  Created by OIDUser on 2/15/19.
//  Copyright © 2019 Team 6. All rights reserved.
//

import UIKit

class ChangeGoalController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var goalPicker: UIPickerView!
    
    let database : DatabaseAccess = DatabaseAccess.getInstance()
    var goalIDs : [String]! = [String]()
    var goalNames : [String]! = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePickerView()
        print("Checking goals...")
        print("goal ids = \(goalIDs)")
        for goal in goalIDs {
            print(goal)
        }
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
    
    func updatePickerView() {
        let goalsClosure = {(returnedGoalIDs: [String]?) -> Void in
            self.goalIDs = returnedGoalIDs
            let goalNameClosure = { (goalName : String?) -> Void in
                if goalName != nil {
                    self.goalNames.append(goalName!)
                    self.goalPicker.reloadAllComponents()
                }
            }
            self.goalIDs = returnedGoalIDs ?? []
            for goalID in self.goalIDs {
                self.database.getStringGoalTitle(goalID: goalID, callback: goalNameClosure)
            }
        }
        self.database.getAllGoalsForUser(callback: goalsClosure)
    }

}
