//
//  OptionsViewController.swift
//  Notebuddy
//
//  Created by Eric Sailers on 8/31/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import UIKit

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
        configureNavigationColors()
    }

    // MARK: - Actions
    
    @IBAction func closeTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func switchTapped(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setBool(optionsCell.optionsSwitch.on, forKey: "NavigationBar")
        NSUserDefaults.standardUserDefaults().synchronize()

        configureNavigationColors()
    }
    
    // MARK: - Helpers
    
    private func configureNavigationColors() {
        if NSUserDefaults.standardUserDefaults().boolForKey("NavigationBar") {
            setNavigationBarColorsWithBarColor(UIColor.blackColor(), titleColor: UIColor.whiteColor(), statusBarStyle: .LightContent)
        } else {
            setNavigationBarColorsWithBarColor(UIColor.whiteColor(), titleColor: UIColor.blackColor(), statusBarStyle: .Default)
        }
    }
    
    private func setNavigationBarColorsWithBarColor(barColor: UIColor, titleColor: UIColor, statusBarStyle: UIStatusBarStyle) {
        navigationController?.navigationBar.barTintColor = barColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: titleColor]
        UIApplication.sharedApplication().statusBarStyle = statusBarStyle
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
