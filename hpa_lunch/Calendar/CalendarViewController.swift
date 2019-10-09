//
//  HaikuViewController.swift
//  hpa_lunch
//
//  Created by Morgan Dean on 11/8/18.
//  Copyright © 2018 Morgan Dean. All rights reserved.
//

import UIKit
import TOWebViewController
import SwiftSoup
import Alamofire
import SafariServices

class CalendarViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource{
    
    var webViewController: TOWebViewController?
    var curClasses: String = ""
    var csrf: String = ""
    struct CalendarItem:Codable {
        var className: String
        var text: String
        var time: String
        var link: String
    }
    var calendar = [CalendarItem]()

    var themeColor = UIColor(red: 0.75, green: 0.10, blue: 0.25, alpha: 1.0)
    var themeTint = UIColor.white
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        do {
            if let data = UserDefaults.standard.value(forKey:"calendar") as? Data {
                    calendar = try PropertyListDecoder().decode(Array<CalendarItem>.self, from: data)
            }
        } catch {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.calendar), forKey: "calendar")
        }
        let updateButton = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(loginTriggered(_:)))
        updateButton.tintColor = themeTint
        navigationBar.rightBarButtonItem = updateButton
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
    }
    
    @IBAction func loginTriggered(_ sender: Any) {
        let urlString = "https://hpa.learning.powerschool.com/do/authentication/google/google_begin?google_domain=hpa.edu"
        UserDefaults.standard.register(defaults: ["UserAgent": "Firefox/17.0"])
        self.webViewController = TOWebViewController(urlString: urlString)
        
        let navigationController = UINavigationController(rootViewController: (self.webViewController)!)
        
        self.present(navigationController, animated: true, completion: nil)

        self.webViewController?.didFinishLoadHandler = onLoad
    }
    
    func onLoad(webView: UIWebView) {
        let url = String((webView.request?.url?.absoluteString.split(separator: "/")[3])!)
        if webView.request?.url?.absoluteString.range(of: "hpa.learning.powerschool.com/u") != nil {
            curClasses = webView.stringByEvaluatingJavaScript(from: "PortalData.currentClasses.toString()") ?? "no clasess"
            curClasses = curClasses.replacingOccurrences(of: ",", with: "+")
            print(curClasses)
            csrf = webView.stringByEvaluatingJavaScript(from: "CSRFTOK") ?? "no csrftok"
            self.webViewController?.dismiss(animated: true
                , completion: {self.didSuccessfullLogin(user: url)});
        }
    }
    func didSuccessfullLogin(user: String!) {
        table.isScrollEnabled = false;
        let url = "https://hpa.learning.powerschool.com/u/\(user ?? "")/portal/portlet_calendar_week?id=\(curClasses)"
        print(url);
        calendar = [CalendarItem]()
        Alamofire.request(url, method: .post).responseString { response in
            do {
                let calDoc: Document = try! SwiftSoup.parse(response.value!)
                let calendarDays: Elements = try! calDoc.getElementsByClass("calendar_day")
                for day in calendarDays.array() {
                    for element in day.children().array() {
                        if try element.className() == "list_item" {
                            let text = try! element.getElementsByClass("item_description").array()[0].child(0).ownText()
                            let name = try! element.getElementsByClass("left").array()[0].child(0).attr("atitle")
                            let link = "https://hpa.learning.powerschool.com\(try! element.getElementsByClass("left").array()[0].child(0).attr("href"))"
                            let time = try! element.getElementsByClass("item_description").array()[0].child(1).ownText()
                            let calItem = CalendarItem(className: name, text: text, time: time, link: link)
                            self.calendar += [calItem]
                            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.calendar), forKey: "calendar")
                        }
                        if element.tagName() == "h3" {
                            let text = ""
                            let name = ""
                            let time = try! element.text()
                            let link = "none"
                            let calItem = CalendarItem(className: name, text: text, time: time, link: link)
                            self.calendar += [calItem]
                            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.calendar), forKey: "calendar")
                        }
                    }

                }
                self.table.reloadData()
                self.table.isScrollEnabled = true;
            } catch Exception.Error( _, let message) {
                print("error \(message)")
            } catch {
                print("error")
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendar.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CalendarTableCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CalendarTableCell
        print(indexPath.row)
        let calendarItem = calendar[indexPath.row]
        if calendarItem.time.hasPrefix("Mon, ") || calendarItem.time.hasPrefix("Tue, ") || calendarItem.time.hasPrefix("Wed, ") || calendarItem.time.hasPrefix("Thu, ") || calendarItem.time.hasPrefix("Fri, ") || calendarItem.time.hasPrefix("Sat, ") || calendarItem.time.hasPrefix("Sun, "){
            cell?.time.text = calendarItem.time
            cell?.time.font = UIFont(name: "Helvetica-Bold", size: 20)
            cell?.time.textColor = themeTint
            cell?.backgroundColor = themeColor
            cell?.isUserInteractionEnabled = false
            cell?.calText.text = " "
            cell?.className.text = " "
        } else {
            cell?.className.text = calendarItem.className
            cell?.className.textColor = themeColor
            cell?.time.font = UIFont(name: "Helvetica", size: 18)
            cell?.isUserInteractionEnabled = true
            cell?.time.text = calendarItem.time
            cell?.time.textColor = UIColor.darkGray
            cell?.backgroundColor = UIColor.white
            cell?.calText.text = calendarItem.text
        }
        return (cell ?? nil)!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let urlString = self.calendar[indexPath.row].link
        if urlString != "none" {
            if let url = URL(string: urlString)
            {
                let safari = SFSafariViewController(url: url)
                safari.delegate = self as? SFSafariViewControllerDelegate
                present(safari, animated: true)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
}
