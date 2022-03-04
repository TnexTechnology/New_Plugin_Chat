//
//  Int+Extension.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 02/03/2022.
//

import UIKit

public extension Int {
    
    func formatString(separator: String = ".") -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = separator
        return formatter.string(from: NSNumber(value:self))
    }
    
    func toCurrencyString() -> String {
        let number = NSNumber(value: self)
        return NumberFormatter.localizedString(from: number, number: .decimal).replacingOccurrences(of: ",", with: ".")
    }

    func toTimeString(dateFormat: String = "dd/MM/yyyy HH:mm") -> String {
        if self == 0 {
            return ""
        }

        let date = Date(timeIntervalSince1970: TimeInterval(exactly: self) ?? 0.0)
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: date)
    }

    func toViewsCount(forLivestream: Bool = false) -> String {
        if forLivestream && self <= 1 {
            return "--"
        }
        let num = abs(Double(self))
        let sign = (self < 0) ? "-" : ""
        var countString: String = ""

        switch num {

        case 1_000_000_000...:
            var formatted = num / 1_000_000_000
            formatted = formatted.truncate(places: 1)
            countString = "\(sign)\(formatted)B"

        case 1_000_000...:
            var formatted = num / 1_000_000
            formatted = formatted.truncate(places: 1)
            countString = "\(sign)\(formatted)M"

        case 1_000...:
            var formatted = num / 1_000
            formatted = formatted.truncate(places: 1)
            countString = "\(sign)\(formatted)K"

        case 0...:
            countString = "\(self)"

        default:
            countString = "\(sign)\(self)"

        }

        countString = countString.replacingOccurrences(of: ".", with: ",")
        return countString.replacingOccurrences(of: ",0", with: "")
    }
    
    func toTimeActive() -> String {
        if self < 60 {
            return "\(self) giây trước"
        }
        if self < 60*60 {
            return  "\(self/60) phút trước"
        }
        return "\(self/3600) giờ trước"
    }
    
    func timeString() -> String {
        let hour = self / 3600
        let min = (self - hour * 3600) / 60
        let sec: Int = self % 60
        if hour > 0 {
            return String(format: "%02d:%02d:%02d", hour, min, sec)
        }
        return String(format: "%02d:%02d", min, sec)
    }
}

public extension Double {
    
    func shortStyle(number: Int) -> String {
        return String(format: "%.\(number)f", self)
    }

    func shortStyle() -> String {
        return String(format: "%.\(0)f", self)
    }
    
    func toCurrencyString() -> String {
        let number = NSNumber(value: self)
        return NumberFormatter.localizedString(from: number, number: .decimal).replacingOccurrences(of: ",", with: ".")
    }
    
    func truncate(places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        let newDecimal = multiplier * self // move the decimal right
        let diff = newDecimal - Double(Int(newDecimal))
        let truncated = diff < 0.5 ? floor(newDecimal) : ceil(newDecimal) // drop the fraction
        let originalDecimal = truncated / multiplier // move the decimal back
        return originalDecimal
    }
    
    func currencyString() -> String {
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        number = NSNumber(value: self)
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        return (formatter.string(from: number) ?? "").replacingOccurrences(of: ",", with: ".")
    }
}
