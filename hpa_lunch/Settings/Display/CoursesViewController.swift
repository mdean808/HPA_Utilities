//
//  SettingsViewController.swift
//  Alamofire
//
//  Created by Morgan Dean on 11/19/18.
//

import UIKit
import Toast_Swift

class CoursesViewController: UIViewController {
    var courses = [
        "",
        "",
        "",
        "",
        "",
        "",
         ""
    ]
    var email = ""
    var name = ""
    
    @IBOutlet weak var courseA: UITextField!
    @IBOutlet weak var courseB: UITextField!
    @IBOutlet weak var courseC: UITextField!
    @IBOutlet weak var courseD: UITextField!
    @IBOutlet weak var courseE: UITextField!
    @IBOutlet weak var courseF: UITextField!
    @IBOutlet weak var courseG: UITextField!


    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        let resetButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetEverything))
        resetButton.tintColor = UIColor.white
        navigationBar.rightBarButtonItem = resetButton
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        courseA.addTarget(self, action: #selector(saveUserData), for: UIControl.Event.editingChanged)
        courseB.addTarget(self, action: #selector(saveUserData), for: UIControl.Event.editingChanged)
        courseC.addTarget(self, action: #selector(saveUserData), for: UIControl.Event.editingChanged)
        courseD.addTarget(self, action: #selector(saveUserData), for: UIControl.Event.editingChanged)
        courseE.addTarget(self, action: #selector(saveUserData), for: UIControl.Event.editingChanged)
        courseF.addTarget(self, action: #selector(saveUserData), for: UIControl.Event.editingChanged)
        courseG.addTarget(self, action: #selector(saveUserData), for: UIControl.Event.editingChanged)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneButtonClicked))
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        courseA.inputAccessoryView = toolbar
        courseB.inputAccessoryView = toolbar
        courseC.inputAccessoryView = toolbar
        courseD.inputAccessoryView = toolbar
        courseE.inputAccessoryView = toolbar
        courseF.inputAccessoryView = toolbar
        courseG.inputAccessoryView = toolbar

        loadUserData()
    }
    
    @objc func doneButtonClicked() {
        view.endEditing(true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotifications()
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
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
    
    @objc func resetEverything() {
        UserDefaults.standard.removeObject(forKey: "courseAlias")
        loadUserData()
        self.view.makeToast("Reset Course Settings.")
    }
    
    func loadUserData() {
        courses = UserDefaults.standard.array(forKey: "courseAlias") as? [String] ?? courses
        courseA.text = courses[0]
        courseB.text = courses[1]
        courseC.text = courses[2]
        courseD.text = courses[3]
        courseE.text = courses[4]
        courseF.text = courses[5]
        courseG.text = courses[6]
    }
    
    @objc func saveUserData() {
        courses[0] = courseA.text ?? "Course A"
        courses[1] = courseB.text ?? "Course B"
        courses[2] = courseC.text ?? "Course C"
        courses[3] = courseD.text ?? "Course D"
        courses[4] = courseE.text ?? "Course E"
        courses[5] = courseF.text ?? "Course F"
        courses[6] = courseG.text ?? "Course G"
        
        
        UserDefaults.standard.set(courses, forKey: "courseAlias")
    
    }

}
