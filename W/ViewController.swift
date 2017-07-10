//
//  ViewController.swift
//  W
//
//  Created by Cathy Leung on 2017-05-17.
//  Copyright © 2017 Cathy Leung. All rights reserved.
//


import UIKit
import CoreLocation

class ViewController: UIViewController, WeathermanDelegate, CoordinateFinderDelegate, UITableViewDataSource {
    
    // MARK: - VARIABLES 
    
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var minMaxTempLabel: UILabel!
    @IBOutlet var unitLabel: UILabel!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var unitButton: UIButton!
    @IBOutlet var timeRangeButton: UIButton!
    @IBOutlet var weatherTable: UITableView!
    @IBOutlet var weekDayLabel: UILabel!
    
    var weatherman: Weatherman!
    var coordinateFinder: CoordinateFinder!
    var iconImg: SKYIconView!
    
    var city: String!
    var icon: String!
    var isCelsius: Bool!
    var minTemp: Double!
    var maxTemp: Double!
    var temp: Double!
    var weeklyData: [[String: AnyObject]] = []
    var dataLoaded: Bool!
    var weekly: Bool!
    var today: Int!
    var date: Date!

    // MARK: - SETUP
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataLoaded = false;
        setUpDisplay()
        
        weatherman = Weatherman(delegate: self)
        coordinateFinder = CoordinateFinder(delegate: self)
        coordinateFinder.getCoordinates(city: city)
        
        weatherTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        weatherTable.tableFooterView = UIView(frame: .zero)
        
        weekly = false
        weatherTable.isHidden = true
        
        timeRangeButton.setTitle("1 Day", for: .normal)
        backButton.setTitle("<", for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    private func setUpDisplay() {
        cityLabel.adjustsFontSizeToFitWidth = true
        
        unitLabel.textColor = UIColor.white
        cityLabel.textColor = UIColor.white
        tempLabel.textColor = UIColor.white
        minMaxTempLabel.textColor = UIColor.white
        self.view.backgroundColor = UIColor.black
        
        cityLabel.text = "--"
        tempLabel.text = "--" + Constant.deg
        minMaxTempLabel.text = "--" + Constant.deg + " / --" + Constant.deg
        
        if isCelsius == false {
            unitLabel.text = "\(Constant.fahrenheit)"
        } else {
            unitLabel.text = "\(Constant.celsius)"
        }
        
        let fillerView = UIView(frame: self.view.bounds)
        fillerView.backgroundColor = UIColor.black
        fillerView.alpha = 0.25
        
        self.view.addSubview(fillerView)
        self.view.sendSubview(toBack: fillerView)
        /*
         let image = #imageLiteral(resourceName: "BackgroundImage")
         let backgroundImage = UIImageView(frame: self.view.bounds)
         backgroundImage.image = image
         backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
         
         self.view.addSubview(backgroundImage)
         self.view.sendSubview(toBack: backgroundImage)
         */
    }


    // MARK: - DELEGATE FUNCTIONS
    
    internal func didGetWeather(weather: Weather) {
        DispatchQueue.main.async() {
            self.temp = weather.temperature
            self.tempLabel.text = String(Int(self.temp.rounded())) + Constant.deg
            
            self.minTemp = weather.temperatureMin
            self.maxTemp = weather.temperatureMax
            self.minMaxTempLabel.text = String(Int(self.minTemp.rounded())) + Constant.deg + " / " + String(Int(self.maxTemp.rounded())) + Constant.deg
            
            self.icon = weather.icon
            self.iconImg = self.setSkycon(iconType: self.icon)
            self.view.addSubview(self.iconImg)
            self.iconImg.pause()
            
            let img = UIImage(named: weather.icon + ".jpg")
            let background = UIImageView(frame: self.view.bounds)
            background.image = img
            background.contentMode = UIViewContentMode.scaleAspectFill
            self.view.addSubview(background)
            self.view.sendSubview(toBack: background)
            
            self.weeklyData = weather.weeklyData
            self.getDate(IANA: weather.time, zone: weather.timeZone)
            
            self.dataLoaded = true;
            self.weatherTable.reloadData()
            
            self.testResults()
        }
    }
    
    internal func didNotGetWeather(error: NSError) {
        Alert.Warning(delegate: self, message: String(error.description))
    }
    
    internal func didGetCoordinate(coordinate: CLLocationCoordinate2D, location: String) {
        DispatchQueue.main.async() {
            self.weatherman.getWeather(lat: coordinate.latitude, lon: coordinate.longitude, isCelsius: self.isCelsius)
            self.city = location
            self.cityLabel.text = self.city
        }
    }
    
    internal func didNotGetCoordinate(error: NSError) {
        Alert.Warning(delegate: self, message: String(error.description))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constant.NumOfDaysInWeek
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = weatherTable.dequeueReusableCell(withIdentifier: "cell")!
        
        if self.dataLoaded == true {
            let day = self.weeklyData[indexPath.row]
            let tempMin = Int(Double(day["temperatureMin"]! as! NSNumber).rounded())
            let tempMax = Int(Double(day["temperatureMax"]! as! NSNumber).rounded())
            let weekday = day["weekday"] as! String
            
            cell.textLabel?.text = "\(weekday)  \(tempMin)\(Constant.deg) / \(tempMax)\(Constant.deg)"
            if indexPath.row == 0 {
                cell.textLabel?.text!.append(" Today")
                cell.contentView.backgroundColor = UIColor(white: 1, alpha: 0.1)
            }
            
            let weatherIcon = setSkycon(iconType: day["icon"] as! String)
            cell.imageView?.image = UIImage(view: weatherIcon)
        } else {
            cell.textLabel?.text = ""
        }
        
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    // MARK: - FUNCTIONS
    
    // Sets the day, changing from numerical data to Mon...Sun
    private func getDate(IANA: Int, zone: String) {
        let timeZone = NSTimeZone(name: zone)
        let time = IANA + (timeZone?.secondsFromGMT)!
        let date = NSDate(timeIntervalSince1970: TimeInterval(time))
        self.date = date as Date!
        
        let calendar = NSCalendar(identifier: .gregorian)
        let components = calendar?.components(.weekday, from: date as Date)
        today = (components?.weekday!)! - 1
        //self.weekDayLabel.text = calendar?.weekdaySymbols[today]
        
        var day: Int = today
        for i in 0...6 {
            if day == 7 {
                day = 0
            }
            weeklyData[i]["weekday"] = calendar?.weekdaySymbols[day] as AnyObject
            day += 1
        }
    }
    
    // Sets weather icon image for day
    private func setSkycon(iconType: String) -> SKYIconView {
        let sky = SKYIconView(frame: CGRect(x: self.view.bounds.midX / 2, y: self.cityLabel.frame.maxY + 20, width: self.view.bounds.midX, height: self.view.bounds.midX))
        
        switch iconType {
            case "clear-day": sky.setType = .clearDay
            case "clear-night": sky.setType = .clearNight
            case "partly-cloudy-day": sky.setType = .partlyCloudyDay
            case "partly-cloudy-night": sky.setType = .partlyCloudyNight
            case "cloudy": sky.setType = .cloudy
            case "rain": sky.setType = .rain
            case "sleet": sky.setType = .sleet
            case "snow": sky.setType = .snow
            case "wind": sky.setType = .wind
            case "fog": sky.setType = .fog
            default: print("Error with setting skycon")
        }
    
        sky.setColor = UIColor.white
        sky.backgroundColor = UIColor.clear
        sky.pause()
        return sky
    }
    
    // changes view between 1-day and 7-day
    @IBAction func changeRange(sender: AnyObject) {
        if self.weekly == false {
            weekly = true
            self.iconImg.removeFromSuperview()
            self.weatherTable.isHidden = false
            timeRangeButton.setTitle("7 day", for: .normal)
            
        } else {
            weekly = false
            self.iconImg = setSkycon(iconType: icon)
            self.view.addSubview(self.iconImg)
            self.weatherTable.isHidden = true
            timeRangeButton.setTitle("1 day", for: .normal)
        }
        
        self.view.reloadInputViews()
    }
    
    // MARK: - TESTING FUNCTIONS
    // prints data results to console
    func testResults() {
        print("///// TESTING... /////")
        print("Temperature: " + String(self.temp))
        print("Min/Max Temperature: " + String(self.minTemp) + "/" + String(self.maxTemp))
        print("Icon: " + self.icon)
        print("Day of the week: " + String(self.today))
        print("Weekly Data \(self.weeklyData)")
        print("//////////////////////")
    }
}

// MARK: - EXTENSIONS

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
}


