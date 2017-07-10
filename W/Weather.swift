//
//  Weather.swift
//  W
//
//  Created by Cathy Leung on 2017-05-17.
//  Copyright © 2017 Cathy Leung. All rights reserved.
//

import Foundation

struct Weather {
    
    let latitude: Double
    let longitude: Double
    let temperature: Double
    let humidity: Double
    let temperatureMin: Double
    let temperatureMax: Double
    let icon: String
    let timeZone: String
    let time: Int
    var weeklyData: [[String: AnyObject]] = []
    
    init(data: [String: AnyObject]) {
        latitude = data["latitude"] as! Double
        longitude = data["longitude"] as! Double
        timeZone = data["timezone"] as! String
        
        let currentData = data["currently"] as! [String: AnyObject]
        temperature = currentData["temperature"] as! Double
        humidity = currentData["humidity"] as! Double
        icon = currentData["icon"] as! String
        time = currentData["time"] as! Int
    
        let dailyData = data["daily"] as! [String: AnyObject]?
        let dailyTempData = dailyData?["data"]![0] as! [String: AnyObject]
        temperatureMin = dailyTempData["temperatureMin"] as! Double
        temperatureMax = dailyTempData["temperatureMax"] as! Double
        
        let week = dailyData?["data"]! as! [[String: AnyObject]]
        print(week.count)
        for i in 0 ..< 7 {
            self.weeklyData.append([:])
            self.weeklyData[i]["temperatureMin"] = week[i]["temperatureMin"]
            self.weeklyData[i]["temperatureMax"] = week[i]["temperatureMax"]
            self.weeklyData[i]["icon"] = week[i]["icon"]
        }
    }
}
