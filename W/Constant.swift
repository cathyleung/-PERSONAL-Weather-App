//
//  Constant.swift
//  W
//
//  Created by Cathy Leung on 2017-05-21.
//  Copyright © 2017 Cathy Leung. All rights reserved.
//

import Foundation
import UIKit

struct Constant {
    
        static let deg = "\u{00B0}"
        static let fahrenheit = "F"
        static let celsius = "C"
        static let NumOfDaysInWeek = 7
}

public class Alert: NSObject {
    class func Warning(delegate: UIViewController, message: String) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        delegate.present(alert, animated: true, completion: nil)
    }
    
}
