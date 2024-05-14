//
//  Lesson3.swift
//  SchoolDiary
//
//  Created by Wolf on 21.06.2023.
//

import Foundation
import RealmSwift

class Lesson3: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var selected: Bool = false
    @objc dynamic var dayOfWeek: String = ""
    @objc dynamic var time: String = ""
    @objc dynamic var homework: String = ""
    @objc dynamic var timeInMinutes: Int = 0
    @objc dynamic var key: String = ""
    @objc dynamic var userUID: String = ""
    @objc dynamic var dateLastChange: Int = 0

    override class func primaryKey() -> String? {
        return "key"
    }
}
