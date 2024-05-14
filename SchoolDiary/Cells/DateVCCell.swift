//
//  DateVCCell.swift
//  SchoolDiary
//
//  Created by Wolf on 15.06.2023.
//

import UIKit

class DateVCCell: UICollectionViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var linearView: UIView!
    @IBOutlet weak var weekDayLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 30
        let gradientView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 120))
                         let gradientLayer:CAGradientLayer = CAGradientLayer()
                        gradientView.layer.cornerRadius = 30
        
                         gradientLayer.frame.size = gradientView.frame.size
                        gradientLayer.cornerRadius = 30
                         gradientLayer.colors =
                         [UIColor(red: 0, green: 0.94, blue: 1, alpha: 1).cgColor,UIColor(red: 0.012, green: 0.69, blue: 0.738, alpha: 1).cgColor]
                        //Use diffrent colors
                         gradientView.layer.addSublayer(gradientLayer)
        
                        linearView.addSubview(gradientView)
                        linearView.layer.cornerRadius = 30
        linearView.isHidden = true
        // Initialization code
    }

    static func nib() -> UINib {
        return UINib(nibName: "DateVCCell", bundle: nil)
    }
}
