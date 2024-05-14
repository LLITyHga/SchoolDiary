//
//  LessonCVCell.swift
//  SchoolDiary
//
//  Created by Wolf on 12.06.2023.
//

import UIKit

class LessonCVCell: UICollectionViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteBTNOutlet: UIButton!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var nameOfSubject: UILabel!
    @IBOutlet weak var linearView: UIView!
    @IBOutlet weak var linearView2: UIView!
    var btnTapAction : (()->())?
    var btnTapEdit : (()->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        linearView.backgroundColor = .white
        linearView.layer.cornerRadius = 15
        linearView2.layer.cornerRadius = 15
        let gradientView = UIView(frame: CGRect(x: 0, y: 0, width: 258, height: 58))
                         let gradientLayer:CAGradientLayer = CAGradientLayer()
                        gradientView.layer.cornerRadius = 15
        
                         gradientLayer.frame.size = gradientView.frame.size
                        gradientLayer.cornerRadius = 15
                         gradientLayer.colors =
                         [UIColor(red: 0, green: 0.94, blue: 1, alpha: 1).cgColor,UIColor(red: 0.012, green: 0.69, blue: 0.738, alpha: 1).cgColor]
                        //Use diffrent colors
                         gradientView.layer.addSublayer(gradientLayer)
        
                        linearView2.addSubview(gradientView)
                        linearView2.layer.cornerRadius = 15
        linearView2.isHidden = true
    }
    static func nib() -> UINib {
        return UINib(nibName: "LessonCVCell", bundle: nil)
    }
    @IBAction func deleteBTN(_ sender: UIButton) {
        btnTapAction?()
    }
    @IBAction func editBTN(_ sender: UIButton) {
        btnTapEdit?()
    }
}
