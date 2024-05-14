//
//  ViewController.swift
//  SchoolDiary
//
//  Created by Wolf on 12.06.2023.
//

import UIKit
import RealmSwift
//need delete
class FirstViewController: UIViewController {
    @IBOutlet weak var skipAuthButton: UIButton!
    let realm = try! Realm()
    var allLessons: Results<Lesson3>?

    override func viewDidLoad() {
        super.viewDidLoad()
        skipAuthButton.frame = CGRect(x: (self.view?.frame.size.width)! / 2.7 , y: (self.view?.frame.size.height)! / 1.27 , width: view.fs_width/3.75, height: view.fs_width/3.75)
        allLessons = realm.objects(Lesson3.self)
        if allLessons?.count ?? 0 > 0 {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "MainVC") as! MainVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }

    @IBAction func authorizationBTN(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func skipAuthorizationBTN(_ sender: UIButton) {
//        let realm = try! Realm()
//        try! realm.write {
//            // Delete all objects from the realm.
//            realm.deleteAll()
//        }
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "SubjectVC") as! SubjectVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

