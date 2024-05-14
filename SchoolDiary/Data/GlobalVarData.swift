//
//  GlobalVarData.swift
//  SchoolDiary
//
//  Created by Wolf on 23.04.2024.
//

import Foundation

class GlobalVarData {
    static let shared = GlobalVarData()
    private init() {}
    var notificationHour = 20
    var notificationMinutes = 0
    var notificationDays = [Int]()
    var notificationIsAccepted = false
    var checkLessonDownload = false
    var checkHomeworkDownload = false
   @Published var lessons = [FirebaseDateLesson]()
   @Published var homeworkFirebase = [Homework]()
}
