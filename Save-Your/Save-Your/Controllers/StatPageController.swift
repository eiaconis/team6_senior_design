//
//  StatPageController.swift
//  Save-Your
//
//  Created by OIDUser on 3/30/19.
//

import UIKit
import FirebaseAuth

class StatPageController: UIViewController {
    
    // Variables
    var database : DatabaseAccess = DatabaseAccess.getInstance()

    // Labels
    @IBOutlet weak var amountSavedLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add logo to navigation bar
        let logo = UIImage(named: "saveyour logo-40.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        // Read data from db for appropriate text rendering
        var currAmount = 0.0
        var goalName = ""
        var targetGoalAmt = 0.0
        self.database.getUserCurrGoal(uid: Auth.auth().currentUser!.uid, callback: {(goalId) -> Void in
            if (goalId == nil) {
                // Add Goal and update user's current goal
                let defaultGoal = Goal(userId: (Auth.auth().currentUser?.uid)!, title: "First Time Saver", target: 100.00)
                var goalId = self.database.addGoal(goal: defaultGoal)
                self.database.addGoalToUser(goalId: goalId, userId: (Auth.auth().currentUser?.uid)!)
                self.database.editGoalInUser(userId: (Auth.auth().currentUser?.uid)!, goalId: goalId)
                self.amountSavedLabel.text = "You have saved $\(0) towards First Time Saver"
                self.percentLabel.text = "\0% of the way there.  Keep saving!"
            } else {
            self.database.getStateOfGoal(goalId: goalId!, callback: {(amount) -> Void in
                print("goal amount = \(amount!)")
                currAmount = amount ?? 0.0
                self.database.getStringGoalTitle(goalID: goalId!, callback: {(name) -> Void in
                    goalName = name ?? "goal"
                    let formattedAmount = self.formatDouble(amount: currAmount)
                    self.amountSavedLabel.text = "You have saved $\(formattedAmount) towards \(goalName)"
                })
            })
            self.database.getTargetOfGoal(goalId: goalId!, callback: {(target) -> Void in
                print("got target amount = \(target!)")
                targetGoalAmt = target ?? 0.0
                let percentage = (currAmount / targetGoalAmt) * 100
                let truncPercentage = self.formatDouble(amount: percentage)
                self.percentLabel.text = "\(truncPercentage)% of the way there.  Keep saving!"
            })
            }
        })
    }
    
    // Format double from DB to two decimals
    func formatDouble(amount: Double) -> String {
        return String(format: "%.2f", round(100 * amount) / 100)
    }

}
