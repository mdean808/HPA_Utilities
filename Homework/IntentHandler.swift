//
//  IntentHandler.swift
//  Homework
//
//  Created by Morgan Dean on 11/27/18.
//  Copyright © 2018 Morgan Dean. All rights reserved.
//

import Intents

class HomeworkIntentHandler: NSObject, TodaysHomeworkIntentHandling {
    func handle(intent: TodaysHomeworkIntent, completion: @escaping (TodaysHomeworkIntentResponse) -> Void) {
        if let userDefaults = UserDefaults(suiteName: "group.hpa.utils") {
            let homework = userDefaults.string(forKey: "homeworkForIntent")
            completion(.success(homework: homework ?? "No homework"))
        }
    }
    
    func confirm(intent: TodaysHomeworkIntent, completion: @escaping (TodaysHomeworkIntentResponse) -> Void) {
        completion(TodaysHomeworkIntentResponse(code: .ready, userActivity: nil))
    }
    
}

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        guard intent is TodaysHomeworkIntent else {
            fatalError("Incorrect Intent")
        }
        return HomeworkIntentHandler()
    }
    
}
