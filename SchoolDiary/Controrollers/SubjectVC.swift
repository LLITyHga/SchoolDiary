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
    let subject = Subject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subject.delegate = self
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
        subject.backTap()
        subjectCV.reloadData()
    }
    @IBAction func forwardBTN(_ sender: UIButton) {
        subject.forwardTap()
        addField.isHidden = true
        subjectCV.reloadData()
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "MainVC") as! MainVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
            }
    @IBAction func plusBTN(_ sender: UIButton) {
        addField.isHidden = false
    }
    @IBAction func nextBTN(_ sender: UIButton) {
        subject.nextTapped(subjectTextField: subjectTextField.text ?? "", timeTextField: timeTextField.text ?? "")
        subjectTextField.text = ""
        timeTextField.text = ""
        addField.isHidden = true
        subjectCV.reloadData()
    }
    

    
}
extension SubjectVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        subject.selectedItem(row: indexPath.row)
        //CV reload??
    }
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return subject.setNumberOfItemsInSection()
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
extension SubjectVC: SubjectDelegate {
    func didDonePressed() {
        donePressed()
    }
    
    func nextDidNotTapped() {
        let alert = UIAlertController(title: "Введіть назву предмета", message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .default, handler: nil)
            
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func didSetLabel(_ string: String) {
        bigLabel.text = string
    }
    
}














