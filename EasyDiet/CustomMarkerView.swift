//
//  CustomMarker.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/08/31.
//

import UIKit


import UIKit
import Charts

class CustomMarkerView: MarkerView {
    
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    private func configureUI() {
        Bundle.main.loadNibNamed("CustomMarkerView", owner: self, options: nil)
        addSubview(contentView)
        self.frame = CGRect(x: 0, y: 0, width: 79, height: 40)
        self.offset = CGPoint(x: -(self.frame.width/2), y: -(self.frame.height + 20))
        contentView.frame = self.frame
        weightLabel.frame = contentView.frame
        contentView.backgroundColor = .white
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowRadius = 12
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.masksToBounds = false
        contentView.layer.shadowPath = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
}
