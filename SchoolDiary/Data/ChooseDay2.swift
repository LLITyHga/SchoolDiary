//
//  ChooseDay2.swift
//  SchoolDiary
//
//  Created by Wolf on 18.06.2023.
//

import Foundation
import RealmSwift

class ChooseDay2: Object {
    
    @objc dynamic var day: Date = Date()
    @objc dynamic var selected: Bool = false
    @objc dynamic var userUID: String = ""
    @objc dynamic var dateLastChange: Int = 0

//    override class func primaryKey() -> Date? {
//        return Date()
//    }
}
