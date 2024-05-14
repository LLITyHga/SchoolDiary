//
//  SubjectVC.swift
//  SchoolDiary
//
//  Created by Wolf on 12.06.2023.
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


class SubjectVC: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var bigLabel: UILabel!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var addField: UIVisualEffectView!
    let realm = try! Realm()
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
    @IBOutlet weak var subjectCV: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plusButton.frame = CGRect(x: (self.view?.frame.size.width)! / 2.7 , y: (self.view?.frame.size.height)! / 1.27 , width: view.fs_width/3.75, height: view.fs_width/3.75)
        addField.isHidden = true
        subjectCV.register(LessonCVCell.nib(), forCellWithReuseIdentifier: "LessonCVCell")
        subjectCV.delegate = self
        subjectCV.dataSource = self
        createDatePicker()
    }

    @IBAction func closeAddField(_ sender: UIButton) {
        addField.isHidden = true
    }
    @IBAction func backBTN(_ sender: UIButton) {
        if count > 0 {
            count -= 1
            bigLabel.text = bigLabelArray[count]
            subjectCV.reloadData()
        }else{
            dismiss(animated: true)
        }
    }
    @IBAction func forwardBTN(_ sender: UIButton) {
        if count < 4 {
        count += 1
        bigLabel.text = bigLabelArray[count]
        addField.isHidden = true
        subjectCV.reloadData()
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
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "MainVC") as! MainVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    @IBAction func plusBTN(_ sender: UIButton) {
        addField.isHidden = false
    }
    @IBAction func nextBTN(_ sender: UIButton) {
        if subjectTextField.text != ""  {
            let lesson = Lesson3()
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
            lesson.key = "\(lesson.title)-\(lesson.timeInMinutes)-\(lesson.userUID)"
            var check = true
            for i in monday{
                if i.key == lesson.key{check = false}
            }
            if check {monday.append(lesson)}
            subjectCV.reloadData()
        case 1:lesson.dayOfWeek = "tuesday"
            donePressed()
            arrayAddedTime.append(timeTextField.text ?? "")
            lesson.time = timeTextField.text!
            lesson.timeInMinutes = timeInMinutes
            lesson.userUID = userUID
            lesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            lesson.key = "\(lesson.title)-\(lesson.timeInMinutes)-\(lesson.userUID)"
            var check = true
            for i in tuesday{
                if i.key == lesson.key{check = false}
            }
            if check {tuesday.append(lesson)}
            subjectCV.reloadData()
        case 2:lesson.dayOfWeek = "wednesday"
            donePressed()
            arrayAddedTime.append(timeTextField.text ?? "")
            lesson.time = timeTextField.text!
            lesson.timeInMinutes = timeInMinutes
            lesson.userUID = userUID
            lesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            lesson.key = "\(lesson.title)-\(lesson.timeInMinutes)-\(lesson.userUID)"
            var check = true
            for i in wednesday{
                if i.key == lesson.key{check = false}
            }
            if check {wednesday.append(lesson)}
            subjectCV.reloadData()
        case 3:lesson.dayOfWeek = "thursday"
            donePressed()
            arrayAddedTime.append(timeTextField.text ?? "")
            lesson.time = timeTextField.text!
            lesson.timeInMinutes = timeInMinutes
            lesson.userUID = userUID
            lesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            lesson.key = "\(lesson.title)-\(lesson.timeInMinutes)-\(lesson.userUID)"
            var check = true
            for i in thursday{
                if i.key == lesson.key{check = false}
            }
            if check {thursday.append(lesson)}
            subjectCV.reloadData()
        case 4:lesson.dayOfWeek = "friday"
            donePressed()
            arrayAddedTime.append(timeTextField.text ?? "")
            lesson.time = timeTextField.text!
            lesson.timeInMinutes = timeInMinutes
            lesson.userUID = userUID
            lesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            lesson.key = "\(lesson.title)-\(lesson.timeInMinutes)-\(lesson.userUID)"
            var check = true
            for i in friday{
                if i.key == lesson.key{check = false}
            }
            if check {friday.append(lesson)}
            subjectCV.reloadData()
        default:
            donePressed()
            arrayAddedSubjects.append(subjectTextField.text ?? "")
            arrayAddedTime.append(timeTextField.text ?? "")
        }
        subjectTextField.text = ""
        timeTextField.text = ""
        subjectCV.reloadData()
        addField.isHidden = true
        }else{
            let alert = UIAlertController(title: "Введіть назву предмета", message: "", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .default, handler: nil)
                
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
    }
    

    
}
extension SubjectVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch count {
        case 0: monday[indexPath.row].selected = !monday[indexPath.row].selected
            collectionView.reloadData()
        case 1: tuesday[indexPath.row].selected = !tuesday[indexPath.row].selected
        case 2: wednesday[indexPath.row].selected = !wednesday[indexPath.row].selected
        case 3: thursday[indexPath.row].selected = !thursday[indexPath.row].selected
        case 4: wednesday[indexPath.row].selected = !wednesday[indexPath.row].selected
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
            self.monday.remove(at: indexPath.row)
            collectionView.reloadData()
        }
        if monday[indexPath.row].selected {
            cell.linearView2.isHidden = false
            cell.deleteBTNOutlet.isHidden = false
            cell.timeLabel.isHidden = true
        } else {
            cell.linearView2.isHidden = true
            cell.deleteBTNOutlet.isHidden = true
            cell.timeLabel.isHidden = false
        }
        return cell
    case 1:cell.timeLabel.text = tuesday[indexPath.row].time
        cell.nameOfSubject.text = tuesday[indexPath.row].title
        cell.btnTapAction = {
            () in
            self.tuesday.remove(at: indexPath.row)
            collectionView.reloadData()
        }
        if tuesday[indexPath.row].selected {
            cell.linearView2.isHidden = false
            cell.deleteBTNOutlet.isHidden = false
            cell.timeLabel.isHidden = true
        } else {
            cell.linearView2.isHidden = true
            cell.deleteBTNOutlet.isHidden = true
            cell.timeLabel.isHidden = false
        }
        return cell
    case 2:cell.timeLabel.text = arrayAddedTime[indexPath.row]
        cell.nameOfSubject.text = wednesday[indexPath.row].title
        cell.btnTapAction = {
            () in
            self.wednesday.remove(at: indexPath.row)
            collectionView.reloadData()
        }
        if wednesday[indexPath.row].selected {
            cell.linearView2.isHidden = false
            cell.deleteBTNOutlet.isHidden = false
            cell.timeLabel.isHidden = true
        } else {
            cell.linearView2.isHidden = true
            cell.deleteBTNOutlet.isHidden = true
            cell.timeLabel.isHidden = false
        }
        return cell
    case 3:cell.timeLabel.text = arrayAddedTime[indexPath.row]
        cell.nameOfSubject.text = thursday[indexPath.row].title
        cell.btnTapAction = {
            () in
            self.thursday.remove(at: indexPath.row)
            collectionView.reloadData()
        }
        if thursday[indexPath.row].selected {
            cell.linearView2.isHidden = false
            cell.deleteBTNOutlet.isHidden = false
            cell.timeLabel.isHidden = true
        } else {
            cell.linearView2.isHidden = true
            cell.deleteBTNOutlet.isHidden = true
            cell.timeLabel.isHidden = false
        }
        return cell
    case 4:cell.timeLabel.text = arrayAddedTime[indexPath.row]
        cell.nameOfSubject.text = friday[indexPath.row].title
        cell.btnTapAction = {
            () in
            self.friday.remove(at: indexPath.row)
            collectionView.reloadData()
        }
        if friday[indexPath.row].selected {
            cell.linearView2.isHidden = false
            cell.deleteBTNOutlet.isHidden = false
            cell.timeLabel.isHidden = true
        } else {
            cell.linearView2.isHidden = true
            cell.deleteBTNOutlet.isHidden = true
            cell.timeLabel.isHidden = false
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














