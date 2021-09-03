//
//  QuestionTableViewCell.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/09/03.
//

import UIKit

class QuestionTableViewCell: UITableViewCell {
    static let identifier = "QuestionTableViewCell"
    
    @IBOutlet weak var answerLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    func configureLabelSpacing(label: UILabel) {
        let attrString = NSMutableAttributedString(string: label.text ?? "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
        label.attributedText = attrString
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configureLabelSpacing(label: answerLabel)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
