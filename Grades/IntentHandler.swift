//
//  IntentHandler.swift
//  Grades
//
//  Created by Morgan Dean on 11/27/18.
//  Copyright © 2018 Morgan Dean. All rights reserved.
//

import Intents

class GradeIntentHandler: NSObject, GradesIntentHandling {
    func handle(intent: GradesIntent, completion: @escaping (GradesIntentResponse) -> Void) {
        struct Grades:Codable {
            var title: String
            var grade: String
        }
        var grades = [Grades]()
        if let userDefaults = UserDefaults(suiteName: "group.hpa.utils") {
            var gradesString = "Your grades are as follows: "
            if let data = userDefaults.value(forKey:"gradesForIntent") as? Data {
                grades = try! PropertyListDecoder().decode(Array<Grades>.self, from: data)
                for grade in grades {
                    gradesString += "\(grade.grade) in \(grade.title), "
                }
            }
            if gradesString == "Your grades are as follows: " {
                gradesString = "You have no grades. Please update them in the HPA Utils app."
            }
            completion(.success(grades: gradesString))
        }
    }
    
    func confirm(intent: GradesIntent, completion: @escaping (GradesIntentResponse) -> Void) {
        completion(GradesIntentResponse(code: .ready, userActivity: nil))
    }
    
}

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        guard intent is GradesIntent else {
            fatalError("Incorrect Intent")
        }
        return GradeIntentHandler()
    }
    
}
