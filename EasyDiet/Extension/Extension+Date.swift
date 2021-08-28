//
//  Extension+Date.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/08/27.
//

import Foundation




extension Date {
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
