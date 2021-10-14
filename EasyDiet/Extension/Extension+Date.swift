//
//  Extension+Date.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/08/27.
//

import Foundation


extension Date {
    var year: Int {
        let cal = Calendar.current
        return cal.component(.year, from: self)
    }
    
    var month: Int {
        let cal = Calendar.current
        return cal.component(.month, from: self)
    }
    
    var day: Int {
        let cal = Calendar.current
        return cal.component(.day, from: self)
    }
    
    var hour: Int {
        let cal = Calendar.current
        return cal.component(.hour, from: self)
    }
    
    var dateCalendarTitleFormatter: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        formatter.locale = Locale(identifier: "ko_kr")
        return formatter.string(from: self)
    }
    
    var removeZeroDateFormatter: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ko_kr")
        return formatter.string(from: self)
    }
    
    var dateDotFormatter: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.dateFormat = "yyyy.MM.dd (E)"
        return formatter.string(from: self)
    }
    
    var fullDateFormatter: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ko_kr")
        return formatter.string(from: self)
    }
    
    var simpleWeekDateFormatter: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "ko_kr")
        return formatter.string(from: self)
    }
    var returnAllWeeks: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_kr")
        var resultWeeks = [String]()
        guard let weeks = formatter.weekdaySymbols else { return [String]()}
        weeks.forEach { resultWeeks.append($0)}
        return resultWeeks
    }
}



