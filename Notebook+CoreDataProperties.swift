//
//  Notebook+CoreDataProperties.swift
//  Notebuddy
//
//  Created by Eric Sailers on 8/17/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Notebook {

    @NSManaged var title: String?
    @NSManaged var notes: NSSet?

}
