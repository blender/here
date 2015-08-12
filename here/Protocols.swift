//
//  HereProtocols.swift
//  here
//
//  Created by Tommaso Piazza on 07/08/15.
//  Copyright (c) 2015 Alloc Init. All rights reserved.
//

import Foundation
import CoreData
import there

protocol ManagedObjectContextSettable: class {
    
    var managedObjectContext: NSManagedObjectContext! { get set }
}

protocol ThereClientSettable: class {
    
    var thereClient: ThereClient! { get set}
}

protocol ItinerarySettable: class {
    
    var itinerary: Itinerary? { get set}
}