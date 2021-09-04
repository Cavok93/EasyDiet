//
//  CustomTextField.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/09/04.
//

import UIKit

class CustomField: UITextField {
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:))
            || action == #selector(UIResponderStandardEditActions.cut(_:))
            || action ==  #selector(UIResponderStandardEditActions.copy(_:))
            || action ==  #selector(UIResponderStandardEditActions.select(_:))
            || action == #selector(UIResponderStandardEditActions.selectAll(_:))
            || action == #selector(UIResponderStandardEditActions.delete(_:))
            || action == #selector(UIResponderStandardEditActions.makeTextWritingDirectionLeftToRight(_:))
            || action == #selector(UIResponderStandardEditActions.makeTextWritingDirectionRightToLeft(_:))
            || action == #selector(UIResponderStandardEditActions.toggleBoldface(_:))
            || action == #selector(UIResponderStandardEditActions.toggleItalics(_:))
            || action == #selector(UIResponderStandardEditActions.toggleUnderline(_:))
            || action == #selector(UIResponderStandardEditActions.increaseSize(_:))
            || action == #selector(UIResponderStandardEditActions.decreaseSize(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
