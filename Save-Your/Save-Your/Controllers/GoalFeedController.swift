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
    var goalNameToPass : String = ""
    var goalIDToPass : String = ""
    var currDefaultGoalID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTableView()
        
        // Add logo to navigation bar
        let logo = UIImage(named: "saveyour logo-40.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        // Get user's current default goal
        self.database.getUserCurrGoal(uid: (Auth.auth().currentUser?.uid)!) { (goalID) in
            self.currDefaultGoalID = goalID ?? ""
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! UITableViewCell
        self.goalNameToPass = (cell.textLabel?.text)!
        self.goalIDToPass = goalIDs[indexPath.row]
        performSegue(withIdentifier: "goalDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goalDetailSegue") {
            let viewController = segue.destination as! GoalDetailsViewController
            viewController.goalName = goalNameToPass
            viewController.goalID = goalIDToPass
            viewController.currDefaultGoalID = currDefaultGoalID
        }
    }
    
    // Denote anchor for unwinding to goal page
    @IBAction func unwindToGoalFeed(segue:UIStoryboardSegue) {
        updateTableView()
    }
    
    func updateTableView() {
        let goalsClosure = {(returnedGoalIDs: [String]?) -> Void in
            self.goalIDs = returnedGoalIDs ?? []
            self.goalNames = [String]()
            let goalNameClosure = { (goalName : String?) -> Void in
                if goalName != nil {
                    if !self.goalNames.contains(goalName!) {
                        self.goalNames.append(goalName!)
                        self.goalTableView.reloadData()
                    }
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
