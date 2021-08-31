//
//  Extension+Int.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/08/31.
//

import Foundation

extension Int {
    var minute: TimeInterval {
        return TimeInterval(self * 60)
    }
    var hour: TimeInterval {
        return minute * 60
    }
    var day: TimeInterval {
        return hour * 24
    }
    var week: TimeInterval {
        return day * 7
    }
    var month: TimeInterval {
        return week * 4
    }
    var year: TimeInterval {
        return month * 12
    }
}

