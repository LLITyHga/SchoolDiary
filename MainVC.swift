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
        DispatchQueue.global(qos: .background).async {
            self.syncWithFirebase()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAll), name: .realmDataDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setNotification), name: .timeLocalNotificationDidChange, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(syncFirebase), name: .firebaseDownloaded, object: nil)
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
        mainLabel.text = "\(chooseDayArray[count].day.mont)"
        reloadAll()
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
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        x = date.daysOfWeek(using: .iso8601)
        chooseDate = date
        chooseDayArray = [ChooseDay2]()
        weekHomework = [Homework2]()
        for i in x {
            let dayX = ChooseDay2()
            dayX.day = i
            for y in allHomeworks! {
                if i.ddMMyyyy == y.day.ddMMyyyy{
                    weekHomework.append(y)
                }
            }
            if i.ddMMyyyy == chooseDate.ddMMyyyy{
                dayX.selected = true
            }else{
                dayX.selected = false
            }
            chooseDayArray.append(dayX)
        }
        count = Int(chooseDate.numberDayInWeek) ?? 1
        count -= 1
        calendarView.isHidden = !calendarView.isHidden
        mainLessonsCV.isHidden = !mainLessonsCV.isHidden
        loadLessons()
        dateLessons()
        dateCV.reloadData()
        mainLessonsCV.reloadData()
    }

    func dateLessons() {
        dateLesslons.removeAll()
            for obj1 in templateDay2 { //check templates in a day and create new dateLesson
                var found = false
                for obj2 in editArrayOfLessons {
                    if obj1.title == obj2.title && obj1.timeInMinutes == obj2.timeInMinutes && obj2.date == x[count] && obj1.userUID == obj2.userUID{
                        found = true
                        dateLesslons.append(obj2)
                    }
                }
                if !found {
                    guard let userUID = Auth.auth().currentUser?.uid else {
                        return
                    }
                    let newLesson = Lesson6()
                    newLesson.title = obj1.title
                    newLesson.timeInMinutes = obj1.timeInMinutes
                    newLesson.dayOfWeek = obj1.dayOfWeek
                    newLesson.time = obj1.time
                    newLesson.homework = obj1.homework
                    newLesson.selected = obj1.selected
                    newLesson.date = x[count]
                    newLesson.userUID = userUID
                    newLesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
                    newLesson.primaryKey = "\(obj1.title)-\(x[count])-\(obj1.timeInMinutes)-\(obj1.userUID)"
                        try! realm.write{
                            realm.add(newLesson)
                        }
                    dateLesslons.append(newLesson)
                }
            }
            switch count {
            case 0: monday = dateLesslons
            case 1: tuesday = dateLesslons
            case 2: wednesday = dateLesslons
            case 3: thursday = dateLesslons
            case 4: friday = dateLesslons
            default:
                monday = dateLesslons
            }
        monday.sort { $0.timeInMinutes < $1.timeInMinutes }
        tuesday.sort { $0.timeInMinutes < $1.timeInMinutes }
        wednesday.sort { $0.timeInMinutes < $1.timeInMinutes }
        thursday.sort { $0.timeInMinutes < $1.timeInMinutes }
        friday.sort { $0.timeInMinutes < $1.timeInMinutes }
        mainLessonsCV.reloadData()
    }
    
    func loadLessons() {
        monday.removeAll()
        tuesday.removeAll()
        wednesday.removeAll()
        thursday.removeAll()
        friday.removeAll()
        templateDay2.removeAll()
        editArrayOfLessons.removeAll()
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
     //   templateLessons = realm.objects(Lesson3.self).filter("userUID == %@", userUID)
        allLessons = realm.objects(Lesson6.self).filter("userUID == %@", userUID)
        allHomeworks = realm.objects(Homework2.self).filter("userUID == %@", userUID)
        switch count{
        case 0: templateDay = realm.objects(Lesson3.self).filter("dayOfWeek == %@ AND userUID == %@", "monday", userUID)
        case 1: templateDay = realm.objects(Lesson3.self).filter("dayOfWeek == %@ AND userUID == %@", "tuesday", userUID)
        case 2: templateDay = realm.objects(Lesson3.self).filter("dayOfWeek == %@ AND userUID == %@", "wednesday", userUID)
        case 3: templateDay = realm.objects(Lesson3.self).filter("dayOfWeek == %@ AND userUID == %@", "thursday", userUID)
        case 4: templateDay = realm.objects(Lesson3.self).filter("dayOfWeek == %@ AND userUID == %@", "friday", userUID)
        default:
            return
        }
        if templateDay != nil{ for day in templateDay!{templateDay2.append(day)}}
        if allLessons != nil {for day in allLessons!{editArrayOfLessons.append(day)}}
        if allLessons != nil {for day in allLessons!{allLessons2.append(day)}}
        if allHomeworks != nil {for i in allHomeworks!{allHomeworks2.append(i)}}
    }
}

// MARK: - Calendar

extension Calendar {
    static let iso8601 = Calendar(identifier: .iso8601)
   // static let gregorian = Calendar(identifier: .gregorian)
}
extension Date {
    func byAdding(component: Calendar.Component, value: Int, wrappingComponents: Bool = false, using calendar: Calendar = .current) -> Date? {
        calendar.date(byAdding: component, value: value, to: self, wrappingComponents: wrappingComponents)
    }
    func dateComponents(_ components: Set<Calendar.Component>, using calendar: Calendar = .current) -> DateComponents {
        calendar.dateComponents(components, from: self)
    }
    func startOfWeek(using calendar: Calendar = .current) -> Date {
        calendar.date(from: dateComponents([.yearForWeekOfYear, .weekOfYear], using: calendar))!
    }
    var noon: Date {
        Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    func daysOfWeek(using calendar: Calendar = .current) -> [Date] {
        let startOfWeek = self.startOfWeek(using: calendar).noon
        return (0...6).map { startOfWeek.byAdding(component: .day, value: $0, using: calendar)! }
    }
    var ddMMyyyy: String { Formatter.ddMMyyyy.string(from: self) }
    var dd: String { Formatter.dd.string(from: self) }
    var weekDay: String { Formatter.weekDay.string(from: self) }
    var numberDayInWeek: String { Formatter.numberDayInWeek.string(from: self) }
    var mont: String { Formatter.mont.string(from: self) }
}
extension Formatter {
    static let ddMMyyyy: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = .init(identifier: "ua_UA")
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter
    }()
    static let weekDay: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE")
//        dateFormatter.locale = .init(identifier: "ua_UA")
//        dateFormatter.dateFormat = "EEE"
        return dateFormatter
    }()
    static let dd: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = .init(identifier: "ua_UA")
        dateFormatter.dateFormat = "dd"
        return dateFormatter
    }()
    static let numberDayInWeek: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = .init(identifier: "ua_UA")
        dateFormatter.dateFormat = "c"
        return dateFormatter
    }()
    static let mont: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.setLocalizedDateFormatFromTemplate("dd MMMM")
        return dateFormatter
    }()
}
// MARK: - CollectionView

extension MainVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == dateCV{
            print("dateCV clicked")
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
            cell.weekDayLabel.text = chooseDayArray[indexPath.row].day.weekDay
       
            if chooseDayArray[indexPath.row].selected {
                cell.linearView.isHidden = false

                cell.weekDayLabel.textColor = .white
                cell.dayLabel.textColor = .white
                chooseDayArray[indexPath.row].selected = false
            }
            else      if currentDay[0] == cell.dayLabel.text && currentDay[1] == cell.weekDayLabel.text {
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
    func loadUrl() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            urls = fileURLs
            // process files
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
    @objc func reloadAll() {
        loadLessons()
        dateLessons()
        mainLessonsCV.reloadData()
    }
    func writeUniqueLessonsToRealm(_ array1: [Lesson6], _ array2: [FirebaseDateLesson]) {
        var uniqueObj1 = [Lesson6]()
        var uniqueObj2 = [FirebaseDateLesson]()
        for obj1 in array1{
            let existInArr2 = array2.contains(where: { obj2 in
                if obj1.primaryKey == obj2.primaryKey && obj1.dateLastChange > obj2.dateLastChange{
                    uniqueObj1.append(obj1)
                }//check changes in the same objects
                return obj1.primaryKey == obj2.primaryKey && obj1.dateLastChange == obj2.dateLastChange
            })
            if !existInArr2 {
                
                uniqueObj1.append(obj1)
            }
        }
        for obj2 in array2 {
            let existInArr1 = array1.contains(where: { obj1 in
                if obj2.primaryKey == obj1.primaryKey && obj2.dateLastChange > obj1.dateLastChange{
                    uniqueObj2.append(obj2)
                }
                return obj2.primaryKey == obj1.primaryKey
            })
            if !existInArr1 {uniqueObj2.append(obj2)}
        }
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        for thisLesson in uniqueObj2 {
            let edittedLesson = Lesson6()
            edittedLesson.title = thisLesson.title
            edittedLesson.timeInMinutes = thisLesson.timeInMinutes
            edittedLesson.dayOfWeek = thisLesson.dayOfWeek
            edittedLesson.time = thisLesson.time
            edittedLesson.homework = thisLesson.homework
            edittedLesson.date = thisLesson.date
            edittedLesson.selected = thisLesson.selected
            edittedLesson.userUID = userUID
            edittedLesson.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            edittedLesson.primaryKey = thisLesson.primaryKey
            uniqueObj1.append(edittedLesson)
        }
        for i in uniqueObj1 {
            do{
                try realm.write{
                    realm.add(i, update: .modified)
                }
            }catch{
                print("Error saving imageUrl")
            }
        }
    }
    func writeUniqueHomeworksToRealm(_ array1: [Homework], _ array2: [Homework2]) {
        var uniqueObj1 = [Homework]()
        var uniqueObj2 = [Homework2]()
        for obj1 in array1{
            let existInArr2 = array2.contains(where: { obj2 in
                if obj1.key == obj2.key && obj1.dateLastChange > obj2.dateLastChange{
                    uniqueObj1.append(obj1)
                }//check changes in the same objects
                return obj1.key == obj2.key && obj1.dateLastChange == obj2.dateLastChange
            })
            if !existInArr2 {
                
                uniqueObj1.append(obj1)
            }
        }
        for obj2 in array2 {
            let existInArr1 = array1.contains(where: { obj1 in
                if obj2.key == obj1.key && obj2.dateLastChange > obj1.dateLastChange{
                    uniqueObj2.append(obj2)
                }
                return obj2.key == obj1.key
            })
            if !existInArr1 {uniqueObj2.append(obj2)}
        }
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        for thisHomework in uniqueObj1 {
            let editHomework = Homework2()
            editHomework.text = thisHomework.text
            editHomework.lesson = thisHomework.lesson
            editHomework.day = thisHomework.day
            editHomework.selected = thisHomework.selected
            editHomework.userUID = userUID
            editHomework.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
            editHomework.key = thisHomework.key

            uniqueObj2.append(editHomework)
        }
        for i in uniqueObj2 {
            do{
                try realm.write{
                    realm.add(i, update: .modified)
                }
            }catch{
                print("Error saving imageUrl")
            }
        }
    }
    func uploadToFirebase() {
        reloadAll()
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
            let base = realm.objects(Lesson6.self).filter("userUID == %@", userUID)
        let homeworksBase = realm.objects(Homework2.self).filter("userUID == %@", userUID)
        var homeworksBase2 = [Homework2]()
            var base2 = [Lesson6]()
            for i in base {base2.append(i)}
        for i in homeworksBase {homeworksBase2.append(i)}
            var lessonsDictionaryFB = [String:Bool]()
        var toUpload = [Lesson6]()
        for i in GlobalVarData.shared.lessons {
            lessonsDictionaryFB[i.primaryKey] = true
        }
        for i in base2 {
            if lessonsDictionaryFB[i.primaryKey] == nil {
                toUpload.append(i)
            }
        }
            for i in toUpload {
            self.db.collection("lessons"+userUID).addDocument(data: [
                "title" : i.title,
                "selected" : i.selected,
                "dayOfWeek" : i.dayOfWeek,
                "time" : i.time,
                "homework" : i.homework,
                "timeInMinutes" : i.timeInMinutes,
                "date" : i.date,
                "primaryKey" : i.primaryKey,
                "userUID" : i.userUID,
                "dateLastChange" : i.dateLastChange
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Lesson added to Firebase")
                }
            }
            }
        
        var homeworkToUpload = [Homework2]()
        var homeworkDictionary = [String:Bool]()
            for i in GlobalVarData.shared.homeworkFirebase {
                homeworkDictionary[i.key] = true
            }
        for i in homeworksBase2 {
            if homeworkDictionary[i.key] == nil {
                homeworkToUpload.append(i)
            }
        }
            for i in homeworkToUpload {
                db.collection("homeworks"+userUID).whereField("key", isEqualTo: i.key).getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("помилка при завантаженні документів \(error)")
                    }else{
                            self.db.collection("homeworks"+userUID).addDocument(data: [
                                "text" : i.text,
                                                    "selected" : i.selected,
                                                    "lesson" : i.lesson,
                                                    "day" : i.day,
                                                    "key" : i.key,
                                                    "userUID" : i.userUID,
                                                    "dateLastChange" : i.dateLastChange
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    print("Document added")
                                }
                            }
            }
        }
            }
        
        
    }


    func checkForPermission() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { [self] settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.dispatchNotification()
            case .denied:
                return
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in
                    if didAllow {
                        self.dispatchNotification()
                    }
                }
            default:
                return
            }
        
        }
    }
    func dispatchNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        let identifier = "notification"
        let title = "Не завершене домашнє завдання"
        let body = "Тут вказуємо невиконані уроки"
        let isDaily = false
        let notificationCenter = UNUserNotificationCenter.current()
        let days = GlobalVarData.shared.notificationDays
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let calendar = Calendar.current
        var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
        dateComponents.hour = GlobalVarData.shared.notificationHour
        dateComponents.minute = GlobalVarData.shared.notificationMinutes
        
        for i in days {
            if i == 0{
                dateComponents.weekday = 2 // monday
                let mondayTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
                let mondayRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: mondayTrigger)
                notificationCenter.add(mondayRequest)
            }
            if i == 1{
                dateComponents.weekday = 3
                let tuesdayTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
                let tuesdayRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: tuesdayTrigger)
                notificationCenter.add(tuesdayRequest)
            }
            if i == 2{dateComponents.weekday = 4
                let wednesdayTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
                let wednesdayRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: wednesdayTrigger)
                notificationCenter.add(wednesdayRequest)
            }
            if i == 3{dateComponents.weekday = 5
                let thursdayTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
                let thursdayRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: thursdayTrigger)
                notificationCenter.add(thursdayRequest)
            }
            if i == 4{dateComponents.weekday = 6
                let fridayTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
                let fridayRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: fridayTrigger)
                notificationCenter.add(fridayRequest)
            }
        }
       // notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
     func checkDoneHomework() {
         GlobalVarData.shared.notificationDays = []
        if let userUID = Auth.auth().currentUser?.uid {
            let monLessons = realm.objects(Lesson6.self).filter("date == %@ AND userUID == %@", x[0], userUID)
            let tueLessons = realm.objects(Lesson6.self).filter("date == %@ AND userUID == %@", x[1], userUID)
            let wedLessons = realm.objects(Lesson6.self).filter("date == %@ AND userUID == %@", x[2], userUID)
            let thuLessons = realm.objects(Lesson6.self).filter("date == %@ AND userUID == %@", x[3], userUID)
            let friLessons = realm.objects(Lesson6.self).filter("date == %@ AND userUID == %@", x[4], userUID)
            let weekLessons = [monLessons, tueLessons, wedLessons, thuLessons, friLessons].self

            var dayCount = 0
            for i in weekLessons {
                let addNF = i.contains { lesson in
                    !lesson.selected
                }
                if addNF {GlobalVarData.shared.notificationDays.append(dayCount)}
                dayCount = dayCount + 1
            }
        }
    }
    func deleteCollection(collectionPath: String, completion: @escaping (Error?) -> Void) {
        let collRef = db.collection(collectionPath)
        collRef.getDocuments { [self] (querySnapshot, error) in
            if let error = error {
                completion(error)
                return
            }
           
            guard let documents = querySnapshot?.documents else {
                completion(nil)
                return
            }
            
            let batch = self.db.batch()
            
            for document in documents {
                batch.deleteDocument(document.reference)
            }
            
            batch.commit { (batchError) in
                completion(batchError)
            }
        }
    }
    func syncWithFirebase() {
        let db = Firestore.firestore()
        if let userUID = Auth.auth().currentUser?.uid{
            db.collection("lessons"+userUID).getDocuments { [self] querySnapshot, error in
          
            
                            if let e = error {
                                print("Помилка при отриманні з фаєрбази \(e)")
                            }else {
        if let snapshotDocumet = querySnapshot?.documents {
            if snapshotDocumet.isEmpty {
                uploadToFirebase()
            }
            for doc in snapshotDocumet {
                let lesson = FirebaseDateLesson(title: doc["title"] as? String ?? "",
                                     selected: doc["selected"] as? Bool ?? false,
                                     dayOfWeek: doc["dayOfWeek"] as? String ?? "",
                                     time: doc["time"] as? String ?? "",
                                     homework: doc["homework"] as? String ?? "",
                                     timeInMinutes: doc["timeInMinutes"] as? Int ?? 0,
                                     date: doc["date"] as? Date ?? Date(),
                                     primaryKey: doc["primaryKey"] as? String ?? "",
                                     userUID: doc["userUID"] as? String ?? "",
                                     dateLastChange: doc["dateLastChange"] as? Int ?? 0)
                print("download", lesson.primaryKey)
                GlobalVarData.shared.lessons.append(lesson)
                if GlobalVarData.shared.lessons.count == snapshotDocumet.count {
                    print("LES DOWNLOADED")
                    writeUniqueLessonsToRealm(allLessons2, GlobalVarData.shared.lessons)
                    GlobalVarData.shared.checkLessonDownload = true
                    if GlobalVarData.shared.checkHomeworkDownload == true && GlobalVarData.shared.checkLessonDownload == true {uploadToFirebase()}
                }
             //   NotificationCenter.default.post(name: Notification.Name.firebaseDownloaded, object: nil)
            }
        }
                }
        }}
        if let userUID = Auth.auth().currentUser?.uid {
            db.collection("homeworks"+userUID).getDocuments { [self] querySnapshot, error in
                            if let e = error {
                                print("Помилка при отриманні з фаєрбази \(e)")
                            }else {
        if let snapshotDocumet = querySnapshot?.documents {
            for doc in snapshotDocumet {
                let homework = Homework(
                    day: doc["day"] as? Date ?? Date(),
                    selected: doc["selected"] as? Bool ?? false,
                    text: doc["text"] as? String ?? "",
                    lesson: doc["lesson"] as? String ?? "",
                    key: doc["key"] as? String ?? "",
                    userUID: doc["userUID"] as? String ?? "",
                    dateLastChange: doc["dateLastChange"] as? Int ?? 0)

                GlobalVarData.shared.homeworkFirebase.append(homework)
            }
            if GlobalVarData.shared.homeworkFirebase.count == snapshotDocumet.count {
                print("HW DOWNLOADED")
                writeUniqueHomeworksToRealm(GlobalVarData.shared.homeworkFirebase, allHomeworks2)
                GlobalVarData.shared.checkHomeworkDownload = true
                if GlobalVarData.shared.checkHomeworkDownload == true && GlobalVarData.shared.checkLessonDownload == true {uploadToFirebase()}
            }
        }
                }
        }
        }
    }
    @objc func setNotification() {
        checkDoneHomework()
        dispatchNotification()
    }
//    @objc func syncFirebase() {
//        writeUniqueLessonsToRealm(allLessons2, GlobalVarData.shared.lessons)
//        writeUniqueHomeworksToRealm(GlobalVarData.shared.homeworkFirebase, allHomeworks2)
//        uploadToFirebase()
//    }
}
