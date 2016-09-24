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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppDelegate().setNavigationBarColors(navigationController)
        if UIDevice.current.userInterfaceIdiom == .pad { navigationItem.leftBarButtonItem = nil }
    }

    // MARK: - Actions
    
    @IBAction func closeTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchTapped(_ sender: UISwitch) {
        UserDefaults.standard.set(optionsCell.optionsSwitch.isOn, forKey: "NavigationBar")
        UserDefaults.standard.synchronize()
        AppDelegate().setNavigationBarColors(navigationController)
        NotificationCenter.default.post(name: Notification.Name(rawValue: ConfigureNavigationColorsNotification), object: nil)
    }
    
    // MARK: - UITableViewSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        optionsCell = tableView.dequeueReusableCell(withIdentifier: optionsCellIdentifier, for: indexPath) as! OptionsTableViewCell
        optionsCell.titleLabel.text = options[(indexPath as NSIndexPath).row]
        optionsCell.optionsSwitch.isOn = UserDefaults.standard.bool(forKey: "NavigationBar")
        return optionsCell
    }
}
