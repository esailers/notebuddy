//
//  Note+CoreDataProperties.swift
//  Notebuddy
//
//  Created by Eric Sailers on 8/19/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Note {

    @NSManaged var content: String?
    @NSManaged var title: String?
    @NSManaged var createdDate: Date
    @NSManaged var notebook: Notebook?
    @NSManaged var photo: Photo?

}
