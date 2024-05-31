//
//  Main.swift
//  SchoolDiary
//
//  Created by Wolf on 24.05.2024.
//

import UIKit
import RealmSwift
import FSCalendar
import AVFoundation
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import SafariServices
import UserNotifications
import Speech

protocol MainDelegate: UIViewController {
    func reloadDateCV()
    func reloadMainCV()
    func lessonCellData(cellLesson: Lesson6, dayHomework: [Homework2])
}

class Main {
    
    weak var delegate: MainDelegate?
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var chooseDayArray = [ChooseDay2]() /*use for pick cells in dateCV*/
    var weekHomework = [Homework2]() // there I download from database homeworks of current week
    var chooseDate = Date()
    var x = Date().daysOfWeek(using: .iso8601) //array week Date`s for objects in chooseDayArray
    let currentDay = ["\(Date().dd)", "\(Date().weekDay)"] //make current day in dateCV orange color
    var count = 0  //take knowlage what day of week show to user
    var db = Firestore.firestore()

    let realm = try! Realm()
    var allLessons: Results<Lesson6>?
    var allLessons2 = [Lesson6]()
    var templateLessons: Results<Lesson3>?
    var allHomeworks: Results<Homework2>?
    var allHomeworks2 = [Homework2]()
    var dateLesslons = [Lesson6]()
    var templateDay: Results<Lesson3>?
    var templateDay2 = [Lesson3]()
    var monday = [Lesson6]()
    var tuesday = [Lesson6]()
    var wednesday = [Lesson6]()
    var thursday = [Lesson6]()
    var friday = [Lesson6]()
    var editArrayOfLessons = [Lesson6]()
    var urls = [URL]()
    
    func reloadData () {
        
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        allLessons = realm.objects(Lesson6.self).filter("userUID == %@", userUID)
        allHomeworks = realm.objects(Homework2.self).filter("userUID == %@", userUID)
        weekHomework = [Homework2]()
        for i in chooseDayArray {
            if allHomeworks != nil{
                for y in allHomeworks! {
                    if y.day.ddMMyyyy == i.day.ddMMyyyy {
                        weekHomework.append(y)
                    }
                }
            }
        }
    }
    
    func sendCellSettings (cellNumber: Int) {
        var cellLesson = Lesson6()
        switch count {
        case 0: cellLesson = monday[cellNumber]
        case 1: cellLesson = tuesday[cellNumber]
        case 2: cellLesson = wednesday[cellNumber]
        case 3: cellLesson = thursday[cellNumber]
        case 4: cellLesson = friday[cellNumber]
        default:
            print("trubble in sendCellSettings")
            cellLesson = monday[cellNumber]
        }
        var dayHomework = [Homework2]()
        for i in weekHomework {
            if i.day.ddMMyyyy == chooseDayArray[count].day.ddMMyyyy {
                dayHomework.append(i)
            }
        }
        delegate?.lessonCellData(cellLesson: cellLesson, dayHomework: dayHomework)
    }
    
    func setWeekHomeworks () {
        for i in x {
            let dayX = ChooseDay2()
            dayX.day = i
            if allHomeworks != nil{
                for y in allHomeworks! {
                    if y.day.ddMMyyyy == i.ddMMyyyy {
                        weekHomework.append(y)
                    }
                }
            }
            chooseDayArray.append(dayX)
        }
    }
    
    func selectedLesson(row: Int) {
        switch count {
        case 0: guard let thisLesson = realm.objects(Lesson6.self).filter("title == %@ AND date == %@ AND timeInMinutes == %@ AND userUID == %@", monday[row].title, monday[row].date, monday[row].timeInMinutes, monday[row].userUID).first else{return}//correct filter for all
            try? realm.write {
                let edittedLesson = Lesson6()
                edittedLesson.title = thisLesson.title
                edittedLesson.timeInMinutes = thisLesson.timeInMinutes
                edittedLesson.dayOfWeek = thisLesson.dayOfWeek
                edittedLesson.time = thisLesson.time
                edittedLesson.homework = thisLesson.homework
                edittedLesson.date = thisLesson.date
                edittedLesson.selected = !thisLesson.selected
                edittedLesson.userUID = thisLesson.userUID
                edittedLesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
                edittedLesson.primaryKey = thisLesson.primaryKey
                realm.add(edittedLesson, update: .modified)
            }
        case 1: guard let thisLesson = realm.objects(Lesson6.self).filter("title == %@ AND date == %@ AND timeInMinutes == %@ AND userUID == %@", tuesday[row].title, tuesday[row].date, tuesday[row].timeInMinutes, tuesday[row].userUID).first else{return}
            // print(thisLesson)
            try? realm.write {
                
                let edittedLesson = Lesson6()
                edittedLesson.title = thisLesson.title
                edittedLesson.timeInMinutes = thisLesson.timeInMinutes
                edittedLesson.dayOfWeek = thisLesson.dayOfWeek
                edittedLesson.time = thisLesson.time
                edittedLesson.homework = thisLesson.homework
                edittedLesson.date = thisLesson.date
                edittedLesson.selected = !thisLesson.selected
                edittedLesson.userUID = thisLesson.userUID
                edittedLesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
                edittedLesson.primaryKey = thisLesson.primaryKey
                realm.add(edittedLesson, update: .modified)
            }
        case 2: guard let thisLesson = realm.objects(Lesson6.self).filter("title == %@ AND date == %@ AND timeInMinutes == %@ AND userUID == %@", wednesday[row].title, wednesday[row].date, wednesday[row].timeInMinutes, wednesday[row].userUID).first else{return}
            //     print(thisLesson)
            try? realm.write {
                
                let edittedLesson = Lesson6()
                edittedLesson.title = thisLesson.title
                edittedLesson.timeInMinutes = thisLesson.timeInMinutes
                edittedLesson.dayOfWeek = thisLesson.dayOfWeek
                edittedLesson.time = thisLesson.time
                edittedLesson.homework = thisLesson.homework
                edittedLesson.date = thisLesson.date
                edittedLesson.selected = !thisLesson.selected
                edittedLesson.userUID = thisLesson.userUID
                edittedLesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
                edittedLesson.primaryKey = thisLesson.primaryKey
                realm.add(edittedLesson, update: .modified)
            }
            
        case 3: guard let thisLesson = realm.objects(Lesson6.self).filter("title == %@ AND date == %@ AND timeInMinutes == %@ AND userUID == %@", thursday[row].title, thursday[row].date, thursday[row].timeInMinutes, thursday[row].userUID).first else{return}
            // print(thisLesson)
            try? realm.write {
                
                let edittedLesson = Lesson6()
                edittedLesson.title = thisLesson.title
                edittedLesson.timeInMinutes = thisLesson.timeInMinutes
                edittedLesson.dayOfWeek = thisLesson.dayOfWeek
                edittedLesson.time = thisLesson.time
                edittedLesson.homework = thisLesson.homework
                edittedLesson.date = thisLesson.date
                edittedLesson.selected = !thisLesson.selected
                edittedLesson.userUID = thisLesson.userUID
                edittedLesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
                edittedLesson.primaryKey = thisLesson.primaryKey
                realm.add(edittedLesson, update: .modified)
            }
        case 4: guard let thisLesson = realm.objects(Lesson6.self).filter("title == %@ AND date == %@ AND timeInMinutes == %@ AND userUID == %@", friday[row].title, friday[row].date, friday[row].timeInMinutes, friday[row].userUID).first else{return}
            // print(thisLesson)
            try? realm.write {
                
                let edittedLesson = Lesson6()
                edittedLesson.title = thisLesson.title
                edittedLesson.timeInMinutes = thisLesson.timeInMinutes
                edittedLesson.dayOfWeek = thisLesson.dayOfWeek
                edittedLesson.time = thisLesson.time
                edittedLesson.homework = thisLesson.homework
                edittedLesson.date = thisLesson.date
                edittedLesson.selected = !thisLesson.selected
                edittedLesson.userUID = thisLesson.userUID
                edittedLesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
                edittedLesson.primaryKey = thisLesson.primaryKey
                realm.add(edittedLesson, update: .modified)
            }
        default:
            guard let thisLesson = realm.objects(Lesson6.self).filter("title == %@ AND date == %@ AND timeInMinutes == %@ AND userUID == %@", tuesday[row].title, tuesday[row].date, tuesday[row].timeInMinutes, monday[row].userUID).first else{return}
            try? realm.write {
                
                let edittedLesson = Lesson6()
                edittedLesson.title = thisLesson.title
                edittedLesson.timeInMinutes = thisLesson.timeInMinutes
                edittedLesson.dayOfWeek = thisLesson.dayOfWeek
                edittedLesson.time = thisLesson.time
                edittedLesson.homework = thisLesson.homework
                edittedLesson.date = thisLesson.date
                edittedLesson.selected = !thisLesson.selected
                edittedLesson.primaryKey = thisLesson.primaryKey
                realm.add(edittedLesson, update: .modified)
            }
        }
    }
    
    func loadUrl() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            urls = fileURLs
            // process files
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
    
    @objc func reloadAll() {
        loadLessons()
        dateLessons()
        delegate?.reloadMainCV()
    }
    
    func writeUniqueLessonsToRealm(_ array1: [Lesson6], _ array2: [FirebaseDateLesson]) {
        var uniqueObj1 = [Lesson6]()
        var uniqueObj2 = [FirebaseDateLesson]()
        for obj1 in array1{
            let existInArr2 = array2.contains(where: { obj2 in
                if obj1.primaryKey == obj2.primaryKey && obj1.dateLastChange > obj2.dateLastChange{
                    uniqueObj1.append(obj1)
                }//check changes in the same objects
                return obj1.primaryKey == obj2.primaryKey && obj1.dateLastChange == obj2.dateLastChange
            })
            if !existInArr2 {
                
                uniqueObj1.append(obj1)
            }
        }
        for obj2 in array2 {
            let existInArr1 = array1.contains(where: { obj1 in
                if obj2.primaryKey == obj1.primaryKey && obj2.dateLastChange > obj1.dateLastChange{
                    uniqueObj2.append(obj2)
                }
                return obj2.primaryKey == obj1.primaryKey
            })
            if !existInArr1 {uniqueObj2.append(obj2)}
        }
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        for thisLesson in uniqueObj2 {
            let edittedLesson = Lesson6()
            edittedLesson.title = thisLesson.title
            edittedLesson.timeInMinutes = thisLesson.timeInMinutes
            edittedLesson.dayOfWeek = thisLesson.dayOfWeek
            edittedLesson.time = thisLesson.time
            edittedLesson.homework = thisLesson.homework
            edittedLesson.date = thisLesson.date
            edittedLesson.selected = thisLesson.selected
            edittedLesson.userUID = userUID
            edittedLesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            edittedLesson.primaryKey = thisLesson.primaryKey
            uniqueObj1.append(edittedLesson)
        }
        for i in uniqueObj1 {
            do{
                try realm.write{
                    realm.add(i, update: .modified)
                }
            }catch{
                print("Error saving imageUrl")
            }
        }
    }
    func writeUniqueHomeworksToRealm(_ array1: [Homework], _ array2: [Homework2]) {
        var uniqueObj1 = [Homework]()
        var uniqueObj2 = [Homework2]()
        for obj1 in array1{
            let existInArr2 = array2.contains(where: { obj2 in
                if obj1.key == obj2.key && obj1.dateLastChange > obj2.dateLastChange{
                    uniqueObj1.append(obj1)
                }//check changes in the same objects
                return obj1.key == obj2.key && obj1.dateLastChange == obj2.dateLastChange
            })
            if !existInArr2 {
                
                uniqueObj1.append(obj1)
            }
        }
        for obj2 in array2 {
            let existInArr1 = array1.contains(where: { obj1 in
                if obj2.key == obj1.key && obj2.dateLastChange > obj1.dateLastChange{
                    uniqueObj2.append(obj2)
                }
                return obj2.key == obj1.key
            })
            if !existInArr1 {uniqueObj2.append(obj2)}
        }
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        for thisHomework in uniqueObj1 {
            let editHomework = Homework2()
            editHomework.text = thisHomework.text
            editHomework.lesson = thisHomework.lesson
            editHomework.day = thisHomework.day
            editHomework.selected = thisHomework.selected
            editHomework.userUID = userUID
            editHomework.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            editHomework.key = thisHomework.key

            uniqueObj2.append(editHomework)
        }
        for i in uniqueObj2 {
            do{
                try realm.write{
                    realm.add(i, update: .modified)
                }
            }catch{
                print("Error saving imageUrl")
            }
        }
    }
    func uploadToFirebase() {
       // reloadAll()
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
            let base = realm.objects(Lesson6.self).filter("userUID == %@", userUID)
        let homeworksBase = realm.objects(Homework2.self).filter("userUID == %@", userUID)
        var homeworksBase2 = [Homework2]()
            var base2 = [Lesson6]()
            for i in base {base2.append(i)}
        for i in homeworksBase {homeworksBase2.append(i)}
            var lessonsDictionaryFB = [String:Bool]()
        var toUpload = [Lesson6]()
        for i in GlobalVarData.shared.lessons {
            lessonsDictionaryFB[i.primaryKey] = true
        }
        for i in base2 {
            if lessonsDictionaryFB[i.primaryKey] == nil {
                toUpload.append(i)
            }
        }
            for i in toUpload {
            self.db.collection("lessons"+userUID).addDocument(data: [
                "title" : i.title,
                "selected" : i.selected,
                "dayOfWeek" : i.dayOfWeek,
                "time" : i.time,
                "homework" : i.homework,
                "timeInMinutes" : i.timeInMinutes,
                "date" : i.date,
                "primaryKey" : i.primaryKey,
                "userUID" : i.userUID,
                "dateLastChange" : i.dateLastChange
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Lesson added to Firebase")
                }
            }
            }
        
        var homeworkToUpload = [Homework2]()
        var homeworkDictionary = [String:Bool]()
            for i in GlobalVarData.shared.homeworkFirebase {
                homeworkDictionary[i.key] = true
            }
        for i in homeworksBase2 {
            if homeworkDictionary[i.key] == nil {
                homeworkToUpload.append(i)
            }
        }
            for i in homeworkToUpload {
                db.collection("homeworks"+userUID).whereField("key", isEqualTo: i.key).getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("помилка при завантаженні документів \(error)")
                    }else{
                            self.db.collection("homeworks"+userUID).addDocument(data: [
                                "text" : i.text,
                                                    "selected" : i.selected,
                                                    "lesson" : i.lesson,
                                                    "day" : i.day,
                                                    "key" : i.key,
                                                    "userUID" : i.userUID,
                                                    "dateLastChange" : i.dateLastChange
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    print("Document added")
                                }
                            }
            }
        }
            }
        
        
    }


    func checkForPermission() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { [self] settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.dispatchNotification()
            case .denied:
                return
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in
                    if didAllow {
                        self.dispatchNotification()
                    }
                }
            default:
                return
            }
        
        }
    }
    func dispatchNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        let identifier = "notification"
        let title = "Не завершене домашнє завдання"
        let body = "Тут вказуємо невиконані уроки"
        let isDaily = false
        let notificationCenter = UNUserNotificationCenter.current()
        let days = GlobalVarData.shared.notificationDays
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let calendar = Calendar.current
        var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
        dateComponents.hour = GlobalVarData.shared.notificationHour
        dateComponents.minute = GlobalVarData.shared.notificationMinutes
        
        for i in days {
            if i == 0{
                dateComponents.weekday = 2 // monday
                let mondayTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
                let mondayRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: mondayTrigger)
                notificationCenter.add(mondayRequest)
            }
            if i == 1{
                dateComponents.weekday = 3
                let tuesdayTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
                let tuesdayRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: tuesdayTrigger)
                notificationCenter.add(tuesdayRequest)
            }
            if i == 2{dateComponents.weekday = 4
                let wednesdayTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
                let wednesdayRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: wednesdayTrigger)
                notificationCenter.add(wednesdayRequest)
            }
            if i == 3{dateComponents.weekday = 5
                let thursdayTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
                let thursdayRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: thursdayTrigger)
                notificationCenter.add(thursdayRequest)
            }
            if i == 4{dateComponents.weekday = 6
                let fridayTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
                let fridayRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: fridayTrigger)
                notificationCenter.add(fridayRequest)
            }
        }
       // notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
     func checkDoneHomework() {
         GlobalVarData.shared.notificationDays = []
        if let userUID = Auth.auth().currentUser?.uid {
            let monLessons = realm.objects(Lesson6.self).filter("date == %@ AND userUID == %@", x[0], userUID)
            let tueLessons = realm.objects(Lesson6.self).filter("date == %@ AND userUID == %@", x[1], userUID)
            let wedLessons = realm.objects(Lesson6.self).filter("date == %@ AND userUID == %@", x[2], userUID)
            let thuLessons = realm.objects(Lesson6.self).filter("date == %@ AND userUID == %@", x[3], userUID)
            let friLessons = realm.objects(Lesson6.self).filter("date == %@ AND userUID == %@", x[4], userUID)
            let weekLessons = [monLessons, tueLessons, wedLessons, thuLessons, friLessons].self

            var dayCount = 0
            for i in weekLessons {
                let addNF = i.contains { lesson in
                    !lesson.selected
                }
                if addNF {GlobalVarData.shared.notificationDays.append(dayCount)}
                dayCount = dayCount + 1
            }
        }
    }
    func deleteCollection(collectionPath: String, completion: @escaping (Error?) -> Void) {
        let collRef = db.collection(collectionPath)
        collRef.getDocuments { [self] (querySnapshot, error) in
            if let error = error {
                completion(error)
                return
            }
           
            guard let documents = querySnapshot?.documents else {
                completion(nil)
                return
            }
            
            let batch = self.db.batch()
            
            for document in documents {
                batch.deleteDocument(document.reference)
            }
            
            batch.commit { (batchError) in
                completion(batchError)
            }
        }
    }
    func syncWithFirebase() {
        let db = Firestore.firestore()
        if let userUID = Auth.auth().currentUser?.uid{
            db.collection("lessons"+userUID).getDocuments { [self] querySnapshot, error in
          
            
                            if let e = error {
                                print("Помилка при отриманні з фаєрбази \(e)")
                            }else {
        if let snapshotDocumet = querySnapshot?.documents {
            if snapshotDocumet.isEmpty {
                uploadToFirebase()
            }
            for doc in snapshotDocumet {
                let lesson = FirebaseDateLesson(title: doc["title"] as? String ?? "",
                                     selected: doc["selected"] as? Bool ?? false,
                                     dayOfWeek: doc["dayOfWeek"] as? String ?? "",
                                     time: doc["time"] as? String ?? "",
                                     homework: doc["homework"] as? String ?? "",
                                     timeInMinutes: doc["timeInMinutes"] as? Int ?? 0,
                                     date: doc["date"] as? Date ?? Date(),
                                     primaryKey: doc["primaryKey"] as? String ?? "",
                                     userUID: doc["userUID"] as? String ?? "",
                                     dateLastChange: doc["dateLastChange"] as? Int ?? 0)
                print("download", lesson.primaryKey)
                GlobalVarData.shared.lessons.append(lesson)
                if GlobalVarData.shared.lessons.count == snapshotDocumet.count {
                    print("LES DOWNLOADED")
                    writeUniqueLessonsToRealm(allLessons2, GlobalVarData.shared.lessons)
                    GlobalVarData.shared.checkLessonDownload = true
                    if GlobalVarData.shared.checkHomeworkDownload == true && GlobalVarData.shared.checkLessonDownload == true {uploadToFirebase()}
                }
             //   NotificationCenter.default.post(name: Notification.Name.firebaseDownloaded, object: nil)
            }
        }
                }
        }}
        if let userUID = Auth.auth().currentUser?.uid {
            db.collection("homeworks"+userUID).getDocuments { [self] querySnapshot, error in
                            if let e = error {
                                print("Помилка при отриманні з фаєрбази \(e)")
                            }else {
        if let snapshotDocumet = querySnapshot?.documents {
            for doc in snapshotDocumet {
                let homework = Homework(
                    day: doc["day"] as? Date ?? Date(),
                    selected: doc["selected"] as? Bool ?? false,
                    text: doc["text"] as? String ?? "",
                    lesson: doc["lesson"] as? String ?? "",
                    key: doc["key"] as? String ?? "",
                    userUID: doc["userUID"] as? String ?? "",
                    dateLastChange: doc["dateLastChange"] as? Int ?? 0)

                GlobalVarData.shared.homeworkFirebase.append(homework)
            }
            if GlobalVarData.shared.homeworkFirebase.count == snapshotDocumet.count {
                print("HW DOWNLOADED")
                writeUniqueHomeworksToRealm(GlobalVarData.shared.homeworkFirebase, allHomeworks2)
                GlobalVarData.shared.checkHomeworkDownload = true
                if GlobalVarData.shared.checkHomeworkDownload == true && GlobalVarData.shared.checkLessonDownload == true {uploadToFirebase()}
            }
        }
                }
        }
        }
    }
    @objc func setNotification() {
        checkDoneHomework()
        dispatchNotification()
    }
 
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        x = date.daysOfWeek(using: .iso8601)
        chooseDate = date
        chooseDayArray = [ChooseDay2]()
        weekHomework = [Homework2]()
        for i in x {
            let dayX = ChooseDay2()
            dayX.day = i
            for y in allHomeworks! {
                if i.ddMMyyyy == y.day.ddMMyyyy{
                    weekHomework.append(y)
                }
            }
            if i.ddMMyyyy == chooseDate.ddMMyyyy{
                dayX.selected = true
            }else{
                dayX.selected = false
            }
            chooseDayArray.append(dayX)
        }
        count = Int(chooseDate.numberDayInWeek) ?? 1
        count -= 1
        loadLessons()
        dateLessons()
        delegate?.reloadDateCV()
        delegate?.reloadMainCV()
    }
    
    func dateLessons() {
        dateLesslons.removeAll()
            for obj1 in templateDay2 { //check templates in a day and create new dateLesson
                var found = false
                for obj2 in editArrayOfLessons {
                    if obj1.title == obj2.title && obj1.timeInMinutes == obj2.timeInMinutes && obj2.date == x[count] && obj1.userUID == obj2.userUID{
                        found = true
                        dateLesslons.append(obj2)
                    }
                }
                if !found {
                    guard let userUID = Auth.auth().currentUser?.uid else {
                        return
                    }
                    let newLesson = Lesson6()
                    newLesson.title = obj1.title
                    newLesson.timeInMinutes = obj1.timeInMinutes
                    newLesson.dayOfWeek = obj1.dayOfWeek
                    newLesson.time = obj1.time
                    newLesson.homework = obj1.homework
                    newLesson.selected = obj1.selected
                    newLesson.date = x[count]
                    newLesson.userUID = userUID
                    newLesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
                    newLesson.primaryKey = "\(obj1.title)-\(x[count])-\(obj1.timeInMinutes)-\(obj1.userUID)"
                        try? realm.write{
                            realm.add(newLesson, update: .modified)
                        }
                    dateLesslons.append(newLesson)
                }
            }
            switch count {
            case 0: monday = dateLesslons
            case 1: tuesday = dateLesslons
            case 2: wednesday = dateLesslons
            case 3: thursday = dateLesslons
            case 4: friday = dateLesslons
            default:
                monday = dateLesslons
            }
        monday.sort { $0.timeInMinutes < $1.timeInMinutes }
        tuesday.sort { $0.timeInMinutes < $1.timeInMinutes }
        wednesday.sort { $0.timeInMinutes < $1.timeInMinutes }
        thursday.sort { $0.timeInMinutes < $1.timeInMinutes }
        friday.sort { $0.timeInMinutes < $1.timeInMinutes }
        delegate?.reloadMainCV()
    }
    
    func loadLessons() {
        monday.removeAll()
        tuesday.removeAll()
        wednesday.removeAll()
        thursday.removeAll()
        friday.removeAll()
        templateDay2.removeAll()
        editArrayOfLessons.removeAll()
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
     //   templateLessons = realm.objects(Lesson3.self).filter("userUID == %@", userUID)
        allLessons = realm.objects(Lesson6.self).filter("userUID == %@", userUID)
        allHomeworks = realm.objects(Homework2.self).filter("userUID == %@", userUID)
        switch count{
        case 0: templateDay = realm.objects(Lesson3.self).filter("dayOfWeek == %@ AND userUID == %@", "monday", userUID)
        case 1: templateDay = realm.objects(Lesson3.self).filter("dayOfWeek == %@ AND userUID == %@", "tuesday", userUID)
        case 2: templateDay = realm.objects(Lesson3.self).filter("dayOfWeek == %@ AND userUID == %@", "wednesday", userUID)
        case 3: templateDay = realm.objects(Lesson3.self).filter("dayOfWeek == %@ AND userUID == %@", "thursday", userUID)
        case 4: templateDay = realm.objects(Lesson3.self).filter("dayOfWeek == %@ AND userUID == %@", "friday", userUID)
        default:
            return
        }
        if templateDay != nil{ for day in templateDay!{templateDay2.append(day)}}
        if allLessons != nil {for day in allLessons!{editArrayOfLessons.append(day)}}
        if allLessons != nil {for day in allLessons!{allLessons2.append(day)}}
        if allHomeworks != nil {for i in allHomeworks!{allHomeworks2.append(i)}}
    }
}

extension Calendar {
    static let iso8601 = Calendar(identifier: .iso8601)
   // static let gregorian = Calendar(identifier: .gregorian)
}

extension Date {
    func byAdding(component: Calendar.Component, value: Int, wrappingComponents: Bool = false, using calendar: Calendar = .current) -> Date? {
        calendar.date(byAdding: component, value: value, to: self, wrappingComponents: wrappingComponents)
    }
    func dateComponents(_ components: Set<Calendar.Component>, using calendar: Calendar = .current) -> DateComponents {
        calendar.dateComponents(components, from: self)
    }
    func startOfWeek(using calendar: Calendar = .current) -> Date {
        calendar.date(from: dateComponents([.yearForWeekOfYear, .weekOfYear], using: calendar))!
    }
    var noon: Date {
        Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    func daysOfWeek(using calendar: Calendar = .current) -> [Date] {
        let startOfWeek = self.startOfWeek(using: calendar).noon
        return (0...6).map { startOfWeek.byAdding(component: .day, value: $0, using: calendar)! }
    }
    var ddMMyyyy: String { Formatter.ddMMyyyy.string(from: self) }
    var dd: String { Formatter.dd.string(from: self) }
    var weekDay: String { Formatter.weekDay.string(from: self) }
    var numberDayInWeek: String { Formatter.numberDayInWeek.string(from: self) }
    var mont: String { Formatter.mont.string(from: self) }
}

extension Formatter {
    static let ddMMyyyy: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = .init(identifier: "uk_UA")
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter
    }()
    static let weekDay: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE")
        dateFormatter.locale = .init(identifier: "uk_UA")
//        dateFormatter.dateFormat = "EEE"
        return dateFormatter
    }()
    static let dd: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = .init(identifier: "uk_UA")
        dateFormatter.dateFormat = "dd"
        return dateFormatter
    }()
    static let numberDayInWeek: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = .init(identifier: "uk_UA")
        dateFormatter.dateFormat = "c"
        return dateFormatter
    }()
    static let mont: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "uk_UA")
        dateFormatter.setLocalizedDateFormatFromTemplate("dd MMMM")
        return dateFormatter
    }()
}
