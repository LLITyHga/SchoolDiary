//
//  EditorLessons.swift
//  SchoolDiary
//
//  Created by Wolf on 17.05.2024.
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

protocol EditorLessonsDelegate: UIViewController {
    func didDonePressed ()
    func reloadCollectionView ()
    func lessonCellData(cellData: Lesson3)
}

class EditorLessons {
    
    weak var delegate: EditorLessonsDelegate?
    
    let realm = try! Realm()
    var allLessons: Results<Lesson3>?
    var allHomeworks: Results<Homework2>?
    let datePicker = UIDatePicker()
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
    var isEditingLesson = Lesson3()
    var lesson = Lesson3()
    var timeForLesson = ""
    
    
    func nextTapped(subjectTextField: String) {
        if subjectTextField != ""  {
            let timeTextField = timeForLesson
            lesson.title = subjectTextField
            lesson.time = timeTextField
            guard let userUID = Auth.auth().currentUser?.uid else {
                return
            }
        switch count {
        case 0:lesson.dayOfWeek = "monday"
            delegate?.didDonePressed()   // текстфіелд зроюить окреме проперті бо параметр приходить порожній і доне прессед його не змінює
            arrayAddedTime.append(timeTextField)
            lesson.time = timeTextField
            lesson.timeInMinutes = timeInMinutes
            lesson.userUID = userUID
            lesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            lesson.key = "\(lesson.title)+\(lesson.timeInMinutes)+\(lesson.userUID)"
            if monday.contains(where: { $0.title == lesson.title && $0.timeInMinutes == lesson.timeInMinutes}){
                
            }else{
                monday.append(lesson)
            }
        case 1:lesson.dayOfWeek = "tuesday"
            delegate?.didDonePressed() 
            arrayAddedTime.append(timeTextField)
            lesson.time = timeTextField
            lesson.timeInMinutes = timeInMinutes
            lesson.userUID = userUID
            lesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            lesson.key = "\(lesson.title)+\(lesson.timeInMinutes)+\(lesson.userUID)"
            if tuesday.contains(where: { $0.title == lesson.title && $0.timeInMinutes == lesson.timeInMinutes}){
                
            }else{
                tuesday.append(lesson)
            }
        case 2:lesson.dayOfWeek = "wednesday"
            delegate?.didDonePressed() 
            arrayAddedTime.append(timeTextField)
            lesson.time = timeTextField
            lesson.timeInMinutes = timeInMinutes
            lesson.userUID = userUID
            lesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            lesson.key = "\(lesson.title)+\(lesson.timeInMinutes)+\(lesson.userUID)"
            if wednesday.contains(where: { $0.title == lesson.title && $0.timeInMinutes == lesson.timeInMinutes}){
                
            }else{
                wednesday.append(lesson)
            }
        case 3:lesson.dayOfWeek = "thursday"
            delegate?.didDonePressed()
            arrayAddedTime.append(timeTextField)
            lesson.time = timeTextField
            lesson.timeInMinutes = timeInMinutes
            lesson.userUID = userUID
            lesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            lesson.key = "\(lesson.title)+\(lesson.timeInMinutes)+\(lesson.userUID)"
            if thursday.contains(where: { $0.title == lesson.title && $0.timeInMinutes == lesson.timeInMinutes}){
                
            }else{
                thursday.append(lesson)
            }
        case 4:lesson.dayOfWeek = "friday"
            delegate?.didDonePressed()
            arrayAddedTime.append(timeTextField)
            lesson.time = timeTextField
            lesson.timeInMinutes = timeInMinutes
            lesson.userUID = userUID
            lesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            lesson.key = "\(lesson.title)+\(lesson.timeInMinutes)+\(lesson.userUID)"
            if friday.contains(where: { $0.title == lesson.title && $0.timeInMinutes == lesson.timeInMinutes}){
                
            }else{
                friday.append(lesson)
            }
        default:
            delegate?.didDonePressed()
            arrayAddedSubjects.append(subjectTextField)
            arrayAddedTime.append(timeTextField)
        }
        }else{
            let alert = UIAlertController(title: "Введіть назву предмета", message: "", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .default, handler: nil)
                
            alert.addAction(cancel)
            delegate?.present(alert, animated: true, completion: nil)
        }
        do{
            try realm.write{
                print(lesson)
                if  ((allLessons?.contains(where: {$0 .key == lesson.key})) != nil){
                    realm.add(lesson, update: .modified)
                    loadLessons()
                    delegate?.reloadCollectionView()
                    lesson = Lesson3()
                }else{
                    realm.add(lesson)
                    loadLessons()
                    delegate?.reloadCollectionView()
                    lesson = Lesson3()
                }
            }
        }catch{
            print("Error saving")
        }
        NotificationCenter.default.post(name: Notification.Name.realmDataDidChange, object: nil)
    }
    
    func loadLessons() {
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        allLessons = realm.objects(Lesson3.self).filter("userUID == %@", userUID)
        if allLessons != nil {
        for i in allLessons! {
            let lesson2 = Lesson3()
                        lesson2.title = i.title
                        lesson2.selected = i.selected
                        lesson2.dayOfWeek = i.dayOfWeek
                        lesson2.time = i.time
                        lesson2.homework = i.homework
                        lesson2.timeInMinutes = i.timeInMinutes
            lesson2.key = i.key
            lesson2.userUID = i.userUID
            lesson2.dateLastChange = i.dateLastChange
            if i.dayOfWeek == "monday" {
                if monday.contains(where: { $0.title == lesson2.title}){
                }else{
                    monday.append(lesson2)
                }
            }
            if i.dayOfWeek == "tuesday" {
                if tuesday.contains(where: { $0.title == lesson2.title}){
                }else{
                    tuesday.append(lesson2)
                }            }
            if i.dayOfWeek == "wednesday" {
                if wednesday.contains(where: { $0.title == lesson2.title}){
                }else{
                    wednesday.append(lesson2)
                }            }
            if i.dayOfWeek == "thursday" {
                if thursday.contains(where: { $0.title == lesson2.title}){
                }else{
                    thursday.append(lesson2)
                }            }
            if i.dayOfWeek == "friday" {
                if friday.contains(where: { $0.title == lesson2.title}){
                }else{
                    friday.append(lesson2)
                }            }
           }
        }
        monday.sort { $0.timeInMinutes < $1.timeInMinutes }
        tuesday.sort { $0.timeInMinutes < $1.timeInMinutes }
        wednesday.sort { $0.timeInMinutes < $1.timeInMinutes }
        thursday.sort { $0.timeInMinutes < $1.timeInMinutes }
        friday.sort { $0.timeInMinutes < $1.timeInMinutes }
        
    }

    func selectedItem(row: Int) {
        do{
            try realm.write {
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
        }catch{
            print("catch in selectedItem")
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
}

