//
//  CardCell.swift
//  NBCampStart
//
//  Created by 서동환 on 3/4/25.
//

import UIKit

class CardCell: UICollectionViewCell {
    @IBOutlet weak var studyImageView: UIImageView!
    @IBOutlet weak var resolutionLabel: UILabel!
    @IBOutlet weak var objectiveLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
    }
    
    // MARK: - Configure
    func configure(cardData: CardData) {
        studyImageView.image = cardData.studyImage
        studyImageView.layer.cornerRadius = 10
        resolutionLabel.text = cardData.resolution
        objectiveLabel.text = cardData.objective
        let dateFormatter = DateFormatter.getDateFormatter()
        let convertDate = dateFormatter.string(from: cardData.date)
        dateLabel.text = convertDate
    }
}
