//
//  SongCollection+CoreDataProperties.swift
//  minimalTunes
//
//  Created by John Moody on 10/26/16.
//  Copyright © 2016 John Moody. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension SongCollection {

    @NSManaged var id: NSNumber?
    @NSManaged var is_smart: NSNumber?
    @NSManaged var name: String?
    @NSManaged var track_id_list: NSObject?
    @NSManaged var is_network: NSNumber?
    @NSManaged var folder: SongCollectionFolder?
    @NSManaged var if_master_library: Library?
    @NSManaged var if_master_list_item: SourceListItem?
    @NSManaged var list_item: SourceListItem?
    @NSManaged var tracks: NSSet?

}