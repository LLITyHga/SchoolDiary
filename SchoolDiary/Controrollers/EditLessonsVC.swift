//
//  EditLessonsVC.swift
//  SchoolDiary
//
//  Created by Wolf on 12.07.2023.
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

class EditLessonsVC: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var lessonsCV: UICollectionView!
    @IBOutlet weak var addField: UIVisualEffectView!
    @IBOutlet weak var mainLabel: UILabel!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
        loadLessons()
        plusButton.frame = CGRect(x: (self.view?.frame.size.width)! / 2.7 , y: (self.view?.frame.size.height)! / 1.27 , width: view.fs_width/3.75, height: view.fs_width/3.75)
        lessonsCV.register(LessonCVCell.nib(), forCellWithReuseIdentifier: "LessonCVCell")
        lessonsCV.delegate = self
        lessonsCV.dataSource = self
        mainLabel.text = bigLabelArray[count]
    }
    
    @IBAction func exitBTN(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func plusBTN(_ sender: UIButton) {
        addField.isHidden = false
        plusButton.isEnabled = false
    }
    
    @IBAction func closeBTN(_ sender: UIButton) {
        plusButton.isEnabled = true
        addField.isHidden = true
    }
    @IBAction func nextBTN(_ sender: UIButton) {
        plusButton.isEnabled = true
        addField.isHidden = true
        if subjectTextField.text != ""  {
            lesson.title = subjectTextField.text!
            lesson.time = timeTextField.text!
            guard let userUID = Auth.auth().currentUser?.uid else {
                return
            }
        switch count {
        case 0:lesson.dayOfWeek = "monday"
            donePressed()
            arrayAddedTime.append(timeTextField.text ?? "")
            lesson.time = timeTextField.text!
            lesson.timeInMinutes = timeInMinutes
            lesson.userUID = userUID
            lesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            lesson.key = "\(lesson.title)+\(lesson.timeInMinutes)+\(lesson.userUID)"
            if monday.contains(where: { $0.title == lesson.title && $0.timeInMinutes == lesson.timeInMinutes}){
                
            }else{
                monday.append(lesson)
            }
        case 1:lesson.dayOfWeek = "tuesday"
            donePressed()
            arrayAddedTime.append(timeTextField.text ?? "")
            lesson.time = timeTextField.text!
            lesson.timeInMinutes = timeInMinutes
            lesson.userUID = userUID
            lesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            lesson.key = "\(lesson.title)+\(lesson.timeInMinutes)+\(lesson.userUID)"
            if tuesday.contains(where: { $0.title == lesson.title && $0.timeInMinutes == lesson.timeInMinutes}){
                
            }else{
                tuesday.append(lesson)
            }
        case 2:lesson.dayOfWeek = "wednesday"
            donePressed()
            arrayAddedTime.append(timeTextField.text ?? "")
            lesson.time = timeTextField.text!
            lesson.timeInMinutes = timeInMinutes
            lesson.userUID = userUID
            lesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            lesson.key = "\(lesson.title)+\(lesson.timeInMinutes)+\(lesson.userUID)"
            if wednesday.contains(where: { $0.title == lesson.title && $0.timeInMinutes == lesson.timeInMinutes}){
                
            }else{
                wednesday.append(lesson)
            }
        case 3:lesson.dayOfWeek = "thursday"
            donePressed()
            arrayAddedTime.append(timeTextField.text ?? "")
            lesson.time = timeTextField.text!
            lesson.timeInMinutes = timeInMinutes
            lesson.userUID = userUID
            lesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            lesson.key = "\(lesson.title)+\(lesson.timeInMinutes)+\(lesson.userUID)"
            if thursday.contains(where: { $0.title == lesson.title && $0.timeInMinutes == lesson.timeInMinutes}){
                
            }else{
                thursday.append(lesson)
            }
        case 4:lesson.dayOfWeek = "friday"
            donePressed()
            arrayAddedTime.append(timeTextField.text ?? "")
            lesson.time = timeTextField.text!
            lesson.timeInMinutes = timeInMinutes
            lesson.userUID = userUID
            lesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            lesson.key = "\(lesson.title)+\(lesson.timeInMinutes)+\(lesson.userUID)"
            if friday.contains(where: { $0.title == lesson.title && $0.timeInMinutes == lesson.timeInMinutes}){
                
            }else{
                friday.append(lesson)
            }
        default:
            donePressed()
            arrayAddedSubjects.append(subjectTextField.text ?? "")
            arrayAddedTime.append(timeTextField.text ?? "")
        }
        subjectTextField.text = ""
        timeTextField.text = ""
        addField.isHidden = true
        }else{
            let alert = UIAlertController(title: "Введіть назву предмета", message: "", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .default, handler: nil)
                
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
        do{
            try realm.write{
                print(lesson)
                if  ((allLessons?.contains(where: {$0 .key == lesson.key})) != nil){
                    realm.add(lesson, update: .modified)
                    loadLessons()
                    lessonsCV.reloadData()
                    lesson = Lesson3()
                }else{
                    realm.add(lesson)
                    loadLessons()
                    lessonsCV.reloadData()
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
        //allHomeworks = realm.objects(Homework2.self).filter("dayOfWeek == %@ AND userUID == %@", "monday", userUID)
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
}

extension EditLessonsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch count {
        case 0:
            monday[indexPath.row].selected = !monday[indexPath.row].selected
            collectionView.reloadData()
        case 1: tuesday[indexPath.row].selected = !tuesday[indexPath.row].selected
            collectionView.reloadData()
        case 2: wednesday[indexPath.row].selected = !wednesday[indexPath.row].selected
            collectionView.reloadData()
        case 3: thursday[indexPath.row].selected = !thursday[indexPath.row].selected
            collectionView.reloadData()
        case 4: friday[indexPath.row].selected = !friday[indexPath.row].selected
            collectionView.reloadData()
        default:
            return
        }
    }
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch count {
    case 0:return monday.count
    case 1:return tuesday.count
    case 2:return wednesday.count
    case 3:return thursday.count
    case 4:return friday.count
    default:
        return 0
    }
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LessonCVCell", for: indexPath) as! LessonCVCell
    switch count {
    case 0:
        cell.timeLabel.text = monday[indexPath.row].time
        cell.nameOfSubject.text = monday[indexPath.row].title
        cell.btnTapAction = {
            () in
            
            do{
                let realm = try! Realm()
                try realm.write {
                    if let lessonToDelete = realm.objects(Lesson3.self).filter("title == %@ AND timeInMinutes == %@", cell.nameOfSubject.text!, self.monday[indexPath.row].timeInMinutes).first {
                        realm.delete(lessonToDelete)
                    }
                    self.monday.remove(at: indexPath.row)
                    // send information to mainVC about changes in database
                    NotificationCenter.default.post(name: Notification.Name.realmDataDidChange, object: nil)
                    collectionView.reloadData()
                }
            }catch{
                print("can`t deleete from realm")
            }
        }
        cell.btnTapEdit = {
            () in
            self.addField.isHidden = false
            self.isEditingLesson = self.monday[indexPath.row]
            self.monday.remove(at: indexPath.row)
        }
        if monday[indexPath.row].selected {
            cell.linearView2.isHidden = false
            cell.deleteBTNOutlet.isHidden = false
            cell.timeLabel.isHidden = true
            cell.editButton.isHidden = false
        } else {
            cell.linearView2.isHidden = true
            cell.deleteBTNOutlet.isHidden = true
            cell.timeLabel.isHidden = false
            cell.editButton.isHidden = true
        }
        return cell
    case 1:cell.timeLabel.text = tuesday[indexPath.row].time
        cell.nameOfSubject.text = tuesday[indexPath.row].title
        cell.btnTapAction = {
            () in
            do{
                let realm = try! Realm()
                try realm.write {
                    if let lessonToDelete = realm.objects(Lesson3.self).filter("title == %@ AND timeInMinutes == %@", cell.nameOfSubject.text!, self.tuesday[indexPath.row].timeInMinutes).first {
                        realm.delete(lessonToDelete)
                    }
                    // send information to mainVC about changes in database
                    NotificationCenter.default.post(name: Notification.Name.realmDataDidChange, object: nil)
                    self.tuesday.remove(at: indexPath.row)
                    collectionView.reloadData()
                }
            }catch{
                print("can`t deleete from realm")
            }
            collectionView.reloadData()
        }
        cell.btnTapEdit = {
            () in
            self.addField.isHidden = false
        }
        if tuesday[indexPath.row].selected {
            cell.linearView2.isHidden = false
            cell.deleteBTNOutlet.isHidden = false
            cell.timeLabel.isHidden = true
            cell.editButton.isHidden = false
        } else {
            cell.linearView2.isHidden = true
            cell.deleteBTNOutlet.isHidden = true
            cell.timeLabel.isHidden = false
            cell.editButton.isHidden = true
        }
        return cell
    case 2:
        cell.timeLabel.text = wednesday[indexPath.row].time
        cell.nameOfSubject.text = wednesday[indexPath.row].title
        cell.btnTapAction = {
            () in
            do{
                let realm = try! Realm()
                try realm.write {
                    if let lessonToDelete = realm.objects(Lesson3.self).filter("title == %@ AND timeInMinutes == %@", cell.nameOfSubject.text!, self.wednesday[indexPath.row].timeInMinutes).first {
                        realm.delete(lessonToDelete)
                    }
                    // send information to mainVC about changes in database
                    NotificationCenter.default.post(name: Notification.Name.realmDataDidChange, object: nil)
                    self.wednesday.remove(at: indexPath.row)
                    collectionView.reloadData()
                }
            }catch{
                print("can`t deleete from realm")
            }
            collectionView.reloadData()
        }
        cell.btnTapEdit = {
            () in
            self.addField.isHidden = false
        }
        if wednesday[indexPath.row].selected {
            cell.linearView2.isHidden = false
            cell.deleteBTNOutlet.isHidden = false
            cell.timeLabel.isHidden = true
            cell.editButton.isHidden = false
        } else {
            cell.linearView2.isHidden = true
            cell.deleteBTNOutlet.isHidden = true
            cell.timeLabel.isHidden = false
            cell.editButton.isHidden = true
        }
        return cell
    case 3:
        cell.timeLabel.text = thursday[indexPath.row].time
        cell.nameOfSubject.text = thursday[indexPath.row].title
        cell.btnTapAction = {
            () in
            do{
                let realm = try! Realm()
                try realm.write {
                    if let lessonToDelete = realm.objects(Lesson3.self).filter("title == %@ AND timeInMinutes == %@", cell.nameOfSubject.text!, self.thursday[indexPath.row].timeInMinutes).first {
                        realm.delete(lessonToDelete)
                    }
                    // send information to mainVC about changes in database
                    NotificationCenter.default.post(name: Notification.Name.realmDataDidChange, object: nil)
                    self.thursday.remove(at: indexPath.row)
                    collectionView.reloadData()
                }
            }catch{
                print("can`t deleete from realm")
            }
            collectionView.reloadData()
        }
        cell.btnTapEdit = {
            () in
            self.addField.isHidden = false
        }
        if thursday[indexPath.row].selected {
            cell.linearView2.isHidden = false
            cell.deleteBTNOutlet.isHidden = false
            cell.timeLabel.isHidden = true
            cell.editButton.isHidden = false
        } else {
            cell.linearView2.isHidden = true
            cell.deleteBTNOutlet.isHidden = true
            cell.timeLabel.isHidden = false
            cell.editButton.isHidden = true
        }
        return cell
    case 4:
        cell.timeLabel.text = friday[indexPath.row].time
        cell.nameOfSubject.text = friday[indexPath.row].title
        cell.btnTapAction = {
            () in
            do{
                let realm = try! Realm()
                try realm.write {
                    if let lessonToDelete = realm.objects(Lesson3.self).filter("title == %@ AND timeInMinutes == %@", cell.nameOfSubject.text!, self.friday[indexPath.row].timeInMinutes).first {
                        realm.delete(lessonToDelete)
                    }
                    // send information to mainVC about changes in database
                    NotificationCenter.default.post(name: Notification.Name.realmDataDidChange, object: nil)
                    self.friday.remove(at: indexPath.row)
                    collectionView.reloadData()
                }
            }catch{
                print("can`t deleete from realm")
            }
            collectionView.reloadData()
        }
        cell.btnTapEdit = {
            () in
            self.addField.isHidden = false
        }
        if friday[indexPath.row].selected {
            cell.linearView2.isHidden = false
            cell.deleteBTNOutlet.isHidden = false
            cell.timeLabel.isHidden = true
            cell.editButton.isHidden = false
        } else {
            cell.linearView2.isHidden = true
            cell.deleteBTNOutlet.isHidden = true
            cell.timeLabel.isHidden = false
            cell.editButton.isHidden = true
        }
        return cell
    default:
        return cell
    }
    
}
    func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBTN = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBTN], animated: true)
        return toolbar
        
    }
    
    func createDatePicker() {
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = NSLocale(localeIdentifier: "ua_UA") as Locale
        timeTextField.inputView = datePicker
        timeTextField.inputAccessoryView = createToolbar()
    }
    
    @objc func donePressed() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        dateFormatter.locale = NSLocale(localeIdentifier: "ua_UA") as Locale
        self.timeTextField.text = dateFormatter.string(from: datePicker.date)
        let components = self.timeTextField.text?.split { $0 == ":" } .map { (x) -> Int in return Int(String(x))! }
        let hours = components?[0]
        let minutes = components?[1]
        if (hours != nil) && minutes != nil {
        timeInMinutes = hours! * 60 + minutes!
        }
        self.view.endEditing(true)
    }
}

