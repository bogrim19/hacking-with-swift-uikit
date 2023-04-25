//
//  Person.swift
//  Project10
//
//  Created by Bogrim on 21.04.2023.
//

import UIKit

class Person: NSObject {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
