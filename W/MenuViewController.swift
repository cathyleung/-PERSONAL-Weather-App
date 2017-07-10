//
//  MenuViewController.swift
//  W
//
//  Created by Cathy Leung on 2017-05-18.
//  Copyright © 2017 Cathy Leung. All rights reserved.
//


import UIKit

class MenuViewController: UIViewController {
    
    // MARK: - VARIABLES
    var city: String = ""
    var isCelsius: Bool!
    
    @IBOutlet var settingButton: UIButton!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var inputTextField: UITextField!
    @IBOutlet var infoButton: UIButton!
    
    // MARK: - SETUP
    
    override func viewDidLoad() {
        submitButton.setTitle("OK", for: .normal)
        submitButton.setTitleColor(UIColor.white, for: .normal)
        
        inputTextField.setBottomBorder(borderColor: UIColor.white)
        
        settingButton.setTitle("\(Constant.deg)\(Constant.fahrenheit)", for: .normal)
        settingButton.setTitleColor(UIColor.white, for: .normal)
        infoButton.setTitle("Powered by Dark Sky", for: .normal)
        infoButton.setTitleColor(UIColor.white, for: .normal)
        
        let fillerView = UIView(frame: self.view.bounds)
        fillerView.backgroundColor = UIColor.black
        fillerView.alpha = 0.25
        
        self.view.addSubview(fillerView)
        self.view.sendSubview(toBack: fillerView)
        
        let image = #imageLiteral(resourceName: "BackgroundImage")
        let backgroundImage = UIImageView(frame: self.view.bounds)
        backgroundImage.image = image
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        
        self.view.addSubview(backgroundImage)
        self.view.sendSubview(toBack: backgroundImage)
        
        isCelsius = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        city = inputTextField.text!
        
        if let vc = (segue.destination as? ViewController) {
            vc.city = city
            vc.isCelsius = self.isCelsius
        }
    }
    
    private func setUpDisplay() {
        
    }
    
    // MARK: - FUNCTIONS
    // Changes view to weather ViewController
    @IBAction func getWeather(sender: AnyObject) {
        if (inputTextField.text?.isEmpty)! {
            Alert.Warning(delegate: self, message: "Please enter a location.")
            return
        } else {
            self.performSegue(withIdentifier: "segueFromMenuToView", sender: self)
        }
    }
    
    // Changes the temperature measure between Celsius and Fahrenheit
    @IBAction func changeTempMeasure(sender: AnyObject) {
        if isCelsius == false {
            isCelsius = true
            settingButton.setTitle("\(Constant.deg)\(Constant.celsius)", for: .normal)
        } else {
            isCelsius = false
            settingButton.setTitle("\(Constant.deg)\(Constant.fahrenheit)", for: .normal)
        }
        self.view.reloadInputViews()
    }
    
    // Opens the Darksky webpage
    @IBAction func sendURL(sender: AnyObject) {
        let link = URL(string: "https://darksky.net/poweredby/")
        UIApplication.shared.open(link!)
    }
}

// MARK: - EXTENSIONS
extension UITextField
{
    // Sets the border styling for the input UItextField
    func setBottomBorder(borderColor: UIColor)
    {
        self.borderStyle = UITextBorderStyle.none
        self.backgroundColor = UIColor.clear
        let width = 2.0
        
        let borderLine = UIView()
        borderLine.frame = CGRect(x: 0, y: Double(self.frame.height) - width, width: Double(self.frame.width), height: width)
        
        borderLine.backgroundColor = borderColor
        self.addSubview(borderLine)
    }
}
