//
//  HomeworkViewController.swift
//  
//
//  Created by Morgan Dean on 11/5/18.
//

import UIKit
import Alamofire
import Intents
import os.log
import IntentsUI

class HomeworkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, INUIAddVoiceShortcutViewControllerDelegate, INUIEditVoiceShortcutViewControllerDelegate {

    var themeColor = UIColor(red: 0.75, green: 0.10, blue: 0.25, alpha: 1.0)
    var themeTint = UIColor.white
    
    struct Course:Codable {
        var title: String
        var complete: Bool
    }
    var courses = [Course]()
    var courseAliases = [
        "Course A",
        "Course B",
        "Course C",
        "Course D",
        "Course E",
        "Course F",
        "Course G"
    ]
    let OGcourseAliases = [
        "Course A",
        "Course B",
        "Course C",
        "Course D",
        "Course E",
        "Course F",
        "Course G"
    ]
    
    override func viewDidAppear(_ animated: Bool) {
        //todo: load themecolor from userdefaults
        themeColor = UserDefaults.standard.colorForKey("primaryColor") ?? UIColor(red: 0.75, green: 0.10, blue: 0.25, alpha: 1.0)
        //todo: load themeting from userdefaults
        themeTint = UserDefaults.standard.colorForKey("secondaryColor") ?? UIColor.white
            super.viewDidAppear(true)
        self.navigationController?.navigationBar.barTintColor = themeColor
        self.navigationController?.navigationBar.backgroundColor = themeColor
            
        self.navigationController?.navigationBar.tintColor = themeTint
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : themeTint]
            
        self.tabBarController?.tabBar.tintColor = themeColor

        table.delegate = self
        table.dataSource = self
        courses = [Course]()
        courseAliases = (UserDefaults.standard.array(forKey: "courseAlias") as? [String]) ?? courseAliases
        
        let siriButton = UIBarButtonItem(title: "Siri", style: .plain, target: self, action: #selector(addToSiri))
        siriButton.tintColor = themeTint
        navigationBar.leftBarButtonItem = siriButton
        
        var courseData: [Course] = []
        if let data = UserDefaults.standard.value(forKey:"homework") as? Data {
            courseData = try! PropertyListDecoder().decode(Array<Course>.self, from: data)
            
        } else {
            courseData = [Course(title: courseAliases[0], complete: false),Course(title: courseAliases[1], complete: false),Course(title: courseAliases[2], complete: false),Course(title: courseAliases[3], complete: false),Course(title: courseAliases[4], complete: false),Course(title: courseAliases[5], complete: false),Course(title: courseAliases[6], complete: false)]
        }
        for i in courseData.indices {
            if courseAliases[i] == "" {
                let newCourse = Course(title: OGcourseAliases[i], complete: courseData[i].complete)
                self.courses += [newCourse]

            } else {
                let newCourse = Course(title: courseAliases[i], complete: courseData[i].complete)
                self.courses += [newCourse]

            }
        }
        self.table.reloadData()
        var homeWorkString = "You have homework in "
        
        if let data = UserDefaults.standard.value(forKey:"homework") as? Data {
            courseData = try! PropertyListDecoder().decode(Array<Course>.self, from: data)
            for i in courseData.indices {
                if courseData[i].complete {
                    if courseAliases[i] == "" {
                        homeWorkString += "\(OGcourseAliases[i]), "
                    } else {
                        homeWorkString += "\(courseAliases[i]), "
                    }
                }
            }
        } else {
            homeWorkString = "You have no homework."
        }
        if let userDefaults = UserDefaults(suiteName: "group.hpa.utils") {
            userDefaults.set(homeWorkString, forKey: "homeworkForIntent")
            userDefaults.synchronize()
        }
        
    }
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    override func viewDidLoad() {
        //todo: load themecolor from userdefaults
        themeColor = UserDefaults.standard.colorForKey("primaryColor") ?? UIColor(red: 0.75, green: 0.10, blue: 0.25, alpha: 1.0)
        //todo: load themeting from userdefaults
        themeTint = UserDefaults.standard.colorForKey("secondaryColor") ?? UIColor.white
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = themeColor
        self.navigationController?.navigationBar.backgroundColor = themeColor
        
        self.navigationController?.navigationBar.tintColor = themeTint
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : themeTint]
        
        self.tabBarController?.tabBar.tintColor = themeColor
        donateHomework()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "HomeworkTableCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HomeworkTableCell
        let course = courses[indexPath.row]
        cell?.courseLabel.text = course.title
        cell?.completeSwitch.isOn = course.complete
        cell?.completeSwitch.onTintColor = themeColor
        cell?.completeSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        return (cell ?? nil)!
    }
    @objc func switchChanged(_ sender : UISwitch!){
        let labels = sender.superview?.subviews.compactMap{ $0 as? UILabel};
        for label in labels! {
            for i in courses.indices {
                if courses[i].title == label.text {
                    courses[i].complete = sender.isOn
                }
            }
            UserDefaults.standard.set(try? PropertyListEncoder().encode(courses), forKey: "homework")
        }
    }
    @objc func loadSettings() {
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Settings") as UIViewController
        self.present(viewController, animated: true, completion: nil)
    }
    
    @objc
    func addToSiri(_ sender: Any) {
        if #available(iOS 12.0, *) {
            let intent = TodaysHomeworkIntent()
            
            intent.suggestedInvocationPhrase = "What is my homework?"
            if let shortcut = INShortcut(intent: intent) {
                let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
                viewController.modalPresentationStyle = .formSheet
                viewController.delegate = self // Object conforming to `INUIAddVoiceShortcutViewControllerDelegate`.
                present(viewController, animated: true, completion: nil)
            }
        } else {
            // Fallback on earlier versions
            let alert = UIAlertController(title: "Unsupported iOS", message: "To use this feature you must update to iOS 12 or greater.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
    }

    
    func donateHomework() {
        if #available(iOS 12.0, *) {
            let intent = TodaysHomeworkIntent()
            intent.suggestedInvocationPhrase = "Homework"
            INInteraction(intent: intent, response: nil).donate(completion: nil)
            print("donated")
        } else {
            // Fallback on earlier versions
            print("Incorrect iOS version")
        }
    }
    @available(iOS 12.0, *)
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @available(iOS 12.0, *)
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @available(iOS 12.0, *)
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @available(iOS 12.0, *)
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @available(iOS 12.0, *)
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
