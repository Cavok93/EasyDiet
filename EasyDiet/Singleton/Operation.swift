//
//  OperationType.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/08/28.
//

import Foundation



class Operation {
    static let shared = Operation()
    private init() {}
    var isSave: Bool?
    var weight: Float32?
    var height: Float32?
    var memo: String? 
}



