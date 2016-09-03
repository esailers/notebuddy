//
//  Notebook.swift
//  Notebuddy
//
//  Created by Eric Sailers on 8/17/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import Foundation
import CoreData

class Notebook: NSManagedObject {

    // MARK: - Singleton
    class func sharedInstance() -> Notebook {
        struct Static {
            static let instance = Notebook()
        }
        return Static.instance
    }
    
    // MARK: - Methods
    
    // Create notebook
    func insertNewNotebook(title: String) {
        let notebook: Notebook = NSEntityDescription.insertNewObjectForEntityForName("Notebook", inManagedObjectContext: DataManager.getContext()) as! Notebook
        notebook.title = title
        DataManager.saveManagedContext()
    }
    
    // Fetch all notebooks
    func fetchNotebookItems() -> [Notebook] {
        let fetchRequest = NSFetchRequest(entityName: "Notebook")
        let context = DataManager.getContext()
        let notebooks = try! context.executeFetchRequest(fetchRequest) as! [Notebook]
        let sortedNotebooks = notebooks.sort { $0.title < $1.title }
        return sortedNotebooks
    }
    
    // Delete notebook
    func deleteNotebook(indexPath: NSIndexPath) {
        let context = DataManager.getContext()
        context.deleteObject(fetchNotebookItems()[indexPath.row])
        DataManager.saveManagedContext()
    }
    
    // Sort notes in alphabetical order for a notebook
    func sortNotesInNotebook(notebook: Notebook) -> [Note] {
        let notes = notebook.notes?.allObjects as! [Note]
        let sortedNotes = notes.sort { $0.title < $1.title }
        return sortedNotes
    }

}
