//
//  LessonCVCell.swift
//  SchoolDiary
//
//  Created by Wolf on 12.06.2023.
//

import UIKit
import RealmSwift

class LessonCVCell: UICollectionViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteBTNOutlet: UIButton!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var nameOfSubject: UILabel!
    @IBOutlet weak var linearView: UIView!
    @IBOutlet weak var linearView2: UIView!
    var btnTapAction : (()->())?
    var btnTapEdit : (()->())?
    var btnTapDelete : (()->())?
    var cellObj: Lesson3?
    var subject: Subject?
    var itemToDelete = Lesson3()
    var numberOfItem = 0
    var editor: EditorLessons?
    var index: Int?

    override func awakeFromNib() {
        super.awakeFromNib()
        linearView.backgroundColor = .white
        linearView.layer.cornerRadius = 15
        linearView2.layer.cornerRadius = 15
        let gradientView = UIView(frame: CGRect(x: 0, y: 0, width: 258, height: 58))
                         let gradientLayer:CAGradientLayer = CAGradientLayer()
                        gradientView.layer.cornerRadius = 15
        
                         gradientLayer.frame.size = gradientView.frame.size
                        gradientLayer.cornerRadius = 15
                         gradientLayer.colors =
                         [UIColor(red: 0, green: 0.94, blue: 1, alpha: 1).cgColor,UIColor(red: 0.012, green: 0.69, blue: 0.738, alpha: 1).cgColor]
                        //Use diffrent colors
                         gradientView.layer.addSublayer(gradientLayer)
        
                        linearView2.addSubview(gradientView)
                        linearView2.layer.cornerRadius = 15
        linearView2.isHidden = true
    }
    static func nib() -> UINib {
        return UINib(nibName: "LessonCVCell", bundle: nil)
    }
    @IBAction func deleteBTN(_ sender: UIButton) {
        print(cellObj?.key ?? "")
        
        switch subject?.count {
        case 0:
    //        print("flag\(subject.monday.count)")
            subject?.monday.forEach({ item in
                print(item.key)
                print(numberOfItem)
                if item.key == cellObj?.key {
                    itemToDelete = item
                    btnTapDelete?()
                }
                numberOfItem += 1
        })
            if editor != nil {
                do{
                    let realm = try! Realm()
                    try realm.write {
                        if let lessonToDelete = realm.objects(Lesson3.self).filter("title == %@ AND timeInMinutes == %@", nameOfSubject.text!, subject?.monday[index ?? 0].timeInMinutes).first {
                            realm.delete(lessonToDelete)
                        }
                        subject?.monday.remove(at: index ?? 0)
                        // send information to mainVC about changes in database
                        NotificationCenter.default.post(name: Notification.Name.realmDataDidChange, object: nil)
                        btnTapAction?()
                    }
                }catch{
                    print("can`t deleete from realm")
                }
            }
        case 1:
            subject?.tuesday.forEach({ item in
                print(item.key)
                print(numberOfItem)
                if item.key == cellObj?.key {
                    itemToDelete = item
                    btnTapDelete?()
                }
                numberOfItem += 1
        })
            if editor != nil {
                do{
                    let realm = try! Realm()
                    try realm.write {
                        if let lessonToDelete = realm.objects(Lesson3.self).filter("title == %@ AND timeInMinutes == %@", nameOfSubject.text!, subject?.tuesday[index ?? 0].timeInMinutes).first {
                            realm.delete(lessonToDelete)
                        }
                        subject?.tuesday.remove(at: index ?? 0)
                        // send information to mainVC about changes in database
                        NotificationCenter.default.post(name: Notification.Name.realmDataDidChange, object: nil)
                        btnTapAction?()
                    }
                }catch{
                    print("can`t deleete from realm")
                }
            }
        case 2:
            subject?.wednesday.forEach({ item in
                if item.key == cellObj?.key {
                    itemToDelete = item
                    btnTapDelete?()
                }
                numberOfItem += 1
        })
            if editor != nil {
                do{
                    let realm = try! Realm()
                    try realm.write {
                        if let lessonToDelete = realm.objects(Lesson3.self).filter("title == %@ AND timeInMinutes == %@", nameOfSubject.text!, subject?.wednesday[index ?? 0].timeInMinutes).first {
                            realm.delete(lessonToDelete)
                        }
                        subject?.wednesday.remove(at: index ?? 0)
                        // send information to mainVC about changes in database
                        NotificationCenter.default.post(name: Notification.Name.realmDataDidChange, object: nil)
                        btnTapAction?()
                    }
                }catch{
                    print("can`t deleete from realm")
                }
            }
        case 3:
            subject?.thursday.forEach({ item in
                print(item.key)
                print(numberOfItem)
                if item.key == cellObj?.key {
                    itemToDelete = item
                    btnTapDelete?()
                }
                numberOfItem += 1
        })
            if editor != nil {
                do{
                    let realm = try! Realm()
                    try realm.write {
                        if let lessonToDelete = realm.objects(Lesson3.self).filter("title == %@ AND timeInMinutes == %@", nameOfSubject.text!, subject?.thursday[index ?? 0].timeInMinutes).first {
                            realm.delete(lessonToDelete)
                        }
                        subject?.thursday.remove(at: index ?? 0)
                        // send information to mainVC about changes in database
                        NotificationCenter.default.post(name: Notification.Name.realmDataDidChange, object: nil)
                        btnTapAction?()
                    }
                }catch{
                    print("can`t deleete from realm")
                }
            }
        case 4:
            subject?.friday.forEach({ item in
                print(item.key)
                print(numberOfItem)
                if item.key == cellObj?.key {
                    itemToDelete = item
                    btnTapDelete?()
                }
                numberOfItem += 1
        })
            if editor != nil {
                do{
                    let realm = try! Realm()
                    try realm.write {
                        if let lessonToDelete = realm.objects(Lesson3.self).filter("title == %@ AND timeInMinutes == %@", nameOfSubject.text!, subject?.friday[index ?? 0].timeInMinutes).first {
                            realm.delete(lessonToDelete)
                        }
                        subject?.friday.remove(at: index ?? 0)
                        // send information to mainVC about changes in database
                        NotificationCenter.default.post(name: Notification.Name.realmDataDidChange, object: nil)
                        btnTapAction?()
                    }
                }catch{
                    print("can`t deleete from realm")
                }
            }
        default:
            print("default in DeleteBTN")
        }
        btnTapAction?()
    }
    
    @IBAction func editBTN(_ sender: UIButton) {
        btnTapEdit?()
    }
    
    func setupCell(lesson: Lesson3, subj: AnyObject, index: Int) {
        cellObj = lesson
        self.index = index
        if subj is Subject {
            subject = subj as? Subject
        }
        if subj is EditorLessons {
            editor = subj as? EditorLessons
        }
        timeLabel.text = lesson.time
        nameOfSubject.text = lesson.title
        if lesson.selected {
            linearView2.isHidden = false
            deleteBTNOutlet.isHidden = false
            timeLabel.isHidden = true
            if editor != nil {editButton.isHidden = false}
        } else {
            linearView2.isHidden = true
            deleteBTNOutlet.isHidden = true
            timeLabel.isHidden = false
            if editor != nil {editButton.isHidden = true}
        }
    }

}
