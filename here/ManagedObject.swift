//
//  ManagedObject.swift
//  here
//
//  Created by Tommaso Piazza on 07/08/15.
//  Copyright (c) 2015 Alloc Init. All rights reserved.
//

import Foundation
import CoreData

class ManagedObject: NSManagedObject {
    
    static var sortedFetchRequest: NSFetchRequest {
        let request = NSFetchRequest(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        return request
    }
    
    class var entityName:String {
        return ""
    }
    
    class var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }
    
    class func fetchedResultControlerInContext(context:NSManagedObjectContext, request:NSFetchRequest) -> NSFetchedResultsController {
        
        let controller = NSFetchedResultsController(fetchRequest:request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "Master")
        return controller
    }
    
    class func fetchedResultControlerWithDefautlRequestInContext(context:NSManagedObjectContext) -> NSFetchedResultsController {
        
        return fetchedResultControlerInContext(context, request: self.sortedFetchRequest)
    }
}