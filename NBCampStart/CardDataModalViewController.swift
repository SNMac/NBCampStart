//
//  CardDataModalViewController.swift
//  NBCampStart
//
//  Created by 서동환 on 3/4/25.
//

import UIKit
import PhotosUI

class CardDataModalViewController: UIViewController {
    
    weak var addDataDelegate: AddDataDelegate?
    weak var editDataDelegate: EditDataDelegate?
    
    private var itemProviders: [NSItemProvider] = []
    private var isEditModal: Bool
    private var cardData: CardData
    private var isImageDirty = false
    
    private var studyImage: UIImage? {
        didSet {
            if let _ = studyImage {
                deleteImageButton.isHidden = false
            } else {
                deleteImageButton.isHidden = true
            }
            studyImageView.image = studyImage
        }
    }
    
    // MARK: - UI Components
    
    private lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancel))
        return button
    }()
    
    @objc func onCancel() {
        self.dismiss(animated: true)
    }
    
    private lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(onSave))
        return button
    }()
    
    @objc func onSave() {
        cardData.studyImage = studyImage
        var resolution = ""
        if resolutionTextView.textColor != .placeholderText {
            resolution = resolutionTextView.text
        }
        cardData.resolution = resolution
        var objective = ""
        if objectiveTextView.textColor != .placeholderText {
            objective = objectiveTextView.text
        }
        cardData.objective = objective
        
        if isEditModal {
            self.editDataDelegate?.editData(cardData: cardData, isImageDirty: isImageDirty)
        } else {
            self.addDataDelegate?.addData(cardData: cardData)
        }
        self.dismiss(animated: true)
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
    
    private var deleteImageButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "xmark.circle.fill")
        configuration.buttonSize = .mini
        configuration.cornerStyle = .capsule
        configuration.baseForegroundColor = .systemRed
        configuration.baseBackgroundColor = .clear
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private var setImageButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "이미지 선택"
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let resoutionPlaceHolder = "오늘의 다짐"
    private lazy var resolutionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 17)
        textView.text = resoutionPlaceHolder
        textView.textColor = .placeholderText
        textView.backgroundColor = .systemGray5
        textView.layer.cornerRadius = 10
        textView.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.returnKeyType = .done
        textView.isScrollEnabled = false
        textView.delegate = self
        return textView
    }()
    
    private let resolutionMaxLength = 15
    private lazy var resolutionTextCountLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 15, weight: .regular)
        label.text = "0/\(resolutionMaxLength)"
        label.textColor = .placeholderText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
        
    private let objectivePlaceHolder = "오늘의 학습 목표"
    private lazy var objectiveTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 17)
        textView.text = objectivePlaceHolder
        textView.textColor = .placeholderText
        textView.backgroundColor = .systemGray5
        textView.layer.cornerRadius = 10
        textView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.returnKeyType = .default
        textView.delegate = self
        return textView
    }()
    
    private let objectiveMaxLength = 100
    private lazy var objectiveTextCountLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 15, weight: .regular)
        label.text = "0/\(objectiveMaxLength)"
        label.textColor = .placeholderText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private var deleteCardButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "카드 삭제"
        configuration.baseForegroundColor = .systemRed
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializer
    
    init(
        addDataDelegate: AddDataDelegate? = nil,
        editDataDelegate: EditDataDelegate? = nil,
        isEditModal: Bool,
        cardData: CardData? = nil
    ) {
        self.addDataDelegate = addDataDelegate
        self.editDataDelegate = editDataDelegate
        self.isEditModal = isEditModal
        if isEditModal {
            self.cardData = cardData!
        } else {
            self.cardData = CardData(uuid: UUID(), date: .now)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        resolutionTextView.alignTextVerticallyInContainer()
        deleteCardButton.isHidden = isEditModal ? false : true
        
        setupNavigation()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
}

// MARK: - UI Methods

private extension CardDataModalViewController {
    func setupNavigation() {
        self.title = isEditModal ? "편집" : "신규"
        self.navigationController?.navigationBar.backgroundColor = .systemBackground
        self.navigationItem.leftBarButtonItem = self.cancelButton
        self.navigationItem.rightBarButtonItem = self.saveButton
    }
    
    func setupUI() {
        setButtonAction()
        setViewHierarchy()
        setConstraints()
        setCardData()
    }
    
    func setButtonAction() {
        let setImageAction = UIAction { _ in
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1
            configuration.filter = .images
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self.present(picker, animated: true)
        }
        
        let deleteAlertAction = UIAction { _ in
            let alert = UIAlertController(title: nil, message: "이 카드를 삭제하겠습니까?", preferredStyle: .actionSheet)
            let delete = UIAlertAction(title: "카드 삭제", style: .destructive) { _ in
                self.editDataDelegate?.deleteData(uuid: self.cardData.uuid)
                self.dismiss(animated: true)
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            alert.addAction(delete)
            alert.addAction(cancel)
            self.present(alert, animated: true)
        }
        
        setImageButton.addAction(setImageAction, for: .touchUpInside)
        
        deleteImageButton.addAction(UIAction { _ in
            if self.studyImage != nil {
                self.isImageDirty = true
            }
            self.studyImage = nil
        }, for: .touchUpInside)
        
        deleteCardButton.addAction(deleteAlertAction, for: .touchUpInside)
    }
    
    func setViewHierarchy() {
        self.view.addSubview(studyImageView)
        self.view.addSubview(deleteImageButton)
        self.view.addSubview(setImageButton)
        self.view.addSubview(resolutionTextView)
        self.view.addSubview(resolutionTextCountLabel)
        self.view.addSubview(objectiveTextView)
        self.view.addSubview(objectiveTextCountLabel)
        self.view.addSubview(dateLabel)
        self.view.addSubview(deleteCardButton)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            studyImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            studyImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            studyImageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            studyImageView.heightAnchor.constraint(equalTo: studyImageView.widthAnchor, multiplier: 0.75),
            
            deleteImageButton.topAnchor.constraint(equalTo: studyImageView.topAnchor, constant: 15),
            deleteImageButton.trailingAnchor.constraint(equalTo: studyImageView.trailingAnchor, constant: -15),
            
            setImageButton.centerXAnchor.constraint(equalTo: studyImageView.centerXAnchor),
            setImageButton.topAnchor.constraint(equalTo: studyImageView.bottomAnchor, constant: 10),
            
            resolutionTextView.topAnchor.constraint(equalTo: setImageButton.bottomAnchor, constant: 10),
            resolutionTextView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            resolutionTextView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            resolutionTextView.heightAnchor.constraint(equalToConstant: 40),
            
            resolutionTextCountLabel.centerYAnchor.constraint(equalTo: resolutionTextView.centerYAnchor),
            resolutionTextCountLabel.trailingAnchor.constraint(equalTo: resolutionTextView.trailingAnchor, constant: -10),
            
            objectiveTextView.topAnchor.constraint(equalTo: resolutionTextView.bottomAnchor, constant: 15),
            objectiveTextView.leadingAnchor.constraint(equalTo: resolutionTextView.leadingAnchor),
            objectiveTextView.trailingAnchor.constraint(equalTo: resolutionTextView.trailingAnchor),
            objectiveTextView.heightAnchor.constraint(equalToConstant: 130),
            
            objectiveTextCountLabel.bottomAnchor.constraint(equalTo: objectiveTextView.bottomAnchor, constant: -10),
            objectiveTextCountLabel.trailingAnchor.constraint(equalTo: objectiveTextView.trailingAnchor, constant: -10),
            
            dateLabel.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            dateLabel.topAnchor.constraint(equalTo: objectiveTextView.bottomAnchor, constant: 20),
            
            deleteCardButton.topAnchor.constraint(greaterThanOrEqualTo: dateLabel.bottomAnchor, constant: 10),
            deleteCardButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            deleteCardButton.bottomAnchor.constraint(lessThanOrEqualTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    func setCardData() {
        studyImage = cardData.studyImage
        
        if let resolution = cardData.resolution {
            if resolution.isEmpty {
                resolutionTextView.text = resoutionPlaceHolder
                resolutionTextView.textColor = .placeholderText
                resolutionTextCountLabel.text = "0/\(resolutionMaxLength)"
            } else {
                resolutionTextView.text = resolution
                resolutionTextView.textColor = .label
                resolutionTextCountLabel.text = "\(resolutionTextView.text.count)/\(resolutionMaxLength)"
            }
        }
        
        if let objective = cardData.objective {
            if objective.isEmpty {
                objectiveTextView.text = objectivePlaceHolder
                objectiveTextView.textColor = .placeholderText
                objectiveTextCountLabel.text = "0/\(objectiveMaxLength)"
            } else {
                objectiveTextView.text = objective
                objectiveTextView.textColor = .label
                objectiveTextCountLabel.text = "\(objectiveTextView.text.count)/\(objectiveMaxLength)"
            }
        }
        let dateFormatter = DateFormatter.getDateFormatter()
        let convertDate = dateFormatter.string(from: cardData.date)
        dateLabel.text = convertDate
    }
}

// MARK: - Private Methods

private extension CardDataModalViewController {
    func setImage() {
        guard let itemProvider = itemProviders.first else { return }
        
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let self = self,
                      let image = image as? UIImage else { return }
                
                DispatchQueue.main.async {
                    if self.studyImage != image {
                        self.isImageDirty = true
                    }
                    self.studyImage = image
                }
            }
        }
    }
    
    @objc func keyboardUp(notification:NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            self.view.transform = CGAffineTransform(translationX: 0, y: -(keyboardRectangle.height - self.view.safeAreaInsets.bottom))
        }
    }
    
    @objc func keyboardDown() {
        self.view.transform = .identity
    }
}

// MARK: - UITextViewDelegate

extension CardDataModalViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        if textView == resolutionTextView {
            if text == "\n" {
                textView.resignFirstResponder()
                return false
            }
            return changedText.count <= resolutionMaxLength
        } else if textView == objectiveTextView {
            return changedText.count <= objectiveMaxLength
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = .label
        }
        
        if textView == resolutionTextView {
            resolutionTextCountLabel.isHidden = false
        } else if textView == objectiveTextView {
            objectiveTextCountLabel.isHidden = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == resolutionTextView {
            resolutionTextCountLabel.isHidden = true
            if textView.text.isEmpty {
                textView.text = resoutionPlaceHolder
                textView.textColor = .placeholderText
            }
        } else if textView == objectiveTextView {
            objectiveTextCountLabel.isHidden = true
            if textView.text.isEmpty {
                textView.text = objectivePlaceHolder
                textView.textColor = .placeholderText
            }
        }
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == resolutionTextView {
            resolutionTextCountLabel.text = "\(textView.text.count)/\(resolutionMaxLength)"
        } else if textView == objectiveTextView {
            objectiveTextCountLabel.text = "\(textView.text.count)/\(objectiveMaxLength)"
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension CardDataModalViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        itemProviders = results.map(\.itemProvider)
        
        if !itemProviders.isEmpty {
            setImage()
        }
    }
}
