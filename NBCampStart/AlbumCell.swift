//
//  AlbumCell.swift
//  NBCampStart
//
//  Created by 서동환 on 3/4/25.
//

import UIKit

class AlbumCell: UICollectionViewCell {
    // MARK: - UI Components
    private var studyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private var resolutionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var objectiveLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializer
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
        setupUI()
    }
    
    // MARK: - Configure
    func configure(albumData: AlbumData) {
        studyImageView.image = albumData.studyImage
        resolutionLabel.text = albumData.resolution
        objectiveLabel.text = albumData.objective
    }
}

// MARK: - UI Methods
private extension AlbumCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubview(studyImageView)
        self.addSubview(resolutionLabel)
        self.addSubview(objectiveLabel)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            studyImageView.topAnchor.constraint(equalTo: self.topAnchor),
            studyImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            studyImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            studyImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -200)
        ])
        
        NSLayoutConstraint.activate([
            resolutionLabel.topAnchor.constraint(equalTo: studyImageView.bottomAnchor, constant: 20),
            resolutionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            resolutionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15)
        ])
        
        NSLayoutConstraint.activate([
            objectiveLabel.topAnchor.constraint(equalTo: resolutionLabel.bottomAnchor, constant: 10),
            objectiveLabel.leadingAnchor.constraint(equalTo: resolutionLabel.leadingAnchor),
            objectiveLabel.trailingAnchor.constraint(equalTo: resolutionLabel.trailingAnchor)
        ])
    }
}


