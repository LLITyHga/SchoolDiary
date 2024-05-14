//
//  FirebaseDateLesson.swift
//  SchoolDiary
//
//  Created by Wolf on 16.04.2024.
//

import Foundation

struct FirebaseDateLesson {
  var title: String = ""
  var selected: Bool = false
  var dayOfWeek: String = ""
  var time: String = ""
  var homework: String = ""
  var timeInMinutes: Int = 0
  var date = Date()
  var primaryKey: String = ""
  var userUID: String = ""
  var dateLastChange: Int = 0
}
