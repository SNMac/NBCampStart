//
//  CardViewController.swift
//  NBCampStart
//
//  Created by 서동환 on 3/5/25.
//

import UIKit


// MARK: - Protocols
protocol EditDataDelegate: AnyObject {
    func editData(cardData: CardData, isImageDirty: Bool)
    func deleteData(uuid: UUID)
}

class CardViewController: UIViewController {
    weak var sendDataDelegate: SendDataDelegate?
    var cardData: CardData
    
    
    // MARK: - UI Components
    private lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(onEdit))
        return button
    }()
    
    @objc func onEdit() {
        let editCardModalVC = CardDataModalViewController(
            editDataDelegate: self,
            isEditModal: true,
            cardData: cardData
        )
        
        let modalNC = UINavigationController(rootViewController: editCardModalVC)
        self.present(modalNC, animated: true)
    }
    
    private var studyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .placeholderText
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var resolutionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var objectiveLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // MARK: - Initializer
    init(sendDataDelegate: SendDataDelegate, cardData: CardData) {
        self.sendDataDelegate = sendDataDelegate
        self.cardData = cardData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        setupNavigation()
        setupUI()
    }
}


// MARK: - UI Methods
private extension CardViewController {
    func setupNavigation() {
        self.title = "카드"
        self.navigationItem.rightBarButtonItem = self.editButton
    }
    
    func setupUI() {
        setViewHierarchy()
        setConstraints()
        setCardData()
    }
    
    func setViewHierarchy() {
        self.view.addSubview(studyImageView)
        self.view.addSubview(resolutionLabel)
        self.view.addSubview(objectiveLabel)
        self.view.addSubview(dateLabel)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            studyImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            studyImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            studyImageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            studyImageView.heightAnchor.constraint(equalTo: studyImageView.widthAnchor, multiplier: 0.75),
            
            resolutionLabel.topAnchor.constraint(equalTo: studyImageView.bottomAnchor, constant: 20),
            resolutionLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            resolutionLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            
            objectiveLabel.topAnchor.constraint(equalTo: resolutionLabel.bottomAnchor, constant: 10),
            objectiveLabel.leadingAnchor.constraint(equalTo: resolutionLabel.leadingAnchor),
            objectiveLabel.trailingAnchor.constraint(equalTo: resolutionLabel.trailingAnchor),
            
            dateLabel.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }
    
    func setCardData() {
        studyImageView.image = cardData.studyImage
        resolutionLabel.text = cardData.resolution
        objectiveLabel.text = cardData.objective
        let dateFormatter = DateFormatter.getDateFormatter()
        let convertDate = dateFormatter.string(from: cardData.date)
        dateLabel.text = convertDate
    }
}


// MARK: - EditDataDelegate
extension CardViewController: EditDataDelegate {
    func editData(cardData: CardData, isImageDirty: Bool) {
        self.cardData = cardData
        self.sendDataDelegate?.editData(cardData: cardData, isImageDirty: isImageDirty)
        self.setCardData()
    }
    
    func deleteData(uuid: UUID) {
        self.sendDataDelegate?.deleteData(uuid: cardData.uuid)
        self.navigationController?.popViewController(animated: true)
    }
}
