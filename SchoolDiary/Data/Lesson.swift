//
//  Lesson.swift
//  SchoolDiary
//
//  Created by Wolf on 27.06.2023.
//


// Firebase don`t work with class Lesson3, that`s why I do struct "Lesson".
//Lesson3 use for Realm becouse there have primary key

import Foundation
import UIKit
import RealmSwift

struct Lesson {
     var title: String = ""
     var selected: Bool = false
     var dayOfWeek: String = ""
     var time: String = ""
     var homework: String = ""
     var timeInMinutes: Int = 0
     var userUID: String = ""
     var dateLastChange: Int = 0

}
