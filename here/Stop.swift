//
//  Stop.swift
//  here
//
//  Created by Tommaso Piazza on 07/08/15.
//  Copyright (c) 2015 Alloc Init. All rights reserved.
//

import Foundation

@objc(Stop)

class Stop : ManagedObject {
    
    @NSManaged var createdAt: NSDate
    @NSManaged var displayName: String
    @NSManaged var lat:Double
    @NSManaged var lon:Double
    @NSManaged var number:Int
    @NSManaged var itinerary:Itinerary
    
    override class var entityName:String {
        return "Stop"
    }
    
    override class var defaultSortDescriptors: [NSSortDescriptor] {
        
        let numberSortDescriptor = NSSortDescriptor(key: "number", ascending: false)
        
        return [numberSortDescriptor]
    }
}