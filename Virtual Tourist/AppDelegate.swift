//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Ahmed Afifi on 7/28/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let dataController = DataController(modelName: "Virtual_Tourist")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        dataController.load()
        
        // Inject dataController dependency into TravelLocationMapViewController
        let navigationController = window?.rootViewController as! UINavigationController
        let travelViewController = navigationController.topViewController as! TravelLocationMapViewController
        travelViewController.dataController = dataController
        return true
    }
    
    func checkIfFirstLaunch() {
        if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            print("App has launched before")
        } else {
            print("This is the first launch ever!")
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }

   }

