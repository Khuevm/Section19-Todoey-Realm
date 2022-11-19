//
//  Item.swift
//  Todoey
//
//  Created by Khue on 26/10/2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var isDone: Bool = false
    @objc dynamic var dateCreated: Date?
    //Relationship
    let parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
