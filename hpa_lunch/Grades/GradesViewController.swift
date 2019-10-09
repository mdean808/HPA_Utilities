//
//  GradesViewController.swift
//  hpa_lunch
//
//  Created by Morgan Dean on 11/15/18.
//  Copyright © 2018 Morgan Dean. All rights reserved.
//

import UIKit
import TOWebViewController
import Intents
import IntentsUI
import SafariServices

class GradesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, INUIAddVoiceShortcutViewControllerDelegate, INUIEditVoiceShortcutViewControllerDelegate  {
    var webViewController: TOWebViewController?

    struct ClassGrade:Codable {
        var title: String
        var grade: String
        var link: String
    }
    var grades = [ClassGrade]()
    
    var themeColor = UIColor(red: 0.75, green: 0.10, blue: 0.25, alpha: 1.0)
    var themeTint = UIColor.white

    @IBOutlet weak var navigationBar: UINavigationItem!
    override func viewDidLoad() {
        //todo: load themecolor from userdefaults
        themeColor = UserDefaults.standard.colorForKey("primaryColor") ?? UIColor(red: 0.75, green: 0.10, blue: 0.25, alpha: 1.0)
        //todo: load themeting from userdefaults
        themeTint = UserDefaults.standard.colorForKey("secondaryColor") ?? UIColor.white
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        let siriButton = UIBarButtonItem(title: "Siri", style: .plain, target: self, action: #selector(addToSiri))
        siriButton.tintColor = themeTint
        navigationBar.leftBarButtonItem = siriButton
        
        let updateButton = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(loginTriggered(_:)))
        updateButton.tintColor = themeTint
        navigationBar.rightBarButtonItem = updateButton
        
        do {
            if let data = UserDefaults.standard.value(forKey:"grades") as? Data {
                grades = try PropertyListDecoder().decode(Array<ClassGrade>.self, from: data)
            }
        } catch {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.grades), forKey: "grades")
        }
        if let userDefaults = UserDefaults(suiteName: "group.hpa.utils") {
            userDefaults.set(try? PropertyListEncoder().encode(grades), forKey: "gradesForIntent")
            userDefaults.synchronize()
        }
        self.table.reloadData()
        donateGrades()
    }
    
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
        self.table.reloadData()
    }
    
    @IBOutlet weak var gradeButton: UIButton!

    @IBAction func loginTriggered(_ sender: Any) {
        let urlString = "https://hpa.learning.powerschool.com/do/authentication/google/google_begin?google_domain=hpa.edu"
        //let callbackScheme = ""
        UserDefaults.standard.register(defaults: ["UserAgent": "Firefox/17.0"])
        self.webViewController = TOWebViewController(urlString: urlString)
        
        let navigationController = UINavigationController(rootViewController: (self.webViewController)!)
        
        self.present(navigationController, animated: true, completion: nil)
        self.table.isScrollEnabled = false;
        self.webViewController?.didFinishLoadHandler = onLoad
    }
    
    func onLoad(webView: UIWebView) {
        if webView.request?.url?.absoluteString.range(of: "hpa.learning.powerschool.com/u") != nil {
            let getGradeScript = "function func2(){var grades=jQuery(jQuery('#portlet_box_content_reportcard').children()[1]);var textGrades=[];var classTitles=[];var classLinks=[];grades.each(function(){jQuery('td',this).each(function(){var elem=jQuery(this);if(elem.hasClass('right')){var gradeElement=jQuery(elem.children()[0]);var gradeText=gradeElement.text();textGrades.push(gradeText)}else if(elem.attr('width')!=15){classLinks.push(elem.children()[0].href); classTitles.push(elem.text())}})});return textGrades.toString().replace(/\\s+/g,'')+'#'+classTitles.toString()+'#'+classLinks.toString()};func2().split('%,').join('%, ').replace(/([a-z]-?\\+?)(?=[0-9])/ig,'$1 ')"
            let gradeInfo = webView.stringByEvaluatingJavaScript(from: getGradeScript) ?? "no crades"
            let grades = gradeInfo.split(separator: "#")[0]
            let courseNames = gradeInfo.split(separator: "#")[1]
            let links = gradeInfo.split(separator: "#")[2]
            self.webViewController?.dismiss(animated: true
                , completion: {self.didSuccessfullLogin(jsGrades: String(grades), jsCourses: String(courseNames), jsLinks: String(links))});
        }
    }
    @IBOutlet weak var table: UITableView!
    func didSuccessfullLogin(jsGrades: String, jsCourses: String, jsLinks: String) {
        let newGrades = jsGrades.split(separator: ",")
        let newCourses = jsCourses.split(separator: ",")
        let newLinks = jsLinks.split(separator: ",")
        grades = [ClassGrade]()
        for index in 0...newGrades.count-1 {
            let newGrade = ClassGrade(title: String(newCourses[index]), grade: String(newGrades[index]), link: String(newLinks[index]))
            grades += [newGrade]
        }
        UserDefaults.standard.set(try? PropertyListEncoder().encode(grades), forKey: "grades")
        if let userDefaults = UserDefaults(suiteName: "group.hpa.utils") {
            userDefaults.set(try? PropertyListEncoder().encode(grades), forKey: "gradesForIntent")
            userDefaults.synchronize()
        }
        self.table.reloadData()
        self.table.isScrollEnabled = true;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grades.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "GradeTableCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GradeTableCell
        let grade = grades[indexPath.row]
        cell?.courseLabel.text = grade.title
        cell?.courseLabel.textColor = themeColor
        cell?.grade.text = grade.grade
        return (cell ?? nil)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        var urlString = grades[indexPath.row].link
        urlString = urlString.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: urlString)
        {
            let safari = SFSafariViewController(url: url)
            safari.delegate = self as? SFSafariViewControllerDelegate
            present(safari, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
    
    
    @objc func addToSiri(_ sender: Any) {
        if #available(iOS 12.0, *) {
            let intent = GradesIntent()
            
            intent.suggestedInvocationPhrase = "What are my grades?"
            if let shortcut = INShortcut(intent: intent) {
                let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
                viewController.modalPresentationStyle = .formSheet
                viewController.delegate = self // Object conforming to `INUIAddVoiceShortcutViewControllerDelegate`.
                present(viewController, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Unsupported iOS", message: "To use this feature you must update to iOS 12 or greater.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    func donateGrades() {
        if #available(iOS 12.0, *) {
            let intent = GradesIntent()
            intent.suggestedInvocationPhrase = "What are my grades?"
            INInteraction(intent: intent, response: nil).donate(completion: nil)
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
