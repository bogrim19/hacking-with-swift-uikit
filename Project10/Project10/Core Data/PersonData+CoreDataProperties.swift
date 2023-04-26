//
//  Person+CoreDataProperties.swift
//  Project10
//
//  Created by Bogrim on 27.04.2023.
//
//

import Foundation
import CoreData
import UIKit


extension PeopleData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PeopleData> {
        return NSFetchRequest<PeopleData>(entityName: "PeopleData")
    }

    @NSManaged public var personImage: Data
    @NSManaged public var personText: String

}

extension PeopleData : Identifiable {

}
