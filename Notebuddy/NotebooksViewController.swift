//
//  NotebooksViewController.swift
//  Notebuddy
//
//  Created by Eric Sailers on 8/15/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import UIKit

class NotebooksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    
    var addBarButton: UIBarButtonItem!
    var editBarButton: UIBarButtonItem!
    
    let notebookCell = "notebookCell"
    var notebooks = [Notebook]()
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - UIViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        editBarButton = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(self.editNotebook(_:)))
        addBarButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.addNotebook(_:)))
        navigationItem.rightBarButtonItems = [editBarButton, addBarButton]

        tableView.dataSource = self
        tableView.delegate = self
        
        self.notebooks = Notebook.sharedInstance().fetchNotebookItems()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        if NSUserDefaults.standardUserDefaults().boolForKey("NavigationBar") {
            setNavigationBarColorsWithBarColor(UIColor.blackColor(), titleColor: UIColor.whiteColor(), statusBarStyle: .LightContent)
        } else {
            setNavigationBarColorsWithBarColor(UIColor.whiteColor(), titleColor: UIColor.blackColor(), statusBarStyle: .Default)
        }
    }
    
    // MARK: - Actions
    
    func editNotebook(sender: UIBarButtonItem) {
        if tableView.editing {
            editBarButton.title = "Edit"
            addBarButton.enabled = true
            tableView.setEditing(false, animated: true)
        } else {
            editBarButton.title = "Done"
            addBarButton.enabled = false
            tableView.setEditing(true, animated: true)
        }
    }
    
    func addNotebook(sender: UIBarButtonItem) {
        presentAlertForNewNotebook()
    }
    
    // MARK: - Helpers
    
    private func setNavigationBarColorsWithBarColor(barColor: UIColor, titleColor: UIColor, statusBarStyle: UIStatusBarStyle) {
        navigationController?.navigationBar.barTintColor = barColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: titleColor]
        UIApplication.sharedApplication().statusBarStyle = statusBarStyle
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notebooks.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(notebookCell, forIndexPath: indexPath)
        cell.textLabel?.text = notebooks[indexPath.row].title
        cell.imageView?.image = UIImage(named: "notebook")
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) in
            Notebook.sharedInstance().deleteNotebook(indexPath)
            self.notebooks.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }
        
        // Began editing tableView row
        editBarButton.title = "Done"
        addBarButton.enabled = false
        
        return [button]
    }
    
    func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        // Ended editing tableView row
        editBarButton.title = "Edit"
        addBarButton.enabled = true
    }
    
    // MARK: - Navigation
    
    private struct StoryboardSegue {
        static let kSegueToNotes = "segueToNotes"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardSegue.kSegueToNotes {
            if let destination = segue.destinationViewController as? NotesViewController, indexPath = tableView.indexPathForSelectedRow {
                let selectedNotebook = notebooks[indexPath.row]
                destination.currentNotebook = selectedNotebook
            }
        }
    }
    
    // MARK: - UIAlert
    
    private func presentAlertForNewNotebook() {
        let alertController = UIAlertController(title: "New Notebook", message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "Title"
            textField.clearButtonMode = .WhileEditing
            textField.autocapitalizationType = .Sentences
            textField.returnKeyType = .Done
            textField.enablesReturnKeyAutomatically = true
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .Default) { action in
            if let textFields = alertController.textFields, text = textFields[0].text  {
                if text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" {
                    Notebook.sharedInstance().insertNewNotebook(text)
                    self.notebooks = Notebook.sharedInstance().fetchNotebookItems()
                    self.tableView.reloadData()
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

}
