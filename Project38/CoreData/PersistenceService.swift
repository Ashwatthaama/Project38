//
//  PersistenceService.swift
//  Project38
//
//  Created by Niraj on 07/12/2019.
//  Copyright © 2019 Niraj. All rights reserved.
//

import Foundation
import CoreData

class PersistenceService {

    private init() { }

    var context: NSManagedObjectContext { return persistenceContainer.viewContext }

    private static let _sharedInstance = PersistenceService()

    // sticking to Apple's way of using a class function for singletons
    class func sharedInstance() -> PersistenceService {
        return _sharedInstance
    }

    lazy var persistenceContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Project38")

        container.loadPersistentStores { descriptor, error in
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                print("Unresolved Error \(error)")
            }
        }
        return container
    }()


    
    func saveContext() {
        if persistenceContainer.viewContext.hasChanges {
            do {
                try persistenceContainer.viewContext.save()
            } catch {
                print("An Error occured while saving: \(error)")
            }
        }
    }
}
