//
//  Week.swift
//  SchoolDiary
//
//  Created by Wolf on 16.05.2024.
//

import Foundation

enum Week: Int {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    
    var week: Int {
        return self.rawValue
    }
}
