//
//  DataManager.swift
//  Notebuddy
//
//  Created by Eric Sailers on 8/19/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import CoreData

class DataManager {

    class func getContext() -> NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    class func deleteManagedObject(object: NSManagedObject) {
        getContext().deleteObject(object)
        saveManagedContext()
    }
    
    class func saveManagedContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
}
