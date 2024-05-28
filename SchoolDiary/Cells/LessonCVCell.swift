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
    var count: Int?

    override func awakeFromNib() {
        super.awakeFromNib()
        if subject != nil {
            count = subject?.count
        }else{
            count = editor?.count
        }
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
        if subject != nil {
            count = subject?.count
        }else{
            count = editor?.count
        }
        switch count {
        case 0:
    //        print("flag\(subject.monday.count)")
            if subject != nil {
                subject?.monday.forEach({ item in
                    print(item.key)
                    print(numberOfItem)
                    if item.key == cellObj?.key {
                        itemToDelete = item
                        btnTapDelete?()
                    }
                    numberOfItem += 1
            })
            }
            if editor != nil {
                btnTapDelete?()
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
                btnTapDelete?()
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
                btnTapDelete?()
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
                btnTapDelete?()
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
                btnTapDelete?()
            }
        default:
            print("default in DeleteBTN")
        }
        btnTapAction?()
        DispatchQueue.main.async {
            Main().syncWithFirebase()
        }
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
