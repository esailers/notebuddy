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
    func insertPhotoInNote(note: Note, imageData: NSData) -> Photo {
        let photo: Photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: DataManager.getContext()) as! Photo
        photo.note = note
        photo.imageData = imageData
        DataManager.saveManagedContext()
        
        return photo
    }
    
    // Get photos from Flickr
    func getFlickrPhotos(results: [[String: AnyObject]]) -> [Photo] {
        var photos = [Photo]()
        for photoResult in results {
            photos.append(getPhotoURL(photoResult))
        }
        return photos
    }
    
    // Get photo URL
    private func getPhotoURL(photoURL: [String: AnyObject]) -> Photo {
        let photo: Photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: DataManager.getContext()) as! Photo
        photo.path = photoURL[FlickrClient.JSONResponseKeys.mediumURL] as? String
        
        return photo
    }
    
}
