//
//  AppDelegate.swift
//  Notebuddy
//
//  Created by Eric Sailers on 8/15/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if UserDefaults.standard.object(forKey: "NavigationBar") == nil {
            UserDefaults.standard.set(false, forKey: "NavigationBar")
            UserDefaults.standard.synchronize()
        }
        setNavigationBarColors()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Set navigation bar colors
    
    func setNavigationBarColors(_ navigationController: UINavigationController? = nil) {
        if UserDefaults.standard.bool(forKey: "NavigationBar") {
            configureNavigationBarColors(navigationController, barColor: UIColor.black, titleColor: UIColor.white, statusBarStyle: .lightContent)
        } else {
            configureNavigationBarColors(navigationController, barColor: UIColor.white, titleColor: UIColor.black, statusBarStyle: .default)
        }
    }
    
    func configureNavigationBarColors(_ navigationController: UINavigationController?, barColor: UIColor, titleColor: UIColor, statusBarStyle: UIStatusBarStyle) {
        if let navigationController = navigationController {
            navigationController.navigationBar.barTintColor = barColor
            navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: titleColor]
        } else {
            UINavigationBar.appearance().barTintColor = barColor
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: titleColor]
        }
        UIApplication.shared.statusBarStyle = statusBarStyle
    }

}

