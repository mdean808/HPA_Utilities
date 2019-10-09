//
//  ScheduleViewController.swift
//  hpa_lunch
//
//  Created by Morgan Dean on 11/5/18.
//  Copyright © 2018 Morgan Dean. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices
import CRRefresh

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    struct Course {
        var title: String
        var timing: String
        var link: String
    }
    var courses = [Course]()
    
    @IBOutlet public weak var dayTitle: UINavigationItem!
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateSchedule()
        table.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            /// start refresh
            /// Do anything you want...
            self?.updateSchedule()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                /// Stop refresh when your job finished, it will reset refresh footer if completion is true
                self?.table.cr.endHeaderRefresh()
            })
        }
    }
    
    func updateSchedule() {
        let url = "https://lunch.mogdan.xyz/api/calendar"
        Alamofire.request(url).responseJSON {response in
            let json = (response.result.value as? NSDictionary) ?? ["err": "error: \(response.result.value ?? "Unknown Error")"]
            if (json.value(forKey: "err") as? String)?.hasPrefix("error:") ?? false {
                self.dayTitle.title = "Error Getting the Schedule."
            } else {
                let courseData = (json.value(forKey: "events") as! NSArray)
                self.dayTitle.title = json.value(forKey: "day") as? String
                self.courses = []
                for index in courseData {
                    let newCourse = Course(title: (index as! NSDictionary).value(forKey: "title") as? String ?? "No Name", timing: (index as! NSDictionary).value(forKey: "duration") as? String ?? "Times not implemented", link: (index as! NSDictionary).value(forKey: "link") as! String)
                    self.courses += [newCourse]
                }
                self.table.reloadData()
                self.table.cr.endHeaderRefresh()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CourseTableCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CourseCell
        let course = courses[indexPath.row]
        cell?.nameLabel.text = course.title
        cell?.timingLabel.text = course.timing

        return (cell ?? nil)!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let urlString = self.courses[indexPath.row].link
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
    @objc func closeView() {
        self.dismiss(animated: true )
    }
}
