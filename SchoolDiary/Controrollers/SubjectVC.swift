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
import GoogleSignIn
import GoogleSignInSwift
import SafariServices


class SubjectVC: UIViewController, UICollectionViewDelegate {
 
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var bigLabel: UILabel!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var addField: UIVisualEffectView!
    let datePicker = UIDatePicker()
    @IBOutlet weak var subjectCV: UICollectionView!
    let subject = Subject()
    var cellData = Lesson3()
    
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
        subjectCV.reloadData() //тут може бути краш
    }
    @IBAction func forwardBTN(_ sender: UIButton) {
        subject.forwardTap()
        addField.isHidden = true
        subjectCV.reloadData()
            }
    @IBAction func plusBTN(_ sender: UIButton) {
        addField.isHidden = false
    }
    @IBAction func nextBTN(_ sender: UIButton) {
        donePressed()
        subject.timeForLesson = timeTextField.text ?? ""
        subject.nextTapped(subjectTextField: subjectTextField.text ?? "")
        subjectTextField.text = ""
        timeTextField.text = ""
        addField.isHidden = true
        subjectCV.reloadData()
    }
    

    
}
extension SubjectVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      //  print("row = \(indexPath.row)")
        subject.selectedItem(row: indexPath.row)
        collectionView.reloadData()
    }
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return subject.setNumberOfItemsInSection()
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LessonCVCell", for: indexPath) as! LessonCVCell
    subject.sendCellSettings(cellNumber: indexPath.row)
    cell.setupCell(lesson: cellData, subj: subject, index: indexPath.row)
    cell.btnTapAction = {
        () in
        collectionView.reloadData()
    }
    cell.btnTapDelete = { [self]
        () in
        subject.deleteLesson(lesson: cell.itemToDelete)
        collectionView.reloadData()
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
        subject.timeInMinutes = hours! * 60 + minutes!
        }
        self.view.endEditing(true)
    }
}
extension SubjectVC: SubjectDelegate {
    func lessonCellData(cellData: Lesson3) {
        self.cellData = cellData
    }
    
    
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














