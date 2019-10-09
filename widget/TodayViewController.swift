//
//  TodayViewController.swift
//  widget
//
//  Created by Morgan Dean on 11/1/18.
//  Copyright © 2018 Morgan Dean. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire

class TodayViewController: UIViewController, NCWidgetProviding {
    var cachedBreakText = ""
    @IBOutlet weak var dinnerActivity: UIActivityIndicatorView!
    @IBOutlet weak var lunchActivity: UIActivityIndicatorView!
    @IBOutlet weak var breakActivity: UIActivityIndicatorView!
    
    @IBOutlet weak var lunchText: UITextView!
    @IBOutlet weak var dinnerText: UITextView!
    @IBOutlet weak var breakText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        breakText.text = "Please Expand the Widget."
        lunchText.text = UserDefaults.standard.string(forKey: "lunch")
        dinnerText.text = UserDefaults.standard.string(forKey: "dinner")
        setMeals()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded

    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
        preferredContentSize = expanded ? CGSize(width: maxSize.width, height: 437) : maxSize
        if (activeDisplayMode == .expanded) {
            dinnerText.isHidden = false
            breakText.isHidden = false
            cachedBreakText = UserDefaults.standard.string(forKey: "breakfast") ?? "Could not find the Breakfast."
            breakText.text = cachedBreakText
        } else {
            dinnerText.isHidden = true
            breakText.text = "Please Expand the Widget."
            dinnerActivity.isHidden = true
        }
    }

    func setMeals() {
        var url = "https://lunch.mogdan.xyz/api/lunch"
        Alamofire.request(url).responseJSON { response in
            var json:Dictionary = ["text": "null"]
            json = (response.result.value as? Dictionary) ?? ["err": "error: \(response.result.value ?? "Unknown Error")"]
            self.lunchActivity.stopAnimating()
            if json["err"] != nil && (json["err"]?.hasPrefix("error:") ?? false) {
                //self.lunchText.text = "Check your internet connection."
                //UserDefaults.standard.set("Check your internet connection.", forKey: "lunch")
            } else {
                self.lunchText.text = json["text"]
                UserDefaults.standard.set(json["text"], forKey: "lunch")
            }

        }
        url = "https://lunch.mogdan.xyz/api/dinner"
        Alamofire.request(url).responseJSON { response in
            var json:Dictionary = ["text": "null"]
            json = (response.result.value as? Dictionary) ?? ["err": "error: \(response.result.value ?? "Unknown Error")"]
            self.dinnerActivity.stopAnimating()
            print(json)
            if json["err"] != nil && (json["err"]?.hasPrefix("error:") ?? false) {
                //self.dinnerText.text = "Check your internet connection."
                //UserDefaults.standard.set("Check your internet connection.", forKey: "dinner")
            } else {
                self.dinnerText.text = json["text"]
                UserDefaults.standard.set(json["text"], forKey: "dinner")
            }
        }
        url = "https://lunch.mogdan.xyz/api/breakfast"
        Alamofire.request(url).responseJSON { response in
            var json:Dictionary = ["text": "null"]
            json = (response.result.value as? Dictionary) ?? ["err": "error: \(response.result.value ?? "Unknown Error")"]
            self.dinnerActivity.stopAnimating()
            if json["err"] != nil && (json["err"]?.hasPrefix("error:") ?? false) {
                //self.breakText.text = "Check your internet connection."
                //UserDefaults.standard.set("Check your internet connection.", forKey: "break")
                if self.breakText.text == "Please Expand the Widget." {
                    self.cachedBreakText = json["text"] ?? "Could not find the Breakfast."
                    let text = json["text"]
                    UserDefaults.standard.set(text, forKey: "breakfast")
                }
            } else {
                self.breakText.text = json["text"]
                let text = json["text"]
                UserDefaults.standard.set(text, forKey: "breakfast")
            }
        }
    }
}
