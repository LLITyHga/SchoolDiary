//
//  LoginVC.swift
//  SchoolDiary
//
//  Created by Wolf on 26.06.2023.
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



class LoginVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var regShowPasswordButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var regEmailTextfield: UITextField!
    @IBOutlet weak var regPasswordTextField: UITextField!
    @IBOutlet weak var regWindow: UIVisualEffectView!
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    let realm = try! Realm()
    var allLessons: Results<Lesson3>?
    var db = Firestore.firestore()
    var lessons = [Lesson]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.frame = CGRect(x: (self.view?.frame.size.width)! / 2.7 , y: (self.view?.frame.size.height)! / 1.27 , width: view.fs_width/3.75, height: view.fs_width/3.75)
        emailTextField.delegate = self
        passwordTextField.delegate = self
        regEmailTextfield.delegate = self
        regPasswordTextField.delegate = self
    }

    @IBAction func showPasswordBTN(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
        if passwordTextField.isSecureTextEntry {
            showPasswordButton.setImage(UIImage(named: "eye-slash"), for: .normal)
        }else{
            showPasswordButton.setImage(UIImage(named: "eye"), for: .normal)
        }
    }
    @IBAction func regNextBTN(_ sender: UIButton) {
        if let email = regEmailTextfield.text, let password = regPasswordTextField.text{
        basicRegIn(email: email, password: password)
        }
    }
    @IBAction func regShowPasswordBTN(_ sender: UIButton) {
        regPasswordTextField.isSecureTextEntry = !regPasswordTextField.isSecureTextEntry
        if regPasswordTextField.isSecureTextEntry {
            regShowPasswordButton.setImage(UIImage(named: "eye-slash"), for: .normal)
        }else{
            regShowPasswordButton.setImage(UIImage(named: "eye"), for: .normal)
        }
    }
    @IBAction func regCloseWindowBTN(_ sender: UIButton) {
        regWindow.isHidden = true
        regEmailTextfield.text = ""
        regPasswordTextField.text = ""
        emailTextField.isHidden = false
        passwordTextField.isHidden = false
    }
    @IBAction func createAccountBTN(_ sender: UIButton) {
        passwordTextField.text = ""
        passwordTextField.isHidden = true
        emailTextField.text = ""
        emailTextField.isHidden = true
        regWindow.isHidden = false
    }
    @IBAction func forgotPasswordBTN(_ sender: UIButton) {
        var emailTextField = UITextField()
        let alert = UIAlertController(title: "Введіть емейл для відновлення", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Надіслати", style: .default){ action in
            if let emailTextField = emailTextField.text{
        Auth.auth().sendPasswordReset(withEmail: emailTextField) { error in
                           DispatchQueue.main.async {
                               if emailTextField.isEmpty==true || error != nil {
                                   let resetFailedAlert = UIAlertController(title: "Reset Failed", message: "Error: \(String(describing: error?.localizedDescription))", preferredStyle: .alert)
                                   resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                   self.present(resetFailedAlert, animated: true, completion: nil)
                               }
                               if error == nil && emailTextField.isEmpty==false{
                                   let resetEmailAlertSent = UIAlertController(title: "Відновлення пароля", message: "На Ваш емейл відправлено лист з подальшими інструкціями що до відновлення пароля", preferredStyle: .alert)
                                   resetEmailAlertSent.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                   self.present(resetEmailAlertSent, animated: true, completion: nil)
                               }
                           }
                       }
            }
           }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Email"
            emailTextField = alertTextField
        }
        alert.addAction(action)

        present(alert, animated: true, completion: nil)

    }
    @IBAction func facebookLogin(_ sender: UIButton) {
    }
    @IBAction func googleLogin(_ sender: UIButton) {
        signIn()
    }
    @IBAction func nexyButton(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            basicSignIn(email: email, password: password)
        }
    }
    func signIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
          guard error == nil else {
            // ...
              print(error!)
              return
          }

          guard let user = result?.user,
            let idToken = user.idToken?.tokenString
          else {
            // ...
              print("have no token")
              return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential, completion: nil)
                if Auth.auth().currentUser?.uid != nil{
                        guard let userUID = Auth.auth().currentUser?.uid else {
                            return
                        }
                    let user = User2()
                    user.name = userUID
                    try! realm.write{
                        realm.add(user)
                    }
                        allLessons = realm.objects(Lesson3.self).filter("userUID == %@", userUID)
                    
                    if allLessons?.count ?? 0 > 0 {
                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "MainVC") as! MainVC
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }else{
                        print("Flag 1")
                        db.collection("lessons"+userUID).addSnapshotListener { [self] querySnapshot, error in
                        self.lessons = []
                        if let e = error {
                            print(e)
                            let vc = self.storyboard!.instantiateViewController(withIdentifier: "SubjectVC") as! SubjectVC
                                           vc.modalPresentationStyle = .fullScreen
                                           self.present(vc, animated: true, completion: nil)
                        }else {
                            print("Flag 2")
                            if let snapshotDocumet = querySnapshot?.documents {
                                for doc in snapshotDocumet {
                                    let lesson = Lesson(title: doc["title"] as? String ?? "",
                                                         selected: doc["selected"] as? Bool ?? false,
                                                         dayOfWeek: doc["dayOfWeek"] as? String ?? "",
                                                         time: doc["time"] as? String ?? "",
                                                         homework: doc["homework"] as? String ?? "",
                                                         timeInMinutes: doc["timeInMinutes"] as? Int ?? 0,
                                                        userUID: doc["userUID"] as? String ?? "",
                                                        dateLastChange: doc["dateLastChange"] as? Int ?? 0)
                                    lessons.append(lesson)
                                    print("Flag 3")
                                    }
                            }
                            if allLessons?.count ?? 0 <= 0 && allLessons != nil{
                                print("Flag 4")
                                for s in lessons {
                                    let lesson2 = Lesson3()
                                                lesson2.title = s.title
                                                lesson2.selected = s.selected
                                                lesson2.dayOfWeek = s.dayOfWeek
                                                lesson2.time = s.time
                                                lesson2.homework = s.homework
                                                lesson2.timeInMinutes = s.timeInMinutes
                                    lesson2.userUID = s.userUID
                                    lesson2.dateLastChange = s.dateLastChange
                                    lesson2.key = "\(s.title)+\(s.timeInMinutes)+\(s.userUID)"
                                    if !(allLessons?.contains(lesson2))!{
                                        do{
                                            try realm.write{
                                                    realm.add(lesson2)
                                            }
                                        }catch{
                                            print("Error saving imageUrl")
                                        }
                                        print("Flag 5")
                                    }
                                  
                                }
                                if allLessons?.count ?? 0 > 0 || lessons.count > 0{
                                let vc = self.storyboard!.instantiateViewController(withIdentifier: "MainVC") as! MainVC
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true, completion: nil)
                                }else{
                                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "SubjectVC") as! SubjectVC
                                                   vc.modalPresentationStyle = .fullScreen
                                                   self.present(vc, animated: true, completion: nil)
                                }
                            }
                                
                            
                               
                        }
    }
                    
                    return
                }
            }
   
        }
    }
    
    @IBAction func emailTextField(_ sender: UITextField) {
        passwordTextField.becomeFirstResponder()
    }
    @IBAction func passwordTextField(_ sender: UITextField) {
        basicSignIn(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
    }
    @IBAction func regEmailTextField(_ sender: UITextField) {
        regPasswordTextField.becomeFirstResponder()
    }
    @IBAction func regPasswordTextField(_ sender: UITextField) {
        basicRegIn(email: regEmailTextfield.text ?? "", password: regPasswordTextField.text ?? "")
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            emailTextField.resignFirstResponder()
            return true
        }
        if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
          return true
        }
        if textField == regEmailTextfield {
            regEmailTextfield.resignFirstResponder()
            return true
        }else{
            regPasswordTextField.resignFirstResponder()
            return true
        }
    }
    func basicRegIn(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let e = error{
                print(e.localizedDescription)
                let resetFailedAlert = UIAlertController(title: "\(e.localizedDescription)", message: "", preferredStyle: .alert)
                resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(resetFailedAlert, animated: true, completion: nil)
            }else{
                    Auth.auth().signIn(withEmail: email, password: password) { [self] authResult, error in
                    if let x = error{
                        let err = x as NSError
                        switch err.code {
                        case AuthErrorCode.wrongPassword.rawValue:
                            let resetFailedAlert = UIAlertController(title: "Неправильний пароль", message: "", preferredStyle: .alert)
                            resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(resetFailedAlert, animated: true, completion: nil)
                        case AuthErrorCode.invalidEmail.rawValue:
                            let resetFailedAlert = UIAlertController(title: "Неправильний емейл", message: "", preferredStyle: .alert)
                            resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(resetFailedAlert, animated: true, completion: nil)
                        default:
                            let resetFailedAlert = UIAlertController(title: "\(err.localizedDescription)", message: "", preferredStyle: .alert)
                            resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(resetFailedAlert, animated: true, completion: nil)                }
                      
                    }else {
                        guard let userUID = Auth.auth().currentUser?.uid else {
                            return
                        }
                        print("REGISTERED USER \(userUID)")
                    let user = User2()
                    user.name = userUID
                    try! realm.write{
                        realm.add(user)
                    }
                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "SubjectVC") as! SubjectVC
                                       vc.modalPresentationStyle = .fullScreen
                                       self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func basicSignIn(email: String, password: String) {
                if self.allLessons?.count ?? 0 < 1 {
                 //   print("FLAG!")
                    Auth.auth().signIn(withEmail: email, password: password) { [self] authResult, error in
                    if let x = error{
                        let err = x as NSError
                        switch err.code {
                        case AuthErrorCode.wrongPassword.rawValue:
                            let resetFailedAlert = UIAlertController(title: "Неправильний пароль", message: "", preferredStyle: .alert)
                            resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(resetFailedAlert, animated: true, completion: nil)
                        case AuthErrorCode.invalidEmail.rawValue:
                            let resetFailedAlert = UIAlertController(title: "Неправильний емейл", message: "", preferredStyle: .alert)
                            resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(resetFailedAlert, animated: true, completion: nil)
                        default:
                            let resetFailedAlert = UIAlertController(title: "\(err.localizedDescription)", message: "", preferredStyle: .alert)
                            resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(resetFailedAlert, animated: true, completion: nil)                }
                      
                    }else{
                     
                            if Auth.auth().currentUser?.uid != nil{
                                guard let userUID = Auth.auth().currentUser?.uid else {
                                    return
                                }
                                let user = User2()
                                user.name = userUID
                                try! realm.write{
                                    realm.add(user)
                                }
                                if self.allLessons?.count ?? 0 > 0 {
                                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "MainVC") as! MainVC
                                    vc.modalPresentationStyle = .fullScreen
                                    self.present(vc, animated: true, completion: nil)
                                    print("\(String(describing: self.allLessons?.count))"+"kjvsbdvkjsdbl jdabnladknblkdasbnslfbn sdklb ladb ladk nklsfn ")
                                    return
                                }else{
                                    db.collection("lessons"+userUID).getDocuments { [self] querySnapshot, error in
                                    self.lessons = []
                                    if let e = error {
                                        print(e)
                                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "SubjectVC") as! SubjectVC
                                                       vc.modalPresentationStyle = .fullScreen
                                                       self.present(vc, animated: true, completion: nil)
                                    }else {
                                        if let snapshotDocumet = querySnapshot?.documents {
                                            for doc in snapshotDocumet {
                                                let lesson = Lesson(title: doc["title"] as? String ?? "",
                                                                     selected: doc["selected"] as? Bool ?? false,
                                                                     dayOfWeek: doc["dayOfWeek"] as? String ?? "",
                                                                     time: doc["time"] as? String ?? "",
                                                                     homework: doc["homework"] as? String ?? "",
                                                                     timeInMinutes: doc["timeInMinutes"] as? Int ?? 0,
                                                                    userUID: doc["userUID"] as? String ?? "",
                                                                    dateLastChange: doc["dateLastChange"] as? Int ?? 0)
                                                lessons.append(lesson)

                                                }
                                        }
                                        if allLessons?.count ?? 0 <= 0 {
                                            for s in lessons {
                                                let lesson2 = Lesson3()
                                                            lesson2.title = s.title
                                                            lesson2.selected = s.selected
                                                            lesson2.dayOfWeek = s.dayOfWeek
                                                            lesson2.time = s.time
                                                            lesson2.homework = s.homework
                                                            lesson2.timeInMinutes = s.timeInMinutes
                                                lesson2.userUID = s.userUID
                                                lesson2.dateLastChange = s.dateLastChange
                                                lesson2.key = "\(s.title)+\(s.timeInMinutes)+\(s.userUID)"
                                                do{
                                                    try realm.write{
                                                        realm.add(lesson2, update: .modified)
                                                    }
                                                }catch{
                                                    print("Error saving imageUrl")
                                                }
                                            }
                                           
                                        }
                                            let vc = self.storyboard!.instantiateViewController(withIdentifier: "MainVC") as! MainVC
                                            vc.modalPresentationStyle = .fullScreen
                                            self.present(vc, animated: true, completion: nil)
                                    }
                }
                                return
                            }
                        }
                    }
                }
                
                }else{
                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "MainVC") as! MainVC
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }

    }
