//
//  Commit+CoreDataProperties.swift
//  Project38
//
//  Created by Niraj on 08/12/2019.
//  Copyright © 2019 Niraj. All rights reserved.
//
//

import Foundation
import CoreData


extension Commit {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Commit> {
        return NSFetchRequest<Commit>(entityName: "Commit")
    }

    @NSManaged public var sha: String
    @NSManaged public var url: String
    @NSManaged public var date: Date
    @NSManaged public var message: String
    @NSManaged public var author: Author

}
