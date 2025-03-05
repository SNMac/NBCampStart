//
//  NBCampStartViewController.swift
//  NBCampStart
//
//  Created by 서동환 on 3/4/25.
//

import UIKit

protocol AddDataDelegate: AnyObject {
    func addData(cardData: CardData)
}

protocol SendDataDelegate: AnyObject {
    func editData(cardData: CardData, indexPathItem: Int)
    func deleteData(indexPathItem: Int)
}

class NBCampStartViewController: UIViewController {
    let sectionInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
    var cardDataArr: [CardData] = []
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    
    
    // MARK: - IBActions
    @IBAction func addCardData(_ sender: Any) {
        let addCardModalVC = CardDataModalViewController(
            addDataDelegate: self,
            isEdit: false
        )
        addCardModalVC.modalPresentationStyle = .fullScreen
        let modalNC = UINavigationController(rootViewController: addCardModalVC)
        self.present(modalNC, animated: true)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "내일배움캠프를 시작하며"
        
        setupUI()
    }
}


// MARK: - UI Methods
private extension NBCampStartViewController {
    func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.layer.cornerRadius = 10
        collectionView.backgroundColor = .clear
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = .zero
        }
    }
}


// MARK: - Private Methods
private extension NBCampStartViewController {
    @objc func didDismissDetailNotification(_ notification: Notification) {
          DispatchQueue.main.async {
              self.collectionView.reloadData()
          }
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension NBCampStartViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        let itemsPerRow: CGFloat = 1
        let widthPadding = sectionInsets.left * (itemsPerRow + 1)
        let itemsPerColumn: CGFloat = 1
        let heightPadding = sectionInsets.top * (itemsPerColumn + 1)
        let cellWidth = (width - widthPadding) / itemsPerRow
        let cellHeight = (height - heightPadding) / itemsPerColumn
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
}


// MARK: - UICollectionViewDelegate
extension NBCampStartViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item != cardDataArr.count {
            let cardVC = CardViewController(
                sendDataDelegate: self,
                cardData: cardDataArr[indexPath.item],
                indexPathItem: indexPath.item
            )
            self.navigationController?.pushViewController(cardVC, animated: true)
        }
    }
}


// MARK: - UICollectionViewDataSource
extension NBCampStartViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if cardDataArr.count == 0 {
            return 1
        } else {
            return cardDataArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as? CardCell else {
            return UICollectionViewCell()
        }
        
        if cardDataArr.count == 0 {
            let addPromptData = CardData(
                resolution: "오늘의 다짐을 생각해보세요",
                objective: "오늘의 학습 목표를 세워보세요",
                date: .now
            )
            cell.configure(cardData: addPromptData)
            cell.backgroundColor = .systemBackground.withAlphaComponent(0.85)
        } else {
            cell.configure(cardData: cardDataArr[indexPath.item])
            cell.backgroundColor = .systemBackground
        }
        
        return cell
    }
}


// MARK: - AddDataDelegate
extension NBCampStartViewController: AddDataDelegate {
    func addData(cardData: CardData) {
        self.cardDataArr.insert(cardData, at: 0)
        self.collectionView.reloadData()
    }
}


// MARK: - SendDataDelegate
extension NBCampStartViewController: SendDataDelegate {
    func editData(cardData: CardData, indexPathItem: Int) {
        self.cardDataArr[indexPathItem] = cardData
        self.collectionView.reloadData()
    }
    
    func deleteData(indexPathItem: Int) {
        self.cardDataArr.remove(at: indexPathItem)
        self.collectionView.reloadData()
    }
}
