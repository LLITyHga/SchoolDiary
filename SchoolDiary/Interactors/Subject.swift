//
//  Subject.swift
//  SchoolDiary
//
//  Created by Wolf on 16.05.2024.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import RealmSwift
import GoogleSignIn
import GoogleSignInSwift
import SafariServices

protocol SubjectDelegate: UIViewController {
    func didSetLabel(_ string: String)
    func nextDidNotTapped ()
    func didDonePressed ()
    func lessonCellData(cellData: Lesson3)
}


class Subject {
    let realm = try! Realm()
    var selected1 = [Bool]()
    var count = 0
    var timeInMinutes = 0 //for sort lesson in a day by time
    var bigLabelArray = ["Понеділок", "Вівторок", "Середа", "Четвер", "П`ятниця"]
    var arrayAddedSubjects = [String]()
    var arrayAddedTime = [String]()
    var monday = [Lesson3]()
    var tuesday = [Lesson3]()
    var wednesday = [Lesson3]()
    var thursday = [Lesson3]()
    var friday = [Lesson3]()
    var timeForLesson = ""
    
    weak var delegate: SubjectDelegate?
    
    func setLabel(_ string: String) {
            delegate?.didSetLabel(string)
        }
    
    func backTap() {
        if count > 0 {
            count -= 1
            setLabel(bigLabelArray[count])
        }
//        else{
//            delegate?.dismiss(animated: true)
//        }
    }
    
    func forwardTap() {
        if count < 4 {
        count += 1
            setLabel(bigLabelArray[count])
        }else{
            do{
                try realm.write{
                    for i in monday {
                        realm.add(i)
                    }
                    for i in tuesday {
                        realm.add(i)
                    }
                    for i in wednesday {
                        realm.add(i)
                    }
                    for i in thursday {
                        realm.add(i)
                    }
                    for i in friday {
                        realm.add(i)
                    }

                }
            }catch{
                print("Error saving imageUrl")
            }
            let vc = delegate?.storyboard!.instantiateViewController(withIdentifier: "MainVC") as! MainVC
            vc.modalPresentationStyle = .fullScreen
            delegate?.present(vc, animated: true, completion: nil)
        }

    }
    
    func nextTapped (subjectTextField: String) {
        if subjectTextField != ""  {
            let lesson = Lesson3()
            lesson.title = subjectTextField
            lesson.time = timeForLesson
                    guard let userUID = Auth.auth().currentUser?.uid else {
                        return
                    }
        switch count {
        case 0:lesson.dayOfWeek = "monday"
            delegate?.didDonePressed()
            arrayAddedTime.append(timeForLesson)
            lesson.time = timeForLesson
            lesson.timeInMinutes = timeInMinutes
            lesson.userUID = userUID
            lesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            lesson.key = "\(lesson.title)-\(lesson.timeInMinutes)-\(lesson.userUID)"
            var check = true
            for i in monday{
                if i.key == lesson.key{check = false}
            }
            if check {monday.append(lesson)}
        case 1:lesson.dayOfWeek = "tuesday"
            delegate?.didDonePressed()
            arrayAddedTime.append(timeForLesson)
            lesson.time = timeForLesson
            lesson.timeInMinutes = timeInMinutes
            lesson.userUID = userUID
            lesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            lesson.key = "\(lesson.title)-\(lesson.timeInMinutes)-\(lesson.userUID)"
            var check = true
            for i in tuesday{
                if i.key == lesson.key{check = false}
            }
            if check {tuesday.append(lesson)}
        case 2:lesson.dayOfWeek = "wednesday"
            delegate?.didDonePressed()
            arrayAddedTime.append(timeForLesson)
            lesson.time = timeForLesson
            lesson.timeInMinutes = timeInMinutes
            lesson.userUID = userUID
            lesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            lesson.key = "\(lesson.title)-\(lesson.timeInMinutes)-\(lesson.userUID)"
            var check = true
            for i in wednesday{
                if i.key == lesson.key{check = false}
            }
            if check {wednesday.append(lesson)}
        case 3:lesson.dayOfWeek = "thursday"
            delegate?.didDonePressed()
            arrayAddedTime.append(timeForLesson)
            lesson.time = timeForLesson
            lesson.timeInMinutes = timeInMinutes
            lesson.userUID = userUID
            lesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            lesson.key = "\(lesson.title)-\(lesson.timeInMinutes)-\(lesson.userUID)"
            var check = true
            for i in thursday{
                if i.key == lesson.key{check = false}
            }
            if check {thursday.append(lesson)}
        case 4:lesson.dayOfWeek = "friday"
            delegate?.didDonePressed()
            arrayAddedTime.append(timeForLesson)
            lesson.time = timeForLesson
            lesson.timeInMinutes = timeInMinutes
            lesson.userUID = userUID
            lesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            lesson.key = "\(lesson.title)-\(lesson.timeInMinutes)-\(lesson.userUID)"
            var check = true
            for i in friday{
                if i.key == lesson.key{check = false}
            }
            if check {friday.append(lesson)}
        default:
            delegate?.didDonePressed()
            arrayAddedSubjects.append(subjectTextField)
            arrayAddedTime.append(timeForLesson)
        }
        }else{
            delegate?.nextDidNotTapped() //made alert
        }
    }
    func selectedItem(row: Int) {
        switch count {
        case 0: monday[row].selected = !monday[row].selected
        case 1: tuesday[row].selected = !tuesday[row].selected
        case 2: wednesday[row].selected = !wednesday[row].selected
        case 3: thursday[row].selected = !thursday[row].selected
        case 4: friday[row].selected = !friday[row].selected
        default:
            return
        }
    }
    
    func setNumberOfItemsInSection() -> Int {
        switch count {
        case 0: return monday.count
        case 1: return tuesday.count
        case 2: return wednesday.count
        case 3: return thursday.count
        case 4: return friday.count
        default:
            return 0
        }

    }
    
    func sendCellSettings(cellNumber: Int) {
        var dataCell = Lesson3()
        switch count {
        case 0: dataCell = monday[cellNumber]
        case 1: dataCell = tuesday[cellNumber]
        case 2: dataCell = wednesday[cellNumber]
        case 3: dataCell = thursday[cellNumber]
        case 4: dataCell = friday[cellNumber]
        default:
            print("trubble in sendCellSettings")
            dataCell = monday[cellNumber]
        }
        delegate?.lessonCellData(cellData: dataCell)
    }
    func deleteLesson (lesson: Lesson3) {
        monday.enumerated().forEach { index, item in
            if item.key == lesson.key { monday.remove(at: index)}
        }
        tuesday.enumerated().forEach { index, item in
            if item.key == lesson.key { tuesday.remove(at: index)}
        }
        wednesday.enumerated().forEach { index, item in
            if item.key == lesson.key { wednesday.remove(at: index)}
        }
        thursday.enumerated().forEach { index, item in
            if item.key == lesson.key { thursday.remove(at: index)}
        }
        friday.enumerated().forEach { index, item in
            if item.key == lesson.key { friday.remove(at: index)}
        }
    }
}

