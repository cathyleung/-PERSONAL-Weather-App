//
//  WeatherIcons.swift
//  W
//
//  Created by Cathy Leung on 2017-05-21.
//  Copyright © 2017 Cathy Leung. All rights reserved.
//

import Foundation
import UIKit
import CoreText

public final class /* struct */ DispatchOnce {
    private var lock = os_unfair_lock()
    private var isInitialized = false
    public /* mutating */ func perform(block: (Void) -> Void) {
        os_unfair_lock_lock(&lock)
        if !isInitialized {
            block()
            isInitialized = true
        }
        os_unfair_lock_unlock(&lock)
    }
}

// MARK: - Public
/// A FontWeather extension to UIFont.
public extension UIFont {
    
    /// Get a UIFont object of FontWeather.
    ///
    /// - parameter fontSize: The preferred font size.
    /// - returns: A UIFont object of FontWeather.
    public class func fontWeatherOfSize(fontSize: CGFloat) -> UIFont {
        
        let token = DispatchOnce()
        
        
        let name = "FontWeather"
        if UIFont.fontNames(forFamilyName: name).isEmpty {
            token.perform {
                FontLoader.loadFont(name: name)
            }
        }
        
        let fontName = "Weather Icons"
        return UIFont(name: fontName, size: fontSize)!
    }
}

/// A FontWeather extension to String.
public extension String {
    
    /// Get a FontWeather icon string with the given icon name.
    ///
    /// - parameter name: The preferred icon name.
    /// - returns: A string that will appear as icon with FontWeather.
    public static func fontWeatherIconWithName(name: fontWeather) -> String {
        return name.rawValue.substringToIndex(name.rawValue.startIndex.advancedBy(1))
    }
    
    /// Get a FontWeather icon string with the given CSS icon code. Icon code can be found here: http://fontWeather.io/icons/
    ///
    /// - parameter code: The preferred icon name.
    /// - returns: A string that will appear as icon with FontWeather.
    public static func fontWeatherIconWithCode(code: String) -> String? {
        guard let raw = FontWeatherIcons[code], let icon = FontWeather(rawValue: raw) else {
            return nil
        }
        
        return self.fontWeatherIconWithName(icon)
    }
}

/// A FontWeather extension to UIImage.
public extension UIImage {
    
    /// Get a FontWeather image with the given icon name, text color, size and an optional background color.
    ///
    /// - parameter name: The preferred icon name.
    /// - parameter textColor: The text color.
    /// - parameter size: The image size.
    /// - parameter backgroundColor: The background color (optional).
    /// - returns: A string that will appear as icon with FontWeather
    public static func fontWeatherIconWithName(name: FontWeather, textColor: UIColor, size: CGSize, backgroundColor: UIColor = UIColor.clear) -> UIImage {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.center
        
        // Taken from FontWeather.io's Fixed Width Icon CSS
        let fontAspectRatio: CGFloat = 1.28571429
        
        let fontSize = min(size.width / fontAspectRatio, size.height)
        let attributedString = NSAttributedString(string: String.fontWeatherIconWithName(name), attributes: [NSFontAttributeName: UIFont.fontWeatherOfSize(fontSize), NSForegroundColorAttributeName: textColor, NSBackgroundColorAttributeName: backgroundColor, NSParagraphStyleAttributeName: paragraph])
        UIGraphicsBeginImageContextWithOptions(size, false , 0.0)
        attributedString.drawInRect(CGRectMake(0, (size.height - fontSize) / 2, size.width, fontSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: - Private
private class FontLoader {
    class func loadFont(name: String) {
        let bundle = Bundle(for: FontLoader.self)
        var fontURL = NSURL()
        let identifier = bundle.bundleIdentifier
        
        if identifier?.hasPrefix("org.cocoapods") == true {
            // If this framework is added using CocoaPods, resources is placed under a subdirectory
            fontURL = bundle.url(forResource: name, withExtension: "ttf", subdirectory: "FontWeather.swift.bundle")! as NSURL
        } else {
            fontURL = bundle.url(forResource: name, withExtension: "ttf")! as NSURL
        }
        
        let data = NSData(contentsOfURL: fontURL as URL)!
        
        let provider = CGDataProviderCreateWithCFData(data)
        let font = CGFontCreateWithDataProvider(provider)!
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            let errorDescription: CFString = CFErrorCopyDescription(error!.takeUnretainedValue())
            let nsError = error!.takeUnretainedValue() as AnyObject as! NSError
            NSException(name: NSExceptionName.internalInconsistencyException, reason: errorDescription as String, userInfo: [NSUnderlyingErrorKey: nsError]).raise()
        }
    }
}
