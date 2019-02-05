//
//  ManualEntryTransaction.swift - Subclass of Transaction
//  senior_design_2019
//
//  Created by Elena Iaconis on 1/30/19.
//  Copyright © 2019 Team 6. All rights reserved.
//

import Foundation

class ManualEntryTransaction: Transaction {
    
    var category: String?

    init(category: String, userId: String, amount: Double, goalId: String) {
        super.init(userId: userId, amount: amount, goalId: goalId)
        self.category = category
    }
    
    override func isManualEntryTransaction() -> Bool {
        return true
    }
    
    override func getCategory() -> String? {
        return self.category   
    }
}
