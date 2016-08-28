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
        
        editBarButton = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(self.editNote(_:)))
        addBarButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.addNote(_:)))
        navigationItem.rightBarButtonItems = [editBarButton, addBarButton]
        
        navigationItem.title = currentNotebook?.title

        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let currentNotebook = currentNotebook {
            notes = Notebook.sharedInstance().sortNotesInNotebook(currentNotebook)
            print(notes.count)
            tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    func editNote(sender: UIBarButtonItem) {
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
    
    func addNote(sender: UIBarButtonItem) {
        performSegueWithIdentifier(StoryboardSegue.kSegueToAddNote, sender: self)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(noteCell, forIndexPath: indexPath)
        let note = notes[indexPath.row]
        cell.textLabel?.text = note.title
        cell.detailTextLabel?.text = Note.sharedInstance().formattedDateAndTimeString(note.createdDate)
        cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
        cell.imageView?.image = UIImage(named: "note")
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) in
            if let currentNotebook = self.currentNotebook {
                Note.sharedInstance().deleteNoteInNotebook(currentNotebook, indexPath: indexPath)
            }
            self.notes.removeAtIndex(indexPath.row)
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
        static let kSegueToAddNote = "segueToAddNote"
        static let kSegueToEditNote = "segueToEditNote"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardSegue.kSegueToAddNote {
            if let destination = segue.destinationViewController as? UINavigationController, noteTVC = destination.visibleViewController as? NoteTableViewController {
                noteTVC.currentNotebook = currentNotebook
            }
        } else if segue.identifier == StoryboardSegue.kSegueToEditNote {
            if let destination = segue.destinationViewController as? NoteTableViewController, indexPath = tableView.indexPathForSelectedRow {
                destination.currentNotebook = currentNotebook
                let selectedNote = notes[indexPath.row]
                destination.currentNote = selectedNote
            }
        }
    }
    
}
