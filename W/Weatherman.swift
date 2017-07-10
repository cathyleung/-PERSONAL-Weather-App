//
//  Weatherman.swift
//  W
//
//  Created by Cathy Leung on 2017-05-17.
//  Copyright © 2017 Cathy Leung. All rights reserved.
//

import Foundation

protocol WeathermanDelegate {
    func didGetWeather(weather: Weather)
    func didNotGetWeather(error: NSError)
}

class Weatherman {
    
    private let baseURL = "https://api.darksky.net/forecast/"
    private let APIkey = "71cb5322696e991c7414d1ce1d1b524b/"
    private var delegate: WeathermanDelegate
    var isCelsius = false;
    
    init(delegate: WeathermanDelegate) {
        self.delegate = delegate
    }
    
    func getWeather(lat: Double, lon: Double, isCelsius: Bool) {
        var param = ""
        if isCelsius == true {
            param = "?units=si"
        }
        
        let url = "\(baseURL)\(APIkey)\(lat),\(lon)\(param)"
        let weatherURL = URL(string: url)
        
        URLSession.shared.dataTask(with: weatherURL!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("Error: \((error! as NSError).description)")
                self.delegate.didNotGetWeather(error: error! as NSError)
            }else{
                if let data = data {
                    do {
                        let JSONData = try JSONSerialization.jsonObject(
                            with: data,
                            options: .mutableContainers) as! [String: AnyObject]
                        
                        let weather = Weather(data: JSONData)
                        self.delegate.didGetWeather(weather: weather)
                    }
                    catch let jsonError as NSError {
                    
                        print("Error: \(jsonError.description)")
                        self.delegate.didNotGetWeather(error: jsonError)
                    }
                    
                    // Print raw weather data
                    //print(String(data: data, encoding: String.Encoding.utf8)!)
                }
            }
        }).resume()
    }
}
