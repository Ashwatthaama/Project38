//
//  Author+CoreDataClass.swift
//  Project38
//
//  Created by Niraj on 04/12/2019.
//  Copyright © 2019 Niraj. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Author)
public class Author: NSManagedObject, Codable {


    enum CodingKeys: String, CodingKey {
        case name
        case email
        case date
        case author
        case commit
    }


    public func encode(to encoder:Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        do {
            try container.encode(name, forKey: .name)
            try container.encode(email, forKey: .email)
        } catch {
            print("Encoding Author Error,\(error)")
        }

    }

    required convenience public init(from decoder: Decoder) throws {


        guard let managedObjectContext = decoder.userInfo[.context] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Author", in: managedObjectContext) else {
                fatalError("Failed to decode Author")
        }
        self.init(entity: entity, insertInto: managedObjectContext)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            name = try values.decode(String.self, forKey: .name)
            email = try values.decode(String.self, forKey: .email)
        } catch {
            print("Error while decoding,\(error)")
        }
    }

}
