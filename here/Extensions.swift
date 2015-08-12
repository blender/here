//
//  Extensions.swift
//  here
//
//  Created by Tommaso Piazza on 12/08/15.
//  Copyright (c) 2015 Alloc Init. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {

    public func saveOrRollBack() -> Bool {
    
        var error: NSError? = nil
        let success = self.save(&error)
        if !success {
            println("Unresolved error \(error), \(error?.userInfo)")
            self.rollback()
        }
        
        return success
    }
}