//
//  MenuVC.swift
//  SchoolDiary
//
//  Created by Wolf on 07.07.2023.
//
import UIKit
import Firebase
import UserNotifications
import RealmSwift

class MenuVC: UIViewController {
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var editLessonsButton: UIButton!
    @IBOutlet weak var editLessonsMenu: UIVisualEffectView!
    @IBOutlet weak var notificationsMenu: UIVisualEffectView!
    let center = UNUserNotificationCenter.current()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            if !GlobalVarData.shared.notificationIsAccepted {
                notificationSwitch.isOn = false
            }else{
                notificationSwitch.isOn = true
            }
        let defaultDate = Calendar.current
        let defaultTime = defaultDate.date(bySettingHour: GlobalVarData.shared.notificationHour, minute: GlobalVarData.shared.notificationMinutes, second: 0, of: Date())
        datePicker.date = defaultTime ?? Date()
        notificationSwitch.addTarget(self, action: #selector(switchValueNotification(_:)), for: .valueChanged)
        editLessonsButton.frame = CGRect(x: (self.view?.frame.size.width)! / 2.7 , y: (self.view?.frame.size.height)! / 1.27 , width: view.fs_width/3.75, height: view.fs_width/3.75)
        let w = view.fs_width/2.5
        let h = view.fs_height/4.3
        let gradientView = UIView(frame: CGRect(x: 0, y: 0, width: w, height: h))
                         let gradientLayer:CAGradientLayer = CAGradientLayer()
                        gradientView.layer.cornerRadius = 20
        
                         gradientLayer.frame.size = gradientView.frame.size
                        gradientLayer.cornerRadius = 20
                         gradientLayer.colors =
        [UIColor(red: 1, green: 0, blue: 0.360, alpha: 1).cgColor,UIColor(red: 1, green: 0.411, blue: 0.623, alpha: 1).cgColor]
                        //Use diffrent colors
                         gradientView.layer.addSublayer(gradientLayer)
        
                        view1.addSubview(gradientView)
                        view1.layer.cornerRadius = 20
        
        let w2 = view.fs_width/2.65
        let h2 = view.fs_height/6.3
        let gradientView2 = UIView(frame: CGRect(x: 0, y: 0, width: w2, height: h2))
                         let gradientLayer2:CAGradientLayer = CAGradientLayer()
                        gradientView2.layer.cornerRadius = 20
        
                         gradientLayer2.frame.size = gradientView2.frame.size
                        gradientLayer2.cornerRadius = 20
                         gradientLayer2.colors =
        [UIColor(red: 0.953, green: 0.408, blue: 0.012, alpha: 1).cgColor,UIColor(red: 1, green: 0.792, blue: 0.059, alpha: 1).cgColor]
                        //Use diffrent colors[UIColor(red: 1, green: 0, blue: 0,36, alpha: 1).cgColor,UIColor(red: 1, green: 0,411, blue: 0,623, alpha: 1).cgColor]
                         gradientView2.layer.addSublayer(gradientLayer2)
        
                        view2.addSubview(gradientView2)
                        view2.layer.cornerRadius = 20
        
        let w3 = view.fs_width/2.5
        let h3 = view.fs_height/6.3
        let gradientView3 = UIView(frame: CGRect(x: 0, y: 0, width: w3, height: h3))
                         let gradientLayer3:CAGradientLayer = CAGradientLayer()
                        gradientView3.layer.cornerRadius = 20
        
                         gradientLayer3.frame.size = gradientView3.frame.size
                        gradientLayer3.cornerRadius = 20
                         gradientLayer3.colors =
        [UIColor(red: 0.510, green: 0.020, blue: 1, alpha: 1).cgColor,UIColor(red: 0.812, green: 0.631, blue: 0.996, alpha: 1).cgColor]
                        //Use diffrent colors
                         gradientView3.layer.addSublayer(gradientLayer3)
        
                        view3.addSubview(gradientView3)
                        view3.layer.cornerRadius = 20
        
        let w4 = view.fs_width/2.65
        let h4 = view.fs_height/4.3
        let gradientView4 = UIView(frame: CGRect(x: 0, y: 0, width: w4, height: h4))
                         let gradientLayer4:CAGradientLayer = CAGradientLayer()
                        gradientView4.layer.cornerRadius = 20
        
                         gradientLayer4.frame.size = gradientView4.frame.size
                        gradientLayer4.cornerRadius = 20
                         gradientLayer4.colors =
        [UIColor(red: 0, green: 0.941, blue: 1, alpha: 1).cgColor,UIColor(red: 0, green: 0.941, blue: 1, alpha: 1).cgColor]
                        //Use diffrent colors
                         gradientView4.layer.addSublayer(gradientLayer4)
        
                        view4.addSubview(gradientView4)
                        view4.layer.cornerRadius = 20
    }
    @IBAction func logOutBTN(_ sender: UIButton) {
        let alert = UIAlertController(title: "Вийти з облікового запису?", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default){ [self] action in
            let firebaseAuth = Auth.auth()
            let userToDelete = realm.objects(User2.self)
            try! realm.write {
                realm.delete(userToDelete)
            }
            do {
              try firebaseAuth.signOut()
            } catch let signOutError as NSError {
              print("Error signing out: %@", signOutError)
            }
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
        let action2 = UIAlertAction(title: "Відмінити", style: .default){ action2 in
            return
        }
        alert.addAction(action)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }

    @IBAction func editLessonsBTN(_ sender: UIButton) {
        editLessonsMenu.isHidden = false
    }
    @IBAction func menuBTN(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func firstBTN(_ sender: UIButton) {
        let vc = CompendiumVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func secondBTN(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "NewsVC") as! NewsVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func thirdBTN(_ sender: UIButton) {
        editLessonsMenu.isHidden = false
    }
    @IBAction func fourthBTN(_ sender: UIButton) {
        notificationsMenu.isHidden = false
    }
    @IBAction func closeEditionWindow(_ sender: UIButton) {
        editLessonsMenu.isHidden = true
    }
    @IBAction func mondayEditBTN(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "EditLessonsVC") as! EditLessonsVC
        vc.count = 0
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func tuesdayEditBTN(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "EditLessonsVC") as! EditLessonsVC
        vc.count = 1
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func wednesdayEditBTN(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "EditLessonsVC") as! EditLessonsVC
        vc.count = 2
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func thursdayEditBTN(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "EditLessonsVC") as! EditLessonsVC
        vc.count = 3
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func setTimeNotificationBTN(_ sender: UIButton) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: datePicker.date)
        if let hour = components.hour, let minute = components.minute {
            GlobalVarData.shared.notificationHour = hour
            GlobalVarData.shared.notificationMinutes = minute
            let userUpdate = User2()
            userUpdate.name = realm.objects(User2.self).first?.name ?? ""
            userUpdate.notificationHour = hour
            userUpdate.notificationMinutes = minute
            try? realm.write {
                realm.add(userUpdate, update: .modified)
            }
            NotificationCenter.default.post(name: Notification.Name.timeLocalNotificationDidChange, object: nil)
        }
        notificationsMenu.isHidden = true
    }
    @IBAction func closeNotificationMenu(_ sender: UIButton) {
        notificationsMenu.isHidden = true
    }
    @IBAction func acceptNotificationBTN(_ sender: UISwitch) {
        
    }
    @IBAction func setTimeNotification(_ sender: UIDatePicker) {
        
       
    }
    @IBAction func fridayEditBTN(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "EditLessonsVC") as! EditLessonsVC
        vc.count = 4
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func switchValueNotification(_ sender: UISwitch) {
        if(sender.isOn) {
            GlobalVarData.shared.notificationIsAccepted = true
            requestNotificationPermission { granted in
                print(granted)
                if !granted {
                    DispatchQueue.main.async {
                        sender.isOn = false // Якщо дозвіл не надано, перемкнути UISwitch назад
                    }
                }
            }
        }  else {
            GlobalVarData.shared.notificationIsAccepted = false
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Помилка під час запиту дозволу: \(error)")
                completion(false)
            } else {
                completion(granted)
            }
        }
    }
}
