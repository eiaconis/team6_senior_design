//
//  MoneyValueViewController.swift
//  spend_to_save
//
//  Created by OIDUser on 1/25/19.
//  Copyright © 2019 OIDUser. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreLocation

class MoneyValueViewController: UIViewController, CLLocationManagerDelegate{

    var database : DatabaseAccess = DatabaseAccess.getInstance()
    let locManager = CLLocationManager()
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var currentAmountLabel: UILabel!
    @IBOutlet weak var progressPercentageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            // creates an instance of a location manager and
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.startUpdatingLocation()
            self.locManager.requestAlwaysAuthorization()
        }
        // Pad and round the 'Logout' Button
        logoutButton.layer.cornerRadius = 5
        logoutButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
        // Pad and round the '+' Button
        plusButton.layer.cornerRadius = 5
        plusButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
        // Read data from db for appropriate text rendering
        var currAmount = 0.0
        self.database.getUserCurrGoal(uid: Auth.auth().currentUser!.uid, callback: {(goalId) -> Void in
            print("got goal id")
            print(goalId ?? "Something went wrong getting goal id.")
            self.database.getStateOfGoal(goalId: goalId!, callback: {(amount) -> Void in
                print("got goal amount")
                print(amount!)
                currAmount = amount!
                
                self.currentAmountLabel.text = "$\(amount!)"
                self.currentAmountLabel.sizeToFit()
            })
            self.database.getTargetOfGoal(goalId: goalId!, callback: {(target) -> Void in
                print("got target amount")
                print(target!)
                let percentage = (currAmount / target!)*100
                let truncPercentage = String (Double(floor(pow(10.0, Double(2)) * percentage)/pow(10.0, Double(2))))
                
                self.progressPercentageLabel.text = "\(truncPercentage)%"
                self.progressPercentageLabel.sizeToFit()
            })
        })
        
        // Pad and round the 'Logout' Button
        logoutButton.layer.cornerRadius = 5
        logoutButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
        // Pad and round the '+' Button
        plusButton.layer.cornerRadius = 5
        plusButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
        // Read data from db for appropriate text rendering
        self.database.getUserCurrGoal(uid: Auth.auth().currentUser!.uid, callback: {(goalId) -> Void in
            print("got goal id")
            print(goalId ?? "Something went wrong getting goal id.")
            self.database.getStateOfGoal(goalId: goalId!, callback: {(amount) -> Void in
                print("got goal amount")
                print(amount!)
                currAmount = amount!
                
                self.currentAmountLabel.text = "$\(amount!)"
                self.currentAmountLabel.sizeToFit()
            })
            self.database.getTargetOfGoal(goalId: goalId!, callback: {(target) -> Void in
                print("got target amount")
                print(target!)
                let percentage = (currAmount / target!)*100
                let truncPercentage = String (Double(floor(pow(10.0, Double(2)) * percentage)/pow(10.0, Double(2))))
               
                self.progressPercentageLabel.text = "\(truncPercentage)%"
                self.progressPercentageLabel.sizeToFit()
            })
        })
        
        print("curr location\(locManager.location)")
        if (CLLocationManager.locationServicesEnabled()) {
            let geocoder = CLGeocoder()
            // Get location of device
//            let deviceLatitude = locManager.location?.coordinate.latitude
//            let deviceLongitude = locManager.location?.coordinate.longitude
//            print("Devices lat = \(deviceLatitude!) and lon = \(deviceLongitude!)")
//
//            let address = "3401 Walnut St, Philadelphia, PA 19104"
//            geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
//                if ((error) != nil){
//                    // If we get an error, print it
//                    print("Error", error ?? "")
//                }
//                if let placemark = placemarks?.first {
//                    let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
//                    // Get latitude and longitude of house
//                    let lat = coordinates.latitude
//                    let lon = coordinates.longitude
//                    // Calculate distance between house and device
//                                        let latDif = abs(lat - deviceLatitude!)
//                                        let lonDif = abs(lon - deviceLongitude!)
//                                        print("latitude difference = \(latDif)")
//                                        print("longitude difference = \(lonDif)")
////                     If device is within 0.0001 km (about 36 feet), allow user to indicate that they are home
//                                        if latDif < 0.0001 && lonDif < 0.0001 {
//                                            self.createAlert(title: "Looks like you are in Starbucks. Want to log a saving transaction?")
//                                        }
//
                   // self.createAlert(title: "Looks like you are in Starbucks. Want to log a saving transaction?")
                    
//                }
//            })
        }
    
    }
    
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        self.database.logout(view: self)
    }
    
    func createAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
