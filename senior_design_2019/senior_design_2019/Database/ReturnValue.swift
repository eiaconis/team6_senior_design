//
//  ReturnValue.swift- Class to handle invalid return values.
//  senior_design_2019
//
//  Created by Elena Iaconis on 2/2/19.
//  Copyright © 2019 Team 6. All rights reserved.
//

import Foundation
import UIKit

class ReturnValue<T> : Error {
    
    let returned_error : Bool
    let error_message : String?
    let error_number : Int
    let data : T?
    var localizedDescription: String? = nil
    
    
    init(error returned_error: Bool, data : T? = nil, error_message : String = "", error_number : Int? = nil) {
        self.returned_error = returned_error
        self.error_message = returned_error ? error_message : nil
        self.error_number = returned_error ? error_number! : 0
        self.data = returned_error ? nil : data
        self.localizedDescription = getErrorDescription()
    }
    
    func getErrorDescription() -> String {
        switch (self.error_number) {
            case 0: return "Executed. No Error"
            case 50: return "Firebase Error"
        // TODO: Switch on error code to format proper error message
        default: return "Unspecified Error: " + (self.error_message ?? "")
        }
        
    }
    
    func raiseErrorAlert(with_title title: String, view: UIViewController) {
        print("raising error alert: \(self.getErrorDescription)")
        let alert = UIAlertController(title: title,
                                      message: self.getErrorDescription() ,
                                      preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "Continue",
                                           style: .default)
        alert.addAction(continueAction)
        view.present(alert, animated: true, completion: nil)
    }
}

class ExpectedExecution<T>: ReturnValue<T> {
    init() {
        super.init(error: false, error_number: 0)
    }
}

class FirebaseError<T>: ReturnValue<T> {
    init(error_message : String = "") {
        super.init(error: true, error_message: error_message, error_number: 50)
    }
}


