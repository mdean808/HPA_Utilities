//
//  UserSettingsViewController.swift
//  hpa_lunch
//
//  Created by Morgan Dean on 12/5/18.
//  Copyright © 2018 Morgan Dean. All rights reserved.
//

import UIKit

class PersonalSettingsView: UIViewController {

    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!

    var name = ""
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let resetButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetInfo))
        self.navigationItem.rightBarButtonItem = resetButton
        
        emailInput.addTarget(self, action: #selector(saveUserData), for: UIControl.Event.editingChanged)
        nameInput.addTarget(self, action: #selector(saveUserData), for: UIControl.Event.editingChanged)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneButtonClicked))
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        nameInput.inputAccessoryView = toolbar
        emailInput.inputAccessoryView = toolbar
        
        loadUserData()
        
        // Do any additional setup after loading the view.
    }
    
    func loadUserData() {
        email = UserDefaults.standard.string(forKey: "emailSetting") ?? ""
        name = UserDefaults.standard.string(forKey: "nameSetting") ?? ""
        
        nameInput.text = name
        emailInput.text = email
    }

    @objc func resetInfo() {
        UserDefaults.standard.removeObject(forKey: "emailSetting")
        UserDefaults.standard.removeObject(forKey: "nameSetting")
        loadUserData()
        self.view.makeToast("Reset Course Settings.")
    }
    
    @objc func saveUserData() {
        name = nameInput.text ?? ""
        email = emailInput.text ?? ""
        
        UserDefaults.standard.set(email, forKey: "emailSetting")
        UserDefaults.standard.set(name, forKey: "nameSetting")
    }
    
    @objc func doneButtonClicked() {
        view.endEditing(true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterNotifications()
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        scrollView.contentInset.bottom = 0
    }
}
