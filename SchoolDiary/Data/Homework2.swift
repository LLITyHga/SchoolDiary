//
//  Homework2.swift
//  SchoolDiary
//
//  Created by Wolf on 20.06.2023.
//

import Foundation
import RealmSwift

class Homework2: Object {
    
    @objc dynamic var day: Date = Date()
    @objc dynamic var selected: Bool = false
    @objc dynamic var text: String = ""
    @objc dynamic var lesson: String = ""
    @objc dynamic var key: String = ""
    @objc dynamic var userUID: String = ""
    @objc dynamic var dateLastChange: Int = 0

    override class func primaryKey() -> String? {
        return "key"
    }
}
