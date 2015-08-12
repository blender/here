//
//  Itinerary.swift
//  here
//
//  Created by Tommaso Piazza on 07/08/15.
//  Copyright (c) 2015 Alloc Init. All rights reserved.
//

import Foundation
import CoreData

@objc(Itinerary)

class Itinerary : ManagedObject {
    
    
    @NSManaged var createdAt: NSDate?
    @NSManaged var displayName: String?
    @NSManaged var stops:Set<Stop>?
    
    override class var entityName:String {
        return "Itinerary"
    }
    
    override class var defaultSortDescriptors: [NSSortDescriptor] {
        let createAtSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        let displaynameSortDescriptor = NSSortDescriptor(key: "displayName", ascending: false)
        
        return [createAtSortDescriptor, displaynameSortDescriptor]
    }
}