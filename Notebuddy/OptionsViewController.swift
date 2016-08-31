//
//  OptionsViewController.swift
//  Notebuddy
//
//  Created by Eric Sailers on 8/31/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import UIKit

// Notification
let ConfigureNavigationColorsNotification = "ConfigureNavigationColorsNotification"

class OptionsViewController: UIViewController, UITableViewDataSource {
    
    // MARK: - Properties
    
    let optionsCellIdentifier = "optionsCell"
    var options = [String]()
    @IBOutlet weak var tableView: UITableView!
    
    var optionsCell: OptionsTableViewCell!
    
    // MARK: - Constructor
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        options = ["Dark Navigation Bar"]
    }
    
    // MARK: - UIViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        AppDelegate().setNavigationBarColors(navigationController)
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad { navigationItem.leftBarButtonItem = nil }
    }

    // MARK: - Actions
    
    @IBAction func closeTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func switchTapped(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setBool(optionsCell.optionsSwitch.on, forKey: "NavigationBar")
        NSUserDefaults.standardUserDefaults().synchronize()
        AppDelegate().setNavigationBarColors(navigationController)
        NSNotificationCenter.defaultCenter().postNotificationName(ConfigureNavigationColorsNotification, object: nil)
    }
    
    // MARK: - UITableViewSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        optionsCell = tableView.dequeueReusableCellWithIdentifier(optionsCellIdentifier, forIndexPath: indexPath) as! OptionsTableViewCell
        optionsCell.titleLabel.text = options[indexPath.row]
        optionsCell.optionsSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey("NavigationBar")
        return optionsCell
    }
}