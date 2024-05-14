//
//  realmNotification.swift
//  SchoolDiary
//
//  Created by Wolf on 21.03.2024.
//

import Foundation

extension Notification.Name {
    static let realmDataDidChange = Notification.Name("RealmDataDidChangeNotification")
    static let timeLocalNotificationDidChange = Notification.Name("TimeLocalNotificationDidChange")
    static let firebaseDownloaded = Notification.Name("FirebaseDownloaded")
}
