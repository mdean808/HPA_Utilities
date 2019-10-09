//
//  CurHomework.swift
//  hpa_lunch
//
//  Created by Morgan Dean on 11/26/18.
//  Copyright © 2018 Morgan Dean. All rights reserved.
//

import Foundation

public func getHomework() -> String {
    struct Course:Codable {
        var title: String
        var complete: Bool
    }
    var courseData: [Course] = []
    var homeWorkString = "You have homework in "
    
    if let data = UserDefaults.standard.value(forKey:"homework") as? Data {
        courseData = try! PropertyListDecoder().decode(Array<Course>.self, from: data)
        for course in courseData {
            if course.complete {
                homeWorkString += "\(course.title), "
            }
        }
    } else {
        homeWorkString += "no homework!"
    }
    let userDefaults = UserDefaults(suiteName: "group.hpa.utils")
    userDefaults?.set(homeWorkString, forKey: "homeworkString")
    userDefaults?.synchronize()
    return homeWorkString
}
