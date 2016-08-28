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
    func insertNoteInNotebook(notebook: Notebook, title: String, content: String) -> Note {
        let note: Note = NSEntityDescription.insertNewObjectForEntityForName("Note", inManagedObjectContext: DataManager.getContext()) as! Note
        note.notebook = notebook
        note.createdDate = NSDate()
        note.title = title
        note.content = content
        DataManager.saveManagedContext()
        
        return note
    }
    
    // Delete note in notebook
    func deleteNoteInNotebook(notebook: Notebook, indexPath: NSIndexPath) {
        let notes = Notebook.sharedInstance().sortNotesInNotebook(notebook)
        let note = notes[indexPath.row]
        DataManager.deleteManagedObject(note)
    }
    
    // MARK: - String for createdDate
    func formattedDateAndTimeString(date: NSDate) -> String {
        let dateString = stringWithDateStyle(date, dateStyle: .MediumStyle, timeStyle: .NoStyle)
        let timeString = stringWithDateStyle(date, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        
        return "\(dateString) @ \(timeString)"
    }
    
    func stringWithDateStyle(date: NSDate, dateStyle: NSDateFormatterStyle, timeStyle: NSDateFormatterStyle) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.stringFromDate(date)
    }
    
}
