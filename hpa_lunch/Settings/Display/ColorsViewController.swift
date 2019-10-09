//
//  ColorsViewController.swift
//  hpa_lunch
//
//  Created by Morgan Dean on 12/4/18.
//  Copyright © 2018 Morgan Dean. All rights reserved.
//

import UIKit
import ColorSlider
import Toast_Swift

class ColorsViewController: UIViewController {

    let primaryColorPicker = ColorSlider(orientation: .horizontal, previewSide: .bottom)
    let secondaryColorPicker = ColorSlider(orientation: .horizontal, previewSide: .bottom)
    
    
    @IBOutlet weak var secondaryCP: UIView!
    @IBOutlet weak var primaryCP: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let resetButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetColors))
        self.navigationItem.rightBarButtonItem = resetButton
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        primaryColorPicker.frame = CGRect(x: 0, y: 50, width: primaryCP.frame.size.width, height: 20)
        primaryColorPicker.addTarget(self, action: #selector(primaryChangedColor(slider:)), for: .valueChanged)

        primaryCP.addSubview(primaryColorPicker)
        
        secondaryColorPicker.frame = CGRect(x: 0, y: 50, width: secondaryCP.frame.size.width, height: 20)
        secondaryColorPicker.addTarget(self, action: #selector(secondaryChangedColor(slider:)), for: .valueChanged)

        secondaryCP.addSubview(secondaryColorPicker)

    }
    
    @IBAction func confirmPrimary(_ sender: UIButton) {
        print(primaryColorPicker.color)
        //todo: store color in userdefaults
        UserDefaults.standard.setColor(primaryColorPicker.color, forKey: "primaryColor")
        self.view.makeToast("Set primary color.")

    }
    @IBAction func confirmSecondary(_ sender: UIButton) {
        print(secondaryColorPicker.color)
        //todo: store color in userdefaults
        UserDefaults.standard.setColor(secondaryColorPicker.color, forKey: "secondaryColor")
        self.view.makeToast("Set secondary color.")

    }
    
    @objc func primaryChangedColor(slider: ColorSlider) {
        self.navigationController?.navigationBar.barTintColor = slider.color
        self.navigationController?.navigationBar.backgroundColor = slider.color
        self.tabBarController?.tabBar.tintColor = slider.color

    }
    
    @objc func secondaryChangedColor(slider: ColorSlider) {
        self.navigationController?.navigationBar.tintColor = slider.color
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : slider.color]
    }
    
    @objc func resetColors() {
        UserDefaults.standard.removeObject(forKey: "primaryColor")
        UserDefaults.standard.removeObject(forKey: "secondaryColor")
        primaryColorPicker.color = UIColor(red: 0.75, green: 0.10, blue: 0.25, alpha: 1.0)
        secondaryColorPicker.color = UIColor.white
        self.tabBarController?.tabBar.tintColor = UIColor(red: 0.75, green: 0.10, blue: 0.25, alpha: 1.0)
        self.view.makeToast("Reset colors to defaults.")
    }
}
