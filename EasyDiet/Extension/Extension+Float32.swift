//
//  Extension+Float32.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/08/28.
//

import Foundation


extension Float32 {
    var numberFormatter: String {
        let str = String(format: "%.2f", self)
        return str
    }
    
    var decimalFormatter: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.positivePrefix = "+"
        return numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}

