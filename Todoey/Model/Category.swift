//
//  Category.swift
//  Todoey
//
//  Created by Khue on 26/10/2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    //Relationship
    let items = List<Item>()
}
