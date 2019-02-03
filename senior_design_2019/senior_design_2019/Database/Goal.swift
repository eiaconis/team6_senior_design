//
//  Goal.swift
//  senior_design_2019
//
//  Created by Elena Iaconis on 1/30/19.
//  Copyright © 2019 Team 6. All rights reserved.
//

import Foundation

class Goal {
    
    var goalId: String?
    var userId: String?
    var amountSaved: NSNumber?
    var deadline: String?
    var lastSaved: String?
    var title: String?
    var target: Double?
    var transactions: [String]? // Array of all transactions contributing to this goal
    
    // Constructor for goal. All goals must have a userId associated, title, and target amount
    // associated when created.
    init(userId: String, title: String, target: Double) {
        print("creating goal")
        self.userId = userId
        self.title = title
        self.target = target
        self.amountSaved = 0
    }
    
    // Sets goal id to unique identifier created when it is added to database
    func setGoalId(id: String) {
        if goalId == nil {
            self.goalId = id
        }
    }
    
}
