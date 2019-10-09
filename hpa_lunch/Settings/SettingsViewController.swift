//
//  SettingsViewController.swift
//  hpa_lunch
//
//  Created by Morgan Dean on 12/4/18.
//  Copyright © 2018 Morgan Dean. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    struct Setting {
        var name: String
        var storyboardId: String
    }

    var themeColor = UIColor(red: 0.75, green: 0.10, blue: 0.25, alpha: 1.0)
    var themeTint = UIColor.white
    
    var displaySettings = [Setting]()
    var userSettings = [Setting]()
    var otherSettings = [Setting]()

    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //todo: load themecolor from userdefaults
        themeColor = UserDefaults.standard.colorForKey("primaryColor") ?? UIColor(red: 0.75, green: 0.10, blue: 0.25, alpha: 1.0)
        //todo: load themeting from userdefaults
        themeTint = UserDefaults.standard.colorForKey("secondaryColor") ?? UIColor.white
        
        table.delegate = self
        table.dataSource = self
        
        displaySettings += [Setting(name: "Course Settings", storyboardId: "CourseSettings"), Setting(name: "Color Settings", storyboardId: "ColorSettings")]
        userSettings += [Setting(name: "Personal Info", storyboardId: "PersonalSettings"),Setting(name: "Notifications", storyboardId: "NotificationSettings")]
        otherSettings += [Setting(name: "About", storyboardId: "AboutSettings"), Setting(name: "Reset Everything", storyboardId: "Reset")]
        
        self.table.reloadData()
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            return displaySettings.count
        case 1:
            return userSettings.count
        default:
            return otherSettings.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SettingCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SettingCell
        switch (indexPath.section) {
            case 0:
            //Access itemsA[indexPath.row]
                let setting = displaySettings[indexPath.row]
                cell?.settingName.text = setting.name
                if indexPath.row == 0 {
                    cell?.imageView?.image = UIImage(named: "book")
                } else {
                    cell?.imageView?.image = UIImage(named: "color")
                }

            case 1:
                let setting = userSettings[indexPath.row]
                cell?.settingName.text = setting.name
                if indexPath.row == 0 {
                    cell?.imageView?.image = UIImage(named: "user")
                } else {
                    cell?.imageView?.image = UIImage(named: "notif")
                }
            default:
                let setting = otherSettings[indexPath.row]
                cell?.settingName.text = setting.name
                if indexPath.row == 0 {
                    cell?.imageView?.image = UIImage(named: "info")
                } else {
                    cell?.imageView?.image = UIImage(named: "trash")
                    cell?.accessoryType = .none
                }

        }
        let itemSize = CGSize.init(width: 25, height: 25)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
        let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
        cell?.imageView?.image!.draw(in: imageRect)
        cell?.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
        cell?.imageView?.tintColor = UIColor(red: 0.6863, green: 0.1765, blue: 0.251, alpha: 1.0)
        UIGraphicsEndImageContext();
        
        return (cell ?? nil)!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch (indexPath.section) {
        case 0:
            //Access itemsA[indexPath.row]
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: self.displaySettings[indexPath.row].storyboardId)
            self.navigationController!.pushViewController(viewController, animated: true)
        case 1:
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: self.userSettings[indexPath.row].storyboardId)
            self.navigationController!.pushViewController(viewController, animated: true)
        default:
            if indexPath.row == 0 {
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: self.otherSettings[indexPath.row].storyboardId)
            self.navigationController!.pushViewController(viewController, animated: true)
            } else {
                //todo: reset all settings
                let alert = UIAlertController(title: "Are you sure?", message: "Resetting all your settings will delete them for forever. (A very long time)", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
                    UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                    UserDefaults.standard.synchronize()
                    self.view.makeToast("Reset all Settings.")
                }))

                
                self.present(alert, animated: true)

            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Display"
        } else if section == 1 {
            return "User"
        } else {
            return "Miscellaneous"
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
}
