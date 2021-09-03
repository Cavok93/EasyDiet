//
//  CustomTextField.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/09/03.
//

import UIKit

class CustomTextField: UITextField {
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }
   
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
         return false
    }
}
