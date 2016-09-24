//
//  Notebook.swift
//  Notebuddy
//
//  Created by Eric Sailers on 8/17/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import Foundation
import CoreData
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


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
    func insertNewNotebook(_ title: String) {
        let notebook: Notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into: DataManager.getContext()) as! Notebook
        notebook.title = title
        DataManager.saveManagedContext()
    }
    
    // Fetch all notebooks
    func fetchNotebookItems() -> [Notebook] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notebook")
        let context = DataManager.getContext()
        let notebooks = try! context.fetch(fetchRequest) as! [Notebook]
        let sortedNotebooks = notebooks.sorted { $0.title < $1.title }
        return sortedNotebooks
    }
    
    // Delete notebook
    func deleteNotebook(_ indexPath: IndexPath) {
        let context = DataManager.getContext()
        context.delete(fetchNotebookItems()[(indexPath as NSIndexPath).row])
        DataManager.saveManagedContext()
    }
    
    // Sort notes in alphabetical order for a notebook
    func sortNotesInNotebook(_ notebook: Notebook) -> [Note] {
        let notes = notebook.notes?.allObjects as! [Note]
        let sortedNotes = notes.sorted { $0.title < $1.title }
        return sortedNotes
    }

}
