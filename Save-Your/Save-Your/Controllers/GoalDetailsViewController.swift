//
//  GoalDetailsViewController.swift
//  Save-Your
//
//  Created by OIDUser on 4/14/19.
//

import UIKit

class GoalDetailsViewController: UIViewController {

    // Variables
    var database : DatabaseAccess = DatabaseAccess.getInstance()
    var goalID : String = ""
    var goalName : String = ""
    var targetAmount : Double = 0.0
    var amountSaved : Double = 0.0
    
    // Labels
    @IBOutlet weak var goalNameLabel: UILabel!
    @IBOutlet weak var currentAmountLabel: UILabel!
    @IBOutlet weak var percentSavedLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var timeUntilLabel: UILabel!
    
    
    // Bar
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add logo to navigation bar
        let logo = UIImage(named: "saveyour logo-40.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView

        goalNameLabel.text = goalName
        
        // Format progress bar
        progressBar.transform = progressBar.transform.scaledBy(x: 1, y: 20)
        
        self.database.getTargetOfGoal(goalId: self.goalID, callback: {(target) -> Void in
            self.targetAmount = target ?? 0.0
            self.targetLabel.text = "$\(self.formatDouble(amount: self.targetAmount))"
            if self.targetAmount > 0 {
                self.database.getStateOfGoal(goalId: self.goalID, callback: {(amountSaved) -> Void in
                    self.amountSaved = amountSaved ?? 0.0
                    let progress = self.amountSaved / self.targetAmount
                    self.progressBar.setProgress(Float(progress), animated: true)
                    self.percentSavedLabel.text = "\(self.formatDouble(amount: progress * 100))%"
                    self.currentAmountLabel.text = "$\(self.formatDouble(amount: self.amountSaved))"
                })
            }
        })
        
        // Format deadline labels
        self.database.getGoalDeadline(goalID: self.goalID, callback: {(deadline) -> Void in
            if deadline == nil {
                self.deadlineLabel.text = "This goal has no deadline"
                self.timeUntilLabel.text = "Keep saving!"
            } else {
                let goalDeadline = deadline ?? ""
                self.deadlineLabel.text = "Complete by: \(goalDeadline)"
                let difference = self.calculateTimeLeft(deadline: goalDeadline)
                let year = difference[0]
                let month = difference[1]
                let day = difference[2]
                if year <= 0 && month <= 0 && day <= 0 {
                    self.timeUntilLabel.text = "Deadline has already passed"
                } else {
                    self.timeUntilLabel.text = "\(year) years, \(month) months, and \(day) days left!"
                }
            }
            
        })
    }
    
    // Format double from DB to two decimals
    func formatDouble(amount: Double) -> String {
        return String(format: "%.2f", round(100 * amount) / 100)
    }
    
    // Calculate time until deadline in years, months, and days
    // Returns array of number of [years, months, days] left to complete goal
    func calculateTimeLeft(deadline: String) -> [Int] {
        let df = DateFormatter()
        let calendar = Calendar.current
        df.calendar = calendar
        df.dateFormat = "MMM d, yyyy"
        let deadlineDate = df.date(from: deadline)!
        let currentDate = Date()
        let requestedComponents: Set<Calendar.Component> = [.year, .month, .day]
        let difference = calendar.dateComponents(requestedComponents, from: currentDate, to: deadlineDate)
        return [difference.year!, difference.month!, difference.day!]
    }

}
