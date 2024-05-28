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
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var chooseDayArray = [ChooseDay2]() /*use for pick cells in dateCV*/
    var weekHomework = [Homework2]() // there I download from database homeworks of current week
    var chooseDate = Date()
    var x = Date().daysOfWeek(using: .iso8601) //array week Date`s for objects in chooseDayArray
    let currentDay = ["\(Date().dd)", "\(Date().weekDay)"] //make current day in dateCV orange color
    var count = 0  //take knowlage what day of week show to user
    var db = Firestore.firestore()
    
    let realm = try! Realm()
    var allLessons: Results<Lesson6>?
    var allLessons2 = [Lesson6]()
    var templateLessons: Results<Lesson3>?
    var allHomeworks: Results<Homework2>?
    var allHomeworks2 = [Homework2]()
    var dateLesslons = [Lesson6]()
    var templateDay: Results<Lesson3>?
    var templateDay2 = [Lesson3]()
    var monday = [Lesson6]()
    var tuesday = [Lesson6]()
    var wednesday = [Lesson6]()
    var thursday = [Lesson6]()
    var friday = [Lesson6]()
    var editArrayOfLessons = [Lesson6]()
    var urls = [URL]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAll), name: .realmDataDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setNotification), name: .timeLocalNotificationDidChange, object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(syncFirebase), name: .firebaseDownloaded, object: nil)
        let currentUser = realm.objects(User2.self).first
        GlobalVarData.shared.notificationHour = currentUser?.notificationHour ?? 20
        GlobalVarData.shared.notificationMinutes = currentUser?.notificationMinutes ?? 0
        loadUrl()
        count = Int(chooseDate.numberDayInWeek) ?? 1
        count -= 1
        mainLessonsCV.register(MainLessonCVCell.nib(), forCellWithReuseIdentifier: "MainLessonCVCell")
        mainLessonsCV.delegate = self
        mainLessonsCV.dataSource = self
        dateCV.register(DateVCCell.nib(), forCellWithReuseIdentifier: "DateVCCell")
        dateCV.delegate = self
        dateCV.dataSource = self
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        calendar.delegate = self
        loadLessons()
        dateLessons()
        checkDoneHomework()
        dispatchNotification()
        if GlobalVarData.shared.notificationIsAccepted {
            print("Notification in \(GlobalVarData.shared.notificationDays)")
        }
        for i in x {
            let dayX = ChooseDay2()
            dayX.day = i
            if allHomeworks != nil{
                for y in allHomeworks! {
                    if y.day.ddMMyyyy == i.ddMMyyyy {
                        weekHomework.append(y)
                    }
                }
            }
            chooseDayArray.append(dayX)
        }
        mainLabel.text = "\(chooseDayArray[count].day.mont)".capitalized
        reloadAll()
        DispatchQueue.global(qos: .background).async {
            self.syncWithFirebase()
            DispatchQueue.main.async { [self] in
                reloadAll()
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
    
    
    // MARK: - CollectionView
    
    extension MainVC: UICollectionViewDataSource, UICollectionViewDelegate {
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if collectionView == dateCV{
                //  print("dateCV clicked")
                chooseDayArray[indexPath.row].selected = !chooseDayArray[indexPath.row].selected
                count = indexPath.row
                loadLessons()
                dateLessons()
                dateCV.reloadData()
                mainLessonsCV.reloadData()
            }else{
                switch count {
                case 0: guard let thisLesson = realm.objects(Lesson6.self).filter("title == %@ AND date == %@ AND timeInMinutes == %@ AND userUID == %@", monday[indexPath.row].title, monday[indexPath.row].date, monday[indexPath.row].timeInMinutes, monday[indexPath.row].userUID).first else{return}//correct filter for all
                    try? realm.write {
                        let edittedLesson = Lesson6()
                        edittedLesson.title = thisLesson.title
                        edittedLesson.timeInMinutes = thisLesson.timeInMinutes
                        edittedLesson.dayOfWeek = thisLesson.dayOfWeek
                        edittedLesson.time = thisLesson.time
                        edittedLesson.homework = thisLesson.homework
                        edittedLesson.date = thisLesson.date
                        edittedLesson.selected = !thisLesson.selected
                        edittedLesson.userUID = thisLesson.userUID
                        edittedLesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
                        edittedLesson.primaryKey = thisLesson.primaryKey
                        realm.add(edittedLesson, update: .modified)
                    }
                case 1: guard let thisLesson = realm.objects(Lesson6.self).filter("title == %@ AND date == %@ AND timeInMinutes == %@ AND userUID == %@", tuesday[indexPath.row].title, tuesday[indexPath.row].date, tuesday[indexPath.row].timeInMinutes, tuesday[indexPath.row].userUID).first else{return}
                    // print(thisLesson)
                    try? realm.write {
                        
                        let edittedLesson = Lesson6()
                        edittedLesson.title = thisLesson.title
                        edittedLesson.timeInMinutes = thisLesson.timeInMinutes
                        edittedLesson.dayOfWeek = thisLesson.dayOfWeek
                        edittedLesson.time = thisLesson.time
                        edittedLesson.homework = thisLesson.homework
                        edittedLesson.date = thisLesson.date
                        edittedLesson.selected = !thisLesson.selected
                        edittedLesson.userUID = thisLesson.userUID
                        edittedLesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
                        edittedLesson.primaryKey = thisLesson.primaryKey
                        realm.add(edittedLesson, update: .modified)
                    }
                case 2: guard let thisLesson = realm.objects(Lesson6.self).filter("title == %@ AND date == %@ AND timeInMinutes == %@ AND userUID == %@", wednesday[indexPath.row].title, wednesday[indexPath.row].date, wednesday[indexPath.row].timeInMinutes, wednesday[indexPath.row].userUID).first else{return}
                    //     print(thisLesson)
                    try? realm.write {
                        
                        let edittedLesson = Lesson6()
                        edittedLesson.title = thisLesson.title
                        edittedLesson.timeInMinutes = thisLesson.timeInMinutes
                        edittedLesson.dayOfWeek = thisLesson.dayOfWeek
                        edittedLesson.time = thisLesson.time
                        edittedLesson.homework = thisLesson.homework
                        edittedLesson.date = thisLesson.date
                        edittedLesson.selected = !thisLesson.selected
                        edittedLesson.userUID = thisLesson.userUID
                        edittedLesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
                        edittedLesson.primaryKey = thisLesson.primaryKey
                        realm.add(edittedLesson, update: .modified)
                    }
                    
                case 3: guard let thisLesson = realm.objects(Lesson6.self).filter("title == %@ AND date == %@ AND timeInMinutes == %@ AND userUID == %@", thursday[indexPath.row].title, thursday[indexPath.row].date, thursday[indexPath.row].timeInMinutes, thursday[indexPath.row].userUID).first else{return}
                    // print(thisLesson)
                    try? realm.write {
                        
                        let edittedLesson = Lesson6()
                        edittedLesson.title = thisLesson.title
                        edittedLesson.timeInMinutes = thisLesson.timeInMinutes
                        edittedLesson.dayOfWeek = thisLesson.dayOfWeek
                        edittedLesson.time = thisLesson.time
                        edittedLesson.homework = thisLesson.homework
                        edittedLesson.date = thisLesson.date
                        edittedLesson.selected = !thisLesson.selected
                        edittedLesson.userUID = thisLesson.userUID
                        edittedLesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
                        edittedLesson.primaryKey = thisLesson.primaryKey
                        realm.add(edittedLesson, update: .modified)
                    }
                case 4: guard let thisLesson = realm.objects(Lesson6.self).filter("title == %@ AND date == %@ AND timeInMinutes == %@ AND userUID == %@", friday[indexPath.row].title, friday[indexPath.row].date, friday[indexPath.row].timeInMinutes, friday[indexPath.row].userUID).first else{return}
                    // print(thisLesson)
                    try? realm.write {
                        
                        let edittedLesson = Lesson6()
                        edittedLesson.title = thisLesson.title
                        edittedLesson.timeInMinutes = thisLesson.timeInMinutes
                        edittedLesson.dayOfWeek = thisLesson.dayOfWeek
                        edittedLesson.time = thisLesson.time
                        edittedLesson.homework = thisLesson.homework
                        edittedLesson.date = thisLesson.date
                        edittedLesson.selected = !thisLesson.selected
                        edittedLesson.userUID = thisLesson.userUID
                        edittedLesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
                        edittedLesson.primaryKey = thisLesson.primaryKey
                        realm.add(edittedLesson, update: .modified)
                    }
                default:
                    guard let thisLesson = realm.objects(Lesson6.self).filter("title == %@ AND date == %@ AND timeInMinutes == %@ AND userUID == %@", tuesday[indexPath.row].title, tuesday[indexPath.row].date, tuesday[indexPath.row].timeInMinutes, monday[indexPath.row].userUID).first else{return}
                    try? realm.write {
                        
                        let edittedLesson = Lesson6()
                        edittedLesson.title = thisLesson.title
                        edittedLesson.timeInMinutes = thisLesson.timeInMinutes
                        edittedLesson.dayOfWeek = thisLesson.dayOfWeek
                        edittedLesson.time = thisLesson.time
                        edittedLesson.homework = thisLesson.homework
                        edittedLesson.date = thisLesson.date
                        edittedLesson.selected = !thisLesson.selected
                        edittedLesson.primaryKey = thisLesson.primaryKey
                        realm.add(edittedLesson, update: .modified)
                    }
                }
                loadLessons()
                dateLessons()
                collectionView.reloadData()
                
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if collectionView == dateCV {
                return chooseDayArray.count
            }else{
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
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            if collectionView == dateCV {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateVCCell", for: indexPath) as! DateVCCell
                cell.dayLabel.text = chooseDayArray[indexPath.row].day.dd
                cell.weekDayLabel.text = chooseDayArray[indexPath.row].day.weekDay.capitalized
                
                if chooseDayArray[indexPath.row].selected {
                    cell.linearView.isHidden = false
                    
                    cell.weekDayLabel.textColor = .white
                    cell.dayLabel.textColor = .white
                    chooseDayArray[indexPath.row].selected = false
                }
                else      if currentDay[0].capitalized == cell.dayLabel.text && currentDay[1].capitalized == cell.weekDayLabel.text {
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
                switch count {
                case 0:
                    if let userUID = Auth.auth().currentUser?.uid {
                        cell.currentDay.day = chooseDayArray[count].day
                        cell.lessonsName.text = monday[indexPath.row].title
                        cell.timeLabel.text = monday[indexPath.row].time
                        cell.homeworkLabel.text = ""
                        var dayHomework = [Homework2]()
                        for i in weekHomework {
                            if i.day.ddMMyyyy == chooseDayArray[count].day.ddMMyyyy {
                                dayHomework.append(i)
                            }
                        }
                        for i in dayHomework {
                            if i.lesson == monday[indexPath.row].title {
                                cell.homeworkLabel.text = i.text
                                cell.fullHomeworkLabel.text = i.text
                            }
                        }
                        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let audiofileName = path.appendingPathComponent(chooseDayArray[count].day.ddMMyyyy+cell.lessonsName.text!+"\(userUID)"+".m4a")
                        if let audiofilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(chooseDayArray[count].day.ddMMyyyy)\(cell.lessonsName.text!)\(userUID).m4a"){
                            if FileManager.default.fileExists(atPath: audiofilePath.path) {
                                let request = SFSpeechURLRecognitionRequest(url: audiofilePath)
                                
                                let recognizer = SFSpeechRecognizer()
                                
                                recognizer?.recognitionTask(with: request) { [self] result, error in
                                    guard let result = result else {
                                        if let error = error {
                                            print("Помилка під час розпізнавання: \(error)")
                                        }
                                        return
                                    }
                                    
                                    let text = result.bestTranscription.formattedString
                                    print("Розпізнаний текст: \(text)")
                                    let homework = Homework2()
                                    homework.day = cell.currentDay.day
                                    homework.text = text
                                    homework.lesson = cell.lessonsName.text ?? ""
                                    cell.homeworkLabel.text = text
                                    homework.userUID = userUID
                                    homework.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
                                    homework.key = "\(cell.currentDay.day.ddMMyyyy)"+"\(cell.lessonsName.text ?? "")"+"\(userUID)"
                                    do{
                                        try realm.write{
                                            realm.add(homework, update: .modified)
                                        }
                                    }catch{
                                        print("Error saving homework")
                                    }
                                    cell.homeworkLabel.text = text
                                    cell.fullHomeworkLabel.text = text
                                    cell.editHomeworkLabel.text = ""
                                    cell.editHomeworkLabel.isHidden = true
                                    cell.showFullHomeworkButton.isHidden = false
                                }
                            } else {
                                print("Файл не знайдено.")
                            }
                        }else{
                            print("Не вдалося створити шлях до файлу.")
                        }
                        
                        cell.playButton.isHidden = true
                        cell.deleteAudioButton.isHidden = true
                        for ii in urls {
                            if ii == audiofileName {
                                cell.playButton.isHidden = false
                                cell.playButton.isEnabled = true
                                cell.deleteAudioButton.isHidden = false
                            }
                        }
                    }
                    if monday[indexPath.row].selected {
                        cell.fullHomeworkLabel.textColor = .white
                        cell.linearView.isHidden = false
                        cell.doneIcon.isHidden = false
                        cell.timeLabel.isHidden = true
                        cell.lessonsName.textColor = .white
                        cell.homeworkLabel.textColor = .white
                    }else{
                        cell.fullHomeworkLabel.textColor = .black
                        cell.linearView.isHidden = true
                        cell.doneIcon.isHidden = true
                        cell.timeLabel.isHidden = false
                        cell.lessonsName.textColor = .black
                        cell.homeworkLabel.textColor = .black
                    }
                    
                case 1:
                    if let userUID = Auth.auth().currentUser?.uid {
                        cell.currentDay.day = chooseDayArray[count].day
                        cell.lessonsName.text = tuesday[indexPath.row].title
                        cell.timeLabel.text = tuesday[indexPath.row].time
                        cell.homeworkLabel.text = ""
                        var dayHomework = [Homework2]()
                        for i in weekHomework {
                            if i.day.ddMMyyyy == chooseDayArray[count].day.ddMMyyyy {
                                dayHomework.append(i)
                            }
                        }
                        for i in dayHomework {
                            if i.lesson == tuesday[indexPath.row].title {
                                cell.homeworkLabel.text = i.text
                                cell.fullHomeworkLabel.text = i.text
                            }
                        }
                        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let audiofileName = path.appendingPathComponent(chooseDayArray[count].day.ddMMyyyy+cell.lessonsName.text!+"\(userUID)"+".m4a")
                        if let audiofilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(chooseDayArray[count].day.ddMMyyyy)\(cell.lessonsName.text!)\(userUID).m4a"){
                            if FileManager.default.fileExists(atPath: audiofilePath.path) {
                                let request = SFSpeechURLRecognitionRequest(url: audiofilePath)
                                
                                let recognizer = SFSpeechRecognizer()
                                
                                recognizer?.recognitionTask(with: request) { [self] result, error in
                                    guard let result = result else {
                                        if let error = error {
                                            print("Помилка під час розпізнавання: \(error)")
                                        }
                                        return
                                    }
                                    
                                    let text = result.bestTranscription.formattedString
                                    print("Розпізнаний текст: \(text)")
                                    let homework = Homework2()
                                    homework.day = cell.currentDay.day
                                    homework.text = text
                                    homework.lesson = cell.lessonsName.text ?? ""
                                    cell.homeworkLabel.text = text
                                    homework.userUID = userUID
                                    homework.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
                                    homework.key = "\(cell.currentDay.day.ddMMyyyy)"+"\(cell.lessonsName.text ?? "")"+"\(userUID)"
                                    do{
                                        try realm.write{
                                            realm.add(homework, update: .modified)
                                        }
                                    }catch{
                                        print("Error saving homework")
                                    }
                                    cell.homeworkLabel.text = text
                                    cell.fullHomeworkLabel.text = text
                                    cell.editHomeworkLabel.text = ""
                                    cell.editHomeworkLabel.isHidden = true
                                    cell.showFullHomeworkButton.isHidden = false
                                }
                            } else {
                                print("Файл не знайдено.")
                            }
                        }else{
                            print("Не вдалося створити шлях до файлу.")
                        }
                        
                        cell.playButton.isHidden = true
                        cell.deleteAudioButton.isHidden = true
                        for ii in urls {
                            if ii == audiofileName {
                                cell.playButton.isHidden = false
                                cell.playButton.isEnabled = true
                                cell.deleteAudioButton.isHidden = false
                                print("DONE")
                            }
                        }
                    }
                    if tuesday[indexPath.row].selected {
                        cell.fullHomeworkLabel.textColor = .white
                        cell.linearView.isHidden = false
                        cell.doneIcon.isHidden = false
                        cell.timeLabel.isHidden = true
                        cell.lessonsName.textColor = .white
                        cell.homeworkLabel.textColor = .white
                    }else{
                        cell.fullHomeworkLabel.textColor = .black
                        cell.linearView.isHidden = true
                        cell.doneIcon.isHidden = true
                        cell.timeLabel.isHidden = false
                        cell.lessonsName.textColor = .black
                        cell.homeworkLabel.textColor = .black
                    }
                    
                case 2:
                    if let userUID = Auth.auth().currentUser?.uid {
                        cell.currentDay.day = chooseDayArray[count].day
                        cell.homeworkLabel.text = ""
                        cell.lessonsName.text = wednesday[indexPath.row].title
                        cell.timeLabel.text = wednesday[indexPath.row].time
                        var dayHomework = [Homework2]()
                        for i in weekHomework {
                            if i.day.ddMMyyyy == chooseDayArray[count].day.ddMMyyyy {
                                dayHomework.append(i)
                            }
                        }
                        for i in dayHomework {
                            if i.lesson == wednesday[indexPath.row].title {
                                cell.homeworkLabel.text = i.text
                                cell.fullHomeworkLabel.text = i.text
                            }
                        }
                        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let audiofileName = path.appendingPathComponent(chooseDayArray[count].day.ddMMyyyy+cell.lessonsName.text!+"\(userUID)"+".m4a")
                        if let audiofilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(chooseDayArray[count].day.ddMMyyyy)\(cell.lessonsName.text!)\(userUID).m4a"){
                            if FileManager.default.fileExists(atPath: audiofilePath.path) {
                                let request = SFSpeechURLRecognitionRequest(url: audiofilePath)
                                
                                let recognizer = SFSpeechRecognizer()
                                
                                recognizer?.recognitionTask(with: request) { [self] result, error in
                                    guard let result = result else {
                                        if let error = error {
                                            print("Помилка під час розпізнавання: \(error)")
                                        }
                                        return
                                    }
                                    
                                    let text = result.bestTranscription.formattedString
                                    print("Розпізнаний текст: \(text)")
                                    let homework = Homework2()
                                    homework.day = cell.currentDay.day
                                    homework.text = text
                                    homework.lesson = cell.lessonsName.text ?? ""
                                    cell.homeworkLabel.text = text
                                    homework.userUID = userUID
                                    homework.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
                                    homework.key = "\(cell.currentDay.day.ddMMyyyy)"+"\(cell.lessonsName.text ?? "")"+"\(userUID)"
                                    do{
                                        try realm.write{
                                            realm.add(homework, update: .modified)
                                        }
                                    }catch{
                                        print("Error saving homework")
                                    }
                                    cell.homeworkLabel.text = text
                                    cell.fullHomeworkLabel.text = text
                                    cell.editHomeworkLabel.text = ""
                                    cell.editHomeworkLabel.isHidden = true
                                    cell.showFullHomeworkButton.isHidden = false
                                }
                            } else {
                                print("Файл не знайдено.")
                            }
                        }else{
                            print("Не вдалося створити шлях до файлу.")
                        }
                        
                        cell.playButton.isHidden = true
                        cell.deleteAudioButton.isHidden = true
                        for ii in urls {
                            if ii == audiofileName {
                                cell.playButton.isHidden = false
                                cell.playButton.isEnabled = true
                                cell.deleteAudioButton.isHidden = false
                                print("DONE")
                            }
                        }
                    }
                    if wednesday[indexPath.row].selected {
                        cell.fullHomeworkLabel.textColor = .white
                        cell.linearView.isHidden = false
                        cell.doneIcon.isHidden = false
                        cell.timeLabel.isHidden = true
                        cell.lessonsName.textColor = .white
                        cell.homeworkLabel.textColor = .white
                    }else{
                        cell.fullHomeworkLabel.textColor = .black
                        cell.linearView.isHidden = true
                        cell.doneIcon.isHidden = true
                        cell.timeLabel.isHidden = false
                        cell.lessonsName.textColor = .black
                        cell.homeworkLabel.textColor = .black
                    }
                    
                case 3:
                    if let userUID = Auth.auth().currentUser?.uid {
                        cell.currentDay.day = chooseDayArray[count].day
                        cell.lessonsName.text = thursday[indexPath.row].title
                        cell.timeLabel.text = thursday[indexPath.row].time
                        cell.homeworkLabel.text = ""
                        var dayHomework = [Homework2]()
                        for i in weekHomework {
                            if i.day.ddMMyyyy == chooseDayArray[count].day.ddMMyyyy {
                                dayHomework.append(i)
                            }
                        }
                        for i in dayHomework {
                            if i.lesson == thursday[indexPath.row].title {
                                cell.homeworkLabel.text = i.text
                                cell.fullHomeworkLabel.text = i.text
                            }
                        }
                        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let audiofileName = path.appendingPathComponent(chooseDayArray[count].day.ddMMyyyy+cell.lessonsName.text!+"\(userUID)"+".m4a")
                        if let audiofilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(chooseDayArray[count].day.ddMMyyyy)\(cell.lessonsName.text!)\(userUID).m4a"){
                            if FileManager.default.fileExists(atPath: audiofilePath.path) {
                                let request = SFSpeechURLRecognitionRequest(url: audiofilePath)
                                
                                let recognizer = SFSpeechRecognizer()
                                
                                recognizer?.recognitionTask(with: request) { [self] result, error in
                                    guard let result = result else {
                                        if let error = error {
                                            print("Помилка під час розпізнавання: \(error)")
                                        }
                                        return
                                    }
                                    
                                    let text = result.bestTranscription.formattedString
                                    print("Розпізнаний текст: \(text)")
                                    let homework = Homework2()
                                    homework.day = cell.currentDay.day
                                    homework.text = text
                                    homework.lesson = cell.lessonsName.text ?? ""
                                    cell.homeworkLabel.text = text
                                    homework.userUID = userUID
                                    homework.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
                                    homework.key = "\(cell.currentDay.day.ddMMyyyy)"+"\(cell.lessonsName.text ?? "")"+"\(userUID)"
                                    do{
                                        try realm.write{
                                            realm.add(homework, update: .modified)
                                        }
                                    }catch{
                                        print("Error saving homework")
                                    }
                                    cell.homeworkLabel.text = text
                                    cell.fullHomeworkLabel.text = text
                                    cell.editHomeworkLabel.text = ""
                                    cell.editHomeworkLabel.isHidden = true
                                    cell.showFullHomeworkButton.isHidden = false
                                }
                            } else {
                                print("Файл не знайдено.")
                            }
                        }else{
                            print("Не вдалося створити шлях до файлу.")
                        }
                        
                        cell.playButton.isHidden = true
                        cell.deleteAudioButton.isHidden = true
                        for ii in urls {
                            if ii == audiofileName {
                                cell.playButton.isHidden = false
                                cell.playButton.isEnabled = true
                                cell.deleteAudioButton.isHidden = false
                                print("DONE")
                            }
                        }
                    }
                    if thursday[indexPath.row].selected {
                        cell.fullHomeworkLabel.textColor = .white
                        cell.linearView.isHidden = false
                        cell.doneIcon.isHidden = false
                        cell.timeLabel.isHidden = true
                        cell.lessonsName.textColor = .white
                        cell.homeworkLabel.textColor = .white
                    }else{
                        cell.fullHomeworkLabel.textColor = .black
                        cell.linearView.isHidden = true
                        cell.doneIcon.isHidden = true
                        cell.timeLabel.isHidden = false
                        cell.lessonsName.textColor = .black
                        cell.homeworkLabel.textColor = .black
                    }
                    
                case 4:
                    if let userUID = Auth.auth().currentUser?.uid {
                        cell.currentDay.day = chooseDayArray[count].day
                        cell.lessonsName.text = friday[indexPath.row].title
                        cell.timeLabel.text = friday[indexPath.row].time
                        //cell.homeworkLabel.text = ""
                        var dayHomework = [Homework2]()
                        for i in weekHomework {
                            if i.day.ddMMyyyy == chooseDayArray[count].day.ddMMyyyy {
                                dayHomework.append(i)
                                print(i.day.ddMMyyyy)
                                print(i.text)
                            }
                        }
                        for i in dayHomework {
                            if i.lesson == friday[indexPath.row].title {
                                cell.homeworkLabel.text = i.text
                                cell.fullHomeworkLabel.text = i.text
                            }
                        }
                        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let audiofileName = path.appendingPathComponent(chooseDayArray[count].day.ddMMyyyy+cell.lessonsName.text!+"\(userUID)"+".m4a")
                        if let audiofilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(chooseDayArray[count].day.ddMMyyyy)\(cell.lessonsName.text!)\(userUID).m4a"){
                            if FileManager.default.fileExists(atPath: audiofilePath.path) {
                                let request = SFSpeechURLRecognitionRequest(url: audiofilePath)
                                
                                let recognizer = SFSpeechRecognizer()
                                
                                recognizer?.recognitionTask(with: request) { [self] result, error in
                                    guard let result = result else {
                                        if let error = error {
                                            print("Помилка під час розпізнавання: \(error)")
                                        }
                                        return
                                    }
                                    
                                    let text = result.bestTranscription.formattedString
                                    print("Розпізнаний текст: \(text)")
                                    let homework = Homework2()
                                    homework.day = cell.currentDay.day
                                    homework.text = text
                                    homework.lesson = cell.lessonsName.text ?? ""
                                    cell.homeworkLabel.text = text
                                    homework.userUID = userUID
                                    homework.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
                                    homework.key = "\(cell.currentDay.day.ddMMyyyy)"+"\(cell.lessonsName.text ?? "")"+"\(userUID)"
                                    do{
                                        try realm.write{
                                            realm.add(homework, update: .modified)
                                        }
                                    }catch{
                                        print("Error saving homework")
                                    }
                                    cell.homeworkLabel.text = text
                                    cell.fullHomeworkLabel.text = text
                                    cell.editHomeworkLabel.text = ""
                                    cell.editHomeworkLabel.isHidden = true
                                    cell.showFullHomeworkButton.isHidden = false
                                }
                            } else {
                                print("Файл не знайдено.")
                            }
                        }else{
                            print("Не вдалося створити шлях до файлу.")
                        }
                        
                        cell.playButton.isHidden = true
                        cell.deleteAudioButton.isHidden = true
                        for ii in urls {
                            if ii == audiofileName {
                                cell.playButton.isHidden = false
                                cell.playButton.isEnabled = true
                                cell.deleteAudioButton.isHidden = false
                                print("DONE")
                            }
                        }
                    }
                    if friday[indexPath.row].selected {
                        cell.fullHomeworkLabel.textColor = .white
                        cell.linearView.isHidden = false
                        cell.doneIcon.isHidden = false
                        cell.timeLabel.isHidden = true
                        cell.lessonsName.textColor = .white
                        cell.homeworkLabel.textColor = .white
                    }else{
                        cell.fullHomeworkLabel.textColor = .black
                        cell.linearView.isHidden = true
                        cell.doneIcon.isHidden = true
                        cell.timeLabel.isHidden = false
                        cell.lessonsName.textColor = .black
                        cell.homeworkLabel.textColor = .black
                    }
                    
                default:
                    cell.timeLabel.text = "AAA"
                }
                
                
                cell.reloadData = { [self]
                    () in
                    guard let userUID = Auth.auth().currentUser?.uid else {
                        return
                    }
                    allLessons = realm.objects(Lesson6.self).filter("userUID == %@", userUID)
                    allHomeworks = realm.objects(Homework2.self).filter("userUID == %@", userUID)
                    weekHomework = [Homework2]()
                    for i in chooseDayArray {
                        if allHomeworks != nil{
                            for y in allHomeworks! {
                                if y.day.ddMMyyyy == i.day.ddMMyyyy {
                                    weekHomework.append(y)
                                }
                            }
                        }
                    }
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
                    loadUrl()
                    collectionView.reloadData()
                }
                return cell
            }
        }
        
        //    @objc func syncFirebase() {
        //        writeUniqueLessonsToRealm(allLessons2, GlobalVarData.shared.lessons)
        //        writeUniqueHomeworksToRealm(GlobalVarData.shared.homeworkFirebase, allHomeworks2)
        //        uploadToFirebase()
        //    }
    }
}
