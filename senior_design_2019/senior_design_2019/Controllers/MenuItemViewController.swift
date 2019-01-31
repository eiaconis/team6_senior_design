//
//  MenuItemViewController.swift
//  spend_to_save
//
//  Created by OIDUser on 12/6/18.
//  Copyright © 2018 OIDUser. All rights reserved.
//

import UIKit

class MenuItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let menu = ["Small Coffee", "Medium Coffee", "Large Coffee"]
    
    @IBOutlet weak var skipButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pad and round the 'Skip' Button
        skipButton.layer.cornerRadius = 5
        skipButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = menu[indexPath.row]
        cell.textLabel?.font = UIFont(name:"DIN Condensed", size:20)
        print(menu[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "menuItemSegue", sender: self)
    }

}
