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
    
    var formatter: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        formatter.locale = Locale(identifier: "ko_kr")
        return formatter.string(from: self)
    }
    
    var sectionFormatter: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ko_kr")
        return formatter.string(from: self)
    }
}



