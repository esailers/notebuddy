//
//  Photo.swift
//  Notebuddy
//
//  Created by Eric Sailers on 8/17/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import Foundation
import CoreData

class Photo: NSManagedObject {
    
    // Singleton
    class func sharedInstance() -> Photo {
        struct Static {
            static let instance = Photo()
        }
        return Static.instance
    }
    
    // Add photo to note
    func insertPhotoInNote(_ note: Note, imageData: Data) -> Photo {
        let photo: Photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: DataManager.getContext()) as! Photo
        photo.note = note
        photo.imageData = imageData
        DataManager.saveManagedContext()
        
        return photo
    }
    
}
