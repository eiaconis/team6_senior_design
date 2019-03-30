//
//  AcknowledgmentsController.swift
//  Save-Your
//
//  Created by OIDUser on 3/30/19.
//

import UIKit

class AcknowledgmentsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add logo to navigation bar
        let logo = UIImage(named: "saveyour logo-40.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }

}
