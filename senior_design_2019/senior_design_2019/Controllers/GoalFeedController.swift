//
//  GoalFeedController.swift
//  senior_design_2019
//
//  Created by OIDUser on 2/18/19.
//  Copyright © 2019 Team 6. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class GoalFeedController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let database : DatabaseAccess = DatabaseAccess.getInstance()
    
    @IBOutlet weak var goalTableView: UITableView!
    
    
    var goalIDs : [String] = [String]()
    var goalNames : [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTableView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goalNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "goalCell")
        cell.textLabel?.text = goalNames[indexPath.row]
        cell.textLabel?.font = UIFont(name:"DIN Condensed", size:20)
        return cell
    }
    
    func updateTableView() {
        let goalsClosure = {(returnedGoalIDs: [String]?) -> Void in
            self.goalIDs = returnedGoalIDs ?? []
            let goalNameClosure = { (goalName : String?) -> Void in
                if goalName != nil {
                    self.goalNames.append(goalName!)
                    self.goalTableView.reloadData()
                }
            }
            self.goalIDs = returnedGoalIDs ?? []
            for goalID in self.goalIDs {
                self.database.getStringGoalTitle(goalID: goalID, callback: goalNameClosure)
            }
        }
        self.database.getAllGoalsForUser(uid: (Auth.auth().currentUser?.uid)!, callback: goalsClosure)
    }

}
