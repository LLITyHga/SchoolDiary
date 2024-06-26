//
//  AppDelegate.swift
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
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    

    var window: UIWindow?
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let realm = try! Realm()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController: UIViewController
let user = realm.objects(User2.self)
        if !user.isEmpty {
    initialViewController = storyboard.instantiateViewController(withIdentifier: "MainVC")
}else{
    initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")
}
            window?.rootViewController = initialViewController
            window?.makeKeyAndVisible()
        return true
    }

    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        NotificationCenter.default.post(name: Notification.Name.timeLocalNotificationDidChange, object: nil)
                
            }
    func applicationWillTerminate(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name.timeLocalNotificationDidChange, object: nil)
    }
    
}
