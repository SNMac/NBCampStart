//
//  AlbumDataModalViewController.swift
//  NBCampStart
//
//  Created by 서동환 on 3/4/25.
//

import UIKit
import PhotosUI

class AlbumDataModalViewController: UIViewController {
    private var itemProviders: [NSItemProvider] = []
    var isEdit: Bool = false
    var albumData: AlbumData?
    var indexPathItem: Int?
    weak var delegate: AlbumDataDelegate?
    
    private var studyImage: UIImage? {
        didSet {
            studyImageView.image = studyImage
            if let _ = studyImage {
                setImageButton.setTitle("이미지 변경", for: .normal)
                deleteImageButton.isHidden = false
            } else {
                setImageButton.setTitle("이미지 선택", for: .normal)
                deleteImageButton.isHidden = true
            }
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
        let resolution = resolutionTextField.text ?? ""
        let objetive = objectiveTextField.text ?? ""
        albumData = AlbumData(studyImage: studyImage, resolution: resolution, objective: objetive)
        self.delegate?.addData(albumData: albumData!)
        self.dismiss(animated: true)
    }
    
    private var horStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var deleteImageButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "이미지 삭제"
        configuration.baseBackgroundColor = .systemRed
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private var setImageButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "이미지 선택"
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var studyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .placeholderText
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var resolutionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "오늘의 다짐"
        textField.font = .systemFont(ofSize: 22, weight: .semibold)
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .next
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var objectiveTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "오늘의 학습 목표"
        textField.font = .systemFont(ofSize: 17)
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private var deleteButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "카드 삭제"
        configuration.baseForegroundColor = .systemRed
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    @objc func keyboardUp(notification:NSNotification) {
        if let keyboardFrame:NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height)
                }
            )
        }
    }
    
    @objc func keyboardDown() {
        self.view.transform = .identity
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
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
        NotificationCenter.default.post(name: NSNotification.Name("DismissAlbumDataModalView"), object: nil, userInfo: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - UITextFieldDelegate
extension AlbumDataModalViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        itemProviders = results.map(\.itemProvider)
        
        if !itemProviders.isEmpty {
            setImage()
        }
    }
}

// MARK: - UITextFieldDelegate
extension AlbumDataModalViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.resolutionTextField {
            self.objectiveTextField.becomeFirstResponder()
        } else if textField == self.objectiveTextField {
            self.objectiveTextField.resignFirstResponder()
        }
        
        return true
    }
}

// MARK: - UI Methods
private extension AlbumDataModalViewController {
    func setupNavigation() {
        self.title = isEdit ? "편집" : "신규"
        self.navigationItem.leftBarButtonItem = self.cancelButton
        self.navigationItem.rightBarButtonItem = self.saveButton
    }
    
    func setupUI() {
        resolutionTextField.delegate = self
        objectiveTextField.delegate = self
        setButtonAction()
        setViewHierarchy()
        setConstraints()
    }
    
    func setButtonAction() {
        let action = UIAction { _ in
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1
            configuration.filter = .images
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self.present(picker, animated: true)
        }
        setImageButton.addAction(action, for: .touchUpInside)
        deleteImageButton.addAction(UIAction { _ in
            self.studyImage = nil
        }, for: .touchUpInside)
        deleteButton.addAction(UIAction { _ in
            if let index = self.indexPathItem {
                self.delegate?.deleteData(indexPathItem: index)
                self.dismiss(animated: true)
            }
        }, for: .touchUpInside)
    }
    
    func setViewHierarchy() {
        self.view.addSubview(studyImageView)
        self.view.addSubview(horStackView)
        horStackView.addArrangedSubview(deleteImageButton)
        horStackView.addArrangedSubview(setImageButton)
        self.view.addSubview(resolutionTextField)
        self.view.addSubview(objectiveTextField)
        if isEdit {
            self.view.addSubview(deleteButton)
        }
        self.view.addSubview(dateLabel)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            studyImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            studyImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            studyImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            studyImageView.heightAnchor.constraint(equalTo: studyImageView.widthAnchor, multiplier: 1)
        ])
        
        NSLayoutConstraint.activate([
            horStackView.centerXAnchor.constraint(equalTo: studyImageView.centerXAnchor),
            horStackView.bottomAnchor.constraint(equalTo: studyImageView.bottomAnchor, constant: -30),
        ])
        
        NSLayoutConstraint.activate([
            resolutionTextField.topAnchor.constraint(equalTo: studyImageView.bottomAnchor, constant: 20),
            resolutionTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            resolutionTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15)
        ])
        
        NSLayoutConstraint.activate([
            objectiveTextField.topAnchor.constraint(equalTo: resolutionTextField.bottomAnchor, constant: 10),
            objectiveTextField.leadingAnchor.constraint(equalTo: resolutionTextField.leadingAnchor),
            objectiveTextField.trailingAnchor.constraint(equalTo: resolutionTextField.trailingAnchor)
        ])
        
        if isEdit {
            NSLayoutConstraint.activate([
                deleteButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                deleteButton.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -10)
            ])
        }
        
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
}

// MARK: - Private Methods
private extension AlbumDataModalViewController {
    func getAlbumData() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.M.d"
        
        if let albumData = self.albumData {
            self.studyImage = albumData.studyImage
            self.resolutionTextField.text = albumData.resolution
            self.objectiveTextField.text = albumData.objective
            let convertDate = dateFormatter.string(from: albumData.date)
            self.dateLabel.text = convertDate
            return true
        } else {
            let convertDate = dateFormatter.string(from: Date.now)
            self.dateLabel.text = convertDate
            return false
        }
    }
    
    func setImage() {
        guard let itemProvider = itemProviders.first else { return }
        
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let self = self,
                      let image = image as? UIImage else { return }
                
                DispatchQueue.main.async {
                    self.studyImage = image
                }
            }
        }
    }
}
