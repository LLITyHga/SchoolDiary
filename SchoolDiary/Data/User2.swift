//
//  User.swift
//  SchoolDiary
//
//  Created by Wolf on 30.04.2024.
//

import Foundation
import RealmSwift

class User2: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var notificationHour: Int = 20
    @objc dynamic var notificationMinutes: Int = 0
    
    override static func primaryKey() -> String? {
        return "name"
    }
}
