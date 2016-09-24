//
//  Note.swift
//  Notebuddy
//
//  Created by Eric Sailers on 8/17/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import Foundation
import CoreData

class Note: NSManagedObject {

    // Singleton
    class func sharedInstance() -> Note {
        struct Static {
            static let instance = Note()
        }
        return Static.instance
    }

    // Insert note in notebook
    func insertNoteInNotebook(_ notebook: Notebook, title: String, content: String) -> Note {
        let note: Note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: DataManager.getContext()) as! Note
        note.notebook = notebook
        note.createdDate = Date()
        note.title = title
        note.content = content
        DataManager.saveManagedContext()
        
        return note
    }
    
    // Delete note in notebook
    func deleteNoteInNotebook(_ notebook: Notebook, indexPath: IndexPath) {
        let notes = Notebook.sharedInstance().sortNotesInNotebook(notebook)
        let note = notes[(indexPath as NSIndexPath).row]
        DataManager.deleteManagedObject(note)
    }
    
    // MARK: - String for createdDate
    func formattedDateAndTimeString(_ date: Date) -> String {
        let dateString = stringWithDateStyle(date, dateStyle: .medium, timeStyle: .none)
        let timeString = stringWithDateStyle(date, dateStyle: .none, timeStyle: .short)
        
        return "\(dateString) @ \(timeString)"
    }
    
    func stringWithDateStyle(_ date: Date, dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: date)
    }
    
}
