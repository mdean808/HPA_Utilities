//
//  MenusViewController.swift
//  hpa_lunch
//
//  Created by Morgan Dean on 11/30/18.
//  Copyright © 2018 Morgan Dean. All rights reserved.
//

import UIKit
import Alamofire
import CRRefresh

class MealsViewController: UIViewController {
    // Menu views
    @IBOutlet weak var breakfastView: UIView!
    @IBOutlet weak var lunchView: UIView!
    @IBOutlet weak var dinnerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Menu text
    @IBOutlet weak var breakfastText: UILabel!
    @IBOutlet weak var lunchText: UILabel!
    @IBOutlet weak var dinnerText: UILabel!
    
    // Activity Indicators
    @IBOutlet weak var breakfastActivity: UIActivityIndicatorView!
    @IBOutlet weak var lunchActivity: UIActivityIndicatorView!
    @IBOutlet weak var dinnerActivity: UIActivityIndicatorView!
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    // Variables
    let email = UserDefaults.standard.string(forKey: "emailSetting")
    let name = UserDefaults.standard.string(forKey: "nameSetting")
    var themeColor = UIColor(red: 0.75, green: 0.10, blue: 0.25, alpha: 1.0)
    var themeTint = UIColor.white

    override func viewDidLoad() {
        super.viewDidLoad()
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "HelveticaNeue", size: 18)!], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "HelveticaNeue", size: 18)!], for: UIControl.State.highlighted)
        UIBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "HelveticaNeue", size: 18)!], for: .normal)
        UIBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "HelveticaNeue", size: 18)!], for: UIControl.State.highlighted)
        
        let closeButton = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(loadSchedule))
        closeButton.tintColor = themeTint
        navigationItem.rightBarButtonItem = closeButton
        updateMealViews()
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
        
        let email = UserDefaults.standard.object(forKey: "emailSetting")

        if email == nil {
            // todo: show popup asking for info
            let alertController = UIAlertController(title: "Sharing", message: "We will use this information to better our product, and occasionally send you emails.", preferredStyle: UIAlertController.Style.alert)
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "First Name"
            }
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Email"
            }
            let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
                let firstTextField = alertController.textFields![0] as UITextField
                let secondTextField = alertController.textFields![1] as UITextField
                UserDefaults.standard.set(firstTextField.text, forKey: "nameSetting")
                UserDefaults.standard.set(secondTextField.text, forKey: "emailSetting")
            })
            let cancelAction = UIAlertAction(title: "Opt-Out", style: UIAlertAction.Style.default, handler: {
                (action : UIAlertAction!) -> Void in })
            
            alertController.addAction(cancelAction)
            alertController.addAction(saveAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        scrollView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            /// start refresh
            /// Do anything you want...
            self?.updateMealViews()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                /// Stop refresh when your job finished, it will reset refresh footer if completion is true
                self?.scrollView.cr.endHeaderRefresh()
            })
        }
    }
    
    func updateMealViews() {
        lunchView.layer.addBorder(edge: .bottom, color: UIColor.lightGray, thickness: 1)
        breakfastView.layer.addBorder(edge: .bottom, color: UIColor.lightGray, thickness: 1)
        dinnerView.layer.addBorder(edge: .bottom, color: UIColor.lightGray, thickness: 1)
        /*lunchText.text = "";
        breakfastText.text = "";
        dinnerText.text = "";
        breakfastActivity.startAnimating()
        lunchActivity.startAnimating()
        dinnerActivity.startAnimating()
        */
        loadBreakfast()
        loadLunch()
        loadDinner()
        scrollView.cr.endHeaderRefresh()
    }
    func loadBreakfast() {
        let url = "https://lunch.mogdan.xyz/api/breakfast?name=\(name ?? "null")&email=\(email ?? "null")"
        Alamofire.request(url).responseJSON { response in
            var json:Dictionary = ["text": "null"]
            json = (response.result.value as? Dictionary) ?? ["err": "error: \(response.result.value ?? "Unknown Error")"]
            self.breakfastActivity.stopAnimating()
            if (json["err"] != nil) && json["err"]?.hasPrefix("error:") ?? false {
                self.breakfastText.text = "Check your internet connection."
            } else {
                self.breakfastText.text = json["text"]
            }
        }
    }
    func loadLunch() {
        let url = "https://lunch.mogdan.xyz/api/lunch?name=\(name ?? "null")&email=\(email ?? "null")"
        Alamofire.request(url).responseJSON { response in
            var json:Dictionary = ["text": "null"]
            json = (response.result.value as? Dictionary) ?? ["err": "error: \(response.result.value ?? "Unknown Error")"]
            self.lunchActivity.stopAnimating()
            if (json["err"] != nil) && json["err"]?.hasPrefix("error:") ?? false {
                self.lunchText.text = "Check your internet connection."
            } else {
                self.lunchText.text = json["text"]
            }
        }
    }
    func loadDinner() {
        let url = "https://lunch.mogdan.xyz/api/dinner?name=\(name ?? "null")&email=\(email ?? "null")"
        Alamofire.request(url).responseJSON { response in
            var json:Dictionary = ["text": "null"]
            json = (response.result.value as? Dictionary) ?? ["err": "error: \(response.result.value ?? "Unknown Error")"]
            self.dinnerActivity.stopAnimating()
            if (json["err"] != nil) && json["err"]?.hasPrefix("error:") ?? false {
                self.dinnerText.text = "Check your internet connection."
            } else {
                self.dinnerText.text = json["text"]
            }
        }
    }
    @objc func loadSchedule() {
        self.navigationController!.pushViewController(self.storyboard!.instantiateViewController(withIdentifier: "Schedule") as! ScheduleViewController, animated: true)

    }
}

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width+55, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        addSublayer(border)
    }
}
