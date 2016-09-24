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
        
        editBarButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.editNotebook(_:)))
        addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addNotebook(_:)))
        navigationItem.rightBarButtonItems = [editBarButton, addBarButton]

        tableView.dataSource = self
        tableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.configureNavigationColors), name: NSNotification.Name(rawValue: ConfigureNavigationColorsNotification), object: nil)
        
        self.notebooks = Notebook.sharedInstance().fetchNotebookItems()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ConfigureNavigationColorsNotification), object: nil)
    }
    
    // MARK: - Actions
    
    func editNotebook(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            editBarButton.title = "Edit"
            addBarButton.isEnabled = true
            tableView.setEditing(false, animated: true)
        } else {
            editBarButton.title = "Done"
            addBarButton.isEnabled = false
            tableView.setEditing(true, animated: true)
        }
    }
    
    func addNotebook(_ sender: UIBarButtonItem) {
        presentAlertForNewNotebook()
    }
    
    // MARK: - Helpers
    
    func configureNavigationColors() {
        AppDelegate().setNavigationBarColors(navigationController)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notebooks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: notebookCell, for: indexPath)
        cell.textLabel?.text = notebooks[(indexPath as NSIndexPath).row].title
        cell.imageView?.image = UIImage(named: "notebook")
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let button = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            Notebook.sharedInstance().deleteNotebook(indexPath)
            self.notebooks.remove(at: (indexPath as NSIndexPath).row)
            tableView.reloadData()
        }
        
        editBarButton.title = "Done"
        addBarButton.isEnabled = false
        
        return [button]
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        editBarButton.title = "Edit"
        addBarButton.isEnabled = true
    }
    
    // MARK: - Navigation
    
    fileprivate struct StoryboardSegue {
        static let kSegueToNotes = "segueToNotes"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.kSegueToNotes {
            if let destination = segue.destination as? NotesViewController, let indexPath = tableView.indexPathForSelectedRow {
                let selectedNotebook = notebooks[(indexPath as NSIndexPath).row]
                destination.currentNotebook = selectedNotebook
            }
        }
    }
    
    // MARK: - UIAlert
    
    fileprivate func presentAlertForNewNotebook() {
        let alertController = UIAlertController(title: "New Notebook", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Title"
            textField.clearButtonMode = .whileEditing
            textField.autocapitalizationType = .sentences
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = true
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            if let textFields = alertController.textFields, let text = textFields[0].text  {
                if text.trimmingCharacters(in: CharacterSet.whitespaces) != "" {
                    Notebook.sharedInstance().insertNewNotebook(text)
                    self.notebooks = Notebook.sharedInstance().fetchNotebookItems()
                    self.tableView.reloadData()
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController, animated: true, completion: nil)
    }

}
