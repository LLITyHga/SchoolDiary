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
    
    let editorLessons = EditorLessons()
    var cellData = Lesson3()
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editorLessons.delegate = self
        createDatePicker()
        editorLessons.loadLessons()
        plusButton.frame = CGRect(x: (self.view?.frame.size.width)! / 2.7 , y: (self.view?.frame.size.height)! / 1.27 , width: view.fs_width/3.75, height: view.fs_width/3.75)
        lessonsCV.register(LessonCVCell.nib(), forCellWithReuseIdentifier: "LessonCVCell")
        lessonsCV.delegate = self
        lessonsCV.dataSource = self
        mainLabel.text = editorLessons.bigLabelArray[editorLessons.count]
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
        donePressed()
     //   print(timeTextField.text)
        editorLessons.timeForLesson = timeTextField.text ?? ""
       // if editorLessons.timeForLesson == "" {donePressed()}
        editorLessons.nextTapped(subjectTextField: subjectTextField.text ?? "")
        
        
        subjectTextField.text = ""
        timeTextField.text = ""
        addField.isHidden = true

    }
    
}

extension EditLessonsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        editorLessons.selectedItem(row: indexPath.row)
        collectionView.reloadData()
    }
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return editorLessons.setNumberOfItemsInSection()
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LessonCVCell", for: indexPath) as! LessonCVCell
    editorLessons.sendCellSettings(cellNumber: indexPath.row)
    cell.setupCell(lesson: cellData, subj: editorLessons, index: indexPath.row)
    cell.btnTapAction = {
        () in
        collectionView.reloadData()
    }
    cell.btnTapEdit = {
        () in
        self.addField.isHidden = false
        self.editorLessons.isEditingLesson = self.editorLessons.monday[indexPath.row]//?????
        self.editorLessons.monday.remove(at: indexPath.row)
    }
    cell.btnTapDelete = { [self]
        () in
        do{
            let realm = try! Realm()
            try realm.write {
                var arrDell: [Lesson3]
                switch editorLessons.count {
                case 0: arrDell = editorLessons.monday
                    editorLessons.monday.remove(at: indexPath.row)
                case 1: arrDell = editorLessons.tuesday
                    editorLessons.tuesday.remove(at: indexPath.row)
                case 2: arrDell = editorLessons.wednesday
                    editorLessons.wednesday.remove(at: indexPath.row)
                case 3: arrDell = editorLessons.thursday
                    editorLessons.thursday.remove(at: indexPath.row)
                case 4: arrDell = editorLessons.friday
                    editorLessons.friday.remove(at: indexPath.row)
                default:
                    return
                }
                if let lessonToDelete = realm.objects(Lesson3.self).filter("title == %@ AND timeInMinutes == %@", cell.nameOfSubject.text!, arrDell[indexPath.row].timeInMinutes).first {
                    realm.delete(lessonToDelete)
                }
                
                // send information to mainVC about changes in database
            }
            NotificationCenter.default.post(name: Notification.Name.realmDataDidChange, object: nil)
            collectionView.reloadData()
        }catch{
            print("can`t delete from realm")
        }
    }
    
    return cell
    
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
            editorLessons.timeInMinutes = hours! * 60 + minutes!
        }
        self.view.endEditing(true)
    }
}
extension EditLessonsVC: EditorLessonsDelegate {
    func lessonCellData(cellData: Lesson3) {
        self.cellData = cellData
    }
    

    func reloadCollectionView() {
        lessonsCV.reloadData()
    }
    
    func didDonePressed() {
        donePressed()
    }
    
    
}

