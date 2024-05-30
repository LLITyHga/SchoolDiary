//
//  MainLessonCVCell.swift
//  SchoolDiary
//
//  Created by Wolf on 15.06.2023.
//

import UIKit
import RealmSwift
import AVFoundation
import FirebaseAuth
import Speech

class MainLessonCVCell: UICollectionViewCell, UITextFieldDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    @IBOutlet weak var showFullHomeworkButton: UIButton!
    @IBOutlet weak var editHomeworkLabel: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var deleteAudioButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var fullHomeworkLabel: UILabel!
    @IBOutlet weak var doneIcon: UIImageView!
    @IBOutlet weak var lessonsName: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mainLessonView: UIView!
    @IBOutlet weak var homeworkLabel: UILabel!
    @IBOutlet weak var linearView: UIView!
    var audioRecorder = AVAudioRecorder()
    var audioPlayer = AVAudioPlayer()
    let realm = try! Realm()
    var btnTapShow : (()->())?
    var btnTapHide : (()->())?
    var btnTapEdit : (()->())?
    var btnTapRecord : (()->())?
    var btnTapPlay : (()->())?
    var btnTapDelete : (()->())?
    var reloadData : (()->())?
    var currentDay = ChooseDay2()
    var main = Main()

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playButton.isEnabled = false
        recordButton.setImage(UIImage(named: "microphone-2"), for: .normal)
        playButton.setImage(UIImage(named: "play-circle"), for: .normal)
        let gradientView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 88))
                         let gradientLayer:CAGradientLayer = CAGradientLayer()
                        gradientView.layer.cornerRadius = 25
        
                         gradientLayer.frame.size = gradientView.frame.size
                        gradientLayer.cornerRadius = 25
                         gradientLayer.colors =
                         [UIColor(red: 0, green: 0.94, blue: 1, alpha: 1).cgColor,UIColor(red: 0.012, green: 0.69, blue: 0.738, alpha: 1).cgColor]
                        //Use diffrent colors
                         gradientView.layer.addSublayer(gradientLayer)
        
                        linearView.addSubview(gradientView)
                        linearView.layer.cornerRadius = 25
        linearView.isHidden = true
        mainLessonView.layer.cornerRadius = 25
        editHomeworkLabel.delegate = self
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "MainLessonCVCell", bundle: nil)
    }
    @IBAction func editBTN(_ sender: UIButton) {
        editHomeworkLabel.isHidden = false
        editHomeworkLabel.becomeFirstResponder()
    }

    @IBAction func recordBTN(_ sender: UIButton) {
//        SFSpeechRecognizer.requestAuthorization { authorizationStatus in
//            switch authorizationStatus {
//            case .authorized:
//                print("Дозвіл отримано")
//            case .denied:
//                print("Дозвіл відмовлено")
//            case .restricted:
//                print("Обмежений доступ")
//            case .notDetermined:
//                print("Дозвіл не визначений")
//            @unknown default:
//                print("Невідомий статус дозволу")
//            }
//        }
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
//        let hw = realm.objects(Homework2.self).filter("userUID == %@", userUID)
//        for i in hw {
//            if i.key == "\(currentDay.day.ddMMyyyy)"+"\(lessonsName.text ?? "")"+"\(userUID)" {
//                print(i)
//                do {
//                    try realm.write{
//                        realm.delete(i)
//                    }
//                } catch {
//        print("can`t delete homework")
//                }
//            }
//        }
        if recordButton.currentImage == UIImage(named: "microphone-2"){
            setupRecord(filename: "\(currentDay.day.ddMMyyyy)"+"\(lessonsName.text ?? "")"+"\(userUID)"+".m4a")
            recordButton.setImage(UIImage(named: "record-circle"), for: .normal)
            playButton.isEnabled = false
        }else{
            playButton.isHidden = false
            deleteAudioButton.isHidden = false
            audioRecorder.stop()
            btnTapRecord?()
            reloadData?()
            speechToText()
            recordButton.setImage(UIImage(named: "microphone-2"), for: .normal)
            playButton.isEnabled = false
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 , execute: { [self] in
//                let audioURL = Bundle.main.url(forResource: "\(currentDay.day.ddMMyyyy)"+"\(lessonsName.text ?? "")", withExtension: "m4a")!
//
//                let recognizer = SFSpeechRecognizer()
//
//                let request = SFSpeechURLRecognitionRequest(url: audioURL)
//
//                recognizer?.recognitionTask(with: request) { result, error in
//                    guard let result = result else {
//                        if let error = error {
//                            print("Помилка під час розпізнавання: \(error)")
//                        }
//                        return
//                    }
//
//                     let text = result.bestTranscription.formattedString
//                    print("Розпізнаний текст: \(text)")
//                    
//                }
//            })
         
        }
    }
    @IBAction func playBTN(_ sender: UIButton) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        setupPlayer(filename: "\(currentDay.day.ddMMyyyy)"+"\(lessonsName.text ?? "")"+"\(userUID)"+".m4a")
        if playButton.currentImage == UIImage(named: "play-circle"){
            audioPlayer.play()
            playButton.setImage(UIImage(named: "stop-circle"), for: .normal)
            recordButton.isEnabled = false
        }else{
            audioPlayer.stop()
            
            playButton.setImage(UIImage(named: "play-circle"), for: .normal)
            recordButton.isEnabled = false
        }
    }
    @IBAction func deleteAudioBTN(_ sender: UIButton) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        let audiofileName = getDocumentsDirectory().appendingPathComponent("\(currentDay.day.ddMMyyyy)"+"\(lessonsName.text ?? "")"+"\(userUID)"+".m4a")
        do {
            try FileManager.default.removeItem(at: audiofileName)
        } catch {
print("can`t delete audiofile")
        }
        homeworkLabel.text = ""
        fullHomeworkLabel.text = ""
        let hw = realm.objects(Homework2.self).filter("userUID == %@", userUID)
        for i in hw {
            if i.key == "\(currentDay.day.ddMMyyyy)"+"\(lessonsName.text ?? "")"+"\(userUID)" {
                print(i)
                do {
                    try realm.write{
                        realm.delete(i)
                    }       
                } catch {
        print("can`t delete homework")
                }
            }
        }
        playButton.isHidden = true
        deleteAudioButton.isHidden = true
        btnTapRecord?()
    }
    @IBAction func showFullHomeworkBTN(_ sender: UIButton) {
        btnTapShow?()
    }
    @IBAction func editHomeworkAction(_ sender: UITextField) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        //showFullHomeworkButton.isHidden = true
        let homework = Homework2()
        homework.day = currentDay.day
        homework.text = sender.text ?? ""
        homework.lesson = lessonsName.text ?? ""
        homeworkLabel.text = sender.text ?? ""
        homework.userUID = userUID
        homework.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
        homework.key = "\(currentDay.day.ddMMyyyy)"+"\(lessonsName.text ?? "")"+"\(userUID)"
        do{
            try realm.write{
                realm.add(homework, update: .modified)
            }
        }catch{
            print("Error saving homework")
        }
        homeworkLabel.text = editHomeworkLabel.text
        fullHomeworkLabel.text = editHomeworkLabel.text
        editHomeworkLabel.text = ""
        editHomeworkLabel.isHidden = true
        showFullHomeworkButton.isHidden = false
        let audiofileName = getDocumentsDirectory().appendingPathComponent("\(currentDay.day.ddMMyyyy)"+"\(lessonsName.text ?? "")"+"\(userUID)"+".m4a")
        do {
            try FileManager.default.removeItem(at: audiofileName)
        } catch {
print("can`t delete audiofile")
        }
        playButton.isHidden = true
        deleteAudioButton.isHidden = true
        btnTapRecord?()
        reloadData?()
    }
    
    func setupCell(lesson: Lesson6, homework: [Homework2], main: Main, index: Int) {
        self.main = main
        if let userUID = Auth.auth().currentUser?.uid {
            currentDay.day = main.chooseDayArray[main.count].day
            lessonsName.text = lesson.title
            timeLabel.text = lesson.time
            homeworkLabel.text = ""
            var dayHomework = [Homework2]()
            for i in main.weekHomework {
                if i.day.ddMMyyyy == main.chooseDayArray[main.count].day.ddMMyyyy {
                    dayHomework.append(i)
                }
            }
            for i in dayHomework {
                if i.lesson == lesson.title {
                    homeworkLabel.text = i.text
                    fullHomeworkLabel.text = i.text
                }
            }
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audiofileName = path.appendingPathComponent(main.chooseDayArray[main.count].day.ddMMyyyy+lessonsName.text!+"\(userUID)"+".m4a")
            
            
            playButton.isHidden = true
            deleteAudioButton.isHidden = true
            for ii in main.urls {
                if ii == audiofileName {
                    playButton.isHidden = false
                    playButton.isEnabled = true
                    deleteAudioButton.isHidden = false
                }
            }
        }
        if lesson.selected {
            fullHomeworkLabel.textColor = .white
            linearView.isHidden = false
            doneIcon.isHidden = false
            timeLabel.isHidden = true
            lessonsName.textColor = .white
            homeworkLabel.textColor = .white
        }else{
            fullHomeworkLabel.textColor = .black
            linearView.isHidden = true
            doneIcon.isHidden = true
            timeLabel.isHidden = false
            lessonsName.textColor = .black
            homeworkLabel.textColor = .black
        }
    
    }
    
    func speechToText() {
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        if let audiofilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(currentDay.day.ddMMyyyy)\(lessonsName.text ?? "")\(userUID).m4a"){
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
                    homework.day = currentDay.day
                    homework.text = text
                    homework.lesson = lessonsName.text ?? ""
                    homeworkLabel.text = text
                    homework.userUID = userUID
                    homework.dateLastChange = Int(DispatchTime.now().uptimeNanoseconds)
                    homework.key = "\(currentDay.day.ddMMyyyy)"+"\(lessonsName.text ?? "")"+"\(userUID)"
                        do{
                            try realm.write{
                                realm.add(homework, update: .modified)
                            }
                        }catch{
                            print("Error saving homework")
                        }
                    homeworkLabel.text = text
                    fullHomeworkLabel.text = text
                    editHomeworkLabel.text = ""
                    editHomeworkLabel.isHidden = true
                    showFullHomeworkButton.isHidden = false
                }
            } else {
                print("Файл не знайдено.")
            }
        }else{
            print("Не вдалося створити шлях до файлу.")
        }
        reloadData?()
    }
    
    // MARK: - Record settings
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func setupRecord(filename: String) {
//        let audiofileName = getDocumentsDirectory().appendingPathComponent(filename)
//        let recordSetting = [AVFormatIDKey : kAudioFormatAppleLossless,
//                        AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
//                        AVEncoderBitRateKey : 320000,
//                     AVNumberOfChannelsKey : 2,
//                           AVSampleRateKey : 44100.2] as [String : Any]
//        do {
//            audioRecorder = try AVAudioRecorder(url: audiofileName, settings: recordSetting)
//            audioRecorder.delegate = self
//            audioRecorder.prepareToRecord()
//        }catch{
//            print("Setup audio ERROR", error)
//        }
        let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
                    try audioSession.setActive(true)

                    let audioURL = getDocumentsDirectory().appendingPathComponent(filename)
                    let settings: [String: Any] = [
                        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 44100,
                        AVNumberOfChannelsKey: 2,
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                    ]
                    audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
                                audioRecorder.delegate = self
                                audioRecorder.record()
                            } catch {
                                print("Error starting recording: \(error.localizedDescription)")
                            }
    }
    
    func setupPlayer(filename: String) {
        let audiofileName = getDocumentsDirectory().appendingPathComponent(filename)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audiofileName)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1.0
        }catch{
            print("Setup error: \(error)")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      editHomeworkLabel.resignFirstResponder()
      return true
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        playButton.isEnabled = true
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.isEnabled = true
        playButton.setImage(UIImage(named: "play-circle"), for: .normal)
    }
 
}
