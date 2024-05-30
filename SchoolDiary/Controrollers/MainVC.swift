//
//  MainVC.swift
//  SchoolDiary
//
//  Created by Wolf on 15.06.2023.
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


class MainVC: UIViewController, FSCalendarDelegate, UITextFieldDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    @IBOutlet weak var fullHomeworkLabel: UILabel!
    @IBOutlet weak var fullHomework: UIVisualEffectView!
    @IBOutlet weak var calendarOutlet: UIButton!
    @IBOutlet weak var menuOutlet: UIButton!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var mainLessonsCV: UICollectionView!
    @IBOutlet weak var dateCV: UICollectionView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var main = Main()
    
    var cellLesson = Lesson6()
    var dayHomework = [Homework2]()
    
//    var audioRecorder: AVAudioRecorder!
//    var audioPlayer: AVAudioPlayer!
//    var chooseDayArray = [ChooseDay2]() /*use for pick cells in dateCV*/
//    var weekHomework = [Homework2]() // there I download from database homeworks of current week
//    var chooseDate = Date()
//    var x = Date().daysOfWeek(using: .iso8601) //array week Date`s for objects in chooseDayArray
//    let currentDay = ["\(Date().dd)", "\(Date().weekDay)"] //make current day in dateCV orange color
//    var count = 0  //take knowlage what day of week show to user
//    var db = Firestore.firestore()
//    
//    let realm = try! Realm()
//    var allLessons: Results<Lesson6>?
//    var allLessons2 = [Lesson6]()
//    var templateLessons: Results<Lesson3>?
//    var allHomeworks: Results<Homework2>?
//    var allHomeworks2 = [Homework2]()
//    var dateLesslons = [Lesson6]()
//    var templateDay: Results<Lesson3>?
//    var templateDay2 = [Lesson3]()
//    var monday = [Lesson6]()
//    var tuesday = [Lesson6]()
//    var wednesday = [Lesson6]()
//    var thursday = [Lesson6]()
//    var friday = [Lesson6]()
//    var editArrayOfLessons = [Lesson6]()
//    var urls = [URL]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        main.delegate = self
        NotificationCenter.default.addObserver(main, selector: #selector(main.reloadAll), name: .realmDataDidChange, object: nil)
        NotificationCenter.default.addObserver(main, selector: #selector(main.setNotification), name: .timeLocalNotificationDidChange, object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(syncFirebase), name: .firebaseDownloaded, object: nil)
        main.loadUrl()
        main.count = Int(main.chooseDate.numberDayInWeek) ?? 1
        main.count -= 1
        mainLessonsCV.register(MainLessonCVCell.nib(), forCellWithReuseIdentifier: "MainLessonCVCell")
        mainLessonsCV.delegate = self
        mainLessonsCV.dataSource = self
        dateCV.register(DateVCCell.nib(), forCellWithReuseIdentifier: "DateVCCell")
        dateCV.delegate = self
        dateCV.dataSource = self
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        calendar.delegate = self
        main.loadLessons()
        main.dateLessons()
        main.checkDoneHomework()
        main.dispatchNotification()
        if GlobalVarData.shared.notificationIsAccepted {
            print("Notification in \(GlobalVarData.shared.notificationDays)")
        }
        main.setWeekHomeworks()
        mainLabel.text = "\(main.chooseDayArray[main.count].day.mont)".capitalized
        //        reloadAll()
        DispatchQueue.global(qos: .background).async { [self] in
            main.syncWithFirebase()
            DispatchQueue.main.async { [self] in
                main.reloadAll()
            }
        }
    }
    
    @IBAction func calendarBTN(_ sender: UIButton) {
        calendarView.isHidden = !calendarView.isHidden
        mainLessonsCV.isHidden = !mainLessonsCV.isHidden
    }
    @IBAction func closeFullHomework(_ sender: UIButton) {
        fullHomework.isHidden = true
    }
    @IBAction func menuBTN(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
    
    // MARK: - CollectionView
    
    extension MainVC: UICollectionViewDataSource, UICollectionViewDelegate {
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if collectionView == dateCV{
                //  print("dateCV clicked")
                main.chooseDayArray[indexPath.row].selected = !main.chooseDayArray[indexPath.row].selected
                main.count = indexPath.row
                main.loadLessons()
                main.dateLessons()
                dateCV.reloadData()
                mainLessonsCV.reloadData()
            }else{
                main.selectedLesson(row: indexPath.row)
                main.loadLessons()
                main.dateLessons()
                collectionView.reloadData()
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if collectionView == dateCV {
                return main.chooseDayArray.count
            }else{
                switch main.count {
                case 0:return main.monday.count
                case 1:return main.tuesday.count
                case 2:return main.wednesday.count
                case 3:return main.thursday.count
                case 4:return main.friday.count
                default:
                    return 0
                }
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            if collectionView == dateCV {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateVCCell", for: indexPath) as! DateVCCell
                cell.dayLabel.text = main.chooseDayArray[indexPath.row].day.dd
                cell.weekDayLabel.text = main.chooseDayArray[indexPath.row].day.weekDay.capitalized
                
                if main.chooseDayArray[indexPath.row].selected {
                    cell.linearView.isHidden = false
                    
                    cell.weekDayLabel.textColor = .white
                    cell.dayLabel.textColor = .white
                    main.chooseDayArray[indexPath.row].selected = false
                }
                else      if main.currentDay[0].capitalized == cell.dayLabel.text && main.currentDay[1].capitalized == cell.weekDayLabel.text {
                    cell.linearView.isHidden = true
                    cell.backgroundColor = .orange
                    cell.weekDayLabel.textColor = .white
                    cell.dayLabel.textColor = .white
                }
                
                else{
                    cell.backgroundColor = .white
                    cell.linearView.isHidden = true
                    cell.weekDayLabel.textColor = .black
                    cell.dayLabel.textColor = .black
                }
                return cell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainLessonCVCell", for: indexPath) as! MainLessonCVCell
                main.sendCellSettings(cellNumber: indexPath.row)
                cell.setupCell(lesson: cellLesson, homework: dayHomework, main: main, index: indexPath.row)
                cell.reloadData = { [self]
                    () in
                    main.reloadData()
                    mainLessonsCV.reloadData()
                }
                cell.btnTapShow = { [self]
                    () in
                    if !cell.homeworkLabel.text!.isEmpty {
                        fullHomework.isHidden = false
                        fullHomeworkLabel.text = cell.homeworkLabel.text
                    }
                }
                cell.btnTapRecord = { [self]
                    () in
                    main.loadUrl()
                    collectionView.reloadData()
                }
                return cell
            }
        }
    }
        //    @objc func syncFirebase() {
        //        writeUniqueLessonsToRealm(allLessons2, GlobalVarData.shared.lessons)
        //        writeUniqueHomeworksToRealm(GlobalVarData.shared.homeworkFirebase, allHomeworks2)
        //        uploadToFirebase()
        //    }

extension MainVC: MainDelegate {
    func lessonCellData(cellLesson: Lesson6, dayHomework: [Homework2]) {
        self.cellLesson = cellLesson
        self.dayHomework = dayHomework
    }
    
    func reloadDateCV() {
        dateCV.reloadData()
    }
    func reloadMainCV() {
        mainLessonsCV.reloadData()
    }
}
