//
//  Lesson6.swift
//  SchoolDiary
//
//  Created by Wolf on 02.04.2024.
//

import Foundation
import RealmSwift

class Lesson6: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var selected: Bool = false
    @objc dynamic var dayOfWeek: String = ""
    @objc dynamic var time: String = ""
    @objc dynamic var homework: String = ""
    @objc dynamic var timeInMinutes: Int = 0
    @objc dynamic var date = Date()
    @objc dynamic var primaryKey: String = ""
    @objc dynamic var userUID: String = ""
    @objc dynamic var dateLastChange: Int = 0

    override static func primaryKey() -> String? {
        return "primaryKey"
    }
}
