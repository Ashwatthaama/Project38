//
//  Commit+CoreDataClass.swift
//  Project38
//
//  Created by Niraj on 03/12/2019.
//  Copyright © 2019 Niraj. All rights reserved.
//
//

import Foundation
import CoreData

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")!
}

enum EventDecodeError: Error {
    case contextNotFound
    case entityNotFound
}

extension JSONDecoder {
    convenience init(context: NSManagedObjectContext) {
        self.init()
        self.userInfo[.context] = context
    }
}


@objc(Commit)
public class Commit: NSManagedObject, Codable {
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    enum CodingKeys: String, CodingKey {
        case commit = "commit"
        case sha = "sha"
        case url = "url"
        case message = "message"
        case author
        case date
        case name
        case email
    }


    public func encode(to encoder:Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        do {
            var commit = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .commit)
            try commit.encode(message, forKey: .message)
            try container.encode(sha, forKey: .sha)
            try container.encode(url , forKey: .url)
        } catch {
             print("Error while encoding Commit,\(error)")
        }
    }

    required convenience public init(from decoder: Decoder) throws {

        guard let managedObjectContext = decoder.userInfo[.context] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Commit", in: managedObjectContext) else {
                fatalError("Failed to decode Commit")
        }
        self.init(entity: entity, insertInto: managedObjectContext)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            let commitNested = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .commit)
            message = try commitNested.decode(String.self, forKey: .message)
            sha = try values.decode(String.self, forKey: .sha)
            url = try values.decode(String.self, forKey: .url)


            let authorsNested = try commitNested.nestedContainer(keyedBy: CodingKeys.self, forKey: .author)
            let dateString = try authorsNested.decode(String.self, forKey: .date)

            /// Decoding Date
            let formatter = ISO8601DateFormatter()
            date = formatter.date(from: dateString) ?? Date()


            if let dateparse = formatter.date(from: dateString) {
                date = dateparse
            } else {
                throw DecodingError.dataCorruptedError(forKey: .date, in: authorsNested, debugDescription: "Date string does not match format expected by formatter.")
            }

            author = try commitNested.decode(Author.self, forKey: .author)

           //Child Object Decoding

//           let factory = ManagedDecodingFactory<Author>(context: managedObjectContext)
//           author = try factory.create(from: decoder)
            
        } catch {
             print("Error while decoding Commit,\(error)")
        }
    }
}
