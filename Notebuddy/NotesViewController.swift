//
//  NotesViewController.swift
//  Notebuddy
//
//  Created by Eric Sailers on 8/15/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    
    var currentNotebook: Notebook?
    
    var addBarButton: UIBarButtonItem!
    var editBarButton: UIBarButtonItem!
    
    let noteCell = "noteCell"
    var notes = [Note]()
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - UIViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        editBarButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.editNote(_:)))
        addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addNote(_:)))
        navigationItem.rightBarButtonItems = [editBarButton, addBarButton]
        
        navigationItem.title = currentNotebook?.title

        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let currentNotebook = currentNotebook {
            notes = Notebook.sharedInstance().sortNotesInNotebook(currentNotebook)
            print(notes.count)
            tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    func editNote(_ sender: UIBarButtonItem) {
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
    
    func addNote(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: StoryboardSegue.kSegueToAddNote, sender: self)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: noteCell, for: indexPath)
        let note = notes[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = note.title
        cell.detailTextLabel?.text = Note.sharedInstance().formattedDateAndTimeString(note.createdDate)
        cell.detailTextLabel?.textColor = UIColor.lightGray
        cell.imageView?.image = UIImage(named: "note")
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let button = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            if let currentNotebook = self.currentNotebook {
                Note.sharedInstance().deleteNoteInNotebook(currentNotebook, indexPath: indexPath)
            }
            self.notes.remove(at: (indexPath as NSIndexPath).row)
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
        static let kSegueToAddNote = "segueToAddNote"
        static let kSegueToEditNote = "segueToEditNote"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.kSegueToAddNote {
            if let destination = segue.destination as? UINavigationController, let noteTVC = destination.visibleViewController as? NoteTableViewController {
                noteTVC.currentNotebook = currentNotebook
            }
        } else if segue.identifier == StoryboardSegue.kSegueToEditNote {
            if let destination = segue.destination as? NoteTableViewController, let indexPath = tableView.indexPathForSelectedRow {
                destination.currentNotebook = currentNotebook
                let selectedNote = notes[(indexPath as NSIndexPath).row]
                destination.currentNote = selectedNote
            }
        }
    }
    
}
